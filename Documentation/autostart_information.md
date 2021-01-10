# Details on how the autostart of the FGTS game on Pi was achieved

This documents how the game starts up automatically.
A custom LXDE session autostart file (`/home/pi/.config/lxsession/LXDE-pi/autostart`) is read when the GUI starts up.
This file contains commands required to initialize the GUI environment (copied from `/etc/xdg/lxsession/LXDE-pi/autostart`), as well as the following line:
```
@/bin/bash /boot/fgts-pi/startup.sh
```
The `startup.sh` file contains:
```
#!/bin/bash
/boot/fgts-pi/game
# sudo poweroff
```
This will run the game's executable as soon as the GUI environment begins setting up.

By adding/removing to/from this `startup.sh` file, we can control what software starts up (ex. any software required for the controls).
Since it is stored under `/boot`, we can also edit it from Windows, in case we are not able to edit on the Pi.
