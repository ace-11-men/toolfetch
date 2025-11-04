#!/usr/bin/env bash
# TOOLFETCH v3 — "Neofetch for Tools"
# Displays installed tools & apps with logo and color
#!/bin/bash
VERSION="3.0"

# Logo
logo="
████████╗ ██████╗  ██████╗ ██╗     ███████╗███████╗██╗  ██╗
╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██╔════╝██╔════╝██║  ██║
   ██║   ██║   ██║██║   ██║██║     █████╗  ███████╗███████║
   ██║   ██║   ██║██║   ██║██║     ██╔══╝  ╚════██║██╔══██║
   ██║   ╚██████╔╝╚██████╔╝███████╗███████╗███████║██║  ██║
   ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝
"

show_version() {
  echo "ToolFetch v$VERSION"
}

show_help() {
  echo "Usage: toolfetch [-f | -m | -j | -t | -v]"
  echo "  -f    Full detailed list (APT, Snap, Flatpak, Python, Node, etc.)"
  echo "  -m    Minimal system tools list"
  echo "  -j    Output as JSON"
  echo "  -t    Save to text file"
  echo "  -v    Show version"
  exit 0
}

# Author: cy-guru’s assistant
VERSION="3.0"

# ====== COLORS ======
BOLD=$(tput bold)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)

# ====== SETTINGS ======
MODE="normal"
OUTPUT_FILE=""
SHOW_FULL=0

# ====== PARSE FLAGS ======
while getopts "fmjtv" opt; do
  case $opt in
    f) SHOW_FULL=1 ;;
    m) MODE="minimal" ;;
    j) MODE="json" ;;
    t) MODE="txt" ;;
    v)
      echo "ToolFetch v$VERSION"
      exit 0
      ;;
    *) echo "Usage: toolfetch [-f] [-m] [-j] [-t] [-v]"; exit 1 ;;
  esac
done

# ====== FUNCTIONS ======
print_header() {
  [[ $MODE != "json" ]] && echo -e "\n${BOLD}${CYAN}==> $1${RESET}\n"
}

print_section() {
  local title=$1
  local cmd=$2
  local data
  if [[ $MODE == "json" ]]; then
    data=$(eval "$cmd" 2>/dev/null | head -n 200 | jq -R -s -c 'split("\n")[:-1]')
    echo "\"$title\": $data,"
  elif [[ $MODE == "txt" ]]; then
    echo -e "\n==> $title" >> "$OUTPUT_FILE"
    eval "$cmd" 2>/dev/null >> "$OUTPUT_FILE"
  else
    print_header "$title"
    eval "$cmd" 2>/dev/null | column -t | ( [[ $SHOW_FULL -eq 1 ]] || head -n 25 )
    [[ $SHOW_FULL -eq 0 ]] && echo -e "${YELLOW}... (showing first 25 items)${RESET}"
  fi
}

# ====== UBUNTU LOGO ======
if [[ $MODE != "json" && $MODE != "txt" ]]; then
  clear
  echo -e "${BOLD}${RED}"
  cat << "EOF"
             _                 _       
  _   _ _ __| |__   ___  _ __ | |_ ___ 
 | | | | '__| '_ \ / _ \| '_ \| __/ _ \
 | |_| | |  | | | | (_) | | | | ||  __/
  \__,_|_|  |_| |_|\___/|_| |_|\__\___|
                                        
EOF
  echo -e "${RESET}${BOLD}${MAGENTA}ToolFetch v${VERSION} — System Tools Dashboard${RESET}"
  echo -e "${BLUE}──────────────────────────────────────────────${RESET}"
fi

# ====== SYSTEM INFO ======
DISTRO=$(lsb_release -d 2>/dev/null | cut -f2 | sed 's/^[ \t]*//')
KERNEL=$(uname -rms)
UPTIME=$(uptime -p)
HOST=$(hostname)

if [[ $MODE == "json" ]]; then
  echo "{"
  echo "\"SystemInfo\": {"
  echo "\"OS\": \"$DISTRO\","
  echo "\"Kernel\": \"$KERNEL\","
  echo "\"Hostname\": \"$HOST\","
  echo "\"Uptime\": \"$UPTIME\""
  echo "},"
