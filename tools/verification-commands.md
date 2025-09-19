# Verification Commands - Linux Server Hardening

This document provides commands to verify that all hardening measures are properly implemented and functioning.

## SSH Hardening Verification

### Configuration Verification
```bash
# Test SSH configuration syntax
sudo sshd -t

# Display active SSH configuration
sudo sshd -T | grep -E "(port|permitrootlogin|passwordauthentication|pubkeyauthentication|maxauthtries)"

# Check SSH service status
systemctl status sshd
systemctl is-active sshd
systemctl is-enabled sshd

# Verify SSH is listening on custom port
sudo netstat -tlnp | grep :2022
sudo ss -tlnp | grep :2022
```

### Access Testing
```bash
# Test that root login fails (should be rejected)
ssh -p 2022 root@localhost

# Test that password authentication fails
ssh -p 2022 -o PreferredAuthentications=password username@localhost

# Test that key-based authentication works
ssh -p 2022 -i ~/.ssh/id_rsa username@localhost

# Test connection on old port fails
ssh -p 22 username@localhost

# Verify connection timeouts work (let connection idle)
ssh -p 2022 username@localhost
```

## Firewall Verification

### UFW Status Check
```bash
# Check UFW status and rules
sudo ufw status verbose
sudo ufw status numbered

# Verify default policies
sudo ufw show raw | grep -E "(DEFAULT_INPUT_POLICY|DEFAULT_OUTPUT_POLICY)"

# Check logging status
sudo ufw show listening
```

### Port Testing
```bash
# Scan from external host (replace IP)
nmap -sS target-server-ip

# Test specific ports
nmap -p 22,2022,80,443 target-server-ip

# Verify only authorized ports are open
netstat -tulpn | grep LISTEN
ss -tulpn | grep LISTEN
```

### iptables Verification
```bash
# View UFW-generated iptables rules
sudo iptables -L -n
sudo iptables -L -n -t nat

# Check for blocked connections
sudo iptables -L -n | grep DROP
sudo iptables -L -n | grep REJECT
```

## Intrusion Prevention Verification

### fail2ban Status
```bash
# Check fail2ban service
systemctl status fail2ban
systemctl is-active fail2ban
systemctl is-enabled fail2ban

# List active jails
sudo fail2ban-client status

# Check SSH jail specifically
sudo fail2ban-client status sshd

# View fail2ban configuration
sudo fail2ban-client get sshd bantime
sudo fail2ban-client get sshd findtime
sudo fail2ban-client get sshd maxretry
```

### Ban Testing
```bash
# Simulate failed login attempts (from another machine)
# This should trigger automatic banning after 3 attempts
for i in {1..5}; do
    ssh -p 2022 fakeuser@target-server
done

# Check if IP gets banned
sudo fail2ban-client get sshd banip

# Check fail2ban logs
sudo tail -f /var/log/fail2ban.log

# Manually unban IP for testing
sudo fail2ban-client set sshd unbanip YOUR_IP_ADDRESS
```

## Network Monitoring Verification

### Traffic Capture
```bash
# Verify tcpdump is capturing SSH traffic
sudo tcpdump -i eth0 -n port 2022

# Check for network monitoring processes
ps aux | grep tcpdump
ps aux | grep "network-monitor"

# Verify capture files are being created
ls -la evidence/logs/network-traffic/

# Test packet capture functionality
sudo tcpdump -i eth0 -w test_capture.pcap -c 10
tcpdump -r test_capture.pcap
```

### Log Monitoring
```bash
# Verify authentication logging
sudo tail -f /var/log/auth.log

# Check system logging
sudo tail -f /var/log/syslog

# Verify UFW logging
sudo tail -f /var/log/ufw.log

# Check log rotation
ls -la /var/log/auth.log*
ls -la /var/log/fail2ban.log*
```

## System Security Verification

### Service Enumeration
```bash
# List running services
systemctl list-units --type=service --state=running

# Check for unnecessary services
systemctl list-units --type=service --state=enabled

# Verify critical services
for service in sshd ufw fail2ban; do
    echo "$service: $(systemctl is-active $service)"
done
```

### File System Security
```bash
# Check for world-writable files
find / -type f -perm -002 2>/dev/null | head -20

# Check for files with no owner
find / -nouser -o -nogroup 2>/dev/null | head -10

# Verify SSH key permissions
ls -la ~/.ssh/
ls -la ~/.ssh/authorized_keys
ls -la ~/.ssh/id_*
```

