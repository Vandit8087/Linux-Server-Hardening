# Security Checklist - Linux Server Hardening

## Pre-Implementation Checklist

### System Preparation
- [ ] System backup created
- [ ] Alternative access method available (console/physical)
- [ ] Documentation of current configuration
- [ ] Test environment validated
- [ ] Dependencies installed

### Network Security Assessment
- [ ] Network topology documented
- [ ] Current firewall rules recorded
- [ ] Open ports identified and justified
- [ ] Network services inventory completed
- [ ] External network access confirmed

## SSH Hardening Checklist

### Configuration Security
- [ ] Root login disabled (`PermitRootLogin no`)
- [ ] Password authentication disabled (`PasswordAuthentication no`)
- [ ] Key-based authentication enforced (`PubkeyAuthentication yes`)
- [ ] Default port changed (recommend port 2022)
- [ ] Maximum authentication attempts limited (`MaxAuthTries 3`)
- [ ] Connection timeouts configured (`ClientAliveInterval 300`)
- [ ] User access restricted (`AllowUsers` specified)
- [ ] Unused authentication methods disabled

### Key Management
- [ ] SSH keys generated with strong algorithms (RSA 4096+ or Ed25519)
- [ ] Private keys protected with passphrases
- [ ] Public keys properly installed on server
- [ ] Old/unused keys removed
- [ ] Key rotation schedule established

### Testing and Verification
- [ ] SSH configuration syntax validated (`sshd -t`)
- [ ] Root login attempts fail
- [ ] Password authentication attempts fail
- [ ] Key-based authentication works
- [ ] Connection timeouts function properly
- [ ] Alternative access method remains available

## Firewall Configuration Checklist

### UFW Basic Setup
- [ ] UFW installed and available
- [ ] Default policies configured (deny incoming, allow outgoing)
- [ ] Essential services identified
- [ ] SSH access rule configured for custom port
- [ ] Logging enabled (`ufw logging on`)
- [ ] IPv6 support configured if needed

### Rule Configuration
- [ ] SSH rule: `ufw allow 2022/tcp`
- [ ] Web services (if required): `ufw allow 80/tcp` and `ufw allow 443/tcp`
- [ ] Rate limiting applied: `ufw limit 2022/tcp`
- [ ] Specific IP ranges configured (if applicable)
- [ ] Unnecessary rules removed
- [ ] Rule comments added for documentation

### Testing and Verification
- [ ] UFW status shows "active"
- [ ] Only required ports are open
- [ ] Blocked connections are properly denied
- [ ] Allowed connections function normally
- [ ] Logging captures connection attempts
- [ ] iptables rules properly generated

## Intrusion Prevention Checklist

### fail2ban Installation
- [ ] fail2ban package installed
- [ ] Service enabled and started
- [ ] Configuration files accessible
- [ ] Log files readable by fail2ban
- [ ] Email notifications configured (optional)

### Jail Configuration
- [ ] SSH jail enabled in jail.local
- [ ] Custom SSH port specified (2022)
- [ ] Ban time configured (3600 seconds recommended)
- [ ] Find time window set (600 seconds recommended)
- [ ] Maximum retry attempts set (3 recommended)
- [ ] Log path correctly specified (`/var/log/auth.log`)

### Additional Jails (if applicable)
- [ ] Apache/Nginx jails configured
- [ ] Custom application jails created
- [ ] Whitelist IPs configured (if needed)
- [ ] Custom filters created (if needed)

### Testing and Verification
- [ ] fail2ban service running (`systemctl status fail2ban`)
- [ ] SSH jail active (`fail2ban-client status sshd`)
- [ ] Failed login attempts trigger bans
- [ ] Ban duration expires correctly
- [ ] Legitimate traffic not blocked
- [ ] Logging captures all actions

## Network Monitoring Checklist

### Monitoring Tools Setup
- [ ] tcpdump installed and functional
- [ ] Wireshark command-line tools available
- [ ] Network interfaces identified
- [ ] Capture directories created
- [ ] Log rotation configured

### Traffic Capture Configuration
- [ ] SSH traffic monitoring enabled
- [ ] General network traffic capture configured
- [ ] Packet capture file rotation set up
- [ ] Storage space allocated for captures
- [ ] Capture filters optimized

