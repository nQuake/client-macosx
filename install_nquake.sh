#!/bin/bash

# nQuake Bash Installer Script v1.3a (for Mac OS X)
# by Empezar

echo
echo Welcome to the nQuake installation
echo ==================================
echo
echo Press ENTER to use [default] option.
echo

# Create the nQuake folder
defaultdir="/Applications/nQuake"
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
defaultsearchdir="~/"
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
curl $proxy -s -o nquake.ini -O http://nquake.sourceforge.net/nquake.ini
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
echo;echo

# Download all the packages
echo "=== Downloading ==="
echo "Downloading demos.zip..."
curl $proxy -o demos.zip -O $mirror/demos.zip
echo
if [ -s "demos.zip" ]
then
	if [ "$(du demos.zip | cut -f1)" \> "0" ]
	then
		echo "Downloading textures.zip..."
		curl $proxy -o textures.zip -O $mirror/textures.zip
		echo
	fi
fi
if [ -s "textures.zip" ]
then
	if [ "$(du textures.zip | cut -f1)" \> "0" ]
	then
		echo "Downloading models.zip..."
		curl $proxy -o models.zip -O $mirror/models.zip
		echo
	fi
fi
if [ -s "models.zip" ]
then
        if [ "$(du models.zip | cut -f1)" \> "0" ]
        then
                echo "Downloading skins.zip..."
                curl $proxy -o skins.zip -O $mirror/skins.zip
                echo
        fi
fi
if [ -s "skins.zip" ]
then
        if [ "$(du skins.zip | cut -f1)" \> "0" ]
        then
                echo "Downloading lits.zip..."
                curl $proxy -o lits.zip -O $mirror/lits.zip
                echo
        fi
fi
if [ -s "lits.zip" ]
then
        if [ "$(du lits.zip | cut -f1)" \> "0" ]
        then
                echo "Downloading ezquake.zip..."
                curl $proxy -o ezquake.zip -O $mirror/ezquake.zip
                echo
        fi
fi
if [ -s "ezquake.zip" ]
then
	if [ "$(du ezquake.zip | cut -f1)" \> "0" ]
	then
		echo "Downloading ezquake-macosx.zip..."
        	curl $proxy -o ezquake-macosx.zip -O $mirror/ezquake-macosx.zip
		echo
	fi
fi
if [ -s "ezquake-macosx.zip" ]
then
	if [ "$(du ezquake-macosx.zip | cut -f1)" \> "0" ]
	then
		echo "Downloading frogbot.zip..."
		curl $proxy -o frogbot.zip -O $mirror/frogbot.zip
		echo
	fi
fi
if [ -s "frogbot.zip" ]
then
	if [ "$(du frogbot.zip | cut -f1)" \> "0" ]
	then
		echo "Downloading maps.zip..."
		curl $proxy -o maps.zip -O $mirror/maps.zip
		echo
	fi
fi
if [ -s "maps.zip" ]
then
	if [ "$(du maps.zip | cut -f1)" \> "0" ]
	then
		echo "Downloading misc.zip..."
		curl $proxy -o misc.zip -O $mirror/misc.zip
		echo
	fi
fi
if [ -s "misc.zip" ]
then
	if [ "$(du misc.zip | cut -f1)" \> "0" ]
	then
		echo "Downloading misc-macosx.zip..."
		curl $proxy -o misc-macosx.zip -O $mirror/misc-macosx.zip
		echo
	fi
fi
if [ -s "misc-macosx.zip" ]
then
        if [ "$(du misc-macosx.zip | cut -f1)" \> "0" ]
        then
                echo "Downloading misc_gpl.zip..."
                curl $proxy -o misc_gpl.zip -O $mirror/misc_gpl.zip
                echo
        fi
fi
if [ -s "misc_gpl.zip" ]
then
        if [ "$(du misc_gpl.zip | cut -f1)" \> "0" ]
        then
                echo "Downloading misc_gpl-macosx.zip..."
                curl $proxy -o misc_gpl-macosx.zip -O $mirror/misc_gpl-macosx.zip
                echo
        fi
fi
if [ -s "misc_gpl-macosx.zip" ]
then
        if [ "$(du misc_gpl-macosx.zip | cut -f1)" \> "0" ]
        then
                echo "Downloading qsw106.zip..."
                curl $proxy -o qsw106.zip -O $mirror/qsw106.zip
                echo
        fi
fi