elif [[ $MODE == "txt" ]]; then
  OUTPUT_FILE="/tmp/toolfetch_$(date +%Y%m%d_%H%M%S).txt"
  echo "ToolFetch v$VERSION Report" > "$OUTPUT_FILE"
  echo "Generated: $(date)" >> "$OUTPUT_FILE"
  echo "System: $DISTRO" >> "$OUTPUT_FILE"
  echo "Kernel: $KERNEL" >> "$OUTPUT_FILE"
  echo "Hostname: $HOST" >> "$OUTPUT_FILE"
  echo "Uptime: $UPTIME" >> "$OUTPUT_FILE"
else
  print_header "System Info"
  echo -e "${GREEN}OS:${RESET} $DISTRO"
  echo -e "${GREEN}Kernel:${RESET} $KERNEL"
  echo -e "${GREEN}Hostname:${RESET} $HOST"
  echo -e "${GREEN}Uptime:${RESET} $UPTIME"
fi

# ====== STOP EARLY IF MINIMAL ======
if [[ $MODE == "minimal" ]]; then
  echo -e "\n${BOLD}${YELLOW}Summary Only (minimal mode)${RESET}\n"
  APT_COUNT=$(dpkg -l | grep '^ii' | wc -l)
  SNAP_COUNT=$(snap list 2>/dev/null | wc -l)
  FLATPAK_COUNT=$(flatpak list 2>/dev/null | wc -l)
  PIP_COUNT=$(pip3 list 2>/dev/null | wc -l)
  echo -e "${GREEN}APT:${RESET} $APT_COUNT | ${GREEN}Snap:${RESET} $SNAP_COUNT | ${GREEN}Flatpak:${RESET} $FLATPAK_COUNT | ${GREEN}Pip:${RESET} $PIP_COUNT"
  exit 0
fi

# ====== MAIN SECTIONS ======
print_section "APT Packages" "dpkg-query -W -f='\${Package}\t\${Version}\n' | sort"
print_section "Snap Packages" "snap list | tail -n +2 | awk '{print \$1, \$2}'"
print_section "Flatpak Packages" "flatpak list --app | awk '{print \$1, \$2}'"
print_section "Python (pip3) Packages" "pip3 list --format=columns"
print_section "Node.js (npm global) Packages" "npm -g list --depth=0 | grep '──' | sed 's/.*── //'"
print_section "Rust (cargo) Packages" "cargo install --list | grep -E '^[a-zA-Z0-9_-]+ v'"
print_section "Ruby Gems" "gem list"
print_section "/usr/local/bin Tools" "ls /usr/local/bin"
print_section "/opt Installed Software" "ls /opt"
print_section "Running Systemd Services" "systemctl list-units --type=service --state=running | awk '{print \$1}' | head -n 20"

# ====== SUMMARY ======
APT_COUNT=$(dpkg -l | grep '^ii' | wc -l)
SNAP_COUNT=$(snap list 2>/dev/null | wc -l)
FLATPAK_COUNT=$(flatpak list 2>/dev/null | wc -l)
PIP_COUNT=$(pip3 list 2>/dev/null | wc -l)

if [[ $MODE == "json" ]]; then
  echo "\"Summary\": {\"APT\": $APT_COUNT, \"Snap\": $SNAP_COUNT, \"Flatpak\": $FLATPAK_COUNT, \"Pip\": $PIP_COUNT}"
  echo "}"
elif [[ $MODE == "txt" ]]; then
  echo -e "\nSummary:" >> "$OUTPUT_FILE"
  echo "APT: $APT_COUNT | Snap: $SNAP_COUNT | Flatpak: $FLATPAK_COUNT | Pip: $PIP_COUNT" >> "$OUTPUT_FILE"
  echo -e "\nReport saved to: $OUTPUT_FILE"
else
  print_header "Summary"
  echo -e "${GREEN}APT:${RESET} $APT_COUNT | ${GREEN}Snap:${RESET} $SNAP_COUNT | ${GREEN}Flatpak:${RESET} $FLATPAK_COUNT | ${GREEN}Pip:${RESET} $PIP_COUNT"
  echo -e "\n${MAGENTA}${BOLD}ToolFetch v$VERSION completed successfully ✅${RESET}\n"
fi
