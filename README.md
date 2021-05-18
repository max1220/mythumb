# MyThumb

This is a set of simple BASH scripts for interactively configuring the
USB gadget mode for mass storage.

For a proper application see: https://git.sr.ht/~martijnbraam/thumbdrives

There are two version:

* The `dialog.sh` script uses dialog for interactive usage,

* The `zenity.sh` script uses zenity for graphical usage.

You can also use the gadget function directly:
```
source gadget_actions.sh
mount_mass_storage /path/to/img
mount_cdrom
unmount
```
It also defines some other functions.


# Credit

`gadget_actions.sh` is adapted from https://git.sr.ht/~martijnbraam/thumbdrives.
