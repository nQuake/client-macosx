#!/bin/bash

# nQuake Bash Installer Script v2.2 (for Mac OS X)
# by Empezar

echo
echo Welcome to the nQuake v2.2 installation
echo =======================================
echo
echo Press ENTER to use [default] option.
echo

# Create the nQuake folder
defaultdir="~/Applications/nQuake"
read -p "Where do you want to install nQuake? [$defaultdir]: " directory
eval directory=$directory
if [ "$directory" = "" ]
then
        directory=$defaultdir
fi
eval directory=$directory
if [ -d "$directory" ]
then
	if [ -w "$directory" ]
	then
		created=0
	else
		echo;echo "Error: You do not have write access to $directory. Exiting."
		exit
	fi
else
	if [ -e "$directory" ]
	then
		echo;echo "Error: $directory already exists and is a file, not a directory. Exiting."
		exit
	else
		mkdir -p $directory 2> /dev/null
		created=1
	fi
fi
if [ -d "$directory" ] && [ -w "$directory" ]
then
        cd $directory
        directory=$(pwd)
else
        echo;echo "Error: You do not have write access to $directory. Exiting."
        exit
fi

# Search for pak1.pak
defaultsearchdir="~"
pak=""
read -p "Do you want setup to search for pak1.pak? (y/n) [n]: " search
if [ "$search" = "y" ]
then
	read -p "Enter path to search for pak1.pak [$defaultsearchdir]: " path
	if [ "$path" = "" ]
	then
		path=$defaultsearchdir
	fi
	eval path=$path
	pak=$(echo $(find $path -type f -iname "pak1.pak" -exec echo {} \; 2> /dev/null) | cut -d " " -f1)
        if [ "$pak" != "" ]
        then
                echo;echo "* Found at location $pak";echo
        else
                echo;echo "* Could not find pak1.pak";echo
        fi
fi

# Setup proxy server
read -p "Do you want to use a proxy server? (y/n) [n]: " useproxy
if [ "$useproxy" = "y" ]
then
        read -p "Enter <IP>:<port> to the proxy server: " ip
        if [ "$ip" = "" ]
        then
                echo;echo "* Proxy settings cancelled."
        else
                read -p "Enter <username>[:<password>] to use for proxy server [off]: " userpass
                if [ "$userpass" = "" ]
                then
                        proxy="-x $ip"
                else
                        proxy="-x $ip -u $userpass"
                fi
        fi
fi
echo

# Download nquake.ini
curl $proxy -s -o nquake.ini -O https://raw.githubusercontent.com/nQuake/client-win32/master/etc/nquake.ini
if [ -s "nquake.ini" ]
then
	echo foo >> /dev/null
else
	echo "Could not download nquake.ini. Better luck next time. Exiting."
        if [ "$created" = "1" ]
        then
		read -p "The directory $directory is about to be removed, press Enter to confirm or CTRL+C to exit." remove
                cd
                rm -rf $directory
        fi
	exit
fi

# List all the available mirrors
echo "From what mirror would you like to download nQuake?"
grep "[0-9]\{1,2\}=\".*" nquake.ini | cut -d "\"" -f2 | nl
read -p "Enter mirror number [random]: " mirror
mirror=$(grep "^$mirror=[fhtp]\{3,4\}://[^ ]*$" nquake.ini | cut -d "=" -f2)
if [ "$mirror" = "" ]
then
        echo;echo -n "* Using mirror: "
        RANGE=$(expr$(grep "[0-9]\{1,2\}=\".*" nquake.ini | cut -d "\"" -f2 | nl | tail -n1 | cut -f1) + 1)
        while [ "$mirror" = "" ]
        do
                number=$RANDOM
                let "number %= $RANGE"
                mirror=$(grep "^$number=[fhtp]\{3,4\}://[^ ]*$" nquake.ini | cut -d "=" -f2)
		mirrorname=$(grep "^$number=\".*" nquake.ini | cut -d "\"" -f2)
        done
        echo "$mirrorname"
fi
mkdir -p id1
echo

# Download all the packages
echo "=== Downloading ==="
echo "Downloading Quake Shareware..."
curl $proxy -o qsw106.zip -O $mirror/qsw106.zip
echo
if [ -s "qsw106.zip" ]
then
	if [ "$(du qsw106.zip | cut -f1)" \> "0" ]
	then
		echo "Downloading nQuake setup files (1 of 2)..."
		curl $proxy -o gpl.zip -O $mirror/gpl.zip
		echo
	fi