### User Account Security
```bash
# Check user accounts
cat /etc/passwd | grep -E "(sh|bash)$"

# Verify sudo access
sudo -l

# Check login history
last -n 20
lastlog | grep -v "Never"

# Verify account lockout policies
sudo cat /etc/login.defs | grep -E "(PASS_|LOGIN_)"
```

## Performance Impact Verification

### System Performance
```bash
# Check CPU usage
top -bn1 | grep "Cpu(s)"
sar -u 1 5

# Check memory usage
free -h
sar -r 1 5

# Check network performance
sar -n DEV 1 5
iftop -t -s 60
```

### Connection Performance
```bash
# Time SSH connections
time ssh -p 2022 username@localhost 'exit'

# Check network latency
ping -c 10 localhost

# Test concurrent connections
for i in {1..5}; do
    ssh -p 2022 username@localhost 'sleep 5' &
done
wait
```

## Security Audit Verification

### Automated Security Scanning
```bash
# Run Lynis security audit
sudo lynis audit system --quick

# Run rootkit check
sudo rkhunter --check --skip-keypress

# Check for malware
sudo clamscan -r /home --quiet

# Network vulnerability scan
nmap -sS -sV --script vuln localhost
```

### Compliance Verification
```bash
# Generate compliance report
sudo lynis audit system --compliance

# Check CIS benchmarks (if available)
# sudo cis-cat --benchmark CIS_Ubuntu_20.04_Benchmark_v1.0.0.pdf

# Verify security configurations
sudo find /etc -name "*.conf" -exec grep -l "security\|hardening" {} \;
```

## Evidence Collection Verification

### Documentation Completeness
```bash
# Check documentation files
find docs/ -name "*.md" -exec wc -l {} +

# Verify command history
wc -l commands/commands-executed.md

# Check evidence directory structure
find evidence/ -type d
find evidence/ -type f | head -20
```

### Screenshot Verification
```bash
# Check screenshot directories
ls -la evidence/screenshots/*/

# Verify image files
find evidence/screenshots/ -name "*.png" -o -name "*.jpg"

# Check file sizes (ensure not empty)
find evidence/screenshots/ -name "*.png" -exec ls -lh {} \;
```

## Integration Testing

### End-to-End Security Test
```bash
# Comprehensive security test script
#!/bin/bash

echo "=== Comprehensive Security Verification ==="

# SSH Security
echo "Testing SSH security..."
ssh -p 22 root@localhost && echo "FAIL: Port 22 accessible" || echo "PASS: Port 22 blocked"
ssh -p 2022 root@localhost && echo "FAIL: Root login possible" || echo "PASS: Root login blocked"

# Firewall
echo "Testing firewall..."
nmap -p 1-1000 localhost | grep -q "22/tcp.*open" && echo "FAIL: Port 22 open" || echo "PASS: Port 22 closed"

# fail2ban
echo "Testing fail2ban..."
systemctl is-active fail2ban >/dev/null && echo "PASS: fail2ban active" || echo "FAIL: fail2ban inactive"

echo "=== Verification Complete ==="
```

## Continuous Verification

### Automated Monitoring
```bash
# Create verification cron job
echo "0 */6 * * * /path/to/security-verification.sh" | sudo crontab -

# Set up log monitoring alerts
# Configure logwatch or similar tool

# Schedule regular security scans
echo "0 2 * * 0 /usr/bin/lynis audit system --cron-job" | sudo crontab -
```

### Health Check Script
```bash
#!/bin/bash
# health-check.sh - Quick security health verification

echo "Security Health Check - $(date)"
echo "================================"

# Service status
services=(sshd ufw fail2ban)
for service in "${services[@]}"; do
    if systemctl is-active $service >/dev/null; then
        echo "✓ $service: Active"
    else
        echo "✗ $service: Inactive"
    fi
done

# Port status
echo
echo "Port Status:"
if netstat -tlnp | grep -q ":2022 "; then
    echo "✓ SSH: Listening on port 2022"
else
    echo "✗ SSH: Not listening on port 2022"
fi

# fail2ban jails
echo
echo "fail2ban Jails:"
if sudo fail2ban-client status | grep -q "sshd"; then
    echo "✓ SSH jail: Active"
else
    echo "✗ SSH jail: Inactive"
fi

echo
echo "Health check completed"
```

This verification guide ensures all hardening measures are working correctly and provides ongoing monitoring capabilities.