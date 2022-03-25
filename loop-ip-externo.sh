#!/usr/bin/env bash
#
# Script fecha looping e fica buscando IPv4 público e manda para telegram
# via telegram-notify, caso tenha configurado.
# Para internet com IP diâmico.
# Forma de uso: ./loop-ip-externo.sh &
# Assim roda em background
# Uma boa opção é por para rodar no boot

LOG="/tmp/loop-ip.log"
# Checar dependencias.
readonly dependencias=(curl telegram-notify wget)
checarDependencias() {
	local erro=0
	for comando in "${dependencias[@]}"; do
		if ! which "$comando" 2>1 > /dev/null ; then
			echo -e "\nComando $comando não encontrado" >&2
			local erro=1
		fi
	done
	if [[ "$erro" != "0" ]]; then
		echo -e "\nErro. Verifique se os comandos listados estão instalados ou em $PATH\n" >&2
		exit 1
	fi
}

checarDependencias # Chamada da função

servidor="https://marantech.com.br/getip.php"
armazenaIP=""
while : ; do
	if wget -q --spider "$servidor" 2> /dev/null; then
		buscaIP4=$(curl -s -4 "$servidor" | head -n1)
		buscaIP6=$(curl -s -6 "$servidor" | head -n1)
	else
		echo "Sem internet"
	fi
	if [[ "$armazenaIP" != "$buscaIP4" ]]; then
		armazenaIP="$buscaIP4"
		echo "Seu IP Público mudou, agora é: $armazenaIP" > $LOG
		if [[ -z "$buscaIP6" ]]; then
			echo "Sem IPv6" >> $LOG
		else
			echo "Seu IPv6 é: $buscaIP6" >> $LOG
		fi
		cat "$LOG" | telegram-notify --text -
	fi
	sleep 5s
done

