#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Display the script header
show_art() {
    echo -e "${BLUE} _____   _    _  _____"
    echo -e "|  __ \\ | |  | ||_   _|"
    echo -e "| |__) || |  | |  | |"
    echo -e "|  ___/ | |  | |  | |"
    echo -e "| |     | |__| | _| |_"
    echo -e "|_|      \\____/ |_____|"
    echo -e "\t\t\tᵇʸ ᴬⁿᵍᵉˡᵒ${RESET}\n"
}

# Define the download URL and installer file name
DOWNLOAD_URL="https://sourceforge.net/projects/xampp/files/XAMPP%20Linux/8.2.12/xampp-linux-x64-8.2.12-0-installer.run/download"
INSTALLER_FILE="xampp-linux-x64-8.2.12-0-installer.run"

# Function to verify XAMPP installation
verify_installation() {
    if [ -d "/opt/lampp" ] && [ -f "/opt/lampp/lampp" ]; then
        echo -e "${GREEN}\n✔ XAMPP ya está instalado en /opt/lampp${RESET}\n"
    else
        echo -e "${RED}\n❌ XAMPP no está instalado en el sistema.${RESET}"
    fi
}

# Function to display Apache and MySQL URLs
show_urls() {
    echo -e "${GREEN}\nPuedes acceder a los siguientes servicios:${RESET}"
    echo -e "${BLUE}• Apache Dashboard: ${RESET}http://localhost/dashboard/"
    echo -e "${BLUE}• phpMyAdmin: ${RESET}http://localhost/phpmyadmin/\n"
}

# Function to install dependencies based on the OS
install_dependencies() {
    case $1 in
        ubuntu|debian)
            echo -e "${YELLOW}\n🔽 Instalando dependencias para Ubuntu/Debian...${RESET}\n"
            sudo apt update
            sudo apt install -y libxcrypt-compat net-tools
            ;;
        arch)
            echo -e "${YELLOW}\n🔽 Instalando dependencias para Arch Linux...${RESET}\n"
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm libxcrypt-compat net-tools
            ;;
        *)
            echo -e "${RED}❌ Sistema operativo no soportado.${RESET}"
            exit 1
            ;;
    esac
}

# Function to check if dependencies are installed
check_dependencies() {
    if [ -x "$(command -v dpkg)" ]; then
        # Check if dependencies are installed on Debian/Ubuntu
        dpkg -l | grep -q "libxcrypt-compat" && dpkg -l | grep -q "net-tools"
    elif [ -x "$(command -v pacman)" ]; then
        # Check if dependencies are installed on Arch Linux
        pacman -Qq | grep -q "libxcrypt-compat" && pacman -Qq | grep -q "net-tools"
    else
        echo -e "${RED}❌ No se pudo verificar las dependencias. Comando de gestión de paquetes no encontrado.${RESET}"
        return 1
    fi
}

# Function to download and install XAMPP
# Function to download and install XAMPP
install_xampp() {
    # Verificar si curl está instalado
    if ! [ -x "$(command -v curl)" ]; then
        echo -e "${RED}\n❌ curl no está instalado.${RESET}"
        echo -e "${YELLOW}🔍 Detectando sistema operativo para instalar curl...${RESET}"

        if [ -x "$(command -v dpkg)" ]; then
            # Para sistemas Ubuntu/Debian
            echo -e "${YELLOW}\n🔽 Instalando curl en Ubuntu/Debian...${RESET}"
            sudo apt update
            sudo apt install -y curl
        elif [ -x "$(command -v pacman)" ]; then
            # Para sistemas Arch Linux
            echo -e "${YELLOW}\n🔽 Instalando curl en Arch Linux...${RESET}"
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm curl
        else
            echo -e "${RED}❌ No se pudo determinar el sistema operativo para instalar curl.${RESET}"
            exit 1
        fi
    else
        echo -e "${GREEN}\n✔ curl ya está instalado.${RESET}"
    fi

    # Verificar si el archivo instalador ya existe
    if [ ! -f "$INSTALLER_FILE" ]; then
        echo -e "${YELLOW}\n🔽 Descargando XAMPP...${RESET}\n"
        curl -L -o "$INSTALLER_FILE" "$DOWNLOAD_URL"
    else
        echo -e "${YELLOW}\n📂 El archivo de instalación de XAMPP ya está descargado.${RESET}"
    fi

    echo -e "${YELLOW}\n🔨 Haciendo el archivo ejecutable...${RESET}\n"
    chmod +x "$INSTALLER_FILE"

    echo -e "${YELLOW}🚀 Iniciando la instalación de XAMPP...${RESET}\n"

    # Ejecutar el instalador y capturar cualquier mensaje de error
    sudo ./"$INSTALLER_FILE" 2>&1 | tee install.log

    # Verificar si la instalación fue exitosa
    if [ -d "/opt/lampp" ] && [ -f "/opt/lampp/lampp" ]; then
        echo -e "${GREEN}\n✔ Instalación completada.${RESET}\n"
    else
        echo -e "${RED}\n❌ Error durante la instalación de XAMPP.${RESET}"
        echo -e "${RED}Consulta el archivo install.log para más detalles.${RESET}"
    fi
}


