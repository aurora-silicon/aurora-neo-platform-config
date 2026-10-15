PREFIX ?= /usr
DESTDIR ?=
NMCONFDIR ?= $(PREFIX)/lib/NetworkManager/conf.d
DRACUTDIR ?= $(PREFIX)/lib/dracut
DISPLAYMOD = $(DRACUTDIR)/modules.d/90aurora-neo-display

all:

check:
	sh tests/run.sh

install:
	install -d $(DESTDIR)$(NMCONFDIR)
	install -m0644 network/networkmanager.conf $(DESTDIR)$(NMCONFDIR)/80-aurora-neo-mt7932.conf
	install -d $(DESTDIR)$(DISPLAYMOD) $(DESTDIR)$(DRACUTDIR)/dracut.conf.d
	install -m0755 dracut/90aurora-neo-display/module-setup.sh $(DESTDIR)$(DISPLAYMOD)/module-setup.sh
	install -m0755 dracut/90aurora-neo-display/aurora-neo-display-early.sh $(DESTDIR)$(DISPLAYMOD)/aurora-neo-display-early.sh
	install -m0644 dracut/90aurora-neo-display/aurora-neo-display-early.service $(DESTDIR)$(DISPLAYMOD)/aurora-neo-display-early.service
	install -m0644 dracut/50-aurora-neo-display.conf $(DESTDIR)$(DRACUTDIR)/dracut.conf.d/50-aurora-neo-display.conf

.PHONY: all check install
