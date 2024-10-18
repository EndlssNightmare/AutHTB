#!/bin/bash

# Cores ANSI
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
RED='\033[0;31m'
RESET='\033[0m'

# Adiciona o caminho do snap ao PATH, caso não esteja presente
export PATH=$PATH:/snap/bin:/usr/games

# Função para verificar e instalar o snapd, se necessário
install_snapd_if_needed() {
  if ! command -v snap &> /dev/null; then
    echo -e "${RED}[*] 'snapd' não está instalado.${RESET}"
    echo -e "${YELLOW}[*] Instalando 'snapd' usando apt...${RESET}"

    # Atualiza os pacotes e instala o snapd
    apt update && apt install -y snapd

    echo -e "${GREEN}[*] 'snapd' instalado com sucesso.${RESET}"
  else
    echo -e "${GREEN}[*] 'snapd' já está instalado.${RESET}"
  fi
}

# Função para verificar e instalar o bc, se necessário
install_bc_if_needed() {
  if ! command -v bc &> /dev/null; then
    echo -e "${RED}[*] 'bc' não está instalado.${RESET}"
    echo -e "${YELLOW}[*] Instalando 'bc' usando apt...${RESET}"

    # Instala o bc usando apt
    apt update && apt install -y bc

    echo -e "${GREEN}[*] 'bc' instalado com sucesso.${RESET}"
  else
    echo -e "${GREEN}[*] 'bc' já está instalado.${RESET}"
  fi
}

# Função para verificar e instalar o lolcat, se necessário
install_lolcat_if_needed() {
  if ! command -v lolcat &> /dev/null; then
    echo -e "${RED}[*] 'lolcat' não está instalado.${RESET}"
    echo -e "${YELLOW}[*] Instalando 'lolcat' usando snap...${RESET}"

    # Verifica se o snapd está instalado
    install_snapd_if_needed

    # Instala o lolcat usando snap
    snap install lolcat

    # Adiciona /snap/bin ao PATH para garantir que o lolcat seja encontrado
    export PATH=$PATH:/snap/bin:/usr/games
    echo -e "${GREEN}[*] 'lolcat' instalado e PATH atualizado.${RESET}"
  else
    echo -e "${GREEN}[*] 'lolcat' já está instalado.${RESET}"
  fi
}

# Função para verificar e instalar o ffuf, se necessário
install_ffuf_if_needed() {
  if ! command -v ffuf &> /dev/null; then
    echo -e "${RED}[*] 'ffuf' não está instalado.${RESET}"
    echo -e "${YELLOW}[*] Instalando 'ffuf' usando apt...${RESET}"

    # Instala o ffuf usando apt
    apt update && apt install -y ffuf

    echo -e "${GREEN}[*] 'ffuf' instalado com sucesso.${RESET}"
  else
    echo -e "${GREEN}[*] 'ffuf' já está instalado.${RESET}"
  fi
}

# Função para verificar e instalar o nmap, se necessário
install_nmap_if_needed() {
  if ! command -v nmap &> /dev/null; then
    echo -e "${RED}[*] 'nmap' não está instalado.${RESET}"
    echo -e "${YELLOW}[*] Instalando 'nmap' usando apt...${RESET}"

    # Instala o nmap usando apt
    apt update && apt install -y nmap

    echo -e "${GREEN}[*] 'nmap' instalado com sucesso.${RESET}"
  else
    echo -e "${GREEN}[*] 'nmap' já está instalado.${RESET}"
  fi
}

# Verifica se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Por favor, execute como root${RESET}"
  exit 1
fi

# Verifica e instala as dependências principais
install_snapd_if_needed
install_bc_if_needed
install_lolcat_if_needed
install_ffuf_if_needed
install_nmap_if_needed

# Exibe o banner "AutHTB" com a fonte Bloody e cores vibrantes
figlet -f Bloody "AutHTB" -w 200 | lolcat

