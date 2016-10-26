
.PHONY: install i force f test t

all: install

install:
	@./install.sh

i: install

force:
	@./install.sh --force

f: force

test:
	@./test/quick.test

t: test
