#!/bin/bash
#Criado por Daniel Domingues
#https://github.com/lohcus

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
	hping3 -S -p 13 -c 1 $rede.$i &> /dev/null
	hping3 -S -p 37 -c 1 $rede.$i &> /dev/null
	hping3 -S -p 30000 -c 1 $rede.$i &> /dev/null
	hping3 -S -p 3000 -c 1 $rede.$i &> /dev/null
	if hping3 -S -p 1337 -c 1 $rede.$i 2> /dev/null | grep flags=SA > /dev/null
	then
		echo $i >> hosts.txt
		#else
		#printf "\033[31;1mERRO!!! $rede.$i!\n\033[m"
	fi
}

#==================================INICIO DO SCRIPT PRINCIPAL=====================================
clear

divisao #CHAMA A FUNCAO PARA DESENHAR UMA DIVISORIA
centro_coluna=$(( $(( $(( $colunas-14))/2 )))) #CALCULO PARA CENTRALIZAR O TEXTO
tput cup 1 $centro_coluna #POSICIONAR O CURSOR
printf "\033[34;1mSCRIPT PORT-KNOCKING\n\033[m"
divisao

rm hosts.txt &> /dev/null

if [ -z $2 ] #TESTA SE NAO FORAM DIGITADOS DOI PARAMETROS
then
	printf "\033[31;1m[-] \033[37;1mSINTAXE DE USO: \033[33;1m$0 \033[32m<IP INICIAL> <IP FINAL>\n\n\033[m"
else
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
		cont=0
		for i in $(seq $inicio 1 $final)
		do
			#EXECUTA A FUNCAO SEQUENCIA PARA CADA IP E JOGA PARA BACKGROUND, LIBERANDO PARA O PROXIMO IP
			sequencia
			let cont=$cont+1
		done 2> /dev/null
		divisao
		#TESTA SE FOI CRIADO O ARQUIVO hosts.txt (EH CRIADO APENAS SE ENCONTRAR ALGUM IP COMPROMETIDO PELO MALWARE)
		if [ -a hosts.txt ]
		then
			encontrados=$(cat hosts.txt | wc -l)
			printf "\033[37;1m[+] VERIFICADO \033[34;1m$cont \033[37;1mHOSTS! MALWARE ENCONTRADO EM \033[34;1m$encontrados \033[37;1mHOSTS!!!\n\033[m"
			divisao
			#LACO PARA EXTRAIR O index.html DO IP COMPROMETIDO
			for i in $(cat hosts.txt)
			do
				printf "\033[32;1m[+] EXTRAINDO PAGINA DO IP \033[33m$rede.$i...\n\n\033[m"
				wget $rede.$i:1337 &> /dev/null
				cat index.html
				rm index.html
				divisao
			done
		else
			printf "\033[37;1m[-] VERIFICADO \033[34;1m$cont \033[37;1mHOSTS! NENHUM HOST COMPROMETIDO!\n\033[m"
			divisao
		fi
	fi
fi