# Função para criar uma barra de carregamento (usando bc para ponto flutuante)
loading_bar() {
  local duration=$1
  local interval="0.1"
  local chars="/-\|"
  local i=0
  while [ "$(echo "$duration > 0" | bc)" -eq 1 ]; do
    printf "\r${YELLOW}[%c] ${RESET}" "${chars:i++%${#chars}}"
    sleep "$interval"
    duration=$(echo "$duration - $interval" | bc)
  done
  echo -e "\r${GREEN}[✔] Feito!${RESET}"
}

# Função para pedir o nome da máquina
get_machine_name() {
  echo -e "${BLUE}Digite o nome da máquina:${RESET} \c"
  read machine_name
}

# Função para criar o diretório da máquina ou reutilizar se já existir
create_machine_directory() {
  machine_dir="/home/v01/Machines/HTB/$machine_name"

  # Verifica se o diretório já existe
  if [ -d "$machine_dir" ]; then
    echo -e "${GREEN}[*] O diretório da máquina '$machine_name' já existe. Usando o diretório existente...${RESET}"
    loading_bar 2
  else
    # Caso o diretório não exista, ele será criado
    echo -e "${YELLOW}[*] Criando o diretório da máquina '$machine_name'...${RESET}"
    mkdir -p "$machine_dir"
    loading_bar 2
    echo -e "${GREEN}[*] Diretório da máquina criado em $machine_dir${RESET}"
  fi
}

# Função para pedir o IP do alvo
get_target_ip() {
  echo -e "${BLUE}Digite o IP do alvo:${RESET} \c"
  read target_ip
}

# Função para pedir o nome de domínio que será adicionado ao /etc/hosts
get_domain_name() {
  echo -e "${BLUE}Digite o nome de domínio para adicionar ao /etc/hosts:${RESET} \c"
  read domain_name
}

# Função para adicionar o IP e o domínio ao /etc/hosts
add_to_hosts() {
  echo -e "${YELLOW}[*] Adicionando $target_ip $domain_name ao /etc/hosts...${RESET}"
  echo "$target_ip $domain_name" >> /etc/hosts
  loading_bar 2
  echo -e "${GREEN}[*] Adicionado $target_ip $domain_name ao /etc/hosts${RESET}"
}

# Chamando diretamente as funções
add_ip_and_domain_to_hosts() {
  get_domain_name
  add_to_hosts
}

# Função para executar o scan do Nmap
run_nmap_scan() {
  log_file="$machine_dir/log.nmap"
  echo -e "${YELLOW}[*] Iniciando scan Nmap no IP $target_ip...${RESET}"
  loading_bar 2
  nmap -vv -sS -Pn -n -sV -sC "$target_ip" --min-rate=1000 -oN "$log_file"
  echo -e "${GREEN}[*] Scan Nmap completo. Verificando resultados no arquivo $log_file:${RESET}"
  loading_bar 2
  cat "$log_file"
}

# Função para perguntar ao usuário se ele quer especificar uma porta
ask_port_for_fuzzing() {
  echo -e "${BLUE}Deseja especificar uma porta para o fuzzing? (S/n)${RESET}"
  read answer
  if [[ "$answer" =~ ^[Ss] ]]; then
    echo -e "${BLUE}Digite a porta para o fuzzing:${RESET} \c"
    read porta
  else
    porta=80  # Porta padrão caso o usuário não especifique
  fi
}