# Terminate installation if not all packages were downloaded
if [ -s "qsw106.zip" ]
then
	if [ "$(du qsw106.zip | cut -f1)" \> "0" ]
	then
		echo foo >> /dev/null
	else
		echo "Some distribution files failed to download. Better luck next time. Exiting."
		rm -rf $directory/demos.zip $directory/textures.zip $directory/models.zip $directory/skins.zip $directory/lits.zip $directory/ezquake.zip $directory/ezquake-macosx.zip $directory/frogbot.zip $directory/maps.zip $directory/misc.zip $directory/misc-macosx.zip $directory/misc_gpl.zip $directory/misc_gpl-macosx.zip $directory/qsw106.zip $directory/nquake.ini
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
	rm -rf $directory/demos.zip $directory/textures.zip $directory/models.zip $directory/skins.zip $directory/lits.zip $directory/ezquake.zip $directory/ezquake-macosx.zip $directory/frogbot.zip $directory/maps.zip $directory/misc.zip $directory/misc-macosx.zip $directory/misc_gpl.zip $directory/misc_gpl-macosx.zip $directory/qsw106.zip $directory/nquake.ini
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
echo -n "* Extracting demos.zip..."
unzip -qqo demos.zip 2> /dev/null;echo "done"
echo -n "* Extracting textures.zip..."
unzip -qqo textures.zip 2> /dev/null;echo "done"
echo -n "* Extracting models.zip..."
unzip -qqo models.zip 2> /dev/null;echo "done"
echo -n "* Extracting skins.zip..."
unzip -qqo skins.zip 2> /dev/null;echo "done"
echo -n "* Extracting lits.zip..."
unzip -qqo lits.zip 2> /dev/null;echo "done"
echo -n "* Extracting ezquake.zip..."
unzip -qqo ezquake.zip 2> /dev/null;echo "done"
echo -n "* Extracting ezquake-macosx.zip..."
unzip -qqo ezquake-macosx.zip 2> /dev/null;echo "done"
echo -n "* Extracting frogbot.zip..."
unzip -qqo frogbot.zip 2> /dev/null;echo "done"
echo -n "* Extracting maps.zip..."
unzip -qqo maps.zip 2> /dev/null;echo "done"
echo -n "* Extracting misc.zip..."
unzip -qqo misc.zip 2> /dev/null;echo "done"
echo -n "* Extracting misc-macosx.zip..."
unzip -qqo misc-macosx.zip 2> /dev/null;echo "done"
echo -n "* Extracting misc_gpl.zip..."
unzip -qqo misc_gpl.zip 2> /dev/null;echo "done"
echo -n "* Extracting misc_gpl-macosx.zip..."
unzip -qqo misc_gpl-macosx.zip 2> /dev/null;echo "done"
echo -n "* Extracting qsw106.zip..."
unzip -qqo qsw106.zip ID1/PAK0.PAK 2> /dev/null;echo "done"
if [ "$pak" != "" ]
then
	echo -n "* Copying pak1.pak..."
	cp $pak $directory/id1/pak1.pak 2> /dev/null;echo "done"
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
rm -rf $directory/ezquake-gl.exe $directory/ezquake/sb/wget.exe $directory/qw/qizmo $directory/qw/qwdtools
echo "done"

# Remove distribution files
echo -n "* Removing distribution files..."
rm -rf $directory/demos.zip $directory/textures.zip $directory/models.zip $directory/skins.zip $directory/lits.zip $directory/ezquake.zip $directory/ezquake-macosx.zip $directory/frogbot.zip $directory/maps.zip $directory/misc.zip $directory/misc-macosx.zip $directory/misc_gpl.zip $directory/misc_gpl-macosx.zip $directory/qsw106.zip $directory/nquake.ini
echo "done"

# Make Mac OS X related updates
echo -n "* Making Mac OS X related updates..."
# Change wget to curl in update_sources
sed s/"wget -m -nd -O"/"curl $proxy -o"/ < $directory/ezquake/sb/update_sources > /tmp/.nquake.tmp
sed s/"http"/"-O http"/ < /tmp/.nquake.tmp > $directory/ezquake/sb/update_sources
# Add some more suitable variables to config.cfg
echo >> $directory/ezquake/configs/config.cfg
cat $directory/ezquake/configs/config-macosx.cfg >> $directory/ezquake/configs/config.cfg
rm -rf $directory/ezquake/configs/config-macosx.cfg
echo "done"

# Convert DOS files to UNIX
echo -n "* Converting DOS files to UNIX..."
for file in $directory/ezquake/cfg/* $directory/ezquake/configs/* $directory/ezquake/keymaps/* $directory/ezquake/sb/* $directory/ezquake/gnu.txt $directory/qw/autoexec.cfg $directory/qw/pak.lst
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
