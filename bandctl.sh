#!/bin/bash

# BandCtl - Bandwidth Control Tool
# Version: 4.3.0
# Author: System Administrator
# Description: Clean view without status column

VERSION="4.3.0"
SCRIPT_NAME="BandCtl"
CONFIG_FILE="/etc/bandctl.conf"
LOG_FILE="/var/log/bandctl.log"
RESTORE_SCRIPT="/usr/local/bin/bandctl-restore"
SERVICE_FILE="/etc/systemd/system/bandctl.service"
TIMER_FILE="/etc/systemd/system/bandctl.timer"
SETUP_FLAG="/etc/bandctl.setup"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Global variables
declare -A RULES
declare -A RULES_METADATA
INTERFACE=""

print_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                                                           ║"
    echo "║     BANDCTL - Bandwidth Control Tool v${VERSION}              ║"
    echo "║     Clean & Simple Traffic Management                    ║"
    echo "║                                                           ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Error: This script must be run as root!${NC}" >&2
        exit 1
    fi
}

get_interface() {
    INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
    if [[ -z "$INTERFACE" ]]; then
        INTERFACE=$(ip link show | grep -v lo | grep -E 'state UP' | head -1 | awk -F: '{print $2}' | xargs)
    fi
    echo "$INTERFACE"
}

check_dependencies() {
    command -v tc >/dev/null 2>&1 || apt-get install -y iproute2
    command -v bc >/dev/null 2>&1 || apt-get install -y bc
    modprobe sch_htb 2>/dev/null
    modprobe cls_u32 2>/dev/null
}

