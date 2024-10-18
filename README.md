# Script Bash para Automatização de Scans e Fuzzing

Este script em Bash foi desenvolvido para automatizar tarefas de reconhecimento e fuzzing em máquinas alvo, como as encontradas no Hack The Box (HTB). Ele verifica e instala dependências automaticamente, executa scans com o Nmap, faz fuzzing de diretórios e subdomínios usando FFUF e facilita a adição de domínios no arquivo /etc/hosts.
Pré-requisitos:

    Sistema operacional Linux (Kali, Ubuntu ou similar)
    Acesso como root (necessário para modificar o arquivo /etc/hosts)
    Conexão com a internet para instalar pacotes necessários
    Ferramentas:
        snapd
        bc
        lolcat
        ffuf
        nmap
        jq
        Wordlists do SecLists

Instalação e Uso:

    Clonar o repositório: Para começar, clone o repositório onde o script será armazenado:

    bash

git clone https://github.com/seu-usuario/seu-repositorio.git

Dar permissão de execução: Após clonar o repositório, você precisa dar permissão de execução ao script:

bash

chmod +x authtb.sh

Executar o script: Para rodar o script, execute-o como root:

bash

sudo ./authtb.sh

Fluxo do Script: O script segue o seguinte fluxo:

    Verifica e instala as ferramentas necessárias (snapd, bc, lolcat, ffuf, nmap)
    Solicita o nome da máquina e cria um diretório específico para ela
    Solicita o IP e nome de domínio da máquina alvo e adiciona ao /etc/hosts
    Executa um scan Nmap no IP alvo
    Pergunta se deseja realizar fuzzing de diretórios e subdomínios
