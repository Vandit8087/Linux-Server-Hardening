#!/bin/bash

# Dependencies Installation Script
# Linux Server Hardening - Task 4
# Purpose: Install all required tools and dependencies

set -e

# Colors
RED='\\033[0;31m'
GREEN='\\033[0;32m'
YELLOW='\\033[1;33m'
BLUE='\\033[0;34m'
NC='\\033[0m'

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

# Check if running with sudo
if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root or with sudo"
   exit 1
fi

log "Starting dependencies installation for Linux Server Hardening..."

# Update package lists
log "Updating package lists..."
apt update

# Core system tools
log "Installing core system tools..."
apt install -y \\
    curl \\
    wget \\
    git \\
    vim \\
    nano \\
    htop \\
    tree \\
    unzip \\
    zip \\
    tar \\
    rsync

success "Core system tools installed"

# Network analysis tools
log "Installing network analysis tools..."
apt install -y \\
    tcpdump \\
    wireshark-common \\
    nmap \\
    netcat \\
    netstat-nat \\
    iftop \\
    nethogs \\
    iotop \\
    ss

success "Network analysis tools installed"

# Security tools
log "Installing security tools..."
apt install -y \\
    ufw \\
    fail2ban \\
    rkhunter \\
    chkrootkit \\
    aide \\
    lynis \\
    clamav \\
    clamav-daemon

success "Security tools installed"

# System monitoring tools
log "Installing system monitoring tools..."
apt install -y \\
    sysstat \\
    psmisc \\
    lsof \\
    strace \\
    ltrace \\
    dstat \\
    atop

success "System monitoring tools installed"

# Additional utilities
log "Installing additional utilities..."
apt install -y \\
    jq \\
    bc \\
    expect \\
    screen \\
    tmux \\
    acl \\
    attr

success "Additional utilities installed"

# Development tools (optional)
log "Installing development tools..."
apt install -y \\
    build-essential \\
    gcc \\
    make \\
    cmake \\
    git

success "Development tools installed"

# Update virus definitions for ClamAV
log "Updating ClamAV virus definitions..."
freshclam || warning "ClamAV update failed, will retry later"

# Configure basic security tools
log "Configuring basic security tools..."

# Enable UFW but don't activate yet
ufw --force reset >/dev/null 2>&1 || true

# Update locate database
updatedb >/dev/null 2>&1 || warning "updatedb failed"

# Set up basic aide configuration
if [ -f /etc/aide/aide.conf ]; then
    aideinit >/dev/null 2>&1 || warning "AIDE initialization failed"
fi

success "Basic configuration completed"

# Verify installations
log "Verifying installations..."

declare -A tools=(
    ["ufw"]="UFW Firewall"
    ["fail2ban-client"]="fail2ban"
    ["tcpdump"]="TCPDump"
    ["nmap"]="Nmap"
    ["rkhunter"]="RKHunter"
    ["lynis"]="Lynis"
    ["aide"]="AIDE"
    ["htop"]="htop"
    ["ss"]="ss"
    ["netstat"]="netstat"
)

echo
echo "Installation Verification:"
echo "========================="

for tool in "${!tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        success "${tools[$tool]}: $(command -v $tool)"
    else
        error "${tools[$tool]}: Not found"
    fi
done

# Display system information
echo
echo "System Information:"
echo "=================="
echo "OS: $(lsb_release -d | cut -f2)"
echo "Kernel: $(uname -r)"
echo "Memory: $(free -h | grep '^Mem:' | awk '{print $2}')"
echo "Disk: $(df -h / | tail -1 | awk '{print $4}') available"

log "Dependencies installation completed!"
echo
echo "Next steps:"
echo "1. Run system information script: ./tools/system-info.sh"
echo "2. Execute hardening setup: sudo ./scripts/hardening-setup.sh"
echo "3. Start monitoring: ./scripts/network-monitor.sh"