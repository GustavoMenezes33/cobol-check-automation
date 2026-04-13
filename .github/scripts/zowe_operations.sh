#!/bin/bash
# zowe_operations.sh

# Converte username para minúsculas
LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')

# Verifica se o diretório existe, cria se não existir
if ! zowe zos-files list uss-files \
     "/z/$LOWERCASE_USERNAME/cobolcheck" &>/dev/null; then
    echo "Directory does not exist. Creating it..."
    zowe zos-files create uss-directory \
         /z/$LOWERCASE_USERNAME/cobolcheck
else
    echo "Directory already exists."
fi

# Upload dos arquivos
zowe zos-files upload dir-to-uss "./cobol-check" \
     "/z/$LOWERCASE_USERNAME/cobolcheck" \
     --recursive \
     --binary-files "cobol-check-0.2.9.jar"

# Verifica o upload
echo "Verifying upload:"
zowe zos-files list uss-files "/z/$LOWERCASE_USERNAME/cobolcheck"
