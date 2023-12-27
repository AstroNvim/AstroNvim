#!/bin/sh

gum style \
	--foreground 201 --border-foreground 201 --border double \
	--align center --width 50 --margin "1 2" --padding "2 4" \
	'PostgreSQL .::. PAJAK'

TYPE=$(gum choose "fix" "stop" "start")

if [ $TYPE = "fix" ]; then
	gum confirm "It will move data to olddata and initialize new data folder for PostgreSQL. Are you sure?"

	if [ $? -eq 0 ]; then
		sudo systemctl stop postgresql
		sudo rm -r /var/lib/postgres/tmp
		sudo rm -r /var/lib/postgres/olddata
		sudo mv /var/lib/postgres/data /var/lib/postgres/olddata
		sudo mkdir /var/lib/postgres/data /var/lib/postgres/tmp
		sudo chown postgres:postgres /var/lib/postgres/data /var/lib/postgres/tmp
		sudo -u postgres initdb --locale en_US.UTF-8 -D /var/lib/postgres/data
		sudo systemctl start postgresql
	fi
elif [ $TYPE = "start" ]; then
	sudo systemctl start postgresql
elif [ $TYPE = "stop" ]; then
	sudo systemctl stop postgresql
fi

gum style \
	--foreground 201 --border-foreground 201 --border double \
	--align center --width 50 --margin "1 2" --padding "2 4" \
	'Done!'
