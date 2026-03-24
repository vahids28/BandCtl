```markdown
# BandCtl - Bandwidth Control Tool

<div align="center">

![Version](https://img.shields.io/badge/version-4.3.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Bash](https://img.shields.io/badge/shell-bash-4EAA25.svg)
![Platform](https://img.shields.io/badge/platform-Ubuntu%20%7C%20Debian-red.svg)

**Simple & Reliable Bandwidth Limiter for Linux Servers**

[Installation](#installation) • [Quick Start](#quick-start) • [Features](#features) • [Use Cases](#use-cases) • [Commands](#commands)

</div>

---

## 📖 About BandCtl

BandCtl is a powerful yet simple command-line tool for managing bandwidth limits on specific ports in Ubuntu/Debian servers. It uses Linux Traffic Control (tc) to apply speed limits and automatically restores all settings after system reboot with a built-in retry mechanism.

**No more manual reapplication after reboot!** BandCtl ensures your bandwidth limits are always active.

---

## ✨ Features

- **🎯 Port-Based Limiting** - Set speed limits on any port (1-65535)
- **⚡ Instant Apply** - Limits become active immediately after adding
- **🔄 Auto-Restore After Reboot** - Multiple redundant methods ensure limits survive reboot:
  - Systemd service with retry
  - Systemd timer (retries every 30 seconds)
  - Cron @reboot fallback
  - rc.local legacy support
- **📊 Traffic Statistics** - View real-time traffic data for limited ports
- **📝 Simple Input** - Enter speed in Mbps with decimal support (0.5, 1, 2.5, 10)
- **💾 Persistent Configuration** - All settings saved to `/etc/bandctl.conf`
- **📋 Comprehensive Logging** - All actions logged to `/var/log/bandctl.log`
- **🧹 Complete Cleanup** - Option to remove everything and start fresh
- **🎨 Clean CLI Interface** - Colorful, easy-to-use menu system

---

## 🚀 Installation

### One-Line Installation (Recommended)

```bash
curl -sSL https://raw.githubusercontent.com/yourusername/bandctl/main/install.sh | sudo bash
```

Or directly download and run:

```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/yourusername/bandctl/main/bandctl.sh)" && sudo bandctl
```

### Manual Installation

```bash
# Download the script
sudo curl -o /usr/local/bin/bandctl https://raw.githubusercontent.com/yourusername/bandctl/main/bandctl.sh

# Make it executable
sudo chmod +x /usr/local/bin/bandctl

# Run BandCtl
sudo bandctl
```

### Requirements

- Ubuntu 18.04+ or Debian 10+
- Root/sudo access
- Internet connection (for dependency installation)

---

## 🎮 Quick Start

### 1. Launch BandCtl

```bash
sudo bandctl
```

### 2. Add a Bandwidth Limit

From the main menu, select option `1` and enter:

- **Port number**: e.g., `443` (HTTPS), `80` (HTTP), `22` (SSH), `8080`, `59615`
- **Speed limit**: e.g., `2` (2 Mbps), `0.5` (512 Kbps), `10` (10 Mbps)

### 3. Verify the Limit

Select option `2` to view all configured limits:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Bandwidth Limits
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PORT       LIMIT (Mbps)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
443        2
80         10
22         1
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total: 3 limit(s) configured
```

### 4. Test the Limit

Generate traffic on the limited port:

```bash
# Test with curl (download a test file)
curl --local-port 443 http://speedtest.tele2.net/10MB.zip -o /dev/null

# Or test with wget
wget --local-port=443 http://speedtest.tele2.net/10MB.zip -O /dev/null
```

### 5. Check Traffic Statistics

Select option `6` to view real-time traffic data:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Traffic Statistics
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Port 443 (2 Mbps):
  Sent 12538624 bytes 104488 pkt (dropped 0, overlimits 0)
  rate 1984Kbit 206pps backlog 0b 0p requeues 0
```

---

## 📋 Main Menu Options

| Option | Description |
|--------|-------------|
| **1** | Add New Bandwidth Limit - Set speed limit on a port (activates immediately) |
| **2** | View All Limits - Display all configured ports and their limits |
| **3** | Edit Existing Limit - Change speed limit for an existing port |
| **4** | Remove Bandwidth Limit - Delete limit from a specific port |
| **5** | Reapply All Limits - Force reapplication of all limits (fix inactive) |
| **6** | View Traffic Statistics - Show real-time traffic data |
| **7** | Show System Status - Display current status and auto-restore info |
| **8** | Reconfigure Auto-Restore - Re-setup persistence mechanisms |
| **9** | COMPLETE CLEANUP - Remove ALL limits and settings |
| **10** | Exit - Exit BandCtl |

---

## 💡 Use Cases

### 1. **VPN Server (OpenVPN/WireGuard)**

Limit bandwidth per VPN port to ensure fair distribution:

```bash
# Limit OpenVPN port 1194 to 10 Mbps
Port: 1194, Limit: 10

# Limit WireGuard port 51820 to 20 Mbps
Port: 51820, Limit: 20
```

### 2. **V2Ray / Xray / Sing-Box**

Control bandwidth for proxy services:

```bash
# Limit V2Ray VLESS/VMess port to 50 Mbps
Port: 443, Limit: 50

# Limit Xray gRPC port to 30 Mbps
Port: 8080, Limit: 30

# Limit Sing-Box port to 100 Mbps
Port: 10086, Limit: 100
```

### 3. **Web Server (Nginx/Apache)**

Prevent a single website from consuming all bandwidth:

```bash
# Limit main web port to 100 Mbps
Port: 80, Limit: 100

