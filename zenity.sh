#!/bin/bash
set -e
ZENITY="zenity"

. "$(dirname $0)/gadget_actions.sh"

function menu() {
	${ZENITY} --title "MyThumb" --list --text "${1}" --hide-header --hide-column=1 --column=short --column=desc "${@:2}"
}
function msgbox() {
	${ZENITY} --title "MyThumb" --info --text "${1}"
}
function fselect() {
	${ZENITY} --title "MyThumb" --file-selection "${1}"
}
function inputbox() {
	${ZENITY} --title "MyThumb" --entry --text "${1}"
}
function yesno() {
	${ZENITY} --title "MyThumb" --question --text "${1}"
}
function err_exit() {
	${ZENITY} --title "MyThumb" --error --text "Error:\n ${1}"
	exit 1;
}

function mount_image() {
	local filename="$(fselect "Select an image file")"
	[ "${filename}" = "" ] && err_exit "No file selected!"

	mount_mass_storage "${filename}" || err_exit "Failed to host ${filename} as mass storage"

	msgbox "Image ${filename} hosted as USB mass storage"
}

function mount_cdrom() {
	local filename="$(fselect "Select a CDROM image")"
	[ "${filename}" = "" ] && err_exit "No file selected!"

	mount_cdrom "${filename}" || err_exit "Failed to host ${filename} as CDROM"

	msgbox "ISO ${filename} hosted as USB CDROM"
}
function create_image() {
	local filename="$(inputbox "Enter filename")"
	[ "${filename}" = "" ] && err_exit "Empty filename!"
	local filesize_mb="$(inputbox "Enter filesize in MB:")"
	[ "${filesize_mb}" -eq "${filesize_mb}" ] || err_exit "Invalid filesize!"

	dd if="/dev/zero" of="${filename}" bs=1M count=${filesize_mb} || err_exit "Image creation failed!"

	if yesno "Setup loopdev?"; then
		local loopdev="$(sudo losetup -f --show "${filename}")"
		echo "Loopdev created: ${loopdev}"
		msgbox "Loopdev created: ${loopdev}"
	fi
}
function unmount() {
	remove_gadget || err_exit "Can't remove!"

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



# show main menu
main_menu

# we exited the main menu
echo "bye!"
exit 0
