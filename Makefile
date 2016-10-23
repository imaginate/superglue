
.PHONY: install i force f test t

all: install

install:
	/usr/bin/sudo ./install.sh

i: install

force:
	/usr/bin/sudo ./install.sh --force

f: force

test:
	./test/quick.test

t: test
