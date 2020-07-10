#!/bin/bash
clear
#Espaço

#Root
if [ "$EUID" -ne 0 ]; then
	echo "Você não está executando o script com root ou sudo"
	exit 1
fi
if [[ -e /etc/debian_version ]]; then
	source /etc/os-release
	OS=$ID # debian or ubuntu
else
	echo "Você não tem instalado ou não esta com sistema Debian ou Ubuntu "
	exit 1
fi

#--unistall
REMOVE=$(pwd)

#Debian ou ubuntu
if [[ $OS == 'ubuntu' ]]; then
      sudo apt install screen unzip zip net-tools -y >>$USUARIO/log.txt 2>&1 ;
elif [[ $OS == 'debian' ]]; then
	sudo apt install screen unzip zip net-tools -y >>$USUARIO/log.txt 2>&1 ;
else
      exit 1
fi

#Software
BDS="$(wget -qO- https://script.sirherobrine23.org/BDS.txt)"

#Usuario
USUARIO=$(cd ~/;pwd)

# Iniacialização
file=mcpe-server
FILE2=mcpe-/sbin/mcpe-server

#pode ser aqui ali ou DEBIAN
TMP=/home/Minecraft-temp
sudo mkdir $TMP >>$USUARIO/log.txt 2>&1 ;

# Remoção dos arquivo de log
sudo rm -rf $TMP/level.txt >>$USUARIO/log.txt 2>&1 ;

echo "o Diretorio do seu usuario é $USUARIO"
echo "Começamos ás $(TZ=UTC+3 date +"%H:%M:%S")"
echo " "
echo "--------------"
echo " "

# --------------- Codigo ------------------------------

diretorio-sh23() {
#caminho da instalação e do backup
if [[ -e installed.txt ]]; then
      PATH_TO_INSTALL="$(cat installed.txt)" 
      echo "Depois pode alterar o diretorio no installed.txt"
else
      read -rp "a onde vai ser instalado: " -e -i "/home/minecraft" PATH_TO_INSTALL
      touch installed.txt -a $PATH_TO_INSTALL
      echo "$PATH_TO_INSTALL" >> installed.txt
fi
}

mapaname(){
    diretorio-sh23
    cat $PATH_TO_INSTALL/server.properties | grep "level-name=" > /tmp/level.txt ; sed -i "s|level-name=||g" "/tmp/level.txt"
    level=$(cat /tmp/level.txt)
    read -rp "Qual é o nome do Mapa (Só confimação do nome): " -e -i "$level" MAPA_DO_SERVIDOR
    cat $PATH_TO_INSTALL/server.properties | grep "server-port=" > /tmp/port.txt ; sed -i "s|server-port=||g" "/tmp/port.txt"
    PORTAD=$(cat /tmp/port.txt)
}


