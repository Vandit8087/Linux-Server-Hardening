# Commands Executed - Linux Server Hardening

## Pre-Hardening Assessment Commands

### System Information Gathering
```bash
# System details
uname -a
lsb_release -a
whoami && id
uptime

# Network configuration
ip addr show
ip route show
netstat -tulpn
ss -tulpn

# Process and service analysis
ps aux
systemctl list-units --type=service --state=running
systemctl list-units --failed

# User account review
cat /etc/passwd | grep -v nologin
last -n 20
lastlog | grep -v "Never"
w

# File system security check
find / -type f -perm -002 2>/dev/null | head -20
find / -type f -perm -4000 -o -perm -2000 2>/dev/null
```

### Security Baseline Assessment
```bash
# Check current security settings
sudo cat /etc/ssh/sshd_config | grep -v "^#" | grep -v "^$"
sudo ufw status verbose
systemctl status fail2ban 2>/dev/null || echo "fail2ban not installed"

# Network security scan
nmap -sS localhost
nmap -sU -p 53,67,68,123,161 localhost

# Log file analysis
sudo tail -50 /var/log/auth.log
sudo tail -50 /var/log/syslog
sudo grep -i "failed" /var/log/auth.log | tail -10
```

## SSH Hardening Commands

### SSH Configuration Backup
```bash
# Create backup directory
sudo mkdir -p /backup/ssh
sudo cp /etc/ssh/sshd_config /backup/ssh/sshd_config.$(date +%Y%m%d_%H%M%S)

# Verify current SSH settings
sudo sshd -T | grep -E "(port|permitrootlogin|passwordauthentication|pubkeyauthentication)"
```

### SSH Configuration Changes
```bash
# Edit SSH configuration
sudo nano /etc/ssh/sshd_config

# Key changes made:
# PermitRootLogin no
# PasswordAuthentication no  
# PubkeyAuthentication yes
# Port 2022
# MaxAuthTries 3
# ClientAliveInterval 300
# ClientAliveCountMax 2

# Test configuration syntax
sudo sshd -t

# Restart SSH service
sudo systemctl restart sshd
sudo systemctl status sshd
```

## Firewall Configuration Commands

### UFW Installation and Setup
```bash
# Install UFW (if not present)
sudo apt update
sudo apt install ufw

# Check current status
sudo ufw status

# Reset to defaults
sudo ufw --force reset

# Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

### UFW Rule Configuration
```bash
# Allow SSH on custom port
sudo ufw allow 2022/tcp comment 'SSH Custom Port'

# Allow specific services (if needed)
sudo ufw allow 80/tcp comment 'HTTP'
sudo ufw allow 443/tcp comment 'HTTPS'

# Enable logging
sudo ufw logging on

# Enable firewall
sudo ufw enable

# Verify configuration
sudo ufw status verbose
sudo ufw status numbered
```

## Intrusion Prevention Commands

### fail2ban Installation
```bash
# Install fail2ban
sudo apt update
sudo apt install fail2ban

# Check installation
fail2ban-client --version
systemctl status fail2ban
```

### fail2ban Configuration
```bash
# Create local configuration
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Edit configuration
sudo nano /etc/fail2ban/jail.local

# Start and enable service
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
sudo systemctl status fail2ban

# Check active jails
sudo fail2ban-client status

# Check specific jail status
sudo fail2ban-client status sshd
```

## Network Monitoring Commands

### Traffic Analysis
```bash
# Install monitoring tools
sudo apt install tcpdump wireshark-common

# Monitor network traffic
sudo tcpdump -i eth0 -n -c 100
sudo tcpdump -i eth0 port 2022
sudo tcpdump -i eth0 -w /tmp/traffic_$(date +%Y%m%d_%H%M%S).pcap

# Analyze connections
netstat -an | grep :2022
ss -tulpn | grep :2022
lsof -i :2022
```

## Verification Commands

### Service Status Verification
```bash
# Check all critical services
systemctl is-active sshd
systemctl is-active ufw  
systemctl is-active fail2ban

# Verify service configurations
sudo sshd -T | grep -E "(port|permitrootlogin|passwordauthentication)"
sudo ufw status verbose
sudo fail2ban-client status
```

### Security Testing Commands  
```bash
# Test SSH hardening
ssh -p 22 root@localhost  # Should fail (wrong port)
ssh -p 2022 root@localhost  # Should fail (root disabled)

# Test firewall effectiveness
nmap -sS localhost
nmap -p 1-65535 localhost
```