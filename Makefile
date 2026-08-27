SHELL := /bin/zsh

APP_NAME := Receipt Archive
APP_PATH := dist/$(APP_NAME).app
ARCHIVE_PATH := dist/Receipt-Archive-macOS.zip
CACHE_ENV := CLANG_MODULE_CACHE_PATH="$(CURDIR)/work/clang-cache" SWIFTPM_MODULECACHE_OVERRIDE="$(CURDIR)/work/clang-cache" XDG_CACHE_HOME="$(CURDIR)/work/swift-cache"

.DEFAULT_GOAL := help

.PHONY: help test build run check package clean

help: ## Show available commands
	@awk 'BEGIN {FS = ":.*## "; printf "Receipt Archive development commands:\n\n"} /^[a-zA-Z_-]+:.*## / {printf "  %-10s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

test: ## Run the Swift test suite
	@mkdir -p work/clang-cache work/swift-cache
	$(CACHE_ENV) swift test --disable-sandbox

build: ## Build and ad-hoc sign the macOS application
	./scripts/build-app.sh

run: build ## Build and open the application
	open "$(APP_PATH)"

check: test build ## Run tests and validate the application bundle
	codesign --verify --deep --strict --verbose=2 "$(APP_PATH)"
	plutil -lint "$(APP_PATH)/Contents/Info.plist"
	git diff --check

package: check ## Create a distributable ZIP archive in dist/
	ditto -c -k --sequesterRsrc --keepParent "$(APP_PATH)" "$(ARCHIVE_PATH)"
	unzip -t "$(ARCHIVE_PATH)"

clean: ## Remove generated build, cache, and distribution files
	rm -rf .build work dist