select_wordlist_directory_fuzzing() {
  echo -e "${BLUE}Escolha a wordlist para o fuzzing:${RESET}"
  echo "1) raft-medium-directories.txt"
  echo "2) big.txt"
  echo "3) Personalizada"
  read choice
  case $choice in
    1) wordlist="/usr/share/wordlists/seclists/Discovery/Web-Content/raft-medium-directories.txt" ;;
    2) wordlist="/usr/share/wordlists/seclists/Discovery/Web-Content/big.txt" ;;
    3)
         echo -e "${BLUE}Digite o caminho da wordlist personalizada:${RESET} \c"
         # Habilita autocompletar com TAB para navegação de diretórios
         read -e wordlist
         ;;
    *)
         echo -e "${RED}[!] Opção inválida! Usando a wordlist padrão. [!]${RESET} \n"
         wordlist="/usr/share/wordlists/seclists/Discovery/Web-Content/raft-medium-directories.txt"
         ;;
  esac
  echo -e "${GREEN}[*] Wordlist selecionada: $wordlist${RESET}"
  loading_bar 2
}

# Função para executar o fuzzing de diretórios
run_directory_fuzzing() {
  ask_port_for_fuzzing
  select_wordlist_directory_fuzzing

  echo -e "${YELLOW}[*] Iniciando fuzzing de diretórios com FFUF na porta $porta...${RESET}"
  loading_bar 2
  ffuf -u "http://$domain_name:$porta/FUZZ" \
       -w $wordlist \
       -t 100 -e .php,.html,.txt,.js -recursion \
       -H "User-Agent: Mozilla/5.0" \
       -o "$machine_dir/directory_fuzz_temp.log" -of ejson

  # Verifica se o fuzzing foi cancelado ou completado
  if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}[*] Fuzzing de diretórios completo. Resultados salvos em $machine_dir/directory_fuzz.log.${RESET}"
  else
    echo -e "${RED}[!] O fuzzing de diretórios foi cancelado. [!]${RESET} \n"
  fi

  # Exibe o conteúdo do arquivo de log com o texto colorido via `lolcat`
  loading_bar 2
  echo -e "${GREEN}[*] Diretórios e arquivos encontrados:${RESET}"
  cat $machine_dir/directory_fuzz_temp.log | jq -r '.results[].url' | grep "http://$domain_name" | lolcat > $machine_dir/directory_fuzz.log
  cat $machine_dir/directory_fuzz.log | lolcat

  loading_bar 2
  echo -e "${YELLOW}[*] Limpando arquivos temporários...${RESET}"
  rm "$machine_dir/directory_fuzz_temp.log"
  loading_bar 2
  echo -e "${GREEN}[✔] Arquivos temporários removidos com sucesso.${RESET}"
}

select_wordlist_subdomain_fuzzing() {
   echo -e "${BLUE}Escolha a wordlist para o fuzzing:${RESET}"
   echo "1) bitquark-subdomains-top100000.txt"
   echo "2) subdomains-top1million-110000.txt"
   echo "3) Personalizada"
   read choice
   case $choice in
     1) wordlist="/usr/share/wordlists/seclists/Discovery/DNS/bitquark-subdomains-top100000.txt" ;;
     2) wordlist="/usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-110000.txt" ;;
     3)
        echo -e "${BLUE}Digite o caminho da wordlist personalizada:${RESET} \c"

        # Habilita autocompletar com TAB para navegação de diretórios
        read -e wordlist
        ;;
     *)
        echo -e "${RED}[!] Opção inválida! Usando a wordlist padrão. [!]${RESET} \n"
        wordlist="/usr/share/wordlists/seclists/Discovery/DNS/bitquark-subdomains-top100000.txt"
        ;;
   esac
   echo -e "${GREEN}[*] Wordlist selecionada: $wordlist${RESET}"
   loading_bar 2
}

