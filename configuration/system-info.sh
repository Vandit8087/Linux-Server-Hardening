#!/bin/bash

# System Information Gathering Script
# Linux Server Hardening - Task 4
# Purpose: Collect comprehensive system information for baseline assessment

set -e

# Colors for output
RED='\\033[0;31m'
GREEN='\\033[0;32m'
YELLOW='\\033[1;33m'
BLUE='\\033[0;34m'
NC='\\033[0m'

# Create output directory
OUTPUT_DIR="evidence/reports/system-info-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log "Starting system information collection..."
log "Output directory: $OUTPUT_DIR"

# System Information
log "Collecting basic system information..."
{
    echo "=== SYSTEM INFORMATION ==="
    echo "Collection Date: $(date)"
    echo "Hostname: $(hostname)"
    echo "FQDN: $(hostname -f 2>/dev/null || echo 'Not configured')"
    echo
    echo "Operating System:"
    cat /etc/os-release
    echo
    echo "Kernel Information:"
    uname -a
    echo
    echo "System Uptime:"
    uptime
    echo
    echo "System Load:"
    cat /proc/loadavg
    echo
} > "$OUTPUT_DIR/system_basic.txt"

# Hardware Information
log "Collecting hardware information..."
{
    echo "=== HARDWARE INFORMATION ==="
    echo
    echo "CPU Information:"
    lscpu
    echo
    echo "Memory Information:"
    cat /proc/meminfo
    echo
    echo "Disk Information:"
    lsblk
    echo
    echo "Storage Usage:"
    df -h
    echo
    echo "PCI Devices:"
    lspci
    echo
} > "$OUTPUT_DIR/hardware_info.txt" 2>/dev/null

# Network Configuration
log "Collecting network configuration..."
{
    echo "=== NETWORK CONFIGURATION ==="
    echo
    echo "Network Interfaces:"
    ip addr show
    echo
    echo "Routing Table:"
    ip route show
    echo
    echo "DNS Configuration:"
    cat /etc/resolv.conf
    echo
    echo "Network Statistics:"
    cat /proc/net/dev
    echo
    echo "Open Ports:"
    netstat -tulpn 2>/dev/null || ss -tulpn
    echo
} > "$OUTPUT_DIR/network_config.txt"

# User and Security Information
log "Collecting user and security information..."
{
    echo "=== USER AND SECURITY INFORMATION ==="
    echo
    echo "Current User:"
    whoami
    id
    echo
    echo "Logged-in Users:"
    w
    echo
    echo "User Accounts:"
    cat /etc/passwd
    echo
    echo "Group Information:"
    cat /etc/group
    echo
    echo "Sudo Configuration:"
    sudo cat /etc/sudoers 2>/dev/null || echo "Access denied to sudoers file"
    echo
    echo "Login History (last 20):"
    last -n 20
    echo
} > "$OUTPUT_DIR/user_security.txt"

# Services and Processes
log "Collecting service and process information..."
{
    echo "=== SERVICES AND PROCESSES ==="
    echo
    echo "Running Processes:"
    ps aux
    echo
    echo "Systemd Services (Running):"
    systemctl list-units --type=service --state=running --no-pager
    echo
    echo "Systemd Services (Failed):"
    systemctl list-units --type=service --state=failed --no-pager
    echo
    echo "Enabled Services:"
    systemctl list-unit-files --type=service --state=enabled --no-pager
    echo
} > "$OUTPUT_DIR/services_processes.txt"

# Security Configuration
log "Collecting security configuration..."
{
    echo "=== SECURITY CONFIGURATION ==="
    echo
    echo "SSH Configuration (non-comment lines):"
    grep -v '^#' /etc/ssh/sshd_config | grep -v '^$' 2>/dev/null || echo "SSH config not accessible"
    echo
    echo "Firewall Status (UFW):"
    if command -v ufw >/dev/null 2>&1; then
        sudo ufw status verbose 2>/dev/null || echo "UFW status not accessible"
    else
        echo "UFW not installed"
    fi
    echo
    echo "iptables Rules:"
    sudo iptables -L -n 2>/dev/null || echo "iptables not accessible"
    echo
    echo "fail2ban Status:"
    if command -v fail2ban-client >/dev/null 2>&1; then
        sudo fail2ban-client status 2>/dev/null || echo "fail2ban not accessible"
    else
        echo "fail2ban not installed"
    fi
    echo
} > "$OUTPUT_DIR/security_config.txt"

