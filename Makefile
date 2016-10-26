
.PHONY: install i force f test t clean c

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

clean:
	@./install.sh --clean
c: clean