run_subdomain_fuzzing() {
   ask_port_for_fuzzing
   select_wordlist_subdomain_fuzzing
   echo -e "${YELLOW}[*] Iniciando fuzzing de subdomínios com FFUF na porta $porta...${RESET}"
   loading_bar 2

   # Primeira tentativa de fuzzing sem filtragem
   ffuf -u "http://$domain_name:$porta/" \
        -w  $wordlist \
        -H "User-Agent: Mozilla/5.0" \
        -H "Host: FUZZ.$domain_name" \
        | tee "$machine_dir/subdomain_fuzz.log"

   # Verifica se o fuzzing foi cancelado ou completado
   if [[ $? -ne 0 ]]; then
     echo -e "${RED}[!] O fuzzing de subdomínios foi cancelado. [!]${RESET} \n"
     loading_bar 2

     # Pergunta ao usuário se deseja aplicar filtragem com -fs ou -fw
     echo -e "${YELLOW}[*] Adicione filtros em conjunto ou separados (-fs ou -fw), 'n' para sair: ${RESET} \c"
     read -r filter_option filter_value1 filter_option2 filter_value2

     # Verifica se foram fornecidos valores para fs ou fw e se são números válidos
     if [[ "$filter_option" =~ ^-fs$ && "$filter_value1" =~ ^[0-9]+$ ]]; then
       fs_filter="-fs $filter_value1"
     fi

     if [[ "$filter_option" =~ ^-fw$ && "$filter_value1" =~ ^[0-9]+$ ]]; then
       fw_filter="-fw $filter_value1"
     fi

     if [[ "$filter_option2" =~ ^-fs$ && "$filter_value2" =~ ^[0-9]+$ ]]; then
       fs_filter="-fs $filter_value2"
     fi

     if [[ "$filter_option2" =~ ^-fw$ && "$filter_value2" =~ ^[0-9]+$ ]]; then
       fw_filter="-fw $filter_value2"
     fi

     # Reinicia o fuzzing com as opções de filtragem fornecidas
     if [[ -n "$fs_filter" || -n "$fw_filter" ]]; then
       echo -e "${YELLOW}[*] Reiniciando fuzzing com as opções de filtragem $fs_filter $fw_filter...${RESET}"
       loading_bar 2

       # Apaga o arquivo temporário anterior
       rm -f "$machine_dir/subdomain_fuzz.log"

       # Executa o fuzzing novamente com as opções de filtro
       ffuf -u "http://$domain_name:$porta/" \
            -w $wordlist \
            -H "User-Agent: Mozilla/5.0" \
            -H "Host: FUZZ.$domain_name" \
            $fw_filter $fw_filter | tee "$machine_dir/subdomain_fuzz.log"
     else
       echo -e "${RED}[!] Nenhuma filtragem válida aplicada. Encerrando o fuzzing.${RESET} \n"
       return
     fi
   else
     echo -e "${GREEN}[*] Fuzzing de subdomínios completo. Resultados salvos em $machine_dir/subdomain_fuzz.log.${RESET}"
   fi

   # Exibe o conteúdo do arquivo de log com o texto colorido via `lolcat`
   loading_bar 2
   echo -e "${GREEN}[*] Subdomínios encontrados:${RESET}"
   cat "$machine_dir/subdomain_fuzz.log" | lolcat

   # Processa os subdomínios removendo sequências ANSI e filtrando o primeiro campo
   cat "$machine_dir/subdomain_fuzz.log" | sed 's/\x1B\[[0-9;]*[a-zA-Z]//g' | awk -F " " '{print $1}' > $machine_dir/temp.txt
   sed -i 's/\r//' $machine_dir/temp.txt

   # Loop através de cada subdomínio encontrado no arquivo temp.txt
   while IFS= read -r subdomain; do
       # Verifica se o subdomínio não está vazio
       if [[ -n "$subdomain" ]]; then
           echo -e "${YELLOW}[*] Adicionando o subdomínio $subdomain.$domain_name em /etc/hosts...${RESET}"
           loading_bar 2

           echo "$target_ip $subdomain.$domain_name" >> /etc/hosts
           echo -e "${GREEN}[*] Adicionado $target_ip $subdomain.$domain_name ao /etc/hosts.${RESET}"
       fi
   done < $machine_dir/temp.txt

   # Realiza o fuzzing de arquivos e diretórios em todos os subdomínios encontrados
   fuzz_subdomains
}

