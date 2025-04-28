#!/bin/bash
# Script de configuração inicial do servidor VPS

# Atualizar o sistema
echo "Atualizando o sistema..."
apt update
apt upgrade -y
apt dist-upgrade -y

# Configurar timezone
echo "Configurando timezone para America/Sao_Paulo..."
timedatectl set-timezone America/Sao_Paulo

# Instalar pacotes essenciais
echo "Instalando pacotes essenciais..."
apt install -y curl wget vim git unzip htop net-tools fail2ban ufw

# Configurar firewall
echo "Configurando firewall (UFW)..."
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow http
ufw allow https
ufw enable

# Configurar Fail2Ban
echo "Configurando Fail2Ban para proteção contra ataques de força bruta..."
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
systemctl enable fail2ban
systemctl start fail2ban

# Criar usuário não-root com privilégios sudo
echo "Criando usuário com privilégios sudo..."
read -p "Digite o nome do novo usuário: " USERNAME
adduser $USERNAME
usermod -aG sudo $USERNAME

# Configurar SSH para maior segurança
echo "Configurando SSH para maior segurança..."
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd

echo "Configuração inicial do servidor concluída!"
echo "Lembre-se de configurar as chaves SSH para o novo usuário antes de sair."
