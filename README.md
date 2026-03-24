# 🚀 BandCtl - Bandwidth Control Tool

<div align="center">

![Version](https://img.shields.io/badge/version-4.3.0-blue?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)
![Bash](https://img.shields.io/badge/shell-bash-4EAA25?style=flat-square)
![Platform](https://img.shields.io/badge/platform-Ubuntu%20%7C%20Debian-red?style=flat-square)

**Simple, Reliable, Auto-Restore Bandwidth Limiter for Linux Servers**

[![Install](https://img.shields.io/badge/🚀-Install-blue?style=for-the-badge)](#-installation)
[![Quick Start](https://img.shields.io/badge/⚡-Quick%20Start-green?style=for-the-badge)](#-quick-start)
[![Docs](https://img.shields.io/badge/📖-Docs-orange?style=for-the-badge)](#-features)

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
Requirements
Ubuntu 18.04+ / Debian 10+

Root access

⚡ Quick Start
bash
# Run BandCtl
sudo bandctl

# From menu:
# 1 → Add limit (port + speed in Mbps)
# 2 → View all limits
# 6 → Check traffic statistics
Example:

text
Enter port: 443
Speed limit (Mbps): 2
✓ Limit ACTIVE now!
📋 Menu Options
text
1) Add New Limit       5) Reapply All
2) View All Limits     6) Traffic Stats
3) Edit Limit          7) System Status
4) Remove Limit        8) Setup Auto-Restore
                       9) Complete Cleanup
                      10) Exit
💡 Common Use Cases
🛡️ VPN / Proxy (V2Ray, Xray, OpenVPN)
bash
Port: 443 | Limit: 50 Mbps   # HTTPS/VLESS
Port: 1194 | Limit: 10 Mbps  # OpenVPN
Port: 51820 | Limit: 20 Mbps # WireGuard
🌐 Web Server (Nginx, Apache)
bash
Port: 80  | Limit: 100 Mbps  # HTTP
Port: 443 | Limit: 50 Mbps   # HTTPS
🎮 Game Servers
bash
Port: 25565 | Limit: 20 Mbps # Minecraft
Port: 27015 | Limit: 30 Mbps # CS2
🗄️ Database
bash
Port: 3306 | Limit: 50 Mbps  # MySQL
Port: 5432 | Limit: 50 Mbps  # PostgreSQL
📁 File Transfer
bash
Port: 21  | Limit: 5 Mbps    # FTP
Port: 22  | Limit: 2 Mbps    # SFTP/SSH
🛠️ Command Line Usage
bash
bandctl --add      # Add new limit
bandctl --view     # View all limits
bandctl --edit     # Edit existing limit
bandctl --remove   # Remove limit
bandctl --fix      # Reapply all limits
bandctl --stats    # Traffic statistics
bandctl --status   # System status
bandctl --restore  # Force restore
bandctl --cleanup  # Complete cleanup
🔄 How Auto-Restore Works
After reboot, BandCtl uses 4 redundant methods to restore limits:

text
🔄 Systemd Service → Runs at boot
⏲️  Systemd Timer   → Retries every 30s (2 mins)
📅 Cron @reboot     → Backup with 15s delay
💾 rc.local         → Legacy support
Result: Limits restored within 1-2 minutes after boot!

📁 Files
File	Purpose
/etc/bandctl.conf	Configuration
/var/log/bandctl.log	Logs
/usr/local/bin/bandctl	Main script
🧪 Testing
bash
# Generate traffic on limited port
curl --local-port 443 http://speedtest.tele2.net/10MB.zip -o /dev/null

# Monitor real-time speed
watch -n 1 'tc -s class show dev eth0 | grep -A 5 "htb"'
❓ Troubleshooting
Issue	Solution
Not active after reboot	Wait 2 mins or run bandctl --restore
Failed to apply	Check interface: ip link show
No statistics	Generate traffic first
🗑️ Complete Cleanup
bash
sudo bandctl
# Select option 9
# Type: DELETE ALL
📄 License
MIT License - Free for personal and commercial use

<div align="center">
Made with ❤️ for the Linux Community

https://img.shields.io/github/stars/vahids28/BandCtl?style=social
https://img.shields.io/github/forks/vahids28/BandCtl?style=social

Take Control of Your Bandwidth

</div> ```
