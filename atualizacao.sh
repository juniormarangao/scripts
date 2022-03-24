#!/usr/bin/env bash
#
# Executa os comandos de atualizacao do sistema e envia arquvi de LOG para o Telegram
#
#Versão 0.2: Adicionando suporte à opção de help (-h)
#Versao 0.3: Adicionado informçao de temperatura, execuçao se somente root e alteraçoes de log, 4 Setembro 2020
#
#
#Criado por Marangão, Maio de 2019
#

MENSAGEM_USO="

-h	Help, tela de ajuda
"

# Tratamento das opções de linha de comando

if test "$1" = "-h"
then
	echo "$MENSAGEM_USO"
	exit 0
fi

######### TESTE SE É ROOT #########
if [[ $(id -u) -ne 0 ]]
then
	echo -e "\nSomente ROOT\n"
	exit 1
fi

######### TESTANDO SE ESTÁ COM INTERNET #########
if ! wget -q --spider www.google.com; then
	echo -e "\nPrecisa estar conectado à internet.\n"
	exit 1
fi

# Processamento

cd $HOME

LOG="log-$HOSTNAME.txt"
dia=$(date)

echo "$dia Atualizacao diaria iniciada

" > $LOG

apt-get update >> $LOG

echo "

UPGRADE

" >> $LOG

apt-get upgrade -y >> $LOG

echo "

Dist Upgrade

" >> $LOG

apt-get dist-upgrade -y >> $LOG

echo "

Limpeza com Autoclean e Clean

" >> $LOG

apt-get autoclean >> $LOG
apt-get clean

# PEGA TEMPERATURA DOS CORES DO PROCESSADOR
# Neste caso abaixo está pegando apenas de um processador
# com 2 cores, caso seu PC tenha mais, adicione mais linhas
# como as seguintes
tempCore1=$(sensors | grep Core | awk -F: '{print $2}' | cut -d '+' -f2 | cut -d ' ' -f1 | sed -n '1p')
tempCore2=$(sensors | grep Core | awk -F: '{print $2}' | cut -d '+' -f2 | cut -d ' ' -f1 | sed -n '2p')
#############################################################

echo "
A temperatura do Core 1 é $tempCore1 e do Core 2 $tempCore2

Atualização provavelmente concluída, pronto para envio de log para Telegram" >> $LOG

./telegram-notify --document $LOG
