#!/bin/sh
set -e
# this file contains utillity functions for setting up USB gadget mode for
# mass storage.
# Adapted from https://git.sr.ht/~martijnbraam/thumbdrives
# see https://git.sr.ht/~martijnbraam/thumbdrives/tree/master/item/COPYING

CONFIGFS="/sys/kernel/config/usb_gadget"
GADGET="${CONFIGFS}/mythumb"

function err_exit() {
	echo "Error: ${1}"
	exit 1
}

function remove_gadget() {
	# only remove existing gadget
	[ -d "${GADGET}" ] || return

	# Disable the gadget
	echo "" > "${GADGET}"/UDC

	# Remove the functions from the config
	for func in "${GADGET}/configs/"*/*.*; do
		rm "${func}"
	done

	# Remove the language data from the config
	for lang in "${GADGET}"/configs/*/strings/*; do
		rmdir "${lang}"
	done

	# Remove the configurations
	for config in "${GADGET}"/configs/*/; do
		rmdir "${config}"
	done

	# Remove the defined functions
	for func in "${GADGET}"/functions/*/; do
		rmdir "${func}"
	done

	# Remove the defined language data
	for lang in "${GADGET}"/strings/*; do
		rmdir "${lang}"
	done

	# Remove the gadget
	rmdir "${GADGET}"
}

function disable_existing_gadgets() {
	for dis_gadget in "${CONFIGFS}"/*/UDC; do
		echo > "${dis_gadget}"
	done
}

function create_gadget() {
	local backing="${1}"
	local devtype="${2}"

	mkdir "${GADGET}"
	echo "0x1209" > "${GADGET}/idVendor" # Generic
	echo "0x4202" > "${GADGET}/idProduct" # Random id

	# English locale
	local dev_locale="${GADGET}/strings/0x409"
	mkdir ${dev_locale} || err_exit "Could not create ${dev_locale}"
	echo "Phone" > "${dev_locale}/manufacturer"
	echo "BLEH" > "${dev_locale}/product"
	echo "mythumb" > "${dev_locale}/serialnumber"

	# Mass storage function
	local func="${GADGET}/functions/mass_storage.0"
	local lun="${func}/lun.0"
	mkdir ${func} || err_exit "Could not create ${func}"
	mkdir ${lun} || err_exit "Could not create ${lun}"

	# Configuration instance
	local config="${GADGET}/configs/c.1"
	local conf_locale="${config}/strings/0x409"
	mkdir ${config} || err_exit "Coud not create ${config}"
	mkdir ${LOCALE} || err_exit "Coud not create ${LOCALE}"
	echo "mythumb" > "${LOCALE}/configuration"

	# Link mass storage gadget to backing file
	echo "${devtype}" > "${lun}/cdrom"
	echo "${backing}" > "${lun}/file"

	# Mass storage hardware name
	echo "mythumb" > "${LUN}/inquiry_string"

	# Add mass storage to the configuration
	ln -s "${func}" "${config}"

	# Link to controller
	echo "$(ls /sys/class/udc)" > ${GADGET}/UDC || ( err_exit "Couldn't write to UDC" )
}


function mount_mass_storage() {
	remove_gadget "${GADGET}"
	disable_existing_gadgets
	create_gadget "${1}" "0"
}
function mount_cdrom() {
	remove_gadget "${GADGET}"
	disable_existing_gadgets
	create_gadget "${1}" "1"
}
function unmount() {
	remove_gadget "${GADGET}"
}
