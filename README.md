# Linux Server Hardening

![Linux](https://img.shields.io/badge/Linux-Ubuntu-orange)
![Security](https://img.shields.io/badge/Security-Hardening-red)
![Network](https://img.shields.io/badge/Network-Analysis-blue)
![Status](https://img.shields.io/badge/Status-Completed-green)

## 🔒 Project Overview

This repository contains a comprehensive Linux server hardening implementation focused on securing Ubuntu systems through network traffic analysis, access control, and security monitoring. The project demonstrates practical knowledge in securing Linux systems against common attack vectors.

### 🎯 Objective
Capture and analyze live network traffic to identify credentials or suspicious activity while implementing robust security measures on Ubuntu server.

### 🛠️ Tools & Technologies
- **Operating System**: Ubuntu Server
- **Network Security**: UFW (Uncomplicated Firewall)
- **Intrusion Prevention**: fail2ban
- **Remote Access**: SSH with key-based authentication
- **Monitoring**: Network traffic analysis tools

## 📋 Project Deliverables

✅ **Before/After State Summary** - Comprehensive security posture analysis  
✅ **Applied Commands List** - Complete command documentation  
✅ **Screenshots & Evidence** - Visual proof of implementation  
✅ **Network Traffic Analysis** - Suspicious activity detection  
✅ **Security Configuration Files** - Production-ready configs  

## 🚀 Quick Start

### Prerequisites
```bash
# Clone the repository
git clone https://github.com/yourusername/linux-server-hardening.git
cd linux-server-hardening

# Make scripts executable
chmod +x scripts/*.sh tools/*.sh
```

### Implementation
```bash
# 1. Run system information gathering
./tools/system-info.sh

# 2. Execute hardening setup
sudo ./scripts/hardening-setup.sh

# 3. Start network monitoring
./scripts/network-monitor.sh

# 4. Run security audit
./scripts/security-audit.sh
```

## 📁 Repository Structure

```
linux-server-hardening/
├── 📄 docs/                     # Comprehensive documentation
├── 🔧 scripts/                  # Automation scripts
├── ⚙️  configs/                  # Security configurations
├── 📊 evidence/                 # Screenshots, logs, reports
├── 💻 commands/                 # Command documentation
├── 🛠️  tools/                   # Utility scripts
└── 🤖 .github/                  # GitHub workflows & templates
```

## 🔐 Security Implementations

### SSH Hardening
- ❌ Disabled root login via SSH
- 🔑 Enforced key-based authentication
- 🚪 Changed default SSH port
- ⏰ Configured connection timeouts

### Firewall Configuration
- 🚫 Blocked unused ports
- ✅ Allowed essential services only
- 📝 Logged connection attempts
- 🔄 Configured automatic rules

### Intrusion Prevention
- 🛡️ fail2ban jail configurations
- 📧 Email notifications for attacks
- 🚫 Automatic IP blocking
- 📊 Attack pattern analysis

## 📈 Results Summary

| Security Metric | Before | After | Improvement |
|-----------------|--------|-------|-------------|
| Open Ports | 25+ | 3 | 88% Reduction |
| Failed Login Attempts | Unlimited | Max 3 | 100% Controlled |
| Root SSH Access | Enabled | Disabled | ✅ Secured |
| Firewall Rules | None | 15+ | ✅ Protected |

## 🔍 Network Analysis Findings

### Suspicious Activity Detected
- Multiple failed SSH login attempts from foreign IPs
- Port scanning activities on common service ports
- Credential stuffing attempts on web services
- Unusual network traffic patterns during off-hours

### Mitigation Applied
- Implemented fail2ban with aggressive policies
- Configured UFW with strict ingress rules
- Deployed SSH key-based authentication
- Enabled comprehensive logging and monitoring

## 📖 Documentation

Detailed documentation is available in the `docs/` directory:

1. **[Project Overview](docs/01-project-overview.md)** - Comprehensive project details
2. **[Prerequisites](docs/02-prerequisites.md)** - System requirements and setup
3. **[Implementation Guide](docs/03-implementation-guide.md)** - Step-by-step hardening process
4. **[Before/After Analysis](docs/04-before-after-analysis.md)** - Security posture comparison
5. **[Results & Findings](docs/05-results-and-findings.md)** - Analysis and recommendations

## 🎯 Learning Outcomes

- ✅ Practical Linux system hardening experience
- ✅ Network traffic analysis and threat detection
- ✅ SSH security best practices implementation
- ✅ Firewall configuration and management
- ✅ Intrusion prevention system deployment
- ✅ Security monitoring and logging setup

## 🤝 Contributing

Feel free to fork this repository and submit pull requests for improvements. Please read our contributing guidelines in the Issues section.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📧 Contact Information

**Author**: Vandit Naman Shah

**Focus Areas**: Network Security, Quantum Cryptography, CyberSecurity, GRC


---

⭐ If you found this project helpful, please give it a star!

#cybersecurity #linux #serverhardening #networksecurity #ubuntu #infosec
