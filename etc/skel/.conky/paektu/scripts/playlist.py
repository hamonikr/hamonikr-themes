#!/usr/bin/python3

# ref : https://winterland.no-ip.org/blog/controlling-lollypop-from-the-command-line/

import dbus

try:
    session_bus = dbus.SessionBus()
    lollypop_bus = session_bus.get_object("org.gnome.Lollypop","/org/mpris/MediaPlayer2")
    lollypop_properties = dbus.Interface(lollypop_bus,"org.freedesktop.DBus.Properties")
    metadata = lollypop_properties.Get("org.mpris.MediaPlayer2.Player", "Metadata")

    title = metadata['xesam:title']
    artist = metadata['xesam:albumArtist'][0]
    arturl = metadata['mpris:artUrl']

    if title == ".": 
        print('{0}'.format(artist))
    else:
        print('{0} by {1}'.format(title, artist))
except dbus.exceptions.DBusException as e:
    # print("DBus Error: ", e)
    pass
