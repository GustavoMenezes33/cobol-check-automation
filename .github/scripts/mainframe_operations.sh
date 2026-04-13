#!/bin/bash
# mainframe_operations.sh

ZOWE_USERNAME="Z83128"

echo "1. Ajustando permissoes locais..."
# Correção 1: O nome da pasta correto é com hífen
cd cobol-check
chmod +x cobolcheck
cd scripts
chmod +x linux_gnucobol_run_tests
cd ..

run_cobolcheck() {
    program=$1
    echo "========================================="
    echo "Processando o programa: $program"

    # Roda o Java apontando direto para o arquivo .jar na pasta bin
    java -jar bin/cobol-check-0.2.19.jar -p $program

    if [ -f "CC##99.CBL" ]; then
        echo "Subindo o código de teste CC##99.CBL para o Mainframe..."
        zowe files upload file-to-data-set "CC##99.CBL" "${ZOWE_USERNAME}.CBL($program)"
    else
        echo "Aviso: CC##99.CBL não foi gerado para $program (Isso é normal se você ainda não escreveu os testes)"
    fi

    if [ -f "../${program}.JCL" ]; then
        echo "Subindo o ../${program}.JCL para o Mainframe..."
        zowe files upload file-to-data-set "../${program}.JCL" "${ZOWE_USERNAME}.JCL($program)"
        echo ">> Upload de $program concluído com sucesso! <<"
    else
        echo "ERRO FATAL: Arquivo ../${program}.JCL não encontrado!"
    fi
}

# Executa para cada programa
for program in NUMBERS EMPPAY DEPTPAY; do
    run_cobolcheck $program
done

echo "Operações do Mainframe finalizadas com sucesso!"