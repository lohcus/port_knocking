#!/bin/bash
#Criado por Daniel Domingues
#https://github.com/lohcus

#FUNCAO PARA TESTAR SE OS IPS SAO VALIDOS
testa () {
re='^(0*(1?[0-9]{1,2}|2([0-4][0-9]|5[0-5]))\.){3}'
re+='0*(1?[0-9]{1,2}|2([‌​0-4][0-9]|5[0-5]))$'
if [[ ! $1 =~ $re ]] || [[ ! $2 =~ $re ]]
then
  return 0
else
  return 1
fi
}

#FUNCAO PARA IMPRIMIR AS DIVISORIAS
divisao () {
	#RECALCULA A LARGURA E ALTURA DA JANELA
	colunas=$(tput cols) #VERIFICA O TAMANHO DA JANELA PARA PODER DESENHAR O LAYOUT DO SCRIPT
	#LACO PARA PREENCHER UMA LINHA COM "="
	for i in $(seq 0 1 $(($colunas-1)))
	do
		printf "\033[37;1m=\033[m"
	done
	echo
}

#FUNCAO DE TENTATIVA DE ATIVACAO DO MALWARE
sequencia () {
	for port in {13,37,30000,3000,1337};
        do
		hping3 -S -p $port -c 1 $rede.$i &> /dev/null
	done

	if hping3 -S -p 1337 -c 1 $rede.$i 2> /dev/null | grep flags=SA > /dev/null
	then
		echo $i >> hosts.txt
	fi
	printf "\033[32;1m.\033[m"

}

#==================================INICIO DO SCRIPT PRINCIPAL=====================================
clear

divisao #CHAMA A FUNCAO PARA DESENHAR UMA DIVISORIA
centro_coluna=$(( $(( $(( $colunas-14))/2 )))) #CALCULO PARA CENTRALIZAR O TEXTO
tput cup 1 $centro_coluna #POSICIONAR O CURSOR
printf "\033[34;1mSCRIPT PORT-KNOCKING\n\033[m"
divisao

rm lista_hosts.txt &> /dev/null
rm hosts.txt &> /dev/null

if [ -z $2 ] #TESTA SE NAO FORAM DIGITADOS DOI PARAMETROS
then
	printf "\033[31;1m[-] \033[37;1mSINTAXE DE USO: \033[33;1m$0 \033[32m<IP INICIAL> <IP FINAL>\n\n\033[m"
else
	testa $1 $2	
	if [[ $(echo $?) == 0 ]] 
	then
		printf "\033[31;1m[-] \033[37;1mENDEREÇO DIGITADO INVÁLIDO!\n\n\033[m"
		exit 1
	fi
	
	inicio=$(echo $1 | cut -d "." -f 4)
	final=$(echo $2 | cut -d "." -f 4)
	rede=$(echo $1 | cut -d "." -f 1-3)
	rede2=$(echo $2 | cut -d "." -f 1-3)
	if [ $rede != $rede2 ] #TESTE PARA VERIFICAR SE O INTERVALO DIGITADO ESTA DENTRO DE UMA REDE /24
	then
		printf "\033[31;1m[-] \033[37;1mSCRIPT DE PORT-KNOCKING PARA UMA REDE DE TAMANHO MAXIMO DE \033[31;1m256 \033[37;1mIPs\n\n\033[m"
		printf "\033[31;1m[-] \033[37;1mSINTAXE DE USO: \033[33;1m$0 \033[32m<IP INICIAL> <IP FINAL>\n\n\033[m"
		printf "\033[31;1m[-] \033[37;1mDIGITE O IP INICIAL E FINAL DENTRO DE UMA MESMA REDE /24\n\n\033[m"
	else
		printf "\033[37;1m[+] REALIZANDO TESTE NOS HOSTS \033[34;1m$1 \033[37m- \033[34m$2\033[37;1m!!!\n\n\033[m"
		printf "\033[37;1m[+] KNOCK 13!\n\033[m"
		printf "\033[37;1m[+] KNOCK 37!\n\033[m"
		printf "\033[37;1m[+] KNOCK 30000!\n\033[m"
		printf "\033[37;1m[+] KNOCK 3000!\n\033[m"
		printf "\033[37;1m[+] KNOCK 1337!\n\n\033[m"
		printf "\033[32;1m[+] AGUARDE\033[m"
		cont=0
		for i in $(seq $inicio 1 $final)
		do
			#EXECUTA A FUNCAO SEQUENCIA PARA CADA IP E JOGA PARA BACKGROUND, LIBERANDO PARA O PROXIMO IP
			sequencia &
			#let cont=$cont+1
			cont=$(($cont+1))
		done
		wait
		echo
		divisao
		#TESTA SE FOI CRIADO O ARQUIVO hosts.txt (EH CRIADO APENAS SE ENCONTRAR ALGUM IP COMPROMETIDO PELO MALWARE)
		if [ -f hosts.txt ]
		then
			encontrados=$(cat hosts.txt | wc -l)
			printf "\033[32;1m[+]\033[37;1m VERIFICADO \033[34;1m$cont \033[37;1mHOSTS! MALWARE ENCONTRADO EM \033[34;1m$encontrados \033[37;1mHOSTS!!!\n\033[m"
			divisao
			#LACO PARA EXTRAIR O index.html DO IP COMPROMETIDO
			for i in $(cat hosts.txt)
			do
				printf "\033[32;1m[+] EXTRAINDO PAGINA DO IP \033[33m$rede.$i...\n\n\033[m"
				#OPCAO 1
				#wget $rede.$i:1337 &> /dev/null
				#cat index.html
				#rm index.html
					#OPCAO 2
				printf "GET / HTTP/1.0\r\n\r\n" | nc $rede.$i 1337
				divisao
			done
		else
			printf "\033[31;1m[-]\033[37;1m VERIFICADO \033[34;1m$cont \033[37;1mHOSTS! NENHUM HOST COMPROMETIDO!\n\033[m"
			divisao
		fi
	fi
fi
