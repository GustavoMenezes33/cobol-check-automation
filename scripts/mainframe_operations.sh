#!/bin/bash
# mainframe_operations.sh

# Configura ambiente
export PATH=$PATH:/usr/lpp/java/J8.0_64/bin
export JAVA_HOME=/usr/lpp/java/J8.0_64
export PATH=$PATH:/usr/lpp/zowe/cli/node/bin

java -version

ZOWE_USERNAME="Z83128"  # <-- altere para seu userid

cd cobolcheck
echo "Changed to $(pwd)"
ls -al

chmod +x cobolcheck
echo "Made cobolcheck executable"

cd scripts
chmod +x linux_gnucobol_run_tests
echo "Made linux_gnucobol_run_tests executable"
cd ..

# Função para executar cobolcheck e copiar arquivos
run_cobolcheck() {
    program=$1
    echo "Running cobolcheck for $program"

    ./cobolcheck -p $program
    echo "Cobolcheck completed for $program"

    if [ -f "CC##99.CBL" ]; then
        if cp CC##99.CBL "//'${ZOWE_USERNAME}.CBL($program)'"; then
            echo "Copied CC##99.CBL to ${ZOWE_USERNAME}.CBL($program)"
        else
            echo "Failed to copy CC##99.CBL"
        fi
    else
        echo "CC##99.CBL not found for $program"
    fi

    if [ -f "${program}.JCL" ]; then
        if cp ${program}.JCL "//'${ZOWE_USERNAME}.JCL($program)'"; then
            echo "Copied ${program}.JCL"
        else
            echo "Failed to copy ${program}.JCL"
        fi
    else
        echo "${program}.JCL not found"
    fi
}

# Executa para cada programa
for program in NUMBERS EMPPAY DEPTPAY; do
    run_cobolcheck $program
done

echo "Mainframe operations completed"
