# Wiring Information
Here is the documentation showing how the Raspberry Pi GPIOs should be connected to the buttons in the cabinet. Please note that each jumper should detach in the middle, so there should never be a need to unplug the jumpers from the Pi or from the buttons. This way, all jumpers can be detached in the middle when removing the Pi, to avoid having to reconnect to the Pi or the buttons.

## Table explanation

Each row in the table shows one jumper cable plugged into the Pi. It shows the colour of the jumper wire, which slot it goes to on the pin header, which GPIO it can be accessed with in software, and which button it should be connected to.

Jumper Colour: The colour of the jumper wire going from the buttons to the Pi

Jumper Slot #: The pin number on the header on the Pi.

Pi GPIO #: The GPIO number used to access this pin in software

Button Function: The actual connection made in the arcade machine's control panel.

If there are any questions about which GPIOs are which, and which slot on the board is which, please refer to [this site](https://pinout.xyz/).

## Table

| Jumper Colour | Jumper Slot # | Pi GPIO # | Button Function |
|---------------|---------------|-----------|-----------------|
| Black         | 06            | Ground    | Ground          |
| White         | 09            | Ground    | Unused          |
| Grey          | 14            | Ground    | Unused          |
| Purple        | 07            | 04        | Up              |
| Blue          | 11            | 17        | Down            |
| Green         | 13            | 27        | Left            |
| Yellow        | 15            | 22        | Right           |
| Orange        | 16            | 23        | Menu            |
| Red           | 18            | 24        | Jump            |
| Brown         | 22            | 25        | Tongue          |
