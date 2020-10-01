#!/usr/bin/env bash
#
# Script fecha looping e fica buscando IPv4 público e manda para telegram
# via telegram-notify, caso tenha configurado.
# Forma de uso: ./loop-ip-externo.sh &
# Assim roda em background
# Uma boa opção é por para rodar no boot
#
######## VARIAVEIS ######################
					#
servidor1="ifconfig.co"			#
servidor2="icanhazip.com"		#
servidor3="ifconfig.me"			#
					#
#########################################

buscaIP=$(curl -s ifconfig.me)
armazenaIP=""

#if wget -q --spider www.google.com; then
#	echo -e "\nEstá com internet!"
#	echo -e "Seu IP público é: $armazenaIP\n"
#	exit 0
#else
#	echo -e "\nPrecisa estar conectado à internet.\n"
#	exit 1
#fi

while [[ "1" -gt "0" ]]; do
	if wget -q --spider "$servidor1"; then
		buscaIP4=$(curl -s -4 "$servidor1")
		buscaIP6=$(curl -s -6 "$servidor1")
	elif wget -q --spider "$servidor2"; then
		sleep 2s
		buscaIP4=$(curl -s -4 "$servidor2")
		buscaIP6=$(curl -s -6 "$servidor2")
	else
		buscaIP4=$(curl -s -4 "$servidor3")
		buscaIP6=$(curl -s -6 "$servidor3")
	fi
	if [[ "$armazenaIP" != "$buscaIP4" ]]; then
		armazenaIP="$buscaIP4"
		echo "
		Seu IP Público mudou, agora é: $armazenaIP
		Seu IPv6 é: $buscaIP6" | ./telegram-notify --text -
	fi
	sleep 5s
done

