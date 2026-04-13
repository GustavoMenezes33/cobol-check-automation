#!/bin/bash
# mainframe_operations.sh

ZOWE_USERNAME="Z83128"

echo "1. Ajustando permissoes locais..."
# Correção 1: O nome da pasta correto é com hífen
cd cobol-check
cd scripts
chmod +x linux_gnucobol_run_tests
cd ..

run_cobolcheck() {
    program=$1
    echo "========================================="
    echo "Processando o programa: $program"

    # Apaga o teste do programa anterior para não subir lixo
    rm -f testruns/CC##99.CBL
    
    # Roda o Java (ele vai dar o erro 'cobc: not found', mas vai gerar o código!)
    java -jar bin/cobol-check-0.2.19.jar -p $program

    # Correção: Apontando para a pasta testruns/ onde o arquivo realmente está
    if [ -f "testruns/CC##99.CBL" ]; then
        echo "Subindo o código de teste CC##99.CBL para o Mainframe..."
        zowe files upload file-to-data-set "testruns/CC##99.CBL" "${ZOWE_USERNAME}.CBL($program)"
    else
        echo "Aviso: testruns/CC##99.CBL não foi encontrado para $program"
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