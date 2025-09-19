# Implementation Guide - Linux Server Hardening

## Phase 1: System Assessment and Baseline

### Step 1: Initial System Information Gathering
```bash
# System information
uname -a
lsb_release -a
whoami
id

# Network configuration
ip addr show
netstat -tulpn
ss -tulpn

# Running services
systemctl list-units --type=service --state=running

# User accounts
cat /etc/passwd
last -n 20
```

### Step 2: Security Baseline Assessment
```bash
# Check for world-writable files
find / -type f -perm -002 2>/dev/null

# Check for SUID/SGID files
find / -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null

# Review sudo configuration
sudo cat /etc/sudoers

# Check password policies
sudo cat /etc/login.defs | grep -i pass
```

## Phase 2: SSH Hardening Implementation

### Step 3: SSH Configuration Backup and Modification
```bash
# Backup original SSH configuration
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Edit SSH configuration
sudo nano /etc/ssh/sshd_config
```

#### Key SSH Hardening Settings:
```bash
# Disable root login
PermitRootLogin no

# Use SSH key authentication only
PubkeyAuthentication yes
PasswordAuthentication no
PermitEmptyPasswords no

# Change default port (optional but recommended)
Port 2022

# Limit user access
AllowUsers secadmin

# Connection timeouts
ClientAliveInterval 300
ClientAliveCountMax 2

# Disable unused authentication methods
ChallengeResponseAuthentication no
KerberosAuthentication no
GSSAPIAuthentication no

# Enable logging
SyslogFacility AUTH
LogLevel INFO
```

### Step 4: SSH Service Restart and Testing
```bash
# Validate SSH configuration
sudo sshd -t

# Restart SSH service
sudo systemctl restart sshd

# Test SSH connection (from another terminal)
ssh -p 2022 secadmin@localhost
```

## Phase 3: Firewall Configuration

### Step 5: UFW Installation and Basic Setup
```bash
# Install UFW (if not already installed)
sudo apt install ufw

# Reset UFW to defaults
sudo ufw --force reset

# Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

### Step 6: UFW Rule Configuration
```bash
# Allow SSH on custom port
sudo ufw allow 2022/tcp

# Allow HTTP and HTTPS (if web server present)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Allow specific IP ranges (if needed)
sudo ufw allow from 192.168.1.0/24 to any port 22

# Enable logging
sudo ufw logging on

# Enable UFW
sudo ufw enable

# Check status
sudo ufw status verbose
```

## Phase 4: Intrusion Prevention Setup

### Step 7: fail2ban Installation and Configuration
```bash
# Install fail2ban
sudo apt install fail2ban

# Create local configuration file
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Edit jail.local configuration
sudo nano /etc/fail2ban/jail.local
```

#### Key fail2ban Configuration:
```ini
[DEFAULT]
# Ban time (in seconds)
bantime = 3600

# Find time window
findtime = 600

# Max retry attempts
maxretry = 3

# Email notifications (configure as needed)
destemail = admin@yourdomain.com
sender = fail2ban@yourdomain.com

[sshd]
enabled = true
port = 2022
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600

[apache-auth]
enabled = false

[apache-badbots]
enabled = false
```

### Step 8: fail2ban Service Management
```bash
# Start and enable fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Check fail2ban status
sudo systemctl status fail2ban

# View active jails
sudo fail2ban-client status

# View specific jail status
sudo fail2ban-client status sshd
```

## Phase 5: Network Monitoring and Analysis

### Step 9: Network Traffic Monitoring Setup
```bash
# Install network monitoring tools
sudo apt install tcpdump wireshark-common

# Monitor network traffic (basic)
sudo tcpdump -i eth0 -n -c 100

# Monitor SSH connections
sudo tcpdump -i eth0 port 2022

# Save network traffic to file
sudo tcpdump -i eth0 -w /tmp/network_traffic.pcap
```

### Step 10: Log Monitoring Configuration
```bash
# Configure rsyslog for centralized logging
sudo nano /etc/rsyslog.conf

# Add custom log files monitoring
tail -f /var/log/auth.log
tail -f /var/log/fail2ban.log
tail -f /var/log/ufw.log
```

## Phase 6: Additional Security Measures

### Step 11: System Updates and Package Management
```bash
# Update package lists
sudo apt update

# Install security updates
sudo apt upgrade

# Remove unnecessary packages
sudo apt autoremove

# Install additional security tools
sudo apt install rkhunter chkrootkit aide
```

### Step 12: User Account Security
```bash
# Set password policies
sudo nano /etc/login.defs

# Lock unused accounts
sudo usermod -L guest
sudo usermod -L daemon

# Review user login history
last -n 50
lastlog
```

## Phase 7: Verification and Testing

### Step 13: Security Configuration Verification
```bash
# Test SSH hardening
ssh -p 2022 root@localhost  # Should fail
ssh -p 22 secadmin@localhost  # Should fail (wrong port)

# Test firewall rules
nmap -sS localhost
nmap -p 1-1000 localhost

# Test fail2ban
# Attempt multiple failed logins to trigger ban
```

### Step 14: Performance and Functionality Testing
```bash
# Check system performance
htop
iotop -o

# Verify all services are running
systemctl list-failed

# Test legitimate access
ssh -p 2022 -i ~/.ssh/id_rsa secadmin@localhost
```

## Phase 8: Documentation and Evidence Collection

### Step 15: Before/After Comparison
```bash
# Generate system security report
sudo lynis audit system

# Compare nmap scans
nmap -sS localhost > after_hardening_nmap.txt

# Document configuration changes
diff /etc/ssh/sshd_config.backup /etc/ssh/sshd_config > ssh_changes.diff
```

### Step 16: Evidence Collection
```bash
# Screenshot important configurations
# - UFW status
# - fail2ban status
# - SSH configuration
# - System logs

# Export log files
sudo cp /var/log/auth.log evidence/logs/
sudo cp /var/log/fail2ban.log evidence/logs/
sudo cp /var/log/ufw.log evidence/logs/
```

## Troubleshooting Common Issues

### SSH Connection Issues
```bash
# Check SSH service status
sudo systemctl status sshd

# Verify SSH configuration syntax
sudo sshd -t

# Check SSH logs
sudo tail -f /var/log/auth.log
```

### Firewall Issues
```bash
# Check UFW status
sudo ufw status verbose

# Reset UFW if needed
sudo ufw reset

# Check iptables rules
sudo iptables -L -n
```

### fail2ban Issues
```bash
# Check fail2ban logs
sudo tail -f /var/log/fail2ban.log

# Restart fail2ban service
sudo systemctl restart fail2ban

# Unban IP address
sudo fail2ban-client set sshd unbanip 192.168.1.100
```

## Post-Implementation Checklist

- [ ] SSH root login disabled
- [ ] SSH key-based authentication enforced
- [ ] Custom SSH port configured
- [ ] UFW firewall enabled with minimal rules
- [ ] fail2ban configured and running
- [ ] Network traffic monitoring active
- [ ] Log files being collected
- [ ] All configurations backed up
- [ ] Security improvements documented
- [ ] Evidence collected and organized