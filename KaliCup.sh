#!/bin/bash

set -e
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

print_banner() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════╗"
    echo "║              KaliCup                 ║"
    echo "║   Complete Security Suite Installer  ║"
    echo "╚══════════════════════════════════════╝"
    echo -e "${NC}"
}

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

section() {
    echo -e "${PURPLE}[SECTION]${NC} $1"
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        warn "Running as root. Some tools may not work properly."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        VERSION=$VERSION_ID
    else
        error "Cannot detect distribution"
        exit 1
    fi
    log "Detected: $PRETTY_NAME"
}

update_system() {
    log "Updating system packages and installing prerequisites..."
    case $DISTRO in
        ubuntu|debian)
            sudo apt update && sudo apt upgrade -y
            sudo apt install -y curl wget git build-essential python3 python3-pip \
                python3-dev libssl-dev libffi-dev libxml2-dev libxslt1-dev \
                zlib1g-dev cmake make gcc g++ default-jdk nodejs npm \
                apt-transport-https ca-certificates gnupg lsb-release
            ;;
        fedora)
            sudo dnf update -y
            sudo dnf install -y curl wget git gcc make python3 python3-pip \
                python3-devel openssl-devel libffi-devel libxml2-devel \
                libxslt-devel zlib-devel cmake java-openjdk nodejs npm
            ;;
        arch)
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm curl wget git base-devel python python-pip \
                openssl libffi libxml2 libxslt zlib cmake jdk-openjdk nodejs npm
            ;;
        *)
            warn "Unsupported distribution. Manual installation may be required."
            ;;
    esac
}

install_python_deps() {
    log "Installing Python security libraries..."
    pip3 install --user --break-system-packages \
        requests beautifulsoup4 scapy paramiko pycrypto colorama urllib3 \
        selenium dnspython python-nmap python-whois netaddr ipaddress \
        shodan censys pwntools ropper capstone keystone-engine unicorn \
        volatility3 yara-python pytesseract pillow matplotlib networkx \
        flask django tornado
}

install_info_gathering() {
    section "Installing Information Gathering Tools..."
    
    case $DISTRO in
        ubuntu|debian)
            sudo apt install -y nmap netdiscover whois dnsutils
            ;;
        fedora)
            sudo dnf install -y nmap netdiscover whois bind-utils
            ;;
        arch)
            sudo pacman -S --noconfirm nmap netdiscover whois bind-tools
            ;;
    esac
    
    mkdir -p ~/security-tools
    cd ~/security-tools
    
    log "Installing DNS enumeration tools..."
    
    if [ ! -d "dnsenum" ]; then
        git clone https://github.com/fwaeytens/dnsenum.git
        cd dnsenum && chmod +x dnsenum.pl && cd ..
    fi
    
    pip3 install --user --break-system-packages fierce
    
    if [ ! -d "Sublist3r" ]; then
        git clone https://github.com/aboul3la/Sublist3r.git
        cd Sublist3r && pip3 install --user --break-system-packages -r requirements.txt && cd ..
    fi
    
    if ! command -v amass &> /dev/null; then
        log "Installing Amass..."
        case $DISTRO in
            ubuntu|debian)
                sudo apt install -y snapd
                sudo snap install amass
                ;;
            *)
                if ! command -v go &> /dev/null; then
                    case $DISTRO in
                        fedora) sudo dnf install -y golang ;;
                        arch) sudo pacman -S --noconfirm go ;;
                    esac
                fi
                go install -v github.com/OWASP/Amass/v3/...@master
                ;;
        esac
    fi
    
    if [ ! -d "WhatWeb" ]; then
        git clone https://github.com/urbanadventurer/WhatWeb.git
    fi
    
    if [ ! -d "theHarvester" ]; then
        git clone https://github.com/laramies/theHarvester.git
        cd theHarvester && pip3 install --user --break-system-packages -r requirements.txt && cd ..
    fi
    
    pip3 install --user --break-system-packages recon-ng
    
    cd ~
}

install_vulnerability_analysis() {
    section "Installing Vulnerability Analysis Tools..."
    
    case $DISTRO in
        ubuntu|debian)
            sudo apt install -y nikto lynis
            ;;
        fedora)
            sudo dnf install -y nikto lynis
            ;;
        arch)
            sudo pacman -S --noconfirm nikto lynis
            ;;
    esac
    
    cd ~/security-tools
    
    if ! command -v wpscan &> /dev/null; then
        log "Installing WPScan..."
        gem install wpscan || pip3 install --user --break-system-packages wpscan
    fi
    
    log "OpenVAS requires manual setup. Install with: sudo apt install openvas"
    
    cd ~
}

