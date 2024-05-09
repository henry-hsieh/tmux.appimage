prefix ?= /usr/local/
build_dir := $(CURDIR)/build
appimage_dir := $(build_dir)/AppDir
packages_dir := $(CURDIR)/packages
tmux_ver := $(shell cat $(packages_dir)/tmux.yaml | grep version | sed 's/.\+:\s//g')

# Check if running inside Docker
DOCKER := $(shell if [ -f /.dockerenv ]; then echo "true"; else echo "false"; fi)
DOCKER_CMD := docker run --rm --user $(shell id -u):$(shell id -g) -v $(CURDIR):$(CURDIR) -w $(CURDIR) tmux

.PHONY: all clean docker_build test linuxdeploy_extract install

all: $(build_dir)/Tmux-x86_64.AppImage

# build appimage
$(build_dir)/Tmux-x86_64.AppImage: $(appimage_dir)/usr/bin/tmux | $(build_dir)/linuxdeploy-x86_64.AppImage $(appimage_dir)/usr/share/applications/tmux.desktop $(appimage_dir)/usr/share/icons/hicolor/scalable/apps/tmux.svg
	@cd $(build_dir); \
		LD_LIBRARY_PATH=$(appimage_dir)/usr/lib \
		$(build_dir)/linuxdeploy-x86_64.AppImage --appdir $(appimage_dir) --output appimage --custom-apprun=$(CURDIR)/data/tmux.bash || $(MAKE) linuxdeploy_extract -C $(CURDIR)

linuxdeploy_extract: $(appimage_dir)/usr/bin/tmux | $(build_dir)/linuxdeploy-x86_64.AppImage $(build_dir)/linuxdeploy $(appimage_dir)/usr/share/applications/tmux.desktop $(appimage_dir)/usr/share/icons/hicolor/scalable/apps/tmux.svg
	@cd $(build_dir)/linuxdeploy; \
	../linuxdeploy-x86_64.AppImage --appimage-extract; \
	cd $(build_dir); \
	LD_LIBRARY_PATH=$(appimage_dir)/usr/lib \
	$(build_dir)/linuxdeploy/squashfs-root/AppRun --appdir $(appimage_dir) --output appimage  --custom-apprun=$(CURDIR)/data/tmux.bash

$(appimage_dir)/usr/share/applications/tmux.desktop:
	@mkdir -p $(appimage_dir)/usr/share/applications
	@cp $(CURDIR)/data/tmux.desktop $(appimage_dir)/usr/share/applications

$(appimage_dir)/usr/share/icons/hicolor/scalable/apps/tmux.svg:
	@mkdir -p $(appimage_dir)/usr/share/icons/hicolor/scalable/apps
	@cp $(CURDIR)/data/tmux.svg $(appimage_dir)/usr/share/icons/hicolor/scalable/apps

# Define the Docker command
ifeq ($(DOCKER),true)
$(appimage_dir)/usr/bin/tmux:
	$(MAKE) -C scripts appimage_dir=$(appimage_dir) build_dir=$(build_dir) packages_dir=$(packages_dir)
else
$(appimage_dir)/usr/bin/tmux: docker_build
	$(DOCKER_CMD) $(MAKE) -C scripts appimage_dir=$(appimage_dir) build_dir=$(build_dir) packages_dir=$(packages_dir) -j
endif

# build docker image
docker_build:
	docker build -t tmux $(CURDIR)

# download files
$(build_dir)/linuxdeploy-x86_64.AppImage: | $(build_dir)
	@$(CURDIR)/scripts/download_file.sh https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage $(build_dir)/linuxdeploy-x86_64.AppImage
	@chmod +x $(build_dir)/linuxdeploy-x86_64.AppImage

# mkdir
$(build_dir):
	@mkdir -p $(build_dir)

$(build_dir)/linuxdeploy:
	@mkdir -p $(build_dir)/linuxdeploy

clean:
	rm -rf $(build_dir)

test: $(build_dir)/Tmux-x86_64.AppImage
	@$(CURDIR)/scripts/test_tmux.sh $< $(tmux_ver) && echo "Test passed" || echo "Test failed"

install: $(build_dir)/Tmux-x86_64.AppImage
	/usr/bin/install -p -D $< $(prefix)/bin/tmux.appimage
