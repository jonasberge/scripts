# Silent Thinkpad fans and fine-grained control

Control your Thinkpad's fans
and reduce noise by PWM'ing an even lower fan speed (`fan.sh`).
Also disables CPU `boost` and reduces CPU limits with `ryzenadj` (`init.sh`)
to limit the power of the device (and reduce heat output),
rendering the machine silent, yet fast enough for my tasks.

I get 2500 RPM instead of 3300 RPM on my laptop,
which is a significant transition from "audible" to "inaudble",
enabling my place to be dead silent
while still having a performant and cool enough machine.

The current configuration leaves the fan at 2500 RPM at all times,
unless it climbs to 60°C or above.
This is the config for when I use my laptop as a permanent desktop.

> **WARNING**  
> Use this at your own risk.
> Your laptop might overheat if this script ceases to work
> (because of a bug or another error).
> I always keep an eye on my temperature by having
> its status (CPU temperature and fan RPM) in my task bar.

Install and run:

```
sudo make install
sudo systemctl start silent
```

Stop it:

```
sudo systemctl stop silent
```