install_web_analysis() {
    section "Installing Web Application Analysis Tools..."
    
    case $DISTRO in
        ubuntu|debian)
            sudo apt install -y dirb gobuster sqlmap zaproxy
            ;;
        fedora)
            sudo dnf install -y dirb gobuster sqlmap zaproxy
            ;;
        arch)
            sudo pacman -S --noconfirm gobuster sqlmap
            ;;
    esac
    
    cd ~/security-tools
    
    log "BurpSuite Community requires manual download from PortSwigger"
    
    if ! command -v ffuf &> /dev/null; then
        log "Installing ffuf..."
        if command -v go &> /dev/null; then
            go install github.com/ffuf/ffuf@latest
        fi
    fi
    
    pip3 install --user --break-system-packages wfuzz
    
    if [ ! -d "XSStrike" ]; then
        git clone https://github.com/s0md3v/XSStrike.git
        cd XSStrike && pip3 install --user --break-system-packages -r requirements.txt && cd ..
    fi
    
    cd ~
}

install_database_tools() {
    section "Installing Database Assessment Tools..."
    
    cd ~/security-tools
    
    if [ ! -f "jsql-injection.jar" ]; then
        log "Downloading jSQL Injection..."
        wget -O jsql-injection.jar https://github.com/ron190/jsql-injection/releases/latest/download/jsql-injection-v0.82.jar
    fi
    
    if [ ! -d "NoSQLMap" ]; then
        git clone https://github.com/codingo/NoSQLMap.git
        cd NoSQLMap && pip3 install --user --break-system-packages -r requirements.txt && cd ..
    fi
    
    cd ~
}

install_password_tools() {
    section "Installing Password Attack Tools..."
    
    case $DISTRO in
        ubuntu|debian)
            sudo apt install -y john hashcat hydra medusa crunch
            ;;
        fedora)
            sudo dnf install -y john hashcat hydra medusa
            ;;
        arch)
            sudo pacman -S --noconfirm john hashcat hydra medusa
            ;;
    esac
    
    cd ~/security-tools
    
    if [ ! -d "CeWL" ]; then
        git clone https://github.com/digininja/CeWL.git
    fi
    
    sudo mkdir -p /usr/share/wordlists
    if [ ! -d "/usr/share/wordlists/rockyou.txt.gz" ]; then
        log "Downloading common wordlists..."
        sudo wget -O /usr/share/wordlists/rockyou.txt.gz https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt
    fi
    
    cd ~
}

install_wireless_tools() {
    section "Installing Wireless Attack Tools..."
    
    case $DISTRO in
        ubuntu|debian)
            sudo apt install -y aircrack-ng reaver mdk3 kismet
            ;;
        fedora)
            sudo dnf install -y aircrack-ng reaver kismet
            ;;
        arch)
            sudo pacman -S --noconfirm aircrack-ng reaver kismet
            ;;
    esac
    
    cd ~/security-tools
    
    if [ ! -d "wifite2" ]; then
        git clone https://github.com/derv82/wifite2.git
        cd wifite2 && sudo python3 setup.py install && cd ..
    fi
    
    pip3 install --user --break-system-packages wifiphisher
    
    cd ~
}

install_reverse_engineering() {
    section "Installing Reverse Engineering Tools..."
    
    case $DISTRO in
        ubuntu|debian)
            sudo apt install -y binwalk radare2
            ;;
        fedora)
            sudo dnf install -y binwalk radare2
            ;;
        arch)
            sudo pacman -S --noconfirm binwalk radare2
            ;;
    esac
    
    cd ~/security-tools
    
    log "Ghidra requires manual download from NSA GitHub releases"
    
    if [ ! -d "cutter" ]; then
        log "Installing Cutter (Radare2 GUI)..."
        case $DISTRO in
            ubuntu|debian)
                wget -O cutter.AppImage https://github.com/rizinorg/cutter/releases/latest/download/Cutter-v2.0.5-x64.Linux.AppImage
                chmod +x cutter.AppImage
                ;;
        esac
    fi
    
    if [ ! -f "apktool.jar" ]; then
        wget -O apktool.jar https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool
        chmod +x apktool.jar
    fi
    
    cd ~
}

install_exploitation_tools() {
    section "Installing Exploitation Tools..."
    
    if ! command -v msfconsole &> /dev/null; then
        log "Installing Metasploit Framework..."
        curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
        chmod 755 msfinstall
        sudo ./msfinstall
        rm msfinstall
    fi
    
    cd ~/security-tools
    
    if [ ! -d "exploitdb" ]; then
        git clone https://github.com/offensive-security/exploitdb.git
        sudo ln -sf ~/security-tools/exploitdb/searchsploit /usr/local/bin/searchsploit
    fi
    
    if [ ! -d "beef" ]; then
        git clone https://github.com/beefproject/beef.git
        cd beef && bundle install && cd ..
    fi
    
    if [ ! -d "routersploit" ]; then
        git clone https://github.com/threat9/routersploit.git
        cd routersploit && pip3 install --user --break-system-packages -r requirements.txt && cd ..
    fi
    
    cd ~
}

install_sniffing_tools() {
    section "Installing Sniffing & Spoofing Tools..."
    
    case $DISTRO in
        ubuntu|debian)
            sudo apt install -y wireshark tcpdump ettercap-text-only dsniff
            ;;
        fedora)
            sudo dnf install -y wireshark tcpdump ettercap dsniff
            ;;
        arch)
            sudo pacman -S --noconfirm wireshark-qt tcpdump ettercap dsniff
            ;;
    esac
    
    sudo usermod -a -G wireshark $USER
    
    cd ~/security-tools
    
    if ! command -v bettercap &> /dev/null; then
        log "Installing Bettercap..."
        if command -v go &> /dev/null; then
            go install github.com/bettercap/bettercap@latest
        fi
    fi
    
    if [ ! -d "Responder" ]; then
        git clone https://github.com/lgandx/Responder.git
    fi
    
    cd ~
}

install_post_exploitation() {
    section "Installing Post Exploitation Tools..."
    
    cd ~/security-tools
    
    if [ ! -d "PowerSploit" ]; then
        git clone https://github.com/PowerShellMafia/PowerSploit.git
    fi
    
    if [ ! -d "Empire" ]; then
        git clone https://github.com/EmpireProject/Empire.git
        cd Empire && sudo ./setup/install.sh && cd ..
    fi
    
    log "Mimikatz and Meterpreter are Windows-specific and included in other frameworks"
    
    cd ~
}

install_forensics_tools() {
    section "Installing Forensics Tools..."
    
    case $DISTRO in
        ubuntu|debian)
            sudo apt install -y autopsy foremost scalpel binwalk exiftool volatility
            ;;
        fedora)
            sudo dnf install -y autopsy foremost scalpel binwalk perl-Image-ExifTool
            ;;
        arch)
            sudo pacman -S --noconfirm autopsy foremost scalpel binwalk exiftool
            ;;
    esac
    
    pip3 install --user --break-system-packages volatility3
}

install_social_engineering() {
    section "Installing Social Engineering Tools..."
    
    cd ~/security-tools
    
    if [ ! -d "setoolkit" ]; then
        git clone https://github.com/trustedsec/social-engineer-toolkit.git setoolkit
        cd setoolkit && pip3 install --user --break-system-packages -r requirements.txt && cd ..
    fi
    
    if [ ! -d "king-phisher" ]; then
        git clone https://github.com/rsmusllp/king-phisher.git
    fi
    
    cd ~
}

install_maintaining_access() {
    section "Installing Maintaining Access Tools..."
    
    case $DISTRO in
        ubuntu|debian)
            sudo apt install -y netcat socat
            ;;
        fedora)
            sudo dnf install -y nc socat
            ;;
        arch)
            sudo pacman -S --noconfirm gnu-netcat socat
            ;;
    esac
    
    cd ~/security-tools
    
    if [ ! -d "weevely3" ]; then
        git clone https://github.com/epinna/weevely3.git
        cd weevely3 && pip3 install --user --break-system-packages -r requirements.txt && cd ..
    fi
    
    if [ ! -d "tunna" ]; then
        git clone https://github.com/SECFORCE/tunna.git
    fi
    
    cd ~
}

install_privilege_escalation() {
    section "Installing Privilege Escalation Tools..."
    
    cd ~/security-tools
    
    if [ ! -d "PEASS-ng" ]; then
        git clone https://github.com/carlospolop/PEASS-ng.git
    fi
    
    if [ ! -d "linux-exploit-suggester" ]; then
        git clone https://github.com/mzet-/linux-exploit-suggester.git
    fi
    
    if [ ! -d "GTFOBins" ]; then
        git clone https://github.com/GTFOBins/GTFOBins.github.io.git GTFOBins
    fi
    
    cd ~
}

