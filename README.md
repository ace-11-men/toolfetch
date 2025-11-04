# toolfetch
a linux tool to show all tools in a system os includes all third party installed softwares 

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
