#!/bin/bash

# Cleanup Script for Linux Server Hardening
# Purpose: Safely remove hardening configurations if needed

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

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root"
   exit 1
fi

warning "This script will remove hardening configurations and restore defaults"
warning "This should only be used in emergency situations or for testing"

read -p "Are you sure you want to proceed? (yes/no): " confirm
if [[ $confirm != "yes" ]]; then
    log "Cleanup cancelled by user"
    exit 0
fi

log "Starting cleanup process..."

# Stop services
log "Stopping security services..."
systemctl stop fail2ban 2>/dev/null || warning "fail2ban not running"
systemctl stop ufw 2>/dev/null || warning "UFW not running"

# Restore SSH configuration
log "Restoring SSH configuration..."
if [[ -f /backup/ssh/sshd_config.backup ]] || [[ -f configs/ssh/sshd_config.backup ]]; then
    if [[ -f /backup/ssh/sshd_config.backup ]]; then
        cp /backup/ssh/sshd_config.backup /etc/ssh/sshd_config
    else
        cp configs/ssh/sshd_config.backup /etc/ssh/sshd_config
    fi
    success "SSH configuration restored"
else
    warning "SSH backup not found, manual restoration required"
fi

# Reset UFW
log "Resetting UFW firewall..."
ufw --force reset
ufw default allow incoming
ufw default allow outgoing
systemctl disable ufw
success "UFW reset to defaults"

# Disable fail2ban
log "Disabling fail2ban..."
systemctl disable fail2ban
systemctl stop fail2ban
success "fail2ban disabled"

# Restart SSH with original configuration
log "Restarting SSH service..."
if sshd -t; then
    systemctl restart sshd
    success "SSH service restarted with original configuration"
else
    error "SSH configuration test failed, manual intervention required"
fi

# Clean up log files (optional)
read -p "Remove collected logs and evidence? (yes/no): " clean_logs
if [[ $clean_logs == "yes" ]]; then
    rm -rf evidence/logs/*
    rm -rf evidence/screenshots/*
    rm -rf evidence/reports/*
    success "Evidence files removed"
fi

log "Cleanup completed"
warning "System restored to pre-hardening state"
warning "SSH is now accessible on port 22 with original settings"
warning "Firewall is disabled - system is less secure"

echo
echo "Post-cleanup checklist:"
echo "- [ ] Verify SSH access on port 22"
echo "- [ ] Check system accessibility"  
echo "- [ ] Review service status"
echo "- [ ] Implement alternative security measures if needed"