fuzz_subdomains() {
  echo -e "${YELLOW}[*] Iniciando fuzzing de arquivos e diretórios em subdomínios...${RESET}"
  loading_bar 2

  # Carrega os subdomínios do arquivo temp.txt em um array
  mapfile -t subdomains < $machine_dir/temp.txt

  # Itera sobre cada subdomínio encontrado
  for subdomain in "${subdomains[@]}"; do
    if [[ -n "$subdomain" ]]; then

      echo -e "${YELLOW}[*] Iniciando as configuracões do fuzzing para o subdomínio $subdomain.$domain_name ${RESET}"
      loading_bar 2

      ask_port_for_fuzzing
      select_wordlist_directory_fuzzing

      echo -e "${YELLOW}[*] Iniciando fuzzing no subdomínio $subdomain.$domain_name ${RESET}"
      loading_bar 2

      # Realiza o fuzzing de diretórios no subdomínio
      ffuf -u "http://$subdomain.$domain_name:$porta/FUZZ" \
           -w $wordlist \
           -t 100 -e .php,.html,.txt,.js -recursion \
           -H "User-Agent: Mozilla/5.0" \
           -o "$machine_dir/$subdomain-directory_fuzz_temp.log" -of ejson

      # Verifica se o fuzzing foi completado ou cancelado
      if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}[*] Fuzzing no subdomínio $subdomain.$domain_name completo. Resultados salvos em $machine_dir/$subdomain-directory_fuzz.log.${RESET} \n"
      else
        echo -e "${RED}[!] O fuzzing de diretórios no subdomínio $subdomain.$domain_name foi cancelado! [!]${RESET} \n"
      fi
    fi

    loading_bar 2
    echo -e "${GREEN}[*] Diretórios e arquivos encontrados:${RESET}"
    cat "$machine_dir/$subdomain-directory_fuzz_temp.log" | jq -r '.results[].url' | grep "http://$subdomain.$domain_name" > $machine_dir/$subdomain-directory_fuzz.log
    cat $machine_dir/$subdomain-directory_fuzz.log | lolcat

    loading_bar 2
    echo -e "${YELLOW}[*] Limpando arquivos temporários...${RESET}"
    rm "$machine_dir/$subdomain-directory_fuzz_temp.log"
    loading_bar 2
    echo -e "${GREEN}[✔] Arquivos temporários removidos com sucesso.${RESET}"
  done

  loading_bar 2
  echo -e "${GREEN}[*] Limpando arquivos temporários...${RESET}"
  rm "$machine_dir/temp.txt"

  loading_bar 2
  echo -e "${GREEN}[✔] Arquivos temporários removidos com sucesso.${RESET}"

  loading_bar 2
  echo -e "${GREEN}[*] Fuzzing de todos os subdomínios completado!${RESET}"
}

# Função para perguntar ao usuário se ele deseja realizar o fuzzing de diretórios
ask_directory_fuzzing() {
  echo -e "${BLUE}Deseja realizar o fuzzing de diretórios (S/n)?${RESET}"
  read answer
  case $answer in
    [Nn]* ) echo -e "${YELLOW}[*] Pulando o fuzzing de diretórios...${RESET}";;
    * ) run_directory_fuzzing;;
  esac
}

# Função para perguntar ao usuário se ele deseja realizar o fuzzing de subdomínios
ask_subdomain_fuzzing() {
  echo -e "${BLUE}Deseja realizar o fuzzing de subdomínios (S/n)?${RESET}"
  read answer
  case $answer in
    [Nn]* ) echo -e "${YELLOW}[*] Pulando o fuzzing de subdomínios...${RESET}";;
    * ) run_subdomain_fuzzing;;
  esac
}

# Função principal para controle do fluxo
main() {
  get_machine_name
  create_machine_directory
  get_target_ip
  add_ip_and_domain_to_hosts
  run_nmap_scan
  ask_directory_fuzzing
  ask_subdomain_fuzzing
}

# Executa o script principal
main

