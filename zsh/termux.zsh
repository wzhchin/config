termux_banner() {
  echo "USER"
  echo "  $(whoami)"
  echo "IP"
  ifconfig | grep -w 'inet' | awk '{print " ", $2}'
  echo "SSH Port"
  echo "  8022"
}

termux_banner
