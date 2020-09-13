#!/usr/bin/env bash
#
# Script para facilitar acesso à diretórios remotos na rede
#
# Versão 0.1
# Setembro 06, 2020
#
# Criado por Marangão
# marangao@vmcloud.ga
#
# Licença GPL
#
#
# Script para auxiliar/facilitar a montagem de diretório/pasta
# remoto em seu sistema.
# Exemplo de uso:
#
# Execute esse script e o mesmo irá solicitar o server onde você
# pode entrar como IP/diretorio ou hostname/diretorio
# 
# $ 192.168.1.10/musica
# 
# O programa também solicitará nome de usuário e senha, também como ponto de montagem
# Caso seu ponto de montagem não exista será questionado se quer criá-lo.
# Se o o ponto de montagem já existir, com autopreenchimento fica
# "/mnt/musicas/", mas para um melhor funcionamento usar "/mnt/musica"
#

######### Teste se é ROOT ###########
if [[ $(id -u) -ne 0 ]]; then
	echo -e "\nSOMENTE ROOT\n"
	exit 1
fi
#####################################

read -p "Entre com o diretorio remoto: " remoteDir # Não precisa usar "//" no início
read -p "Informe o usuário: " remoteUser
echo "Informe a senha: "
read -s remotePass
echo "Entre com o ponto de montagem: " # Diretório onde quer montar
read -e mountDir

######### VARIÁVEIS PARA USAR EM TESTES #########
mountedDir=$(df -h | grep "$mountDir" | cut -d '%' -f2 | cut -d ' ' -f2)
mounted=$(df -h | grep "$mountDir")

#test "$mountDir" = "$mountedDir" \
#	&& { echo -e "\nJá está montado\n$mounted\n" ; exit 0 ;}

######### TESTE SE DIRETÓRIO JÁ ESTÁ MONTADO #########
if [[ "$mountDir" = "$mountedDir" ]]; then
	echo -e "\nJá está montado\n"$mounted"\n"
	exit 0
fi

######### TESTE SE PONTO DE MONTAGEM EXISTE OU NÃO #########
if [ -e "$mountDir" ]; then
	echo -e "\nMontando diretório remoto"
	mount -t cifs -o username="$remoteUser",password="$remotePass" //"$remoteDir" "$mountDir"
	echo -e "Montado com sucesso: $(df -h | grep "$mountDir") \n"
	exit 0
else
	read -p "Diretório não existe. Deseja criar? [S/N]: " confirm
	case "$confirm" in
	# CONFERENCIA DE RESPOSTA DO USUÁRIO #
	s|S|"")
		mkdir "$mountDir"
	;;
	n|N|"")
		echo -e "\nOk, encerrando!\n"
		exit 1
	;;
	*)
		echo -e "\nOpção inválida\n"
		exit 2
	;;
	esac
fi

echo -e "\nMontando diretório remoto..."
mount -t cifs -o username="$remoteUser",password="$remotePass" //"$remoteDir" "$mountDir"
echo -e "Montado com sucesso: $(df -h | grep "$mountDir") \n"

