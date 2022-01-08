# Automation and convenience scripts

This repository holds the following programs:

- `thinkpad-silent-fans`  
  Adds another (more silent) fan speed by manipulating PWM levels
  (2500 RPM instead the the lowest level, which is 3300 RPM on my machine)
  and reduces the power usage and consequent heat generation
  by lowering CPU limits.
- `gnirehtet-serial-autorun`  
  Run [gnirehtet](https://github.com/Genymobile/gnirehtet) (reverse tethering) once a specific android phone connects
  (specified with its serial) to have internet over USB.
- `brightness`  
  Brightness control of my external monitor,
  to increase and decrease its brightness level with my external keyboard.
- `phone-screen`  
  Starts [scrcpy](https://github.com/Genymobile/scrcpy)
  with sensible default parameters for my setup.