load_rules() {
    RULES=()
    RULES_METADATA=()
    if [[ -f "$CONFIG_FILE" ]]; then
        while IFS='|' read -r port rate created modified; do
            if [[ -n "$port" && ! "$port" =~ ^# ]]; then
                RULES["$port"]="$rate"
                RULES_METADATA["$port"]="$created|$modified"
            fi
        done < "$CONFIG_FILE"
    fi
}

save_rules() {
    echo "# BandCtl Configuration v${VERSION}" > "$CONFIG_FILE"
    echo "# Generated: $(date)" >> "$CONFIG_FILE"
    echo "" >> "$CONFIG_FILE"
    
    for port in "${!RULES[@]}"; do
        local metadata="${RULES_METADATA[$port]}"
        if [[ -z "$metadata" ]]; then
            local current_date=$(date '+%Y-%m-%d %H:%M:%S')
            metadata="$current_date|$current_date"
        fi
        echo "${port}|${RULES[$port]}|${metadata}" >> "$CONFIG_FILE"
    done
}

convert_rate_to_kbit() {
    echo "$1 * 1000" | bc | cut -d. -f1
}

get_class_id() {
    echo $(( ($1 % 9000) + 1 ))
}

apply_limit() {
    local port=$1
    local rate_mbps=$2
    local interface=$3
    local rate_kbit=$(convert_rate_to_kbit "$rate_mbps")
    local class_id=$(get_class_id "$port")
    
    if ! tc qdisc show dev "$interface" 2>/dev/null | grep -q "htb 1:"; then
        tc qdisc add dev "$interface" root handle 1: htb default 9999 2>/dev/null
        tc class add dev "$interface" parent 1: classid 1:9999 htb rate 1000mbit 2>/dev/null
    fi
    
    tc filter del dev "$interface" protocol ip parent 1:0 prio 1 u32 match ip dport "$port" 0xffff 2>/dev/null
    tc filter del dev "$interface" protocol ip parent 1:0 prio 1 u32 match ip sport "$port" 0xffff 2>/dev/null
    tc class del dev "$interface" classid 1:$class_id 2>/dev/null
    
    tc class add dev "$interface" parent 1: classid 1:$class_id htb rate "${rate_kbit}kbit" ceil "${rate_kbit}kbit" burst 15k 2>/dev/null || return 1
    
    tc filter add dev "$interface" protocol ip parent 1:0 prio 1 u32 \
        match ip dport "$port" 0xffff \
        match ip protocol 6 0xff \
        flowid 1:$class_id 2>/dev/null
    
    tc filter add dev "$interface" protocol ip parent 1:0 prio 1 u32 \
        match ip sport "$port" 0xffff \
        match ip protocol 6 0xff \
        flowid 1:$class_id 2>/dev/null
    
    return 0
}

check_limit_active() {
    local port=$1
    local interface=$2
    tc filter show dev "$interface" 2>/dev/null | grep -q "dport $port"
}

add_limit() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}Add New Bandwidth Limit${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    read -p "Enter port number (1-65535): " port
    if [[ ! "$port" =~ ^[0-9]+$ ]] || [[ "$port" -lt 1 ]] || [[ "$port" -gt 65535 ]]; then
        echo -e "${RED}Invalid port!${NC}"
        return 1
    fi
    
    echo -e "\n${YELLOW}Speed limit in Mbps (examples: 1, 2.5, 5, 0.5):${NC}"
    read -p "Limit: " rate_input
    
    if [[ ! "$rate_input" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        echo -e "${RED}Invalid rate!${NC}"
        return 1
    fi
    
    get_interface > /dev/null
    
    if [[ -n "${RULES[$port]}" ]]; then
        echo -e "${YELLOW}Limit exists: ${RULES[$port]} Mbps${NC}"
        read -p "Update? (y/n): " confirm
        [[ "$confirm" != "y" ]] && return 1
        local old_class=$(get_class_id "$port")
        tc filter del dev "$INTERFACE" protocol ip parent 1:0 prio 1 u32 match ip dport "$port" 0xffff 2>/dev/null
        tc class del dev "$INTERFACE" classid 1:$old_class 2>/dev/null
    fi
    
    echo -e "${YELLOW}Applying...${NC}"
    if apply_limit "$port" "$rate_input" "$INTERFACE"; then
        local current_date=$(date '+%Y-%m-%d %H:%M:%S')
        RULES[$port]="$rate_input"
        RULES_METADATA[$port]="$current_date|$current_date"
        save_rules
        
        echo -e "${GREEN}✓ Limit ACTIVE now!${NC}"
        echo -e "  Port: $port | Rate: ${rate_input} Mbps"
        log_action "Added: port=$port rate=${rate_input}Mbps"
    else
        echo -e "${RED}Failed!${NC}"
        return 1
    fi
}

# ============================================
# FIXED: View Limits - WITHOUT STATUS column
# ============================================
view_limits() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}Bandwidth Limits${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if [[ ${#RULES[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No limits configured.${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        return 0
    fi
    
    get_interface > /dev/null 2>&1
    
    printf "${WHITE}%-10s %-15s${NC}\n" "PORT" "LIMIT (Mbps)"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    for port in "${!RULES[@]}"; do
        local rate="${RULES[$port]}"
        printf "%-10s %-15s\n" "$port" "$rate"
    done
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}Total: ${#RULES[@]} limit(s) configured${NC}"
}

# Simple view without any extra info (for edit/remove menus)
view_limits_simple() {
    printf "${WHITE}%-10s %-15s${NC}\n" "PORT" "LIMIT (Mbps)"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    for port in "${!RULES[@]}"; do
        local rate="${RULES[$port]}"
        printf "%-10s %-15s\n" "$port" "$rate"
    done
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

edit_limit() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}Edit Bandwidth Limit${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if [[ ${#RULES[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No limits configured.${NC}"
        return 0
    fi
    
    view_limits_simple
    echo ""
    read -p "Enter port number to edit (0 to cancel): " port
    
    if [[ "$port" == "0" || -z "${RULES[$port]}" ]]; then
        return 0
    fi
    
    local current="${RULES[$port]}"
    echo -e "\n${YELLOW}Current limit: ${current} Mbps${NC}"
    read -p "New limit (Mbps): " new_rate
    
    if [[ -n "$new_rate" && "$new_rate" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        local old_class=$(get_class_id "$port")
        tc filter del dev "$INTERFACE" protocol ip parent 1:0 prio 1 u32 match ip dport "$port" 0xffff 2>/dev/null
        tc class del dev "$INTERFACE" classid 1:$old_class 2>/dev/null
        
        if apply_limit "$port" "$new_rate" "$INTERFACE"; then
            local metadata="${RULES_METADATA[$port]}"
            IFS='|' read -r created modified <<< "$metadata"
            RULES[$port]="$new_rate"
            RULES_METADATA[$port]="$created|$(date '+%Y-%m-%d %H:%M:%S')"
            save_rules
            echo -e "${GREEN}✓ Updated to ${new_rate} Mbps${NC}"
            log_action "Edited: port=$port ${current}Mbps -> ${new_rate}Mbps"
        else
            echo -e "${RED}Failed!${NC}"
        fi
    fi
}

remove_limit_menu() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}Remove Bandwidth Limit${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if [[ ${#RULES[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No limits configured.${NC}"
        return 0
    fi
    
    view_limits_simple
    echo ""
    read -p "Enter port number to remove (0 to cancel): " port
    
    if [[ "$port" != "0" && -n "${RULES[$port]}" ]]; then
        local class_id=$(get_class_id "$port")
        tc filter del dev "$INTERFACE" protocol ip parent 1:0 prio 1 u32 match ip dport "$port" 0xffff 2>/dev/null
        tc class del dev "$INTERFACE" classid 1:$class_id 2>/dev/null
        
        unset RULES[$port]
        unset RULES_METADATA[$port]
        save_rules
        echo -e "${GREEN}✓ Removed${NC}"
        log_action "Removed: port=$port"
    fi
}

reapply_all_limits() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}Reapplying All Limits${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    get_interface > /dev/null
    tc qdisc del dev "$INTERFACE" root 2>/dev/null
    
    local success=0
    for port in "${!RULES[@]}"; do
        local rate="${RULES[$port]}"
        echo -n "  Port $port (${rate} Mbps)... "
        if apply_limit "$port" "$rate" "$INTERFACE"; then
            echo -e "${GREEN}OK${NC}"
            ((success++))
        else
            echo -e "${RED}FAILED${NC}"
        fi
        sleep 0.2
    done
    
    echo -e "\n${GREEN}Applied: $success of ${#RULES[@]}${NC}"
}

show_statistics() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}Traffic Statistics${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    get_interface > /dev/null 2>&1
    
    for port in "${!RULES[@]}"; do
        local class_id=$(get_class_id "$port")
        echo -e "${WHITE}Port $port (${RULES[$port]} Mbps):${NC}"
        tc -s class show dev "$INTERFACE" 2>/dev/null | grep -A 5 "1:$class_id" | grep -E "(Sent|dropped)" | sed 's/^/  /' || echo "  No traffic data"
        echo ""
    done
}

# Restore script with retry
create_restore_script() {
    cat > "$RESTORE_SCRIPT" << 'EOF'
#!/bin/bash
CONFIG_FILE="/etc/bandctl.conf"
LOG_FILE="/var/log/bandctl.log"
PID_FILE="/var/run/bandctl-restore.pid"

if [[ -f "$PID_FILE" ]]; then
    exit 0
fi
echo $$ > "$PID_FILE"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log "========== RESTORE STARTED =========="

for i in {1..12}; do
    INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
    if [[ -z "$INTERFACE" ]]; then
        INTERFACE=$(ip link show | grep -v lo | grep -E 'state UP' | head -1 | awk -F: '{print $2}' | xargs)
    fi
    
    if [[ -n "$INTERFACE" ]]; then
        log "✓ Interface: $INTERFACE (attempt $i)"
        break
    fi
    
    log "Waiting for network... ($i/12)"
    sleep 5
done

if [[ -z "$INTERFACE" ]]; then
    log "✗ No network interface"
    rm -f "$PID_FILE"
    exit 1
fi

sleep 3
modprobe sch_htb 2>/dev/null
modprobe cls_u32 2>/dev/null

if [[ ! -f "$CONFIG_FILE" ]]; then
    log "No config file"
    rm -f "$PID_FILE"
    exit 0
fi

get_class_id() {
    echo $(( ($1 % 9000) + 1 ))
}

RESTORED=0
while IFS='|' read -r port rate rest; do
    [[ -z "$port" || "$port" =~ ^# ]] && continue
    
    rate_kbit=$(echo "$rate * 1000" | bc | cut -d. -f1 2>/dev/null)
    [[ -z "$rate_kbit" ]] && rate_kbit=$(($rate * 1000))
    
    class_id=$(get_class_id "$port")
    
    if ! tc qdisc show dev "$INTERFACE" 2>/dev/null | grep -q "htb 1:"; then
        tc qdisc add dev "$INTERFACE" root handle 1: htb default 9999
        tc class add dev "$INTERFACE" parent 1: classid 1:9999 htb rate 1000mbit
    fi
    
    tc class del dev "$INTERFACE" classid 1:$class_id 2>/dev/null
    tc filter del dev "$INTERFACE" protocol ip parent 1:0 prio 1 u32 match ip dport "$port" 0xffff 2>/dev/null
    
    if tc class add dev "$INTERFACE" parent 1: classid 1:$class_id htb rate "${rate_kbit}kbit" ceil "${rate_kbit}kbit" burst 15k 2>/dev/null; then
        tc filter add dev "$INTERFACE" protocol ip parent 1:0 prio 1 u32 \
            match ip dport "$port" 0xffff \
            match ip protocol 6 0xff \
            flowid 1:$class_id 2>/dev/null
        
        tc filter add dev "$INTERFACE" protocol ip parent 1:0 prio 1 u32 \
            match ip sport "$port" 0xffff \
            match ip protocol 6 0xff \
            flowid 1:$class_id 2>/dev/null
        
        log "✓ Restored: port=$port rate=${rate}Mbps"
        ((RESTORED++))
    else
        log "✗ Failed: port=$port"
    fi
done < "$CONFIG_FILE"

log "Restored $RESTORED limits"
log "========== RESTORE FINISHED =========="

rm -f "$PID_FILE"
exit 0
EOF

    chmod +x "$RESTORE_SCRIPT"
}

create_systemd_service() {
    cat > "$SERVICE_FILE" << 'EOF'
[Unit]
Description=BandCtl Bandwidth Limiter
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/bandctl-restore
RemainAfterExit=yes
Restart=on-failure
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable bandctl.service 2>/dev/null
}

create_timer() {
    cat > "$TIMER_FILE" << 'EOF'
[Unit]
Description=BandCtl Retry Timer
Requires=bandctl.service

[Timer]
OnBootSec=30s
OnUnitActiveSec=30s
Persistent=true

[Install]
WantedBy=timers.target
EOF

    systemctl daemon-reload
    systemctl enable bandctl.timer 2>/dev/null
}

setup_persistence() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}Setting Up Auto-Restore${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    create_restore_script
    create_systemd_service
    create_timer
    
    (crontab -l 2>/dev/null | grep -v "bandctl-restore"; echo "@reboot sleep 15 && /usr/local/bin/bandctl-restore") | crontab - 2>/dev/null
    
    touch "$SETUP_FLAG"
    
    echo -e "\n${GREEN}✓ Auto-restore configured${NC}"
    echo -e "  • Systemd service (boot)"
    echo -e "  • Timer (retries every 30s)"
    echo -e "  • Cron (backup)"
    
    bash "$RESTORE_SCRIPT" 2>/dev/null
    echo -e "${GREEN}✓ Restore tested${NC}"
    
    log_action "Auto-restore configured"
}

show_status() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}BandCtl Status${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    get_interface > /dev/null
    echo -e "${GREEN}Interface:${NC} $INTERFACE"
    
    if [[ -f "$CONFIG_FILE" ]]; then
        local count=$(grep -c "^[0-9]" "$CONFIG_FILE" 2>/dev/null || echo "0")
        echo -e "${GREEN}Configured:${NC} $count limits"
    fi
    
    echo -e "\n${WHITE}Configured Limits:${NC}"
    view_limits_simple
    
    echo -e "\n${WHITE}Auto-Restore:${NC}"
    systemctl is-enabled bandctl.service 2>/dev/null | grep -q "enabled" && echo -e "  ${GREEN}✓${NC} Service: enabled"
    systemctl is-enabled bandctl.timer 2>/dev/null | grep -q "enabled" && echo -e "  ${GREEN}✓${NC} Timer: enabled"
}

complete_cleanup() {
    echo -e "${RED}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║              COMPLETE CLEANUP - WARNING!                  ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════╝${NC}"
    read -p "Type 'DELETE ALL' to confirm: " confirm
    [[ "$confirm" != "DELETE ALL" ]] && return 0
    
    echo -e "\n${YELLOW}Cleaning...${NC}"
    
    get_interface > /dev/null 2>&1
    [[ -n "$INTERFACE" ]] && tc qdisc del dev "$INTERFACE" root 2>/dev/null
    
    systemctl stop bandctl.service bandctl.timer 2>/dev/null
    systemctl disable bandctl.service bandctl.timer 2>/dev/null
    rm -f "$SERVICE_FILE" "$TIMER_FILE"
    
    crontab -l 2>/dev/null | grep -v "bandctl" | crontab - 2>/dev/null
    
    rm -f "$CONFIG_FILE" "$RESTORE_SCRIPT" "$SETUP_FLAG"
    
    RULES=()
    RULES_METADATA=()
    
    systemctl daemon-reload
    
    echo -e "${GREEN}✓ Complete cleanup done!${NC}"
    log_action "Complete cleanup performed"
    exit 0
}

main_menu() {
    if [[ ! -f "$RESTORE_SCRIPT" ]]; then
        setup_persistence
    fi
    
    while true; do
        print_banner
        echo -e "${WHITE}Main Menu:${NC}"
        echo -e "  ${GREEN}1)${NC} Add New Bandwidth Limit"
        echo -e "  ${GREEN}2)${NC} View All Limits"
        echo -e "  ${GREEN}3)${NC} Edit Existing Limit"
        echo -e "  ${GREEN}4)${NC} Remove Bandwidth Limit"
        echo -e "  ${GREEN}5)${NC} Reapply All Limits"
        echo -e "  ${GREEN}6)${NC} View Traffic Statistics"
        echo -e "  ${GREEN}7)${NC} Show System Status"
        echo -e "  ${GREEN}8)${NC} Reconfigure Auto-Restore"
        echo -e "  ${RED}9)${NC} COMPLETE CLEANUP"
        echo -e "  ${RED}10)${NC} Exit"
        echo ""
        read -p "Select [1-10]: " choice
        
        case $choice in
            1) add_limit ;;
            2) view_limits ;;
            3) edit_limit ;;
            4) remove_limit_menu ;;
            5) reapply_all_limits ;;
            6) show_statistics ;;
            7) show_status ;;
            8) setup_persistence ;;
            9) complete_cleanup ;;
            10) exit 0 ;;
        esac
        
        echo ""
        read -p "Press Enter..."
    done
}

main() {
    check_root
    check_dependencies
    load_rules
    get_interface > /dev/null 2>&1
    
    if [[ $# -eq 0 ]]; then
        main_menu
    else
        case "$1" in
            -a|--add) add_limit ;;
            -v|--view) view_limits ;;
            -e|--edit) edit_limit ;;
            -r|--remove) remove_limit_menu ;;
            -f|--fix) reapply_all_limits ;;
            --restore) bash "$RESTORE_SCRIPT" ;;
            --status) show_status ;;
            --cleanup) complete_cleanup ;;
            *) echo "BandCtl v$VERSION" ;;
        esac
    fi
}

main "$@"
