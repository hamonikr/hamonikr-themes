#!/bin/bash

cp -af usr/share/themes/* ~/.themes/
cp -af usr/share/icons/* ~/.icons/

if [ X$1 != "Xdark" ] ; then
    # Test HamoniKR-Light theme
    gsettings set org.cinnamon.desktop.interface icon-theme 'HamoniKR'
    gsettings set org.cinnamon.desktop.interface gtk-theme 'HamoniKR-Light'
    gsettings set org.cinnamon.desktop.wm.preferences theme 'HamoniKR'
    gsettings set org.cinnamon.theme name 'HamoniKR-Light'
    gsettings set org.cinnamon.desktop.interface cursor-theme 'HamoniKR'

else
    # Test HamoniKR-Dark theme
    gsettings set org.cinnamon.desktop.interface icon-theme 'HamoniKR'
    gsettings set org.cinnamon.desktop.interface gtk-theme 'HamoniKR-Dark'
    gsettings set org.cinnamon.desktop.wm.preferences theme 'HamoniKR'
    gsettings set org.cinnamon.theme name 'HamoniKR-Dark'    
    gsettings set org.cinnamon.desktop.interface cursor-theme 'HamoniKR' 
fi 
