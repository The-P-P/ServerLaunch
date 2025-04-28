#!/bin/bash
# Script para backup automático do WordPress

# Configurações
SITE_NAME="meusite"
BACKUP_DIR="/var/backups/wordpress"
SITE_DIR="/var/www/html/$SITE_NAME"
DB_NAME="wordpress"
DB_USER="wpuser"
DB_PASS="senha_segura"
DATE=$(date +%Y-%m-%d)
RETENTION_DAYS=7

# Verificar se o diretório de backup existe
if [ ! -d "$BACKUP_DIR" ]; then
  mkdir -p "$BACKUP_DIR"
  echo "Diretório de backup criado: $BACKUP_DIR"
fi

# Backup do banco de dados
echo "Iniciando backup do banco de dados..."
mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_DIR/${SITE_NAME}_db_${DATE}.sql"

# Verificar se o backup do banco de dados foi bem-sucedido
if [ $? -eq 0 ]; then
  echo "Backup do banco de dados concluído com sucesso."
else
  echo "Erro ao fazer backup do banco de dados."
  exit 1
fi

# Backup dos arquivos
echo "Iniciando backup dos arquivos..."
tar -czf "$BACKUP_DIR/${SITE_NAME}_files_${DATE}.tar.gz" -C "$(dirname "$SITE_DIR")" "$(basename "$SITE_DIR")"

# Verificar se o backup dos arquivos foi bem-sucedido
if [ $? -eq 0 ]; then
  echo "Backup dos arquivos concluído com sucesso."
else
  echo "Erro ao fazer backup dos arquivos."
  exit 1
fi

# Remover backups antigos
echo "Removendo backups com mais de $RETENTION_DAYS dias..."
find "$BACKUP_DIR" -name "${SITE_NAME}_db_*.sql" -mtime +$RETENTION_DAYS -delete
find "$BACKUP_DIR" -name "${SITE_NAME}_files_*.tar.gz" -mtime +$RETENTION_DAYS -delete

# Resumo
echo "Backup concluído em $(date)"
echo "Arquivos de backup:"
echo "- Banco de dados: $BACKUP_DIR/${SITE_NAME}_db_${DATE}.sql"
echo "- Arquivos: $BACKUP_DIR/${SITE_NAME}_files_${DATE}.tar.gz"
echo "Tamanho total dos backups:"
du -sh "$BACKUP_DIR"

# Adicionar ao log
echo "$(date): Backup concluído com sucesso" >> "$BACKUP_DIR/backup_log.txt"
