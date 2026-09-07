BIN := bin
APP := $(BIN)/containerbar.app
GO  ?= go

.PHONY: all check clean test e2e docs-check docs-generate install
all: $(BIN)/containerctl $(BIN)/containerdns $(APP)

$(BIN)/containerctl: $(shell find cmd/containerctl internal -name '*.go')
	$(GO) build -o $@ ./cmd/containerctl

$(BIN)/containerdns: $(shell find cmd/containerdns internal -name '*.go')
	$(GO) build -o $@ ./cmd/containerdns

# The menu bar app has to be a bundle: LSUIElement is what keeps it out of the
# Dock and the app switcher, and only Info.plist can say so.
$(APP): $(BIN)/containerctl $(BIN)/containerdns $(shell find cmd/containerbar -type f) $(shell find internal -name '*.go')
	mkdir -p $(APP)/Contents/MacOS
	$(GO) build -o $(APP)/Contents/MacOS/containerbar ./cmd/containerbar
	printf '%s\n' \
	  '<?xml version="1.0" encoding="UTF-8"?>' \
	  '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' \
	  '<plist version="1.0"><dict>' \
	  '  <key>CFBundleName</key><string>containerbar</string>' \
	  '  <key>CFBundleIdentifier</key><string>dev.containerctl.bar</string>' \
	  '  <key>CFBundleExecutable</key><string>containerbar</string>' \
	  '  <key>CFBundlePackageType</key><string>APPL</string>' \
	  '  <key>CFBundleShortVersionString</key><string>0.1</string>' \
	  '  <key>LSUIElement</key><true/>' \
	  '  <key>LSMinimumSystemVersion</key><string>13.0</string>' \
	  '</dict></plist>' > $(APP)/Contents/Info.plist
	plutil -lint $(APP)/Contents/Info.plist >/dev/null
	@# containerbar hands the privileged steps to the containerctl beside it, and
	@# registers a launchd job pointing at the containerdns beside it.
	cp $(BIN)/containerctl $(BIN)/containerdns $(APP)/Contents/MacOS/

check: all test docs-check
	$(GO) vet ./...
	@test -z "$$(gofmt -l cmd internal)" || { gofmt -l cmd internal; exit 1; }

test:
	$(GO) test ./...

docs-check: $(BIN)/containerctl
	$(GO) run ./cmd/docsgen
	$(GO) run ./cmd/docscheck

docs-generate: $(BIN)/containerctl
	$(GO) run ./cmd/docsgen -write

# Starts real containers.
e2e:
	CONTAINERCTL_E2E=1 $(GO) test ./... -count=1 -timeout 25m

# One-time machine setup. Everything after this runs unprivileged.
install: all
	$(BIN)/containerctl install

clean:
	rm -rf $(BIN)
