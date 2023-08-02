#!/bin/bash

#color codes
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE="\\033[38;5;27m"
SEA="\\033[38;5;49m"
GREEN='\033[1;32m'
CYAN='\033[1;36m'
NC='\033[0m'

#paths
crank_conf="/data/global_conf_crankk.json" #keeping this for future crankk uninstallation
global_conf="/data/global_conf.json"
thix_conf="/data/global_conf_thix.json"
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
    # Disabling MatchX services
    sed -i 's,/bin/bash,/bin/true,' /opt/MatchX/bin/start_daemon.sh

    # Disabling firmware update helper script
    test -f /opt/MatchX/bin/start_upgrade.sh && mv /opt/MatchX/bin/start_upgrade.sh /opt/MatchX/bin/start_upgrade_manual.sh

    # Downloading and extracting the ThingsIX forwarder
	cd /home/$USER
    mkdir thix
    cd /home/$USER/thix
    echo -e "${CYAN}Now we download the ThingsIX Forwarder.${NC}"
    wget https://github.com/ThingsIXFoundation/packet-handling/releases/download/v1.2.1/thingsix-forwarder-linux-arm64-v1.2.1.tar.gz
    tar -xvf thingsix-forwarder-linux-arm64-v1.2.1.tar.gz
    

    echo "${CYAN}Creating LoRa packet forwarder startup script...${NC}"
    cp /data/global_conf.json /data/global_conf_thix.json

    # Changing the server address and port to localhost for the forwarding process
    sed -i 's/"server_address": ".*",/"server_address": "127.0.0.1",/' $global_conf_thix
    sed -i 's/"serv_port_up": [0-9]*,/"serv_port_up": 1680,/' $global_conf_thix
    sed -i 's/"serv_port_down": [0-9]*,/"serv_port_down": 1680,/' $global_conf_thix
    

    lora_script_content='
    #!/bin/bash

    cd /opt/MatchX/bin/
    while true; do
        ./reset_lgw_both.sh start
        ./lora_pkt_fwd -c /data/global_conf_thix.json
        sleep 5
    done &> /dev/null &
    '
    echo "${lora_script_content}" > /opt/MatchX/bin/lora_pkt_fwd.sh
    chmod +x /opt/MatchX/bin/lora_pkt_fwd.sh
    grep -q lora_pkt_fwd.sh /etc/init.d/mx190x-startup.sh || sed -ri 's,(/opt/MatchX/web_server/start_server.sh),\1\n    /opt/MatchX/bin/lora_pkt_fwd.sh,' /etc/init.d/mx190x-startup.sh
    echo -e "${CYAN}Download completed now you can proceed with the next step.${NC}"
    echo -e "${CYAN}Run the same command again and choose option number 2 to onboard.${NC}"
    echo "${CYAN}We need to reboot now.${NC}"

    sleep 10
    reboot
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

    id=$(sed -n 's/.*"gateway_ID": "\(.*\)",/\1/p' $global_conf)
    echo "Your local Id is $id"
    echo -e "${CYAN}Please enter your Polygon Wallet address to onboard this device to your Wallet${NC}"
    read wallet
    cd /home/$USER/thix
    ./forwarder gateway onboard-and-push $id $wallet

}


echo -e "${BLUE}"
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
		onboard
 ;;
 3) 
		clear
		sleep 1
		exit
 ;;
esac