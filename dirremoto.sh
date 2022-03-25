#!/usr/bin/env bash
#
# Script para facilitar acesso à diretórios remotos na rede
#
# Versão 0.1
# Versão 0.2 - 	Adicionando teste para verificar se ponto de montagem
#				contém "/" ao final e removendo caso tenha.
#				Adicionado opção de inserir número de porta.
#				Setembro 15, 2020
#
# Criado por Marangão - Setembro 06, 2020
# marangao@vmcloud.ga
#
# Licença GPL
#
#
# Script para auxiliar/facilitar a montagem de diretório/pasta remoto em seu sistema.
# Exemplo de uso:
#
# Execute esse script e o mesmo irá solicitar o server onde você pode entrar como IP/diretorio ou hostname/diretorio
# 192.168.1.10/musica
# 
# O programa também solicitará nome de usuário e senha, também como ponto de montagem
# Caso seu ponto de montagem não exista será questionado se quer criá-lo.

### Testando se é ROOT ###
if [[ $(id -u) -ne 0 ]]; then
	echo -e "\nSOMENTE ROOT\n"
	exit 1
fi

read -p "Entre com o diretorio remoto: " remoteDir # Não precisa usar "//" no início
read -p "Informe o usuário: " remoteUser
echo "Informe a senha: "
read -s remotePass
echo "Entre com o ponto de montagem: " # Diretório onde quer montar
read -e mountDir
read -p "Informe a porta, se houver: " port

[[ "$port" ]] || port="445" # Se não inserir porta, define como padrão 445

# Verificando as barras "//" iniciais de host remoto
if [[ "$(grep -o '^..' <<< "$remoteDir")" != "//" ]]; then
	remoteDir=$(sed 's/^/\/\//g' <<< "$remoteDir")
fi

# Verifica barra "/" no final e remover se houver
if [[ "$(grep -o '.$' <<< $mountDir)" = "/" ]]; then
	mountDir=$(sed 's/.$//g' <<< $mountDir)
fi

mountedDir=$(df -h | grep "$mountDir" | cut -d '%' -f2 | cut -d ' ' -f2)
mounted=$(df -h | grep "$mountDir")

if [[ "$mountDir" = "$mountedDir" ]]; then
	echo -e "\nJá está montado\n$mounted\n"
	exit 0
fi

if [ -e $mountDir ]; then
	echo -e "\nMontando diretório remoto"
	mount -t cifs -o username="$remoteUser",password="$remotePass",port="$port" "$remoteDir" "$mountDir"
	if [[ "$?" -eq "0" ]]; then
		echo -e "Montado com sucesso: $(df -h | grep $mountDir) \n"
		exit 0
	else
		echo -e "Algo deu errado. Verifique!"
		exit 1
	fi
else
	read -p "Diretório não existe. Deseja criar? [S/N]: " confirm
	case "$confirm" in

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
mount -t cifs -o username="$remoteUser",password="$remotePass",port="$port" "$remoteDir" "$mountDir"
if [[ "$?" -eq "0" ]]; then
	echo -e "Montado com sucesso: $(df -h | grep "$mountDir") \n"
	exit 0
else
	echo "Algo deu errado. Verifique!"
	exit 1
fi
