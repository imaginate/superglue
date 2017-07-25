
################################################################################
## DECLARE PHONY TARGETS
################################################################################

.PHONY: \
	b build \
	c clean \
	f force \
	h help \
	i install install-f install-force \
	t test \
	x uninstall

################################################################################
## DEFINE DEFAULT TARGET
################################################################################

all: install

################################################################################
## DEFINE PHONY TARGETS
################################################################################

b: build
build: install

c: clean
clean: uninstall

f: force
force: install-force

h: help
help:
	@cat ./Makefile.help

i: install
install:
	@./install.sh
install-f: install-force
install-force:
	@./install.sh --force

t: test
test:
	@./test/bin/test.sh

x: uninstall
uninstall:
	@./install.sh --uninstall
