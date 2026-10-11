PREFIX ?= /usr
DESTDIR ?=
UDEVRULESDIR ?= $(PREFIX)/lib/udev/rules.d
NMCONFDIR ?= $(PREFIX)/lib/NetworkManager/conf.d

all:

check:
	sh tests/run.sh

install:
	install -d $(DESTDIR)$(NMCONFDIR)
	install -m0644 network/networkmanager.conf $(DESTDIR)$(NMCONFDIR)/80-aurora-neo-mt7932.conf
	install -d $(DESTDIR)$(UDEVRULESDIR)
	install -m0644 udev/80-aurora-neo-charge-limit.rules $(DESTDIR)$(UDEVRULESDIR)/80-aurora-neo-charge-limit.rules

.PHONY: all check install
