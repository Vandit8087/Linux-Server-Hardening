# Prerequisites - Linux Server Hardening

## System Requirements

### Hardware Specifications
- **CPU**: Minimum 2 cores, 2.0 GHz
- **RAM**: Minimum 4 GB (8 GB recommended)
- **Storage**: 20 GB available disk space
- **Network**: Internet connection for updates and testing

### Software Requirements
- **Operating System**: Ubuntu Server 20.04 LTS or later
- **Access Level**: Root/sudo access required
- **Network Access**: Ability to configure firewall rules
- **SSH Access**: Terminal access to the server

## Pre-Installation Setup

### 1. System Updates
```bash
# Update package lists
sudo apt update

# Upgrade system packages
sudo apt upgrade -y

# Install essential packages
sudo apt install -y curl wget git vim nano htop
```

### 2. User Account Setup
```bash
# Create a non-root user (if not exists)
sudo adduser secadmin

# Add user to sudo group
sudo usermod -aG sudo secadmin

# Verify user permissions
groups secadmin
```

### 3. Network Configuration Check
```bash
# Check network interfaces
ip addr show

# Verify internet connectivity
ping -c 4 google.com

# Check current firewall status
sudo ufw status
```

## Knowledge Prerequisites

### Required Skills
- **Linux Command Line**: Basic to intermediate proficiency
- **Text Editors**: Familiarity with vim/nano
- **File Permissions**: Understanding of chmod/chown
- **Process Management**: ps, top, systemctl commands
- **Network Basics**: TCP/IP, ports, protocols

### Recommended Background
- Previous Linux administration experience
- Basic cybersecurity concepts
- Understanding of SSH protocol
- Familiarity with log files and system monitoring

## Environment Setup

### 1. Virtual Machine Setup (if applicable)
```bash
# For VirtualBox/VMware users
# Ensure VM has:
# - NAT or Bridged network adapter
# - Sufficient resources allocated
# - Guest additions installed
```

### 2. SSH Key Generation
```bash
# Generate SSH key pair on client machine
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"

# Copy public key to server (replace with your server IP)
ssh-copy-id username@server-ip
```

### 3. Backup Current Configuration
```bash
# Create backup directory
sudo mkdir -p /backup/configs

# Backup important configuration files
sudo cp /etc/ssh/sshd_config /backup/configs/
sudo cp /etc/ufw/before.rules /backup/configs/
sudo cp /etc/fail2ban/jail.conf /backup/configs/
```

## Testing Environment

### Network Testing Tools
```bash
# Install network analysis tools
sudo apt install -y nmap wireshark-common tcpdump netcat

# Install security scanning tools  
sudo apt install -y nikto dirb gobuster
```

### Monitoring Tools
```bash
# Install system monitoring tools
sudo apt install -y iotop iftop nethogs
```

## Security Considerations

### Before Starting
1. **Create System Snapshot**: If using VM, create a snapshot
2. **Document Current State**: Record current configurations
3. **Plan Rollback Strategy**: Prepare restoration procedures
4. **Test in Isolated Environment**: Avoid production systems
5. **Have Console Access**: Ensure non-SSH access available

### Risk Mitigation
- Keep backup of original configurations
- Test changes in development environment first
- Maintain alternative access methods
- Document all changes made
- Plan for emergency recovery

## Compliance Requirements

### Documentation Standards
- All commands must be documented
- Screenshots required for major changes
- Before/after states must be recorded
- Security improvements must be measurable

### Evidence Collection
- Terminal session recordings
- Configuration file diffs
- Log file analysis
- Network traffic captures
- Vulnerability scan reports

## Getting Help

### Resources
- Ubuntu Server Documentation
- UFW Manual Pages
- fail2ban Configuration Guide
- SSH Security Best Practices
- Network Security Fundamentals

### Troubleshooting
- Check system logs: `/var/log/syslog`
- Review command history: `history`
- Verify service status: `systemctl status`
- Test network connectivity: `netstat -tulpn`