# Installed Software
log "Collecting installed software information..."
{
    echo "=== INSTALLED SOFTWARE ==="
    echo
    echo "APT Packages:"
    dpkg -l
    echo
    echo "Snap Packages:"
    snap list 2>/dev/null || echo "Snap not available"
    echo
} > "$OUTPUT_DIR/installed_software.txt"

# Log Files Summary
log "Collecting log file information..."
{
    echo "=== LOG FILES SUMMARY ==="
    echo
    echo "System Logs Directory:"
    ls -la /var/log/
    echo
    echo "Recent System Messages (last 50 lines):"
    sudo tail -50 /var/log/syslog 2>/dev/null || echo "Syslog not accessible"
    echo
    echo "Recent Authentication Events (last 50 lines):"
    sudo tail -50 /var/log/auth.log 2>/dev/null || echo "Auth log not accessible"
    echo
    echo "Kernel Messages (last 50 lines):"
    sudo dmesg | tail -50 2>/dev/null || echo "dmesg not accessible"
    echo
} > "$OUTPUT_DIR/log_summary.txt"

# File System Information
log "Collecting file system information..."
{
    echo "=== FILE SYSTEM INFORMATION ==="
    echo
    echo "Mount Points:"
    mount
    echo
    echo "File System Usage:"
    df -h
    echo
    echo "Inode Usage:"
    df -i
    echo
    echo "File System Types:"
    cat /proc/filesystems
    echo
    echo "World-writable files (first 20):"
    find / -type f -perm -002 2>/dev/null | head -20
    echo
    echo "SUID/SGID files (first 20):"
    find / -type f \\( -perm -4000 -o -perm -2000 \\) 2>/dev/null | head -20
    echo
} > "$OUTPUT_DIR/filesystem_info.txt"

# Generate Summary Report
log "Generating summary report..."
{
    echo "=== SYSTEM INFORMATION COLLECTION SUMMARY ==="
    echo "Generated: $(date)"
    echo "Collection Directory: $OUTPUT_DIR"
    echo
    echo "Files Generated:"
    ls -la "$OUTPUT_DIR/"
    echo
    echo "Key System Metrics:"
    echo "- Hostname: $(hostname)"
    echo "- OS: $(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '\"')"
    echo "- Kernel: $(uname -r)"
    echo "- Uptime: $(uptime | awk '{print $3,$4}' | sed 's/,//')"
    echo "- Memory: $(free -h | grep '^Mem:' | awk '{print $2}') total, $(free -h | grep '^Mem:' | awk '{print $3}') used"
    echo "- Disk: $(df -h / | tail -1 | awk '{print $2}') total, $(df -h / | tail -1 | awk '{print $3}') used"
    echo "- Load Average: $(cat /proc/loadavg | awk '{print $1,$2,$3}')"
    echo
    echo "Security Status:"
    echo "- SSH Service: $(systemctl is-active sshd 2>/dev/null || echo 'unknown')"
    echo "- UFW Firewall: $(if command -v ufw >/dev/null 2>&1; then sudo ufw status | head -1 | awk '{print $2}' 2>/dev/null || echo 'unknown'; else echo 'not installed'; fi)"
    echo "- fail2ban: $(systemctl is-active fail2ban 2>/dev/null || echo 'not installed/inactive')"
    echo
    echo "Collection completed successfully at $(date)"
    
} > "$OUTPUT_DIR/summary_report.txt"

# Create archive
log "Creating archive of collected information..."
tar -czf "$OUTPUT_DIR.tar.gz" -C "$(dirname "$OUTPUT_DIR")" "$(basename "$OUTPUT_DIR")"

success "System information collection completed!"
echo
echo "Output files:"
echo "- Directory: $OUTPUT_DIR"
echo "- Archive: $OUTPUT_DIR.tar.gz"
echo
echo "Summary:"
cat "$OUTPUT_DIR/summary_report.txt"