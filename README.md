# KaliCup - Complete Security Suite Installer

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Linux-blue.svg)](https://www.linux.org/)
[![Tools](https://img.shields.io/badge/Tools-60+-green.svg)](#tools-included)

> ⚠️ **LEGAL DISCLAIMER**: This tool is for educational and authorized security testing purposes only. Only use on systems you own or have explicit permission to test. Unauthorized use may violate laws and regulations.

## 🎯 What is KaliCup?

KaliCup is a comprehensive security tools installer that transforms any Linux distribution into a powerful penetration testing platform. It automatically installs and configures 60+ essential security tools across 14 different categories, essentially giving you a Kali Linux-like experience on any Linux system.

## 🚀 Quick Start

### Prerequisites
- Linux system (Ubuntu, Debian, Fedora, or Arch Linux)
- Internet connection
- At least 10GB free disk space
- sudo privileges

### Installation

1. **Download KaliCup:**
   ```bash
   curl -O https://raw.githubusercontent.com/10xrashed/KaliCup/main/kalicup.sh
   ```

2. **Make it executable:**
   ```bash
   chmod +x kalicup.sh
   ```

3. **Run the installer:**
   ```bash
   ./kalicup.sh
   ```

4. **Follow the prompts:**
   - Read and accept the legal terms
   - The script will automatically detect your distribution
   - Installation takes 30-60 minutes depending on your system

5. **Reload your environment:**
   ```bash
   source ~/.bashrc
   # OR restart your terminal
   ```

## 📁 Directory Structure

After installation, your security tools will be organized as follows:

```
~/security-tools/                 # Main tools directory
├── Sublist3r/                   # Subdomain enumeration
├── theHarvester/                # OSINT gathering
├── XSStrike/                    # XSS detection
├── NoSQLMap/                    # NoSQL injection
├── wifite2/                     # Automated wireless attacks
├── beef/                        # Browser exploitation
├── setoolkit/                   # Social engineering
├── weevely3/                    # PHP webshell
├── PEASS-ng/                    # Privilege escalation
└── ...and many more

/usr/share/wordlists/            # Password lists and dictionaries
├── rockyou.txt                  # Common passwords
└── ...other wordlists
```

## 🛠️ Tools Included

### 1. Information Gathering
| Tool | Purpose | Usage Example |
|------|---------|---------------|
| **nmap** | Network scanning | `nmap -sC -sV target.com` |
| **netdiscover** | ARP scanner | `netdiscover -r 192.168.1.0/24` |
| **sublist3r** | Subdomain enumeration | `sublist3r -d target.com` |
| **amass** | Advanced subdomain enum | `amass enum -d target.com` |
| **theharvester** | OSINT gathering | `theharvester -d target.com -b google` |
| **whatweb** | Web technology ID | `whatweb target.com` |
| **whois** | Domain information | `whois target.com` |
| **recon-ng** | Reconnaissance framework | `recon-ng` |

### 2. Vulnerability Analysis
| Tool | Purpose | Usage Example |
|------|---------|---------------|
| **nikto** | Web server scanner | `nikto -h http://target.com` |
| **wpscan** | WordPress scanner | `wpscan --url http://target.com` |
| **lynis** | System hardening audit | `lynis audit system` |
| **nmap NSE** | Vulnerability scripts | `nmap --script vuln target.com` |

### 3. Web Application Analysis
| Tool | Purpose | Usage Example |
|------|---------|---------------|
| **gobuster** | Directory brute-force | `gobuster dir -u http://target.com -w /usr/share/wordlists/dirb/common.txt` |
| **sqlmap** | SQL injection | `sqlmap -u "http://target.com?id=1"` |
| **ffuf** | Fast web fuzzer | `ffuf -u http://target.com/FUZZ -w wordlist.txt` |
| **xsstrike** | XSS scanner | `xsstrike -u http://target.com?q=query` |
| **zaproxy** | Web proxy | `zaproxy` |

### 4. Password Attacks
| Tool | Purpose | Usage Example |
|------|---------|---------------|
| **john** | Password cracking | `john --wordlist=/usr/share/wordlists/rockyou.txt hashes.txt` |
| **hashcat** | GPU password cracking | `hashcat -m 0 -a 0 hashes.txt wordlist.txt` |
| **hydra** | Network login brute-force | `hydra -l admin -P passwords.txt ssh://target.com` |
| **crunch** | Wordlist generator | `crunch 8 8 -t pass%%%% -o wordlist.txt` |

### 5. Wireless Attacks
| Tool | Purpose | Usage Example |
|------|---------|---------------|
| **aircrack-ng** | WPA/WPA2 cracking | `aircrack-ng -w wordlist.txt capture.cap` |
| **wifite** | Automated wireless attacks | `wifite` |
| **reaver** | WPS attack | `reaver -i wlan0mon -b AA:BB:CC:DD:EE:FF` |

### 6. Exploitation Tools
| Tool | Purpose | Usage Example |
|------|---------|---------------|
| **metasploit** | Exploitation framework | `msfconsole` |
| **searchsploit** | Exploit database search | `searchsploit apache 2.4` |
| **beef** | Browser exploitation | `beef` (then navigate to web interface) |

### 7. Forensics & Analysis
| Tool | Purpose | Usage Example |
|------|---------|---------------|
| **binwalk** | Firmware analysis | `binwalk -e firmware.bin` |
| **volatility** | Memory forensics | `vol.py -f memory.dump imageinfo` |
| **foremost** | File carving | `foremost -i disk.img` |
| **exiftool** | Metadata analysis | `exiftool image.jpg` |

## 🎮 Quick Start Commands

### Essential Aliases (Available after installation)
```bash
# Navigation
tools              # Go to security tools directory
wordlists          # Go to wordlists directory

# Quick scans
nmap-quick IP      # Fast port scan
nmapall IP         # Comprehensive scan with scripts
portscan IP        # Scan all ports

# Common tasks
dirsearch URL      # Directory brute-force
sublist3r          # Launch Sublist3r
theharvester       # Launch theHarvester
```

### Example Penetration Testing Workflow

#### 1. Information Gathering
```bash
# Subdomain enumeration
sublist3r -d target.com -o subdomains.txt

# Port scanning
nmap-quick target.com
nmapall target.com

# Web technology identification
whatweb target.com

# OSINT gathering
theharvester -d target.com -b all
```

#### 2. Vulnerability Analysis
```bash
# Web vulnerability scan
nikto -h http://target.com

# WordPress scan (if applicable)
wpscan --url http://target.com --enumerate u,p,t

# Nmap vulnerability scan
nmap --script vuln target.com
```

#### 3. Web Application Testing
```bash
# Directory brute-force
gobuster dir -u http://target.com -w /usr/share/wordlists/dirb/common.txt

# SQL injection testing
sqlmap -u "http://target.com/page.php?id=1" --batch

# XSS testing
xsstrike -u "http://target.com/search.php?q=test"
```

#### 4. Password Attacks
```bash
# Generate custom wordlist
cewl http://target.com -w custom_wordlist.txt

# Hash cracking
john --wordlist=/usr/share/wordlists/rockyou.txt hashes.txt

# Service brute-force
hydra -l admin -P passwords.txt ssh://target.com
```

## ⚙️ Configuration

### Setting up Wireshark (Non-root usage)
```bash
sudo usermod -a -G wireshark $USER
# Logout and login again
```

### Burp Suite Setup
1. Download Burp Suite Community from PortSwigger
2. Install Java if not already installed
3. Run: `java -jar burpsuite_community.jar`

### Metasploit Database Setup
```bash
sudo systemctl start postgresql
sudo msfdb init
msfconsole
```

## 🔧 Troubleshooting

### Common Issues

1. **Permission denied errors:**
   ```bash
   sudo usermod -a -G wireshark $USER
   newgrp wireshark
   ```

2. **Tools not found in PATH:**
   ```bash
   source ~/.bashrc
   # Or restart terminal
   ```

3. **Python package conflicts:**
   ```bash
   pip3 install --user --break-system-packages package_name
   ```

4. **Go tools not working:**
   ```bash
   export PATH=$PATH:$HOME/go/bin
   ```

### Manual Tool Installation

Some tools require manual installation:

**Ghidra:**
1. Download from: https://ghidra-sre.org/
2. Extract and run: `./ghidraRun`

**Burp Suite:**
1. Download from: https://portswigger.net/burp/communitydownload
2. Install and run

## 🎓 Learning Resources

### Recommended Practice Platforms
- **VulnHub**: Vulnerable VMs for practice
- **TryHackMe**: Guided learning paths
- **Hack The Box**: Challenge-based learning
- **OverTheWire**: Wargames for beginners
- **DVWA**: Damn Vulnerable Web Application

### Books & Documentation
- "The Web Application Hacker's Handbook"
- "Metasploit: The Penetration Tester's Guide"
- "Black Hat Python"
- OWASP Testing Guide
- NIST Cybersecurity Framework

### Certification Paths
- **CEH** (Certified Ethical Hacker)
- **OSCP** (Offensive Security Certified Professional)
- **CISSP** (Certified Information Systems Security Professional)
- **Security+** (CompTIA Security+)

## 🔒 Legal and Ethical Guidelines

### ✅ Legal Use Cases
- Testing your own systems and networks
- Authorized penetration testing with written permission
- Educational purposes in controlled environments
- Bug bounty programs with proper scope
- Academic research with institutional approval

### ❌ Illegal Activities (DO NOT)
- Testing systems without permission
- Accessing unauthorized networks or data
- Disrupting services or systems
- Stealing or exposing sensitive information
- Using tools for malicious purposes

### Best Practices
1. **Always get written permission** before testing
2. **Understand the scope** of your testing
3. **Document everything** during assessments
4. **Follow responsible disclosure** for vulnerabilities
5. **Respect privacy and confidentiality**
6. **Stay updated** on laws and regulations

## 🤝 Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch
3. Test your changes thoroughly
4. Submit a pull request with clear description
5. Follow our coding standards

### Adding New Tools
To add a new tool to KaliCup:

1. Add installation commands to the appropriate category function
2. Update the aliases section if needed
3. Add documentation to this README
4. Test on multiple distributions

## 📞 Support
- **GitHub Issues**: Report bugs and request features
## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

*   **Original Author:** [10xrashed](https://github.com/10xrashed)
## 🙏 Acknowledgments

Special thanks to:
- The Kali Linux team for inspiration
- All open-source security tool developers
- The information security community
- Contributors and testers

---

**Remember: With great power comes great responsibility. Use these tools ethically and legally.**

**Happy (Ethical) Hacking! 🛡️🔍**
