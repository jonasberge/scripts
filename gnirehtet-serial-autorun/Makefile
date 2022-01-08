SERVICE_DIR=/etc/systemd/system
SCRIPT_DIR=/usr/local/libexec/gnirehtet-autorun

install:
	mkdir -p $(SCRIPT_DIR)
	cp *.service $(SERVICE_DIR)
	cp *.sh $(SCRIPT_DIR)
	cp .env $(SCRIPT_DIR)
	systemctl enable *.service

.PHONY: install
