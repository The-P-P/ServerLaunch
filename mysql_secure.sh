#!/bin/bash
# Script para configuração segura do MySQL/MariaDB

# Verificar se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
  echo "Este script deve ser executado como root"
  exit 1
fi

# Verificar se o MySQL/MariaDB está instalado
if ! command -v mysql &> /dev/null; then
    echo "MySQL/MariaDB não está instalado. Instalando..."
    apt update
    apt install -y mariadb-server
fi

# Iniciar o serviço se não estiver rodando
systemctl start mariadb
systemctl enable mariadb

echo "Executando configuração segura do MySQL/MariaDB..."

# Definir variáveis
MYSQL_ROOT_PASSWORD="SuaSenhaSeguraAqui"
SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"\r\"
expect \"Set root password?\"
send \"y\r\"
expect \"New password:\"
send \"$MYSQL_ROOT_PASSWORD\r\"
expect \"Re-enter new password:\"
send \"$MYSQL_ROOT_PASSWORD\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")

# Executar a configuração segura
echo "$SECURE_MYSQL"

# Configurações adicionais de segurança
mysql -u root -p$MYSQL_ROOT_PASSWORD <<EOF
# Limitar conexões por usuário
SET GLOBAL max_user_connections=25;

# Limitar tempo de conexão inativa
SET GLOBAL wait_timeout=600;
SET GLOBAL interactive_timeout=600;

# Desabilitar carregamento de arquivos locais
SET GLOBAL local_infile=0;

# Aplicar alterações
FLUSH PRIVILEGES;
EOF

echo "Configuração segura do MySQL/MariaDB concluída!"
echo "Senha do root definida como: $MYSQL_ROOT_PASSWORD"
echo "Anote esta senha em um local seguro e altere a variável no script após o uso."
