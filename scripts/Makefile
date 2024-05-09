prefix ?= /usr/local/
build_dir ?= $(CURDIR)/build
appimage_dir ?= $(build_dir)/AppDir
install_prefix := $(appimage_dir)/usr
packages_dir ?= $(CURDIR)/packages
tmux_ver := $(shell cat $(packages_dir)/tmux.yaml | grep version | sed 's/.\+:\s//g')
ncurses_ver := $(shell cat $(packages_dir)/ncurses.yaml | grep version | sed 's/.\+:\s//g')
utempter_ver := $(shell cat $(packages_dir)/utempter.yaml | grep version | sed 's/.\+:\s//g')
libevent_ver := $(shell cat $(packages_dir)/libevent.yaml | grep version | sed 's/.\+:\s//g')
libevent_lib_ver := $(shell echo $(libevent_ver) | sed 's/\.[0-9]\+-stable//g')
utf8proc_ver := $(shell cat $(packages_dir)/utf8proc.yaml | grep version | sed 's/.\+:\s//g')
runtime_libs := libncursesw.so libtinfow.so libutempter.so libevent.so libutf8proc.so libevent-$(libevent_lib_ver).so
runtime_libs_src := $(addprefix $(build_dir)/deps/lib/,$(runtime_libs))
runtime_libs_dst := $(addprefix $(appimage_dir)/usr/lib/,$(runtime_libs))

all: $(appimage_dir)/usr/bin/tmux $(runtime_libs_dst) $(appimage_dir)/usr/share/terminfo

# tmux
$(appimage_dir)/usr/bin/tmux: $(build_dir)/tmux-$(tmux_ver)/tmux
	@$(MAKE) install -C $(build_dir)/tmux-$(tmux_ver)/

$(build_dir)/tmux-$(tmux_ver)/tmux: $(runtime_libs_src) | $(build_dir)/tmux-$(tmux_ver).tar.xz
	@cd $(build_dir)/tmux-$(tmux_ver); \
		export LD_LIBRARY_PATH="$(build_dir)/deps/lib:${LD_LIBRARY_PATH}"; \
		CFLAGS="            -I$(build_dir)/deps/include                                                                                              " \
		LIBNCURSESW_CFLAGS="$(shell PKG_CONFIG_PATH=$(build_dir)/deps/lib/pkgconfig/ pkg-config --cflags $(build_dir)/deps/lib/pkgconfig/ncursesw.pc)" \
		LIBTINFO_CFLAGS="   $(shell PKG_CONFIG_PATH=$(build_dir)/deps/lib/pkgconfig/ pkg-config --cflags $(build_dir)/deps/lib/pkgconfig/tinfow.pc  )" \
		LIBEVENT_CFLAGS="   $(shell PKG_CONFIG_PATH=$(build_dir)/deps/lib/pkgconfig/ pkg-config --cflags $(build_dir)/deps/lib/pkgconfig/libevent.pc)" \
		LIBUTF8PROC_CFLAGS="-I$(build_dir)/deps/include                                                                                              " \
		LDFLAGS="           -L$(build_dir)/deps/lib -lutempter                                                                                       " \
		LIBNCURSESW_LIBS="  $(shell PKG_CONFIG_PATH=$(build_dir)/deps/lib/pkgconfig/ pkg-config --libs   $(build_dir)/deps/lib/pkgconfig/ncursesw.pc)" \
		LIBTINFO_LIBS="     $(shell PKG_CONFIG_PATH=$(build_dir)/deps/lib/pkgconfig/ pkg-config --libs   $(build_dir)/deps/lib/pkgconfig/tinfow.pc  )" \
		LIBEVENT_LIBS="     $(shell PKG_CONFIG_PATH=$(build_dir)/deps/lib/pkgconfig/ pkg-config --libs   $(build_dir)/deps/lib/pkgconfig/libevent.pc)" \
		LIBUTF8PROC_LIBS="  -L$(build_dir)/deps/lib -lutf8proc                                                                                       " \
		./configure --prefix=$(appimage_dir)/usr --enable-utempter --enable-utf8proc --enable-sixel; \
		$(MAKE)

$(appimage_dir)/usr/share/terminfo: $(build_dir)/deps/lib/libncursesw.so
	@cd $(build_dir)/ncurses-$(ncurses_ver); \
		mkdir -p $@; \
		LD_LIBRARY_PATH=$(build_dir)/deps/lib ./progs/tic ./misc/terminfo.src -o $@

$(build_dir)/deps/lib/libncursesw.so: | $(build_dir)/ncurses-$(ncurses_ver).tar.gz $(build_dir)/deps
	@cd $(build_dir)/ncurses-$(ncurses_ver); \
		./configure --prefix=$(build_dir)/deps --with-shared --without-normal --without-debug --with-termlib \
		--with-pkg-config --with-pkg-config-libdir=$(build_dir)/deps/lib/pkgconfig/ \
		--enable-widec --enable-ext-colors --enable-ext-mouse --enable-bsdpad --enable-opaque-curses --enable-pc-files --enable-symlinks; \
		$(MAKE); \
		$(MAKE) install.includes; \
		$(MAKE) install.libs

