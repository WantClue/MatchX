#! /bin/bash

#color codes
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE="\\033[38;5;27m"
SEA="\\033[38;5;49m"
GREEN='\033[1;32m'
CYAN='\033[1;36m'
NC='\033[0m'

#paths
crank_conf="/data/gloabl_conf_crankk.json"
global_conf="/data/gloabl_conf.json"
reset_id="/opt/MatchX/bin/reset_lgw_both.sh"
chip_id="/opt/MatchX/bin/chip_id"
dir_path="/etc/thingsix-forwarder"


function install() {
    echo -e "${GREEN}Module: Install ThingsIX${NC}"
	echo -e "${YELLOW}================================================================${NC}"
	if [[ "$USER" != "root" ]]; then
		echo -e "${CYAN}You are currently logged in as ${GREEN}$USER${NC}"
		echo -e "${CYAN}Please switch to the root account use command 'sudo su -'.${NC}"
		echo -e "${YELLOW}================================================================${NC}"
		echo -e "${NC}"
		exit
	fi
    if [ -d "$dir_path" ]; then
        echo -e "${CYAN}Directory exists${NC}"
    else
        echo -e "${RED}Directory does not exist${NC}"
        echo -e "${RED}Directory will be created ...${NC}"
        mkdir -p /etc/thingsix-forwarder
    fi

    # Downloading and extracting the ThingsIX forwarder
	cd /home/$USER
    mkdir thix
    cd /thix
    echo -e "${CYAN}Now we download the ThingsIX Forwarder.${NC}"
    wget https://github.com/ThingsIXFoundation/packet-handling/releases/download/v1.2.1/thingsix-forwarder-linux-arm64-v1.2.1.tar.gz
    tar -xvf thingsix-forwarder-linux-arm64-v1.2.1.tar.gz
    
    echo -e "${CYAN}Download completed now you can proceed with the next step.${NC}"
    echo -e "${CYAN}Run the same command again and choose option number 2 to onboard.${NC}"

}

function onboard() {
    echo -e "${GREEN}Module: Onboarding ThingsIX${NC}"
    echo -e "${CYAN}Now we will onboard your device onto the ThingsIX Network${NC}"
	echo -e "${YELLOW}================================================================${NC}"
    if [[ "$USER" != "root" ]]; then
		echo -e "${CYAN}You are currently logged in as ${GREEN}$USER${NC}"
		echo -e "${CYAN}Please switch to the root account use command 'sudo su -'.${NC}"
		echo -e "${YELLOW}================================================================${NC}"
		echo -e "${NC}"
		exit
	fi
    sleep 3

    if whiptail --yesno "Now we will start the forwarder and onboard it to your polygon address." 14 60; then
            id=$(sed -n 's/.*"gateway_ID": "\(.*\)",/\1/p' $global_conf)
            echo -e "${CYAN}Please enter your Polygon Wallet address to onboard this device to your Wallet${NC}"
            read wallet
    else
        echo "Aborted"
        exit
    fi

}

echo -e "${BLUE}"
figlet -f slant "Toolbox"
echo -e "${YELLOW}================================================================${NC}"
echo -e "${GREEN}OS: MatchX ${NC}"
echo -e "${GREEN}Created by: WantClue${NC}"
echo -e "${YELLOW}================================================================${NC}"
echo -e "${CYAN}1  - Installation of ThingsIX forwarder${NC}"
echo -e "${CYAN}2  - Onboarding of ThingsIX Gateway${NC}"
echo -e "${CYAN}3  - Abort${NC}"
echo -e "${YELLOW}================================================================${NC}"

read -rp "Pick an option and hit ENTER: "
case "$REPLY" in
 1)  
		clear
		sleep 1
		install
 ;;
 2) 
		clear
		sleep 1
		Onboarding
 ;;
 3) 
		clear
		sleep 1
		exit
 ;;
esac