#!/bin/bash
# Script para configuração de SSL com Let's Encrypt

# Configurações
DOMAIN="example.com"
EMAIL="admin@example.com"
WEBROOT="/var/www/html/$DOMAIN/public_html"

# Verificar se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
  echo "Este script deve ser executado como root"
  exit 1
fi

# Instalar Certbot e plugin para Apache
echo "Instalando Certbot e plugin para Apache..."
apt update
apt install -y certbot python3-certbot-apache

# Verificar se o domínio está configurado no Apache
if [ ! -f "/etc/apache2/sites-available/$DOMAIN.conf" ]; then
  echo "Arquivo de configuração do Apache para $DOMAIN não encontrado."
  echo "Crie primeiro o Virtual Host para o domínio."
  exit 1
fi

# Obter certificado SSL
echo "Obtendo certificado SSL para $DOMAIN..."
certbot --apache -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos --email $EMAIL

# Verificar se a obtenção do certificado foi bem-sucedida
if [ $? -eq 0 ]; then
  echo "Certificado SSL obtido com sucesso para $DOMAIN."
else
  echo "Erro ao obter certificado SSL."
  exit 1
fi

# Configurar renovação automática
echo "Configurando renovação automática do certificado..."
echo "0 3 * * * root certbot renew --quiet" > /etc/cron.d/certbot-renew
chmod 644 /etc/cron.d/certbot-renew

# Testar renovação
echo "Testando processo de renovação..."
certbot renew --dry-run

# Verificar configuração do Apache
echo "Verificando configuração do Apache..."
apache2ctl configtest

# Reiniciar Apache
echo "Reiniciando Apache..."
systemctl restart apache2

echo "Configuração de SSL concluída para $DOMAIN."
echo "O certificado será renovado automaticamente antes de expirar."
echo "Você pode verificar a configuração SSL em: https://www.ssllabs.com/ssltest/analyze.html?d=$DOMAIN"