$(build_dir)/deps/lib/libtinfow.so: $(build_dir)/deps/lib/libncursesw.so

$(build_dir)/deps/lib/libutempter.so: | $(build_dir)/libutempter-$(utempter_ver).tar.gz $(build_dir)/deps
	@cd $(build_dir)/libutempter-$(utempter_ver)/libutempter; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(build_dir)/deps libdir="/lib" libexecdir="/lib" includedir="/include" mandir="/share/man"

$(build_dir)/deps/lib/libevent.so: | $(build_dir)/libevent-$(libevent_ver).tar.gz $(build_dir)/deps
	@cd $(build_dir)/libevent-$(libevent_ver); \
		mkdir -p build; \
		cd build; \
		cmake ../ -DCMAKE_INSTALL_PREFIX=$(build_dir)/deps -DEVENT__DISABLE_OPENSSL=ON -DEVENT__DISABLE_TESTS=ON; \
		make -j install

$(build_dir)/deps/lib/libevent-$(libevent_lib_ver).so: $(build_dir)/deps/lib/libevent.so

$(build_dir)/deps/lib/libutf8proc.so: | $(build_dir)/utf8proc-$(utf8proc_ver).tar.gz $(build_dir)/deps
	@cd $(build_dir)/utf8proc-$(utf8proc_ver); \
		mkdir -p build; \
		cd build; \
		cmake ../ -DCMAKE_INSTALL_PREFIX=$(build_dir)/deps -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_INSTALL_FULL_LIBDIR=/lib; \
		cmake --build . --target install

# Download files
$(build_dir)/tmux-$(tmux_ver).tar.xz:
	@$(CURDIR)/download_file.sh https://github.com/tmux/tmux/releases/download/$(tmux_ver)/tmux-$(tmux_ver).tar.gz $(build_dir)/tmux-$(tmux_ver).tar.xz
	@tar -axf $(build_dir)/tmux-$(tmux_ver).tar.xz -C $(build_dir)

$(build_dir)/ncurses-$(ncurses_ver).tar.gz:
	@$(CURDIR)/download_file.sh https://invisible-mirror.net/archives/ncurses/ncurses-$(ncurses_ver).tar.gz $(build_dir)/ncurses-$(ncurses_ver).tar.gz
	@tar -axf $(build_dir)/ncurses-$(ncurses_ver).tar.gz -C $(build_dir)

$(build_dir)/libutempter-$(utempter_ver).tar.gz:
	@$(CURDIR)/download_file.sh https://github.com/altlinux/libutempter/archive/refs/tags/$(utempter_ver).tar.gz $(build_dir)/libutempter-$(utempter_ver).tar.gz
	@tar -axf $(build_dir)/libutempter-$(utempter_ver).tar.gz -C $(build_dir)

$(build_dir)/libevent-$(libevent_ver).tar.gz:
	@$(CURDIR)/download_file.sh https://github.com/libevent/libevent/releases/download/release-$(libevent_ver)/libevent-$(libevent_ver).tar.gz $(build_dir)/libevent-$(libevent_ver).tar.gz
	@tar -axf $(build_dir)/libevent-$(libevent_ver).tar.gz -C $(build_dir)

$(build_dir)/utf8proc-$(utf8proc_ver).tar.gz:
	@$(CURDIR)/download_file.sh https://github.com/JuliaLang/utf8proc/archive/v$(utf8proc_ver).tar.gz $(build_dir)/utf8proc-$(utf8proc_ver).tar.gz
	@tar -axf $(build_dir)/utf8proc-$(utf8proc_ver).tar.gz -C $(build_dir)

# runtime-libs
$(appimage_dir)/usr/lib/%.so: $(build_dir)/deps/lib/%.so | $(appimage_dir)/usr/lib
	/usr/bin/cp -P --preserve=mode,timestamps $<* $(appimage_dir)/usr/lib/

$(appimage_dir)/usr/lib/libevent-$(libevent_lib_ver).so: $(build_dir)/deps/lib/libevent-$(libevent_lib_ver).so | $(appimage_dir)/usr/lib
	/usr/bin/cp -P --preserve=mode,timestamps $(build_dir)/deps/lib/libevent-$(libevent_lib_ver).so* $(appimage_dir)/usr/lib/

# mkdir
$(build_dir)/deps:
	@mkdir -p $(build_dir)/deps

$(appimage_dir)/usr/lib:
	@mkdir -p $(appimage_dir)/usr/lib

clean:
	rm -rf $(build_dir) $(appimage_dir)