setup_environment() {
    log "Setting up environment and aliases..."
    
    cp ~/.bashrc ~/.bashrc.backup.$(date +%Y%m%d)
    
    cat >> ~/.bashrc << 'EOF'

export TOOLS_DIR="$HOME/security-tools"
export WORDLISTS_DIR="/usr/share/wordlists"

alias ll='ls -la'
alias la='ls -la'
alias grep='grep --color=auto'
alias myip='curl -s checkip.amazonaws.com'
alias localip='hostname -I'
alias ports='netstat -tulanp'
alias listening='netstat -tulanp | grep LISTEN'

alias nse='ls /usr/share/nmap/scripts/ | grep'
alias nmap-quick='nmap -T4 -F'
alias nmap-intense='nmap -T4 -A -v'
alias nmap-ping='nmap -sn'

alias tools='cd $TOOLS_DIR'
alias seclists='cd $TOOLS_DIR/SecLists'
alias payloads='cd $TOOLS_DIR/PayloadsAllTheThings'
alias wordlists='cd $WORDLISTS_DIR'

alias sublist3r='python3 $TOOLS_DIR/Sublist3r/sublist3r.py'
alias theharvester='python3 $TOOLS_DIR/theHarvester/theHarvester.py'
alias whatweb='$TOOLS_DIR/WhatWeb/whatweb'
alias dnsenum='perl $TOOLS_DIR/dnsenum/dnsenum.pl'

alias xsstrike='python3 $TOOLS_DIR/XSStrike/xsstrike.py'
alias jsql='java -jar $TOOLS_DIR/jsql-injection.jar'
alias nosqlmap='python3 $TOOLS_DIR/NoSQLMap/nosqlmap.py'

alias wifite='python3 $TOOLS_DIR/wifite2/Wifite.py'

alias cutter='$TOOLS_DIR/cutter.AppImage'

alias searchsploit='$TOOLS_DIR/exploitdb/searchsploit'
alias beef='cd $TOOLS_DIR/beef && ./beef'
alias routersploit='cd $TOOLS_DIR/routersploit && python3 rsf.py'

alias responder='python3 $TOOLS_DIR/Responder/Responder.py'

alias setoolkit='cd $TOOLS_DIR/setoolkit && python3 setoolkit.py'

alias weevely='python3 $TOOLS_DIR/weevely3/weevely.py'

alias linpeas='bash $TOOLS_DIR/PEASS-ng/linPEAS/linpeas.sh'
alias linux-exploit-suggester='bash $TOOLS_DIR/linux-exploit-suggester/linux-exploit-suggester.sh'

alias cewl='ruby $TOOLS_DIR/CeWL/cewl.rb'

nmapall() { nmap -sC -sV -O -A -T4 $1; }
dirsearch() { gobuster dir -u $1 -w /usr/share/wordlists/dirb/common.txt; }
portscan() { nmap -p- -T4 $1; }

echo "KaliCup environment loaded! Use 'tools' to navigate to security tools directory"
echo "Type 'alias | grep -E \"(nmap|sub|the|what|dns)\"' to see available shortcuts"
EOF

    mkdir -p ~/.local/share/applications
    
    source ~/.bashrc || true
}

install_go() {
    if ! command -v go &> /dev/null; then
        log "Installing Go programming language..."
        case $DISTRO in
            ubuntu|debian)
                sudo apt install -y golang-go
                ;;
            fedora)
                sudo dnf install -y golang
                ;;
            arch)
                sudo pacman -S --noconfirm go
                ;;
        esac
        
        echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
    fi
}

install_ruby() {
    if ! command -v ruby &> /dev/null; then
        log "Installing Ruby..."
        case $DISTRO in
            ubuntu|debian)
                sudo apt install -y ruby-full rubygems
                ;;
            fedora)
                sudo dnf install -y ruby rubygems
                ;;
            arch)
                sudo pacman -S --noconfirm ruby rubygems
                ;;
        esac
    fi
}

