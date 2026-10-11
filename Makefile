PREFIX ?= /usr
DESTDIR ?=
NMCONFDIR ?= $(PREFIX)/lib/NetworkManager/conf.d

all:

check:
	sh tests/run.sh

install:
	install -d $(DESTDIR)$(NMCONFDIR)
	install -m0644 network/networkmanager.conf $(DESTDIR)$(NMCONFDIR)/80-aurora-neo-mt7932.conf

.PHONY: all check install
