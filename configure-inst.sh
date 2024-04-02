#!/bin/sh

BUFFER=$(cat $1)

ask() {
	unset answer
	argument="$1"
	[ "$1" = "-s" ] && shift;
	[ -n "$2" ] && >&2 echo -n "$1 [$2]: " || >&2 echo -n "$1: ";
	if [ "$argument" = "-s" ]
	then
		read -s answer
	else
		read answer
	fi
}

confirm() {
	>&2 echo -n "$1 [y/N]: "
	read answer
	if [ "$answer" != "y" ]; then
		return 1
	fi
}

jqw() {
	BUFFER=$(printf %s "$BUFFER" | jq "$@")
}

jq_select() {
	printf %s "$BUFFER" | jq "$@"
}

hostname=$(jq_select '.postInstallation[] | select(.operation == "hostname").params[0]')
ask "Enter hostname" "$hostname"
[ -n "$answer" ] && jqw --arg value "$answer" '(.postInstallation[] | select(.operation == "hostname")).params = [$value]'

locale=$(jq_select '.postInstallation[] | select(.operation == "locale").params[0]')
ask "Enter locale" "$locale"
[ -n "$answer" ] && jqw --arg value "$answer" '(.postInstallation[] | select(.operation == "locale")).params = [$value]'

layout=$(jq_select '.postInstallation[] | select(.operation == "keyboard").params[0]')
model=$(jq_select '.postInstallation[] | select(.operation == "keyboard").params[1]')
variant=$(jq_select '.postInstallation[] | select(.operation == "keyboard").params[2]')
confirm "Default keyboard layout is $layout, model $model, variant $variant.
Do you want to change keyboard settings?"
if [ $? -eq 0 ]; then
	ask "Enter keyboard layout" "$layout"
	[ -n "$answer" ] && jqw --arg value "$answer" '(.postInstallation[] | select(.operation == "keyboard")).params[0] = $value'
	ask "Enter keyboard model" "$model"
	[ -n "$answer" ] && jqw --arg value "$answer" '(.postInstallation[] | select(.operation == "keyboard")).params[1] = $value'
	ask "Enter keyboard variant" "${variant:-'none'}"
	[ -n "$answer" ] && jqw --arg value "$answer" '(.postInstallation[] | select(.operation == "keyboard")).params[2] = $value'
fi

timezone=$(jq_select '.postInstallation[] | select(.operation == "timezone").params[0]')
ask "Enter timezone" "$timezone"
[ -n "$answer" ] && jqw --arg value "$answer" '(.postInstallation[] | select(.operation == "timezone")).params = [$value]'

username=$(jq_select '.postInstallation[] | select(.operation == "adduser").params[0]')
fullname=$(jq_select '.postInstallation[] | select(.operation == "adduser").params[1]')
password=$(jq_select '.postInstallation[] | select(.operation == "adduser").params[3]')
confirm "Default user is $username with password $password.
Do you want to change user settings?"
if [ $? -eq 0 ]; then
	ask "Enter username" "$username"
	if [ -n "$answer" ]; then
		jqw --arg value "$answer" '(.postInstallation[] | select(.operation == "adduser")).params[0] = $value'
		jqw --arg value "chown -R $username:$username /home/$username" '(.postInstallation[] | select(.operation == "shell") | select(.params[0] == "chown -R vanillin:vanillin /home/vanillin")).params = [$value]'
	fi
	[ -n "$answer" ] && jqw --arg value "$answer" '(.postInstallation[] | select(.operation == "adduser")).params[0] = $value'
	ask "Enter full name" "$fullname"
	[ -n "$answer" ] && jqw --arg value "$answer" '(.postInstallation[] | select(.operation == "adduser")).params[1] = $value'
	ask -s "Enter password" "$password"
	[ -n "$answer" ] && jqw --arg value "$answer" '(.postInstallation[] | select(.operation == "adduser")).params[3] = $value'
fi

printf %s "$BUFFER" | jq