print_summary() {
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║                KaliCup Installation Complete             ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${CYAN}Installed Tool Categories:${NC}"
    echo "• Information Gathering (nmap, amass, sublist3r, theharvester, etc.)"
    echo "• Vulnerability Analysis (nikto, openvas, wpscan, lynis)"
    echo "• Web Application Analysis (burpsuite, zap, dirb, sqlmap, xsstrike)"
    echo "• Database Assessment (sqlmap, jsql-injection, nosqlmap)"
    echo "• Password Attacks (john, hashcat, hydra, crunch, cewl)"
    echo "• Wireless Attacks (aircrack-ng, wifite, wifiphisher)"
    echo "• Reverse Engineering (ghidra, radare2, binwalk)"
    echo "• Exploitation Tools (metasploit, beef, routersploit)"
    echo "• Sniffing & Spoofing (wireshark, ettercap, bettercap, responder)"
    echo "• Post Exploitation (empire, powersploit, meterpreter)"
    echo "• Forensics (autopsy, volatility, foremost, binwalk)"
    echo "• Social Engineering (setoolkit, king-phisher)"
    echo "• Maintaining Access (weevely, netcat, tunna)"
    echo "• Privilege Escalation (linpeas, linux-exploit-suggester)"
    echo
    echo -e "${YELLOW}Directory Structure:${NC}"
    echo "• Security tools: ~/security-tools/"
    echo "• Wordlists: /usr/share/wordlists/"
    echo "• Aliases and shortcuts configured in ~/.bashrc"
    echo
    echo -e "${PURPLE}Quick Start Commands:${NC}"
    echo "• tools          - Navigate to tools directory"
    echo "• nmap-quick IP  - Quick port scan"
    echo "• nmapall IP     - Comprehensive scan"
    echo "• sublist3r      - Subdomain enumeration"
    echo "• dirsearch URL  - Directory brute force"
    echo
    echo -e "${BLUE}Post-Installation Steps:${NC}"
    echo "1. Restart terminal or run: source ~/.bashrc"
    echo "2. Add user to wireshark group: sudo usermod -a -G wireshark \$USER"
    echo "3. Download BurpSuite Community from PortSwigger"
    echo "4. Download Ghidra from NSA GitHub releases"
    echo "5. Configure OpenVAS: sudo gvm-setup (if installed)"
    echo
    echo -e "${RED}CRITICAL LEGAL REMINDER:${NC}"
    echo "• These tools are for EDUCATIONAL and AUTHORIZED testing ONLY"
    echo "• Only use on systems you own or have explicit permission"
    echo "• Unauthorized use violates laws and regulations"
    echo "• Always follow responsible disclosure practices"
    echo
    echo -e "${GREEN}Total tools installed: 60+ security tools across 14 categories${NC}"
}

main() {
    print_banner
    
    echo -e "${RED}╔══════════════════════════════════════════════════════════╗"
    echo -e "║                    LEGAL WARNING                         ║"
    echo -e "╠══════════════════════════════════════════════════════════╣"
    echo -e "║ This installer provides advanced security testing tools. ║"
    echo -e "║ These tools can be used for illegal activities.          ║"
    echo -e "║                                                          ║"
    echo -e "║ BY CONTINUING, YOU AGREE TO:                             ║"
    echo -e "║ • Use these tools ONLY on systems you own                ║"
    echo -e "║ • Use these tools ONLY with explicit permission          ║"
    echo -e "║ • Follow all local, state, and federal laws              ║"
    echo -e "║ • Practice responsible disclosure                        ║"
    echo -e "║ • Take full responsibility for your actions              ║"
    echo -e "╚══════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${YELLOW}This installation includes tools for:${NC}"
    echo "• Network penetration testing"
    echo "• Web application security testing" 
    echo "• Wireless security assessment"
    echo "• Digital forensics"
    echo "• Reverse engineering"
    echo "• Social engineering (educational)"
    echo
    read -p "Do you understand and agree to these terms? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled. Stay legal!"
        exit 1
    fi
    
    echo
    log "Starting comprehensive security tools installation..."
    
    check_root
    detect_distro
    update_system
    install_go
    install_ruby
    install_python_deps
    install_info_gathering
    install_vulnerability_analysis
    install_web_analysis
    install_database_tools
    install_password_tools
    install_wireless_tools
    install_reverse_engineering
    install_exploitation_tools
    install_sniffing_tools
    install_post_exploitation
    install_forensics_tools
    install_social_engineering
    install_maintaining_access
    install_privilege_escalation
    setup_environment
    print_summary
    
    log "KaliCup installation completed successfully!"
    echo "Please restart your terminal or run 'source ~/.bashrc' to load the new environment."
}

main "$@"