install-sh23() {
    diretorio-sh23
    #banner
    cat banner.txt;
    # Prerequisite
    echo "  ";

    #Download do arquivos servidor
    echo "Baixando o Software do Servidor";
    sudo wget "$BDS" -O mcpe.zip >>$USUARIO/log.txt 2>&1 ;

    echo "Instalando o Servidor";
    sudo unzip mcpe.zip -d mcpe/ >>$USUARIO/log.txt 2>&1 ;
    sudo rm -rf mcpe.zip;

    #config
    echo "Configuração Base"
    rm -rf mcpe/server.properties >>$USUARIO/log.txt 2>&1 ;
    rm -rf mcpe/whitelist.json >>$USUARIO/log.txt 2>&1 ;
    cp -r ./server.properties mcpe/ >>$USUARIO/log.txt 2>&1 ;
    cp -r ./whitelist.json mcpe/ >>$USUARIO/log.txt 2>&1 ;

    #Movendo
    echo "Movendo para o $PATH_TO_INSTALL"
    rm -rf $PATH_TO_INSTALL
    mkdir $PATH_TO_INSTALL
    cp -r mcpe/* $PATH_TO_INSTALL/
    echo "Limpando alguns arquivos"
    rm -rf mcpe/
    echo "O log está no arquivo $USUARIO/log.txt"
}
update-sh23() {
    diretorio-sh23
    #Preparando
    echo " "
    echo "Backup?"
        read -rp "Nome do backup:  " -e -i "$(TZ=UTC+3 date +"%d-%m-%Y")" BACKUP
    echo " "
    echo "Por padrão é no /home/Minecraft-Backup, mais esse diretorio será a apagado depois, mas isso não é do Backup, mas mantendo os novos no $PATH_TO_INSTALL (debug)"
        read -rp "Aonde vai ser o backup: " -e -i "/home/Minecraft-Backup" PATH_TO_BACKUP
    echo " "
    echo "arquivos temporarios (debug)"
        read -rp "A onde vai ser a pasta temporaria: " -e -i "/tmp/mcpe-update" TMP_UPDATE
        read -rp  "A onde sera savo o backup para amazenamento: " -e -i "$(cd ~/;pwd)/mcpe-Backup" PATHBACKUP
    echo " "
    echo " "

      mkdir "$TMP_UPDATE"
    #---------------------------------------------------------------------------------------------------------
    cat "$PATH_TO_INSTALL/server.properties" | grep "level-name=" >> "$TMP_UPDATE/level.txt" ;
    sed -i "s|level-name=||g" "$TMP_UPDATE/level.txt"
    MAPA=$(cat $TMP_UPDATE/level.txt) >>$USUARIO/log.txt 2>&1 ;
    #---------------------------------------------------------------------------------------------------------
    echo " "
    echo " "

    echo "verificando se a arquivos antingos no $(pwd)"
    if [[ -d mcpe/ ]]; then
    rm -rf mcpe/
    fi
    if [[ -e mcpe.zip ]];then
    rm -rf mcpe.zip
    fi

    #copia
      cp -rf "$PATH_TO_INSTALL/*" "$PATH_TO_BACKUP"

    #copia de seguraça
      mkdir "$PATH_TO_BACKUP/"
      mkdir "$PATHBACKUP/"
      zip  "$PATHBACKUP/$BACKUP".zip -r "$PATH_TO_INSTALL/*"

      if [[ -d $PATH_TO_INSTALL/ ]];then
            rm -rf $PATH_TO_INSTALL/
      fi

      #baixar a nova versão
      wget "$BDS" -O mcpe.zip
      unzip mcpe.zip -d mcpe

      #removendo alguns arquivos
      rm -r mcpe/server.properties
      rm -r mcpe/whitelist.json

      # Movendo para o temp
      rm -rf $PATH_TO_INSTALL/
      
      #copiar mundo e as configuraçoe
      cp -r "$PATH_TO_BACKUP/worlds" "mcpe/"
      cp "$PATH_TO_BACKUP/server.properties" "mcpe/"
      cp "$PATH_TO_BACKUP/whitelist.json" "mcpe/"

      #movendo
      mkdir $PATH_TO_INSTALL/
      cp -rf mcpe/* $PATH_TO_INSTALL/

      #remover arquivos antigos
      rm mcpe.zip
      #rm -rf mcpe/
      #rm -rf $PATH_TO_BACKUP
      #rm -rf $TMP_UPDATE
}
backup-sh23() {
      diretorio-sh23
      if [ -e /sbin/mcpe-server ] ; then
      echo "Para fazer o backup coloque sim (yes) e de [enter], caso não queira, não (no) e de [enter]"
      read -rp "Vai querer fazer o backup?  " -e -i "sim" BC
            case $BC in
            sim | yes ) touch $PATH_TO_INSTALL/backup.txt -a $PATH_TO_INSTALL ; echo "Vamos configurar agora o Gdrive, precisamos fazer um login na sua conta do google. nenhum dado será amarzenado pelo script." ; sleep2 ; gdrive about  ;;
            nao | no ) exit;;
            * ) echo "não houve escolha, saindo ..."; exit
            esac
      else
      echo "não podemos cria agora, por favor execute primeiro o --fundo"
      fi
}
ip-sh23(){
      #Comando --ip variaveis
      IP_V4=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
      SEARCH_IPV6=$(ip -6 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
      IP_V6=$(ifconfig $SEARCH_IPV6 | grep "inet6" | awk -F' ' '{print $2}' | awk '{print $1}') 
      IP_PUBLICO=$(wget -qO- http://ipecho.net/plain)
      #Echo's
            echo "Seu IPv4 é $IP_V4 para Jogar localmente , e o Seu IPv6 é $(echo -ne $IP_V6)"
            echo " "
            echo "Caso Queira Jogar Remotamento com alguém Abra as Portas 19132 e 19133 no seu Roteador ou seu Firewall, seu IPv4 Publico é $IP_PUBLICO"
            echo "Também verifique se sua operadora ou provedor libera as portas do servidor. contate-os"
      echo " ";
}
apache2-install-sh23() {
diretorio-sh23
      #Instalação do apache2
      echo "Instalando o Apache2"
      sudo apt update >> /dev/null 2>&1 
      sudo apt install apache2 -y >> /dev/null 2>&1 

      # Removendo pasta HTML e Adicionando denovo
      rm -rf /var/www/html/
      mkdir /var/www/html/

      # Pegando as config
      echo "Agora vamos começar a configurar o nova pagina do Apache"
      sleep 2
      echo "Vamos precicar de algumas informações como:"
      echo "Dominio caso você tenha"
      echo "nome que aparacera na Pagina. etc ..."
      sleep 3
      mapaname
      read -rp "Qual será o dominio ou nos da o IP publico: " -e -i "$(wget -qO- http://ipecho.net/plain)" IPDOMAIN
      read -rp "Qual é o nome que aparacera na pagina: " -e -i "$(cat /tmp/level.txt)" MAINSERVERNAME

      # Montando as Configurações
      sed -i "s|ENDEREÇODOSERVIDOROUIP|$IPDOMAIN|g" "./html-files/index.html"
      sed -i "s|MAINSERVERNAME|$MAPA_DO_SERVIDOR|g" "./html-files/index.html"
      sed -i "s|PORTASERVER|$PORTAD|g" "./html-files/index.html"

      # Movendo as configurações
      cp -rf ./html-files/* /var/www/html/
}
externo-sh23() {
      diretorio-sh23
      # vsftp and Samba
      sudo apt install -y vsftpd samba >> /dev/null 2>&1 ;

      #config
      sed -i "s|PATHTOISNTALL|$PATH_TO_INSTALL|g" "./smb.conf"
      sed -i "s|root||g" "/etc/ftpusers"

      rm /etc/samba/smb.conf
      cp -rf ./smb.conf /etc/samba/
      cp -rf ./vsftp.conf /etc/vsftpd.conf

      service smbd restart
      service vsftpd restart

echo "Para adicionar um usuario no Smb use smbpasswd -a username"
echo "Para usar o ftp não precisar de nada a mais para configura só ter um usuario no sistema"

}

#

fundo-sh23() {
    echo " "
        rm /sbin/mcpe-server
        rm -rf /tmp/level.txt
        rm -rf /sbin/mcpe
        rm -rf /usr/sbin/mcpe-server
        rm -rf /usr/sbin/mcpe
        mapaname
            # -- Config --
                cp fundo.sh /tmp/
                MINE2Sh23="/home/MCPE-Backups"
                read -rp "Qual é o ID da pasta no google Drive caso fará backup para A Nuven (Exemplo: 1-FWzQJWhhJK_00ETU4uVOg6R5c5p_yMP)? " -e -i "" ID
                read -rp "Aonde você vai quere colocar os Backups Locais (Caso queira)? " -e -i "$MINE2Sh23" MINE2Sh23
                mkdir $MINE2Sh23
                sed -i "s|ID|$ID|g" "/tmp/fundo.sh";
                sed -i "s|MINE|$PATH_TO_INSTALL|g" "/tmp/fundo.sh";
                sed -i "s|NAME|$MAPA_DO_SERVIDOR|g" "/tmp/fundo.sh";
                sed -i "s|2MINESh23|$MINE2Sh23|g" "/tmp/fundo.sh";
                cp -rf /tmp/fundo.sh /usr/sbin/mcpe-server
                sudo chmod a+x /usr/sbin/mcpe-server
            # -- Config --
    echo " "
    echo "Para deixar o servidor em segundo plano aperte CRTL + A + D. deixara em segundo plano para voltar basta executar o comando screen -r"

}
sistema-sh23() {
      diretorio-sh23
      wget "https://drive.google.com/uc?export=download&id=1UlemfOSQUxbxTFDriAeDV7o1hRwXcS43" -O /usr/bin/gdrive >>$USUARIO/log.txt 2>&1 ;
      chmod a+x /usr/bin/gdrive

# ---------------------------------------    
    echo " "
        rm /sbin/mcpe-server
        rm -rf /tmp/level.txt
        rm -rf /sbin/mcpe
        rm -rf /usr/sbin/mcpe-server
        rm -rf /usr/sbin/mcpe
        mapaname
            # -- Config --
                cp fundo.sh /tmp/
                MINE2Sh23="/home/MCPE-Backups"
                read -rp "Qual é o ID da pasta no google Drive caso fará backup para A Nuven (Exemplo: 1-FWzQJWhhJK_00ETU4uVOg6R5c5p_yMP)? " -e -i "" ID
                read -rp "Aonde você vai quere colocar os Backups Locais (Caso queira)? " -e -i "$MINE2Sh23" MINE2Sh23
                mkdir $MINE2Sh23
                sed -i "s|ID|$ID|g" "/tmp/fundo.sh";
                sed -i "s|MINE|$PATH_TO_INSTALL|g" "/tmp/fundo.sh";
                sed -i "s|NAME|$MAPA_DO_SERVIDOR|g" "/tmp/fundo.sh";
                sed -i "s|2MINESh23|$MINE2Sh23|g" "/tmp/fundo.sh";
                cp -rf /tmp/fundo.sh /usr/sbin/mcpe-server
                sudo chmod a+x /usr/sbin/mcpe-server
            # -- Config --
    echo " "
    echo "Para deixar o servidor em segundo plano aperte CRTL + A + D. deixara em segundo plano para voltar basta executar o comando screen -r"

    # ---------------------------------------

    echo "Iniciando as Configurações do arquivo para Inicialização junto com o Sistema"
        sudo cp start-on-system.sh /tmp/systemsh23.sh;
            sed -i "s|IDSh23|$ID|g" "/tmp/systemsh23.sh";
            sed -i "s|MINESh23|$PATH_TO_INSTALL|g" "/tmp/systemsh23.sh";
            sed -i "s|NAMESh23|$MAPA_DO_SERVIDOR|g" "/tmp/systemsh23.sh";
            sed -i "s|2MINESh23|$MINE2Sh23|g" "/tmp/systemsh23.sh";
        sudo cp "/tmp/systemsh23.sh" "/etc/init.d/mcpe-server";
    echo "copiando o arquivo";
        sudo chmod a+x /etc/init.d/mcpe-server;
        update-rc.d mcpe-server defaults
        update-rc.d mcpe-server enable
    echo "pronto ele inicia junto com sistema(Beta), o comando abaixo pode ajudar"
    echo " "
    echo 'sudo service mcpe-server start | stop | restart'
    echo " "
}

#


script-update() {
      git clone https://github.com/Sirherobrine23/Minecraft-Bedrock-auto-install.git -b linux ../ins2/
      cp -rf ../ins2/* ./
      rm -rf ../ins2/
}


# Escolha --------------  ***  -----------
case $1 in
--install* | --Instalação* | --instalacao* | --Install* | -i | -I )  install-sh23 ;;
--update* | --Atualizar* | --Update* | --Update* | -u | -U) update-sh23 ;;
--backup* | --Backup* | -b | -B ) backup-sh23 ;;
--System | --Sistema | --system | --sistema | -S | -s ) sistema-sh23 ;;
--fundo* | --Fundo* | --Backgroud* | --background* | -f | -F ) fundo-sh23 ;;
--ip | --Ip | --IP | --pi | -p | -P ) ip-sh23 ;;
--Apache2 | apache2 | --Page | --page | -a | -A ) apache2-install-sh23 ;;
--externo | -e | -E) externo-sh23 ;;
--script | --Script | -S | -s) script-update ;;
--unistall | --remover | -r | -R ) sudo rm -rf "$REMOVE";;
*) cat help.txt ; echo " "; exit 1
esac



# --------------- Codigo ------------------------------

echo " "
echo "--------------"
echo " "
echo "qualquer erro no script me comunique no https://github.com/Sirherobrine23/Minecraft-Bedrock-auto-install/issues"
echo "Terminamos as $(TZ=UTC+3 date +"%H:%M:%S")"
sudo rm -rf mcpe.zip