# Function to start XAMPP processes
start_xampp() {
    # Install dependencies if not already installed
    echo -e "${YELLOW}\n🔍 Verificando e instalando dependencias necesarias...${RESET}"
    if [ -d "/opt/lampp" ] && [ -f "/opt/lampp/lampp" ]; then
        echo -e "${YELLOW}\n🚀 Iniciando XAMPP...${RESET}\n"
        sudo /opt/lampp/lampp start
        show_urls
    else
        echo -e "${RED}\n❌ XAMPP no está instalado. Por favor, instálalo primero.${RESET}"
    fi
}

# Function to stop XAMPP processes
stop_xampp() {
    if [ -d "/opt/lampp" ] && [ -f "/opt/lampp/lampp" ]; then
        echo -e "${YELLOW}\n🛑 Deteniendo XAMPP...${RESET}\n"
        sudo /opt/lampp/lampp stop
        echo -e "${GREEN}\n✔ XAMPP ha sido detenido.${RESET}\n"
    else
        echo -e "${RED}\n❌ XAMPP no está instalado o ejecutándose.${RESET}"
    fi
}


# Function to uninstall XAMPP
uninstall_xampp() {
    if [ -d "/opt/lampp" ]; then
        echo -e "${YELLOW}\n🚮 Desinstalando XAMPP...${RESET}"
        sudo rm -rf /opt/lampp
        echo -e "${GREEN}\n✔ XAMPP ha sido desinstalado.${RESET}"
    else
        echo -e "${RED}\n❌ XAMPP no está instalado.${RESET}"
    fi
}

# Function to show the menu
show_menu() {
    clear
    show_art
    echo -e "${BLUE}**** Administración de XAMPP ****${RESET}\n"
    echo -e "${YELLOW}1. Verificar instalación de XAMPP${RESET}"
    echo -e "${YELLOW}2. Instalar XAMPP${RESET}"
    echo -e "${YELLOW}3. Iniciar procesos de XAMPP${RESET}"
    echo -e "${YELLOW}4. Detener procesos de XAMPP${RESET}"
    echo -e "${RED}5. Desinstalar XAMPP${RESET}"
    echo -e "${RED}6. Salir${RESET}"
    echo
    read -p "-> Qué quieres hacer: " option
    case $option in
        1) verify_installation ;;
        2) install_xampp ;;
        3)
            if ! check_dependencies; then
                echo -e "\n${YELLOW}🔽 Instalación de dependencias${RESET}"
                echo -e "\n${YELLOW}Selecciona tu sistema operativo:${RESET}"
                echo -e "${YELLOW}1. Ubuntu/Debian${RESET}"
                echo -e "${YELLOW}2. Arch Linux${RESET}"
                echo -e "${RED}3. Volver al menú principal${RESET}\n"
                read -p "-> Tu opción: " os_option
                case $os_option in
                    1) os_name="ubuntu" ;;
                    2) os_name="arch" ;;
                    3) 
                        echo -e "${GREEN}\nRegresando al menú principal...${RESET}"
                        return ;;  # Regresa al menú principal
                    *) 
                        echo -e "${RED}❌ Opción no válida.${RESET}" ;;
                esac
                install_dependencies $os_name
            fi
            start_xampp ;;
        4) stop_xampp ;;  # Llama a la nueva función para detener XAMPP
        5) uninstall_xampp ;;
        6) 
            clear
            echo -e "${GREEN}\nHasta la proxima. Goodbye!${RESET}"
            exit 0 ;;
        *) 
            echo -e "${RED}❌ Opción no válida.${RESET}" ;;
    esac
}

# Main menu loop
while true; do
    show_menu
    read -p "Presiona Enter para continuar..." 
done
