#!/bin/bash
#v1.2

check_root() {
	if [ "$EUID" -ne 0 ]; then
		echo -e "[!] This script must be run as root!"
		exit 1
	fi
}

# Define variables
IMAGE_URL="https://raw.githubusercontent.com/MR-Suda/New-Machine-Setup-RTX/main/Desktop_Wallpaper.png"
DOWNLOAD_DIR="/home/kali/Pictures"
BACKGROUND_DIR="$DOWNLOAD_DIR/Wallpapers"
EXTRACTED_IMAGE="$BACKGROUND_DIR/Desktop_Wallpaper.png" # Adjust if necessary

# Banner
banner() {
	# Install figlet silently if missing
	if ! command -v figlet >/dev/null 2>&1; then
		apt-get install -y figlet >/dev/null 2>&1
		hash -r
	fi

	# ANSI red
	RED='\033[1;31m'
	NC='\033[0m'

	clear
	echo
	sleep 0.4
	echo -e "${RED}$(figlet RTX)${NC}"
	echo
	echo -ne "[*] Initializing script "
	for i in {1..20}; do
		echo -ne "#"
		sleep 0.07
	done
	echo -e " [✓] Done"
	sleep 0.5
}

# Function to append alias to .bashrc if not already present
add_alias_to_bashrc() {
	local alias_command="alias xc='xclip -selection clipboard'"
	if ! grep -Fxq "$alias_command" ~/.bashrc; then
		echo "Adding xc alias to .bashrc..."
		echo "$alias_command" >> ~/.bashrc
	else
		echo "xc alias already exists in .bashrc."
	fi
}

# Function to append alias to .zshrc if not already present
add_alias_to_zshrc() {
	local alias_command="alias xc='xclip -selection clipboard'"
	if ! grep -Fxq "$alias_command" ~/.zshrc; then
		echo "Adding xc alias to .zshrc..."
		echo "$alias_command" >> ~/.zshrc
	else
		echo "xc alias already exists in .zshrc."
	fi
}

# Function to update and upgrade the system
update_system() {
	read -p "Do you want to update the system? (y/n): " update_choice
	if [[ "$update_choice" =~ ^[Yy]$ ]]; then
		echo "Updating the package list..."
		apt update >/dev/null 2>&1
		read -p "Do you want to upgrade the system after update? (y/n): " upgrade_after_update
		if [[ "$upgrade_after_update" =~ ^[Yy]$ ]]; then
			echo "Upgrading the system..."
			apt upgrade -y >/dev/null 2>&1
		else
			echo "Skipped system upgrade."
		fi
	else
		read -p "Do you want to upgrade the system without updating? (y/n): " upgrade_choice
		if [[ "$upgrade_choice" =~ ^[Yy]$ ]]; then
			echo "Upgrading the system..."
			apt upgrade -y >/dev/null 2>&1
		else
			echo "Skipped both update and upgrade."
		fi
	fi
}

# Function to install Geany
install_geany() {
	echo "Installing Geany..."
	apt-get install geany xclip feh -y >/dev/null 2>&1
}

# Function to download and set background image
set_background_image() {
	echo "[*] Setting desktop and lock screen wallpapers..."

	# Desktop wallpaper
	mkdir -p "$BACKGROUND_DIR"
	wget -qO "$EXTRACTED_IMAGE" "$IMAGE_URL"
	chown kali:kali "$EXTRACTED_IMAGE"

	# Apply desktop wallpaper via xfconf
	sudo -u kali DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus" \
	xfconf-query -c xfce4-desktop \
	-p /backdrop/screen0/monitorVirtual1/workspace0/last-image \
	-s "$EXTRACTED_IMAGE" -t string --create

	# Force reload of xfdesktop
	sudo -u kali DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus" xfdesktop --quit >/dev/null 2>&1
	sleep 1
	sudo -u kali DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus" xfdesktop >/dev/null 2>&1 &

	echo "[✓] Desktop wallpaper applied."

	# Lock screen wallpaper setup
	LOCKSCREEN_URL="https://raw.githubusercontent.com/MR-Suda/New-Machine-Setup-RTX/main/LockScreen_Wallpaper.png"
	LOCKSCREEN_IMAGE="/usr/share/backgrounds/LockScreen_Wallpaper.png"
	GREETER_CONF="/etc/lightdm/lightdm-gtk-greeter.conf"

	wget -qO "$LOCKSCREEN_IMAGE" "$LOCKSCREEN_URL"
	chmod 644 "$LOCKSCREEN_IMAGE"

	# Remove ALL background= lines to avoid conflicts
	sed -i '/^background[[:space:]]*=.*/d' "$GREETER_CONF"

	# Ensure [greeter] section exists
	if ! grep -q "^\[greeter\]" "$GREETER_CONF"; then
		echo -e "[greeter]\nbackground=$LOCKSCREEN_IMAGE" >> "$GREETER_CONF"
	else
		sed -i "/^\[greeter\]/a background=$LOCKSCREEN_IMAGE" "$GREETER_CONF"
	fi

	# Ensure greeter-session is set correctly
	if ! grep -q "^greeter-session=lightdm-gtk-greeter" /etc/lightdm/lightdm.conf; then
		sed -i "/^\[Seat:\*\]/a greeter-session=lightdm-gtk-greeter" /etc/lightdm/lightdm.conf
	fi

	echo "[✓] Lock screen wallpaper and greeter-session configured."
}

# Function to make Num Lock always on
enable_numlock_on_login() {
	echo "Enabling Num Lock at login..."

	if ! command -v numlockx >/dev/null 2>&1; then
		echo "Installing numlockx..."
		apt install -y numlockx >/dev/null 2>&1
	else
		echo "numlockx is already installed."
	fi

	CONFIG_FILE="/etc/lightdm/lightdm.conf"
	SETUP_LINE="greeter-setup-script=/usr/bin/numlockx on"

	if grep -Fxq "$SETUP_LINE" "$CONFIG_FILE"; then
		echo "Num Lock setup already exists in $CONFIG_FILE"
	else
		echo "Updating $CONFIG_FILE to enable Num Lock..."
		if grep -Fxq "[Seat:*]" "$CONFIG_FILE"; then
			sed -i "/^\[Seat:\*\]/a $SETUP_LINE" "$CONFIG_FILE"
		else
			echo -e "\n[Seat:*]\n$SETUP_LINE" | tee -a "$CONFIG_FILE" > /dev/null
		fi
		echo "Num Lock enabled at login."
	fi
}

# Rebooting the system
delayed_reboot() {
	echo
	echo -e "\033[1;33m[!] The system will reboot in -\033[0m"
	echo -e "(press Ctrl+C to cancel)"
	echo
	for i in 5 4 3 2 1; do
		echo -e "\033[1;31m$i...\033[0m"
		sleep 1
	done
	sleep 0.5
	/sbin/reboot
}

# Main script execution
banner
check_root
add_alias_to_zshrc
update_system
install_geany
set_background_image
enable_numlock_on_login
delayed_reboot
