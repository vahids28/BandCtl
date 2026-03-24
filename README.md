markdown
# 🚀 BandCtl - Bandwidth Control Tool

<div align="center">

![Version](https://img.shields.io/badge/version-4.3.0-blue?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)
![Bash](https://img.shields.io/badge/shell-bash-4EAA25?style=flat-square)
![Platform](https://img.shields.io/badge/platform-Ubuntu%20%7C%20Debian-red?style=flat-square)

**Simple, Reliable, Auto-Restore Bandwidth Limiter for Linux Servers**

</div>

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🎯 **Port-Based** | Limit any port (1-65535) |
| ⚡ **Instant Apply** | No restart needed |
| 🔄 **Auto-Restore** | Survives reboot with retry mechanism |
| 📊 **Statistics** | Real-time traffic monitoring |
| 💾 **Persistent** | Settings saved permanently |
| 🧹 **Clean UI** | Colorful, easy-to-use menu |
| 🔧 **Simple Input** | Just enter Mbps (e.g., 2, 0.5, 10) |

---

## 🚀 Installation

### One-Line Install

```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/vahids28/BandCtl/main/bandctl.sh)" && sudo bandctl
```

### Manual Install

```bash
# Download
sudo curl -o /usr/local/bin/bandctl https://raw.githubusercontent.com/vahids28/BandCtl/main/bandctl.sh

# Make executable
sudo chmod +x /usr/local/bin/bandctl

# Run
sudo bandctl
```

### Requirements
- Ubuntu 18.04+ / Debian 10+
- Root access

---

## ⚡ Quick Start

```bash
# Run BandCtl
sudo bandctl

# From menu:
# 1 → Add limit (port + speed in Mbps)
# 2 → View all limits
# 6 → Check traffic statistics
```

**Example:**
```
Enter port: 443
Speed limit (Mbps): 2
✓ Limit ACTIVE now!
```

---

## 📋 Menu Options

```
╔══════════════════════════════════════════╗
║              MAIN MENU                   ║
╠══════════════════════════════════════════╣
║  1) Add New Limit       5) Reapply All   ║
║  2) View All Limits     6) Traffic Stats ║
║  3) Edit Limit          7) System Status ║
║  4) Remove Limit        8) Auto-Restore  ║
║                        9) Complete Cleanup║
║                       10) Exit           ║
╚══════════════════════════════════════════╝
```

---

## 💡 Common Use Cases

### 🛡️ VPN / Proxy (V2Ray, Xray, OpenVPN)

```bash
Port: 443   | Limit: 50 Mbps   # HTTPS / VLESS / VMess
Port: 1194  | Limit: 10 Mbps   # OpenVPN
Port: 51820 | Limit: 20 Mbps   # WireGuard
Port: 8080  | Limit: 30 Mbps   # Xray / V2Ray HTTP
Port: 10086 | Limit: 100 Mbps  # Sing-Box
```

### 🌐 Web Server (Nginx, Apache)

```bash
Port: 80    | Limit: 100 Mbps  # HTTP
Port: 443   | Limit: 50 Mbps   # HTTPS
Port: 8080  | Limit: 30 Mbps   # Alternative port
```

### 🎮 Game Servers

```bash
Port: 25565 | Limit: 20 Mbps   # Minecraft
Port: 27015 | Limit: 30 Mbps   # CS:GO / CS2
Port: 28015 | Limit: 25 Mbps   # Rust
Port: 7777  | Limit: 50 Mbps   # ARK / Unreal
```

### 🗄️ Database Servers

```bash
Port: 3306  | Limit: 50 Mbps   # MySQL / MariaDB
Port: 5432  | Limit: 50 Mbps   # PostgreSQL
Port: 27017 | Limit: 100 Mbps  # MongoDB
Port: 6379  | Limit: 30 Mbps   # Redis
```

### 📁 File Transfer

```bash
Port: 21    | Limit: 5 Mbps    # FTP
Port: 22    | Limit: 2 Mbps    # SFTP / SSH
Port: 20    | Limit: 5 Mbps    # FTP Data
```

### 📡 Streaming Services

```bash
Port: 1935  | Limit: 100 Mbps  # RTMP
Port: 554   | Limit: 50 Mbps   # RTSP
Port: 8000  | Limit: 200 Mbps  # HLS / DASH
```

### 🏢 Multi-Tenant Server

```bash
# Fair bandwidth distribution
Port: 8080  | Limit: 10 Mbps   # Customer A
Port: 8081  | Limit: 10 Mbps   # Customer B
Port: 8082  | Limit: 20 Mbps   # Customer C (Premium)
Port: 8083  | Limit: 5 Mbps    # Customer D (Basic)
```

---

## 🛠️ Command Line Usage

```bash
# Interactive menu (default)
sudo bandctl

# Direct commands
sudo bandctl --add      # Add new limit
sudo bandctl --view     # View all limits
sudo bandctl --edit     # Edit existing limit
sudo bandctl --remove   # Remove limit
sudo bandctl --fix      # Reapply all limits
sudo bandctl --stats    # Traffic statistics
sudo bandctl --status   # System status
sudo bandctl --restore  # Force restore from config
sudo bandctl --cleanup  # Complete cleanup

# Help
sudo bandctl --help
```

---

## 🔄 How Auto-Restore Works

After reboot, BandCtl uses **4 redundant methods** to restore limits:

```
┌─────────────────────────────────────────┐
│         AUTO-RESTORE MECHANISM          │
├─────────────────────────────────────────┤
│ 🔄 Systemd Service  → Runs at boot      │
│ ⏲️  Systemd Timer    → Retries every 30s│
│ 📅 Cron @reboot      → Backup (15s delay)│
│ 💾 rc.local          → Legacy support   │
└─────────────────────────────────────────┘
```

**Result:** Limits restored within 1-2 minutes after boot!

### Check Auto-Restore Status

```bash
# View all services status
sudo bandctl --status

# Check systemd timer
systemctl status bandctl.timer

# View restore logs
tail -f /var/log/bandctl.log
```

---

## 📁 Files & Locations

| File | Purpose | Location |
|------|---------|----------|
| Main Script | BandCtl executable | `/usr/local/bin/bandctl` |
| Configuration | All limits stored here | `/etc/bandctl.conf` |
| Log File | All actions logged | `/var/log/bandctl.log` |
| Restore Script | Auto-restore after reboot | `/usr/local/bin/bandctl-restore` |
| Systemd Service | Boot service | `/etc/systemd/system/bandctl.service` |
| Systemd Timer | Retry mechanism | `/etc/systemd/system/bandctl.timer` |

### Configuration Format

```bash
# /etc/bandctl.conf
# Format: port|rate_mbps|created_date|modified_date

443|2|2024-01-15 10:30:00|2024-01-15 10:30:00
80|10|2024-01-15 10:31:00|2024-01-15 10:31:00
22|1|2024-01-15 10:32:00|2024-01-15 10:32:00
```

---

## 🧪 Testing & Monitoring

### Generate Test Traffic

```bash
# Single connection test
curl --local-port 443 http://speedtest.tele2.net/10MB.zip -o /dev/null

# Multiple connections (stress test)
for i in {1..5}; do
    curl --local-port 443 http://speedtest.tele2.net/10MB.zip -o /dev/null &
done

# Download large file with wget
wget --local-port=443 http://speedtest.tele2.net/100MB.zip -O /dev/null
```

### Monitor Real-Time Speed

```bash
# Watch TC statistics
watch -n 1 'tc -s class show dev eth0 | grep -A 5 "htb"'

# BandCtl statistics
sudo bandctl --stats

# Live traffic on specific port
tc -s filter show dev eth0 | grep -A 10 "dport 443"
```

### Speed Test Results

```bash
# Test your actual speed
curl -o /dev/null http://speedtest.tele2.net/100MB.zip

# Check if limit is working
# Should show download speed close to your limit
```

---

## ❓ Troubleshooting Guide

| Problem | Solution |
|---------|----------|
| **Limits not active after reboot** | Wait 1-2 minutes (timer retries) or run `sudo bandctl --restore` |
| **Failed to apply limit** | Check interface: `ip link show`, ensure interface is UP |
| **No traffic statistics** | Generate traffic first with curl/wget |
| **Port not found** | Verify port is correct and service is running |
| **Permission denied** | Run with sudo: `sudo bandctl` |
| **tc command not found** | Install iproute2: `apt install iproute2 -y` |
| **Auto-restore not working** | Run option 8 to reconfigure: `sudo bandctl` → 8 |

### Diagnostic Commands

```bash
# Check interface status
ip link show

# View current TC rules
tc qdisc show
tc class show dev eth0
tc filter show dev eth0

# Check kernel modules
lsmod | grep -E "sch_htb|cls_u32"

# View logs
tail -50 /var/log/bandctl.log

# Check systemd services
systemctl status bandctl.service
systemctl status bandctl.timer
```

---

## 🗑️ Complete Cleanup

To remove BandCtl and ALL bandwidth limits completely:

```bash
# Method 1: Using BandCtl menu
sudo bandctl
# Select option 9
# Type: DELETE ALL
# Press Enter

# Method 2: Command line
sudo bandctl --cleanup
# Type: DELETE ALL
# Press Enter
```

This removes:
- All active bandwidth limits
- Configuration file (`/etc/bandctl.conf`)
- Log file (`/var/log/bandctl.log`)
- Systemd services
- Cron jobs
- Restore scripts
- All TC rules

---

## 📊 Performance & Limits

| Parameter | Value |
|-----------|-------|
| **Minimum Rate** | 0.1 Mbps (100 Kbps) |
| **Maximum Rate** | 10000 Mbps (10 Gbps) |
| **Decimal Support** | Yes (0.5, 1.5, 2.75, etc.) |
| **Port Range** | 1-65535 |
| **Protocols** | TCP + UDP |
| **Traffic Direction** | Incoming + Outgoing |
| **Max Limits** | Unlimited |

---

## 🔧 Advanced Configuration

### Custom Interface

BandCtl auto-detects the default network interface. To use a specific interface:

```bash
# Edit the script to set custom interface
# Find line: INTERFACE=$(ip route...)
# Replace with: INTERFACE="eth0"
```

### Modify Retry Settings

Edit `/etc/systemd/system/bandctl.timer`:

```ini
[Timer]
OnBootSec=10s      # Start after 10 seconds
OnUnitActiveSec=20s # Retry every 20 seconds
```

Then reload:
```bash
sudo systemctl daemon-reload
sudo systemctl restart bandctl.timer
```

---

## 📝 Logging

All actions are logged to `/var/log/bandctl.log`:

```bash
# View real-time logs
tail -f /var/log/bandctl.log

# Search for specific port
grep "port=443" /var/log/bandctl.log

# View restore attempts
grep "RESTORE" /var/log/bandctl.log

# Count successful restores
grep "✓ Restored" /var/log/bandctl.log | wc -l
```

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push (`git push origin feature/amazing`)
5. Open Pull Request

---

## 📄 License

MIT License - Free for personal and commercial use

```
MIT License

Copyright (c) 2024 vahids28

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions...

Full license: https://opensource.org/licenses/MIT
```

---

## ⚠️ Disclaimer

BandCtl uses Linux Traffic Control (tc) which requires root privileges. Use responsibly and ensure you have proper authorization to limit bandwidth on your server. The author is not responsible for any misuse or damage caused by this tool.

---

## 📞 Support & Community

- **GitHub Issues**: [Report bugs](https://github.com/vahids28/BandCtl/issues)
- **Discussions**: [Ask questions](https://github.com/vahids28/BandCtl/discussions)
- **Email**: vahids28@gmail.com

---

## 🌟 Star History

If you find BandCtl useful, please give it a star ⭐ on GitHub!

[![Star History Chart](https://api.star-history.com/svg?repos=vahids28/BandCtl&type=Date)](https://star-history.com/#vahids28/BandCtl&Date)

---

<div align="center">

### Made with ❤️ for the Linux Community

**BandCtl - Take Control of Your Bandwidth**

---

*“With great bandwidth comes great responsibility.”*

</div>
