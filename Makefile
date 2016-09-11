
.PHONY: install i force f

all: install

install:
	/usr/bin/sudo ./install.sh

i: install

force:
	/usr/bin/sudo ./install.sh --force

f: force