# Limit HTTPS to 50 Mbps
Port: 443, Limit: 50
```

### 4. **Game Server**

Control bandwidth for game servers:

```bash
# Minecraft server
Port: 25565, Limit: 20

# CS:GO / CS2 server
Port: 27015, Limit: 30

# Rust server
Port: 28015, Limit: 25
```

### 5. **File Transfer (FTP/SFTP)**

Limit upload/download speeds:

```bash
# FTP port
Port: 21, Limit: 5

# SFTP/SSH
Port: 22, Limit: 2
```

### 6. **Database Server**

Prevent backup processes from overwhelming network:

```bash
# MySQL/MariaDB
Port: 3306, Limit: 50

# PostgreSQL
Port: 5432, Limit: 50

# MongoDB
Port: 27017, Limit: 100
```

### 7. **Streaming Server**

Control bandwidth for streaming services:

```bash
# RTMP streaming
Port: 1935, Limit: 100

# HLS streaming
Port: 8080, Limit: 200
```

### 8. **Multi-Tenant Server**

Fair bandwidth distribution among customers:

```bash
# Customer A
Port: 8080, Limit: 10

# Customer B
Port: 8081, Limit: 10

# Customer C
Port: 8082, Limit: 20
```

---

## 🛠️ Command Line Usage

BandCtl supports direct command-line arguments for automation:

```bash
# Add a limit
sudo bandctl --add
# Follow interactive prompts

# View all limits
sudo bandctl --view

# Edit a limit
sudo bandctl --edit

# Remove a limit
sudo bandctl --remove

# Reapply all limits
sudo bandctl --fix

# View traffic statistics
sudo bandctl --stats

# Show system status
sudo bandctl --status

# Force restore from config
sudo bandctl --restore

# Complete cleanup
sudo bandctl --cleanup
```

---

## 🔧 Configuration Files

| File | Purpose |
|------|---------|
| `/etc/bandctl.conf` | Main configuration file with all limits |
| `/var/log/bandctl.log` | Log file for all actions and restore attempts |
| `/usr/local/bin/bandctl-restore` | Auto-restore script |

### Configuration Format

```
# BandCtl Configuration
# Format: port|rate_mbps|created_date|modified_date

443|2|2024-01-15 10:30:00|2024-01-15 10:30:00
80|10|2024-01-15 10:31:00|2024-01-15 10:31:00
22|1|2024-01-15 10:32:00|2024-01-15 10:32:00
```

---

## 🔄 How Auto-Restore Works

BandCtl uses multiple redundant methods to ensure limits survive reboot:

1. **Systemd Service** - Runs at boot after network is ready
2. **Systemd Timer** - Retries every 30 seconds for the first 2 minutes
3. **Cron @reboot** - Backup method with 15-second delay
4. **rc.local** - Legacy system support

This ensures limits are applied even if the network takes time to initialize.

---

## 📊 Performance & Limits

- **Supported Rates**: 0.1 Mbps to 10000 Mbps (0.1 to 10000)
- **Decimal Support**: Yes (0.5, 1.5, 2.75, etc.)
- **Port Range**: 1-65535
- **Protocols**: TCP and UDP
- **Traffic Direction**: Both incoming and outgoing

---

## 🧪 Testing Your Limits

### Generate Test Traffic

```bash
# Download a large file on the limited port
curl --local-port 443 http://speedtest.tele2.net/100MB.zip -o /dev/null

# Or use wget
wget --local-port=443 http://speedtest.tele2.net/100MB.zip -O /dev/null

# Multiple connections test
for i in {1..5}; do
    curl --local-port 443 http://speedtest.tele2.net/10MB.zip -o /dev/null &
done
```

### Monitor Real-Time Speed

```bash
# Watch traffic statistics
watch -n 1 'tc -s class show dev eth0 | grep -A 5 "class htb"'

# Or use BandCtl
sudo bandctl --stats
```

---

## 🗑️ Complete Cleanup

To remove BandCtl and all limits completely:

1. Run BandCtl: `sudo bandctl`
2. Select option `9` (COMPLETE CLEANUP)
3. Type `DELETE ALL` to confirm
4. All limits, configurations, and services will be removed

---

## 📝 Logging

All actions are logged to `/var/log/bandctl.log`:

```bash
# View recent logs
tail -f /var/log/bandctl.log

# Search for specific port
grep "port=443" /var/log/bandctl.log
```

---

## ❓ Troubleshooting

### Limits not active after reboot?

BandCtl's timer service retries every 30 seconds. Wait up to 2 minutes after boot:

```bash
# Check auto-restore status
sudo bandctl --status

# Force restore manually
sudo bandctl --restore

# Check logs
tail -20 /var/log/bandctl.log
```

### "Failed to apply limit" error?

- Ensure network interface is up: `ip link show`
- Check kernel modules: `lsmod | grep sch_htb`
- Run option 5 to reapply all limits

### Port not showing in statistics?

- Generate traffic on that port first
- Wait a few seconds for statistics to update
- Use `tc -s class show dev eth0` to see raw data

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

---

## 📄 License

MIT License - Free for personal and commercial use.

---

## ⚠️ Disclaimer

BandCtl uses Linux Traffic Control (tc) which requires root privileges. Use responsibly and ensure you have proper authorization to limit bandwidth on your server.

---

## 🌟 Star History

If you find BandCtl useful, please consider giving it a star on GitHub!

---

## 📞 Support

For issues and feature requests, please open an issue on GitHub.

---

**Made with ❤️ for the Linux Community**

*BandCtl - Take Control of Your Bandwidth*
```
