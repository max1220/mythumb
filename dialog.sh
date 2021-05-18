#!/bin/bash
set -e
DIALOG="dialog"
BACKTITLE="MyThumb"

. "$(dirname $0)/gadget_actions.sh"

function menu() {
	${DIALOG} --keep-tite --backtitle "${BACKTITLE}" --stdout --menu "${1}" 0 0 0 "${@:2}"
}
function msgbox() {
	${DIALOG} --keep-tite --msgbox "${1}" 0 0
}
function fselect() {
	${DIALOG} --keep-tite --stdout --fselect "${1}" 0 0
}
function inputbox() {
	${DIALOG} --keep-tite --stdout --inputbox "${1}" 0 0 "${2}"
}
function yesno() {
	${DIALOG} --keep-tite --yesno "${1}" 0 0
}
function alternate_screen() {
	[ "${1}" = "" ] && echo -e "\e[?1049l" || echo -e "\e[?1049h"
}
function err_exit() {
	alternate_screen y
	msgbox "Error:\n ${1}"
	alternate_screen
	echo -e "\nError:\n${1}\n"
	exit 1;
}

function mount_image() {
	local filename="$(fselect)"
	[ "${filename}" = "" ] && err_exit "No file selected!"
	alternate_screen
	mount_mass_storage "${filename}" || err_exit "Failed to host ${filename} as mass storage"
	alternate_screen y
	msgbox "Image ${filename} hosted as USB mass storage"
}

function mount_cdrom() {
	local filename="$(fselect)"
	[ "${filename}" = "" ] && err_exit "No file selected!"
	alternate_screen
	mount_cdrom "${filename}" || err_exit "Failed to host ${filename} as CDROM"
	alternate_screen y
	msgbox "ISO ${filename} hosted as USB CDROM"
}
function create_image() {
	local filename="$(inputbox "Enter filename")"
	[ "${filename}" = "" ] && err_exit "Empty filename!"
	local filesize_mb="$(inputbox "Enter filesize in MB:")"
	[ "${filesize_mb}" -eq "${filesize_mb}" ] || err_exit "Invalid filesize!"
	alternate_screen

	dd if="/dev/zero" of="${filename}" bs=1M count=${filesize_mb} || err_exit "Image creation failed!"

	alternate_screen y
	if yesno "Setup loopdev?"; then
		alternate_screen

		local loopdev="$(sudo losetup -f --show "${filename}")"
		echo "Loopdev created: ${loopdev}"

		alternate_screen y

		msgbox "Loopdev created: ${loopdev}"
	fi
}
function unmount() {
	alternate_screen
	remove_gadget || err_exit "Can't remove!"
	alternate_screen y
	msgbox "Unmounted ok."
}

function main_menu() {
	selected="$(menu "Main menu" \
		"image"		"Use an image as USB mass storage" \
		"cdrom"		"Use an image as USB CDROM" \
		"create"	"Create empty image" \
		"unmount"	"Disable USB gadget"
		)"

	if [ "${selected}" = "image" ]; then
		mount_image
	elif [ "${selected}" = "cdrom" ]; then
		mount_cdrom
	elif [ "${selected}" = "create" ]; then
		create_image
	elif [ "${selected}" = "unmount" ]; then
		unmount
	else
		break
	fi
}



# enable alternate screen buffer
alternate_screen y

# disable on any exit
trap "alternate_screen" EXIT

# show main menu
main_menu

# disable alternate screen buffer
alternate_screen

# we exited the main menu
echo "\n\nbye!"
exit 0
