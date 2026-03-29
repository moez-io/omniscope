#!/bin/bash

# =============================================================================
# OMNISCOPE INTERACTIVE - Automated Bug Bounty Hunting Framework
# Author: Moez Ijaz
# Version: 1.2
# =============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Banner
banner() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                       ${RED}OMNISCOPE INTERACTIVE RECON${NC}                      ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
}

# Setup Target and Directory
setup_target() {
    echo -e "${YELLOW}[!] Setup Target${NC}"
    read -p "Enter Domain (e.g., google.com): " DOMAIN
    if [[ -z "$DOMAIN" ]]; then echo "Domain required!"; exit 1; fi
    
    RESULTS_DIR="./results_${DOMAIN//./_}"
    mkdir -p "$RESULTS_DIR"
    echo -e "${GREEN}[+] Results will be saved in: $RESULTS_DIR${NC}\n"
}

# The Menu
show_menu() {
    echo -e "${PURPLE}--- MAIN MENU ---${NC}"
    echo -e "${BLUE}1)${NC} Find Subdomains (Subfinder)"
    echo -e "${BLUE}2)${NC} Check which hosts are Live (Httpx)"
    echo -e "${BLUE}3)${NC} Scan Open Ports (Nmap)"
    echo -e "${BLUE}4)${NC} Scan Vulnerabilities (Nuclei)"
    echo -e "${BLUE}5)${NC} Identify Technologies (WhatWeb)"
    echo -e "${BLUE}6)${NC} Find Hidden Directories (Gobuster)"
    echo -e "${BLUE}7)${NC} Scan Web Server (Nikto)"
    echo -e "${BLUE}8)${NC} Scan for WordPress (WPScan)"
    echo -e "${BLUE}9)${NC} AUTOMATED SUITE (Run 1 to 4 automatically)"
    echo -e "${BLUE}10)${NC} Exit"
    echo ""
    read -p "Select an option [1-10]: " choice
}

# Main Logic
banner
setup_target

while true; do
    show_menu
    case $choice in
        1)
            echo -e "${YELLOW}[*] Running Subfinder...${NC}"
            subfinder -d "$DOMAIN" -o "$RESULTS_DIR/subdomains.txt"
            ;;
        2)
            echo -e "${YELLOW}[*] Running Httpx...${NC}"
            if [ ! -f "$RESULTS_DIR/subdomains.txt" ]; then echo "Run Option 1 first!"; else
            cat "$RESULTS_DIR/subdomains.txt" | httpx -o "$RESULTS_DIR/live_hosts.txt"; fi
            ;;
        3)
            echo -e "${YELLOW}[*] Running Nmap...${NC}"
            nmap -sV "$DOMAIN" -oN "$RESULTS_DIR/nmap_scan.txt"
            ;;
        4)
            echo -e "${YELLOW}[*] Running Nuclei...${NC}"
            nuclei -u "$DOMAIN" -o "$RESULTS_DIR/vulns.txt"
            ;;
        5)
            whatweb "$DOMAIN"
            ;;
        6)
            gobuster dir -u "http://$DOMAIN" -w /usr/share/wordlists/dirb/common.txt
            ;;
        7)
            nikto -h "$DOMAIN"
            ;;
        8)
            wpscan --url "$DOMAIN" --enumerate u
            ;;
        9)
            echo -e "${RED}[!] Starting Full Suite...${NC}"
            subfinder -d "$DOMAIN" -o "$RESULTS_DIR/subdomains.txt"
            cat "$RESULTS_DIR/subdomains.txt" | httpx -o "$RESULTS_DIR/live_hosts.txt"
            nmap -sV "$DOMAIN" -oN "$RESULTS_DIR/nmap_scan.txt"
            nuclei -l "$RESULTS_DIR/live_hosts.txt" -o "$RESULTS_DIR/vulns.txt"
            ;;
        10)
            echo "Exiting. Happy Hunting!"; exit 0
            ;;
        *)
            echo "Invalid choice."
            ;;
    esac
    echo -e "\n${GREEN}[✔] Task Finished.${NC}\n"
done