### Log Analysis Setup
- [ ] Authentication log monitoring active
- [ ] System log monitoring configured
- [ ] Security event alerting enabled
- [ ] Real-time monitoring scripts deployed
- [ ] Log retention policies established

## Security Validation Checklist

### Penetration Testing
- [ ] Port scanning from external source
- [ ] SSH brute force simulation
- [ ] Service enumeration attempts
- [ ] Vulnerability scanning completed
- [ ] Results documented and analyzed

### Compliance Verification
- [ ] Security policies documented
- [ ] Configuration changes recorded
- [ ] Evidence collection completed
- [ ] Before/after comparisons generated
- [ ] Compliance requirements met

### Performance Testing
- [ ] System performance baselines recorded
- [ ] Security impact on performance measured
- [ ] Network latency tested
- [ ] Service availability confirmed
- [ ] Resource utilization monitored

## Documentation and Evidence Checklist

### Configuration Documentation
- [ ] All commands executed documented
- [ ] Configuration files backed up
- [ ] Changes tracked with version control
- [ ] Implementation steps recorded
- [ ] Troubleshooting procedures documented

### Evidence Collection
- [ ] Screenshots captured (before/during/after)
- [ ] Log files preserved
- [ ] Network traffic captures saved
- [ ] Vulnerability scan reports generated
- [ ] Performance metrics recorded

### Reporting
- [ ] Before/after analysis completed
- [ ] Security improvements quantified
- [ ] Risk assessment updated
- [ ] Recommendations documented
- [ ] Executive summary prepared

## Post-Implementation Checklist

### System Hardening Verification
- [ ] All security controls active
- [ ] No critical services disrupted
- [ ] User access functioning properly
- [ ] Automated security responses working
- [ ] Monitoring and alerting operational

### Maintenance Setup
- [ ] Regular security updates scheduled
- [ ] Log rotation configured
- [ ] Backup procedures established
- [ ] Monitoring scripts scheduled
- [ ] Documentation kept current

### Training and Knowledge Transfer
- [ ] System administrators trained
- [ ] Procedures documented
- [ ] Emergency contacts established
- [ ] Escalation procedures defined
- [ ] Knowledge base maintained

## Emergency Procedures Checklist

### Rollback Preparation
- [ ] Original configurations backed up
- [ ] Rollback procedures tested
- [ ] Emergency access methods available
- [ ] Contact information readily available
- [ ] Recovery time objectives defined

### Incident Response
- [ ] Security incident response plan
- [ ] Communication procedures established
- [ ] Evidence preservation protocols
- [ ] Recovery procedures documented
- [ ] Lessons learned process defined

## Compliance and Audit Checklist

### Regulatory Compliance
- [ ] Industry standards identified (CIS, NIST, etc.)
- [ ] Compliance requirements mapped
- [ ] Control implementation verified
- [ ] Audit trails maintained
- [ ] Regular compliance reviews scheduled

### Security Audit Preparation
- [ ] Audit evidence organized
- [ ] Configuration baselines documented
- [ ] Change management records maintained
- [ ] Security metrics tracked
- [ ] Continuous monitoring implemented

---

## Checklist Completion Summary

**Pre-Implementation**: ___/5 items completed  
**SSH Hardening**: ___/18 items completed  
**Firewall Configuration**: ___/18 items completed  
**Intrusion Prevention**: ___/18 items completed  
**Network Monitoring**: ___/15 items completed  
**Security Validation**: ___/15 items completed  
**Documentation**: ___/15 items completed  
**Post-Implementation**: ___/15 items completed  
**Emergency Procedures**: ___/10 items completed  
**Compliance and Audit**: ___/10 items completed  

**Total Progress**: ___/139 items completed (___%)

---

**Notes and Comments:**
[Space for implementation notes, issues encountered, and additional observations]

**Sign-off:**
- [ ] Technical Implementation Completed
- [ ] Security Review Completed  
- [ ] Documentation Review Completed
- [ ] Management Approval Received

**Implementation Date**: ___________  
**Implemented By**: ___________  
**Reviewed By**: ___________  
**Approved By**: ___________