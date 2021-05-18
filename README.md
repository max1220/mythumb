# MyThumb

This is a set of simple BASH scripts for interactively configuring the
USB gadget mode for mass storage.

*For a proper application see: https://git.sr.ht/~martijnbraam/thumbdrives*



# Usage

* The `dialog.sh` script uses dialog for interactive usage,
* The `zenity.sh` script uses zenity for graphical usage.

Both scripts have a menu-based navigation.
In the main menu you can select an action to take:
 * mount an image
 * create an image
 * unmount image

You can also use the functions directly:
```
source gadget_actions.sh
mount_mass_storage /path/to/img
mount_cdrom /path/to/img
unmount
```
It also defines some other functions.



# Credit

`gadget_actions.sh` is adapted from https://git.sr.ht/~martijnbraam/thumbdrives.