fi
if [ -s "gpl.zip" ]
then
	if [ "$(du gpl.zip | cut -f1)" \> "0" ]
	then
		echo "Downloading nQuake setup files (2 of 2)..."
		curl $proxy -o non-gpl.zip -O $mirror/non-gpl.zip
		echo
	fi
fi
if [ -s "non-gpl.zip" ]
then
        if [ "$(du non-gpl.zip | cut -f1)" \> "0" ]
        then
                echo "Downloading nQuake OS X files..."
                curl $proxy -o macosx.zip -O $mirror/macosx.zip
                echo
        fi
fi

# Terminate installation if not all packages were downloaded
if [ -s "macosx.zip" ]
then
	if [ "$(du macosx.zip | cut -f1)" \> "0" ]
	then
		echo foo >> /dev/null
	else
		echo "Some distribution files failed to download. Better luck next time. Exiting."
		rm -rf $directory/qsw106.zip $directory/gpl.zip $directory/non-gpl.zip $directory/macosx.zip $directory/nquake.ini
		if [ "$created" = "1" ]
		then
			read -p "The directory $directory is about to be removed, press Enter to confirm or CTRL+C to exit." remove
			cd
			rm -rf $directory
		fi
		exit
	fi
else
	echo "Some distribution files failed to download. Better luck next time. Exiting."
	rm -rf $directory/qsw106.zip $directory/gpl.zip $directory/non-gpl.zip $directory/macosx.zip $directory/nquake.ini
        if [ "$created" = "1" ]
        then
		read -p "The directory $directory is about to be removed, press Enter to confirm or CTRL+C to exit." remove
                cd
                rm -rf $directory
        fi
        exit
fi

# Extract all the packages
echo "=== Installing ==="
echo -n "* Extracting Quake Shareware..."
unzip -qqo qsw106.zip ID1/PAK0.PAK 2> /dev/null;echo "done"
echo -n "* Extracting nQuake setup files (1 of 2)..."
unzip -qqo gpl.zip 2> /dev/null;echo "done"
echo -n "* Extracting nQuake setup files (2 of 2)..."
unzip -qqo non-gpl.zip 2> /dev/null;echo "done"
echo -n "* Extracting nQuake OS X files..."
unzip -qqo macosx.zip 2> /dev/null;echo "done"
if [ "$pak" != "" ]
then
        echo -n "* Copying pak1.pak..."
        cp $pak $directory/id1/pak1.pak 2> /dev/null
	rm -rf $directory/id1/gpl_maps.pk3 $directory/id1/readme.txt
	echo "done"
fi
echo

# Rename files
echo "=== Cleaning up ==="
echo -n "* Renaming files..."
mv $directory/id1/PAK0.PAK $directory/id1/pak0.pak 2> /dev/null
mv $directory/ezquake/sb/update_sources.bat $directory/ezquake/sb/update_sources
echo "done"

# Remove the Windows specific files
echo -n "* Removing Windows specific binaries..."
rm -rf $directory/ezquake.exe $directory/ezquake/sb/wget.exe
echo "done"

# Remove distribution files
echo -n "* Removing distribution files..."
rm -rf $directory/qsw106.zip $directory/gpl.zip $directory/non-gpl.zip $directory/macosx.zip $directory/nquake.ini
echo "done"

# Make Mac OS X related updates
echo -n "* Making Mac OS X related updates..."
# Change wget to curl in update_sources
sed s/"wget -m -nd -O"/"curl $proxy -o"/ < $directory/ezquake/sb/update_sources > /tmp/.nquake.tmp
sed s/"http"/"-O http"/ < /tmp/.nquake.tmp > $directory/ezquake/sb/update_sources
echo "done"

# Convert DOS files to UNIX
echo -n "* Converting DOS files to UNIX..."
for file in $directory/readme.txt $directory/id1/readme.txt $directory/ezquake/cfg/* $directory/ezquake/configs/* $directory/ezquake/keymaps/* $directory/ezquake/sb/* $directory/ezquake/gnu.txt
do
	if [ -f "$file" ]
	then
		awk '{ sub("\r$", ""); print }' $file > /tmp/.nquake.tmp
		mv /tmp/.nquake.tmp $file
	fi
done
echo "done"

# Set the correct permissions
echo -n "* Setting permissions..."
find $directory -type f -exec chmod -f 644 {} \;
find $directory -type d -exec chmod -f 755 {} \;
chmod -f +x $directory/EZQuake-GL.app/Contents/MacOS/EZQuake-GL 2> /dev/null
chmod -f +x $directory/ezquake/sb/update_sources 2> /dev/null
echo "done"

echo;echo "Installation complete. Happy gibbing!"
