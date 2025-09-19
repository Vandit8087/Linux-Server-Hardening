#!/bin/bash

# Network Monitoring Script
# Linux Server Hardening - Task 4

set -e

# Colors
RED='\\033[0;31m'
GREEN='\\033[0;32m'
YELLOW='\\033[1;33m'
BLUE='\\033[0;34m'
NC='\\033[0m'

# Configuration
MONITOR_INTERFACE="eth0"
CAPTURE_DIR="evidence/logs/network-traffic"
LOG_DIR="evidence/logs/security-logs"
SSH_PORT="2022"

# Create directories
mkdir -p "$CAPTURE_DIR" "$LOG_DIR"

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

# Check if running as root for packet capture
if [[ $EUID -ne 0 ]]; then
   error "This script requires root privileges for packet capture"
   exit 1
fi

log "Starting Network Security Monitoring..."

# Get the correct interface
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
if [ -z "$INTERFACE" ]; then
    INTERFACE="eth0"
fi

log "Monitoring interface: $INTERFACE"

# Function to monitor SSH connections
monitor_ssh() {
    log "Monitoring SSH connections on port $SSH_PORT..."
    
    # Capture SSH traffic
    timeout 300 tcpdump -i "$INTERFACE" -n -s 65535 -w "$CAPTURE_DIR/ssh_traffic_$(date +%Y%m%d_%H%M%S).pcap" "port $SSH_PORT" &
    SSH_PID=$!
    
    # Monitor authentication logs
    tail -f /var/log/auth.log | while read line; do
        echo "[$(date)] $line" >> "$LOG_DIR/ssh_monitor.log"
        
        # Check for suspicious activity
        if echo "$line" | grep -q "Failed password"; then
            warning "Failed SSH login attempt detected: $line"
            echo "[ALERT] $(date): $line" >> "$LOG_DIR/security_alerts.log"
        fi
        
        if echo "$line" | grep -q "Invalid user"; then
            warning "Invalid user login attempt: $line"  
            echo "[ALERT] $(date): $line" >> "$LOG_DIR/security_alerts.log"
        fi
        
        if echo "$line" | grep -q "Connection closed"; then
            log "SSH connection closed: $line"
        fi
    done &
    LOG_PID=$!
    
    success "SSH monitoring started (PID: $SSH_PID, $LOG_PID)"
}

# Function to monitor network traffic
monitor_traffic() {
    log "Starting general network traffic monitoring..."
    
    # Capture all traffic (limited time)
    timeout 180 tcpdump -i "$INTERFACE" -n -c 1000 -w "$CAPTURE_DIR/network_traffic_$(date +%Y%m%d_%H%M%S).pcap" &
    TRAFFIC_PID=$!
    
    # Monitor suspicious port scans
    netstat -an | grep -E "(SYN_RECV|TIME_WAIT)" > "$LOG_DIR/connection_states_$(date +%Y%m%d_%H%M%S).log" 2>/dev/null &
    
    success "Network traffic monitoring started (PID: $TRAFFIC_PID)"
}

# Function to monitor system resources
monitor_resources() {
    log "Starting system resource monitoring..."
    
    # CPU and memory usage
    while true; do
        {
            echo "=== $(date) ==="
            echo "CPU Usage:"
            top -bn1 | grep "Cpu(s)" | awk '{print $2 $3 $4 $5 $6 $7 $8}'
            echo "Memory Usage:"
            free -h
            echo "Network Connections:"
            netstat -an | wc -l
            echo "Active SSH Connections:" 
            netstat -an | grep ":$SSH_PORT" | grep ESTABLISHED | wc -l
            echo
        } >> "$LOG_DIR/system_resources_$(date +%Y%m%d).log"
        
        sleep 30
    done &
    RESOURCE_PID=$!
    
    success "System resource monitoring started (PID: $RESOURCE_PID)"
}

# Function to analyze fail2ban status
monitor_fail2ban() {
    if command -v fail2ban-client >/dev/null 2>&1; then
        log "Monitoring fail2ban status..."
        
        while true; do
            {
                echo "=== $(date) ==="
                echo "fail2ban Status:"
                fail2ban-client status 2>/dev/null || echo "fail2ban not responding"
                echo "SSH Jail Status:"
                fail2ban-client status sshd 2>/dev/null || echo "SSH jail not active"
                echo
            } >> "$LOG_DIR/fail2ban_status_$(date +%Y%m%d).log"
            
            sleep 60
        done &
        FAIL2BAN_PID=$!
        
        success "fail2ban monitoring started (PID: $FAIL2BAN_PID)"
    else
        warning "fail2ban not installed, skipping fail2ban monitoring"
    fi
}

# Function to generate real-time alerts
generate_alerts() {
    log "Setting up real-time security alerts..."
    
    # Monitor for multiple failed attempts from same IP
    tail -f /var/log/auth.log | while read line; do
        if echo "$line" | grep -q "Failed password"; then
            IP=$(echo "$line" | grep -oE '[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}' | head -1)
            if [ ! -z "$IP" ]; then
                COUNT=$(grep -c "$IP.*Failed password" /var/log/auth.log)
                if [ "$COUNT" -gt 5 ]; then
                    error "CRITICAL: Multiple failed attempts from $IP (Total: $COUNT)"
                    echo "[CRITICAL] $(date): Multiple failed attempts from $IP (Total: $COUNT)" >> "$LOG_DIR/critical_alerts.log"
                fi
            fi
        fi
    done &
    ALERT_PID=$!
    
    success "Real-time alerts started (PID: $ALERT_PID)"
}

# Cleanup function
cleanup() {
    log "Stopping network monitoring..."
    
    # Kill background processes
    for pid in $SSH_PID $LOG_PID $TRAFFIC_PID $RESOURCE_PID $FAIL2BAN_PID $ALERT_PID; do
        if [ ! -z "$pid" ]; then
            kill $pid 2>/dev/null || true
        fi
    done
    
    success "Network monitoring stopped"
    
    # Generate summary report
    log "Generating monitoring summary..."
    {
        echo "=== NETWORK MONITORING SUMMARY ==="
        echo "End Time: $(date)"
        echo
        echo "Captured Files:"
        ls -la "$CAPTURE_DIR"/ 2>/dev/null || echo "No capture files"
        echo
        echo "Log Files:"
        ls -la "$LOG_DIR"/ 2>/dev/null || echo "No log files"
        echo
        echo "Security Alerts:"
        if [ -f "$LOG_DIR/security_alerts.log" ]; then
            wc -l "$LOG_DIR/security_alerts.log"
            echo "Recent alerts:"
            tail -5 "$LOG_DIR/security_alerts.log" 2>/dev/null
        else
            echo "No security alerts recorded"
        fi
        echo
    } > "$LOG_DIR/monitoring_summary_$(date +%Y%m%d_%H%M%S).log"
    
    success "Summary report generated"
}

# Set trap for cleanup
trap cleanup EXIT INT TERM

# Start monitoring functions
monitor_ssh
monitor_traffic  
monitor_resources
monitor_fail2ban
generate_alerts

# Run for specified duration or until interrupted
DURATION=${1:-300}  # Default 5 minutes
log "Monitoring will run for $DURATION seconds (or until interrupted with Ctrl+C)"
log "Monitoring in progress... Press Ctrl+C to stop and generate summary"

sleep $DURATION

log "Monitoring duration completed"