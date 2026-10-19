PREFIX ?= /usr
DESTDIR ?=
NMCONFDIR ?= $(PREFIX)/lib/NetworkManager/conf.d
# libinput reads its quirks in version order and the last matching section
# wins, so this sorts after libinput's own 50-system-apple.quirks.
QUIRKSDIR ?= $(PREFIX)/share/libinput

all:

check:
	sh tests/run.sh

install:
	install -d $(DESTDIR)$(NMCONFDIR)
	install -m0644 network/networkmanager.conf $(DESTDIR)$(NMCONFDIR)/80-aurora-neo-mt7932.conf
	install -d $(DESTDIR)$(QUIRKSDIR)
	install -m0644 libinput/j700-trackpad.quirks $(DESTDIR)$(QUIRKSDIR)/60-aurora-neo-j700.quirks

.PHONY: all check install
