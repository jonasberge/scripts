# Run gnirehtet on a single device automatically

Copy `.env.sample` to `.env` and set the following values:

* `DEVICE_SERIAL`: The serial of your phone.
  Get it with `$ adb devices`.
* `DNS_SERVERS_CSV`: Comma-separated list of DNS servers to use.
  You can use the default of gnirehtet, if you want (`8.8.8.8`).

Install and start with:

```
sudo make install
sudo systemctl start gnirehtet-autorun.service
```

Check status with:

```
watch -n .5 systemctl status gnirehtet-autorun.service
```

Connect your phone to have internet via USB.
Accept USB Debugging on your phone if not already done.

If you want the gnirehtet app to quit on your phone,
upon disconnecting your USB cable,
build and install gnirehtet with the following pull request:
https://github.com/Genymobile/gnirehtet/pull/399.

At the time of this writing you can build it by cloning
this repository and checking out the `stop-on-disconnect branch`:
https://github.com/chengyuhui/gnirehtet/tree/stop-on-disconnect

Then run `./gradlew build` and open Android Studio
to rebuild the apk and sign it (so it can be installed on your phone):
https://developer.android.com/studio/publish/app-signing

More info on building here:
https://github.com/Genymobile/gnirehtet/blob/master/DEVELOP.md
