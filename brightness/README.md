# Control brightness of an external monitor

Build:

```
go build -o brightness
```

Run with:

```
./brightness .monitor-brightness add
./brightness .monitor-brightness sub
```

This adds or subtracts brightness from your external monitor.
The state is saved in `.monitor-brightness`,
which is useful when switching desktops and wanting to retain the brightness,
or when restarting your computer.

Configure the brightness step size and the brightness limits,
by editing the constants
```STEP_COUNT```, ```MIN_BRIGHTNESS``` and ```MAX_BRIGHTNESS``` constants.
