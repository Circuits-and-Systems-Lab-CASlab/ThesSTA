#!/bin/bash
# Generated Date: 2026-09-01 18:25:32

# reset locale to the default locale
unset LC_ALL LANG LC_CTYPE LC_COLLATE LC_NUMERIC LC_TIME LC_MONETARY LC_MESSAGES
export LC_ALL=C
export LANG=C

if [ -z "$LibreEDA_INSTALL_DIR" ]; then \

    echo "ERROR: LibreEDA Installation Directory is NOT specified. Please set the LibreEDA_INSTALL_DIR shell variable to the Installation path."; 

else
    export LD_PRELOAD=$LibreEDA_INSTALL_DIR/freetype-2.6.5/INSTALLED/lib/libfreetype.so.6;
    
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$LibreEDA_INSTALL_DIR/lib
    
    echo "LibreEDA Setup Complete.";
fi
