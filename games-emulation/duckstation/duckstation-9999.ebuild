# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# This ebuild is a port of this AUR package: https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=duckstation-git

EAPI=8

inherit xdg cmake desktop git-r3

DESCRIPTION="Fast Sony PlayStation (PSX) emulator"
HOMEPAGE="https://github.com/stenzek/duckstation"
EGIT_REPO_URI="https://github.com/stenzek/duckstation.git"
SRC_URI="https://github.com/duckstation/chtdb/releases/download/latest/cheats.zip -> duckstation-cheats.zip
	 https://github.com/duckstation/chtdb/releases/download/latest/patches.zip -> duckstation-patches.zip"
EGIT_CHECKOUT_DIR="${WORKDIR}/${PN}"
EGIT_SUBMODULES=()
#EGIT_COMMIT="v0.1-10193"
LICENSE="Attribution-NonCommercial-NoDerivatives 4.0 International"
SLOT="0"
IUSE="discord egl evdev fbdev +gamepad gbm +nogui qt6 retroachievements wayland X"

# Either or both frontends must be built
REQUIRED_USE="
	?? ( fbdev gbm )
	gbm? ( egl )
	wayland? ( egl )
"

BDEPEND="
	media-libs/libpng
	llvm-core/clang
	dev-libs/libbacktrace
	media-libs/libwebp
	app-arch/zstd
	virtual/pkgconfig
	wayland? ( kde-frameworks/extra-cmake-modules )
	=media-libs/freetype-2.13.3
	media-libs/libsoundtouch
	dev-cpp/gtest[abseil]
"
DEPEND="
	evdev? ( dev-libs/libevdev )
	gamepad? ( =media-libs/libsdl3-3.2.26 )
	gbm? ( x11-libs/libdrm )
	qt6? (
			dev-qt/qtcore
			dev-qt/qtgui
			dev-qt/qtnetwork
	)
	retroachievements? ( net-misc/curl[curl_ssl_gnutls] )
	X? (
			x11-libs/libX11
			x11-libs/libXrandr
	)
"
RDEPEND="${DEPEND}"

# Set working directory to checkout directory
S="${WORKDIR}/${PN}"

src_prepare() {
 default
 # eapply "${FILESDIR}/0001-Use-my-Qt6-please.patch"
 # Fetch dependencies, they need to be compiled seperately
 git-r3_fetch https://github.com/stenzek/shaderc.git HEAD
 git-r3_fetch https://github.com/abseil/abseil-cpp.git HEAD
 git-r3_fetch https://github.com/google/re2.git HEAD
 git-r3_fetch https://github.com/google/effcee.git HEAD
 git-r3_fetch https://github.com/KhronosGroup/SPIRV-Cross.git refs/tags/vulkan-sdk-1.4.328.1
 git-r3_fetch https://github.com/stenzek/cpuinfo.git HEAD
 git-r3_fetch https://github.com/stenzek/discord-rpc.git HEAD
 git-r3_fetch https://github.com/stenzek/soundtouch.git HEAD
 git-r3_fetch https://github.com/stenzek/plutosvg.git HEAD
 #git-r3_fetch https://github.com/pnggroup/libpng.git refs/tags/v1.6.50
 mkdir -v ${WORKDIR}/deps
 git-r3_checkout https://github.com/stenzek/shaderc.git ${WORKDIR}/deps/stenzek.shaderc
 git-r3_checkout https://github.com/abseil/abseil-cpp.git ${WORKDIR}/deps/stenzek.shaderc/third_party/abseil_cpp
 git-r3_checkout https://github.com/google/re2.git ${WORKDIR}/deps/stenzek.shaderc/third_party/re2
 git-r3_checkout https://github.com/google/effcee.git ${WORKDIR}/deps/stenzek.shaderc/third_party/effcee
 #git-r3_checkout https://github.com/pnggroup/libpng.git ${WORKDIR}/deps/libpng16
 git-r3_checkout https://github.com/KhronosGroup/SPIRV-Cross.git ${WORKDIR}/deps/spirv-cross
 git-r3_checkout https://github.com/stenzek/cpuinfo.git ${WORKDIR}/deps/stenzek.cpuinfo
 git-r3_checkout https://github.com/stenzek/discord-rpc.git ${WORKDIR}/deps/stenzek.discord-rpc
 git-r3_checkout https://github.com/stenzek/soundtouch.git ${WORKDIR}/deps/stenzek.soundtouch
 git-r3_checkout https://github.com/stenzek/plutosvg.git ${WORKDIR}/deps/stenzek.plutosvg
}

src_configure() {
      dependencies=(
      stenzek.shaderc
      spirv-cross
      stenzek.cpuinfo
      stenzek.discord-rpc
      stenzek.soundtouch
      stenzek.plutosvg
     )
     _source_var=(
      "stenzek.shaderc:SHADERC"
      "spirv-cross:SPIRV_CROSS:SPIRV-Cross"
      "stenzek.cpuinfo:CPUINFO"
      "stenzek.discord-rpc:DISCORD_RPC"
      "stenzek.soundtouch:SOUNDTOUCH"
      "stenzek.plutosvg:PLUTOSVG"
     )
     # bundle additional resources
    cp -v "${DISTDIR}/duckstation-cheats.zip" "${DISTDIR}/duckstation-patches.zip" "${S}/data/resources" || die
    mv -v "${S}/data/resources/duckstation-cheats.zip" "${S}/data/resources/cheats.zip" || die
    mv -v "${S}/data/resources/duckstation-patches.zip" "${S}/data/resources/patches.zip" || die
     for src in "${dependencies[@]}"; do
        local src_name=${src%%::*}
        for dep in "${_source_var[@]}"; do
            local dep_name dep_var dep_dir
            IFS=':' read dep_name dep_var dep_dir <<< "$dep"
	    #echo "${dep_name} ${dep_var} ${dep_dir}"
            if [ "$src_name" = "$dep_name" ]; then
        ls         [ -z "$dep_dir" ] && dep_dir=$dep_var
                local dep_opts
                dep_opts=$(
                    awk -v dir="$dep_dir" -v var="$dep_var" '
                      $0 ~ "^cd.+\\$" var {in_block=1; next}
                      $0 ~ "^cd.+" dir {in_block=1; next}
                      $0 ~ "^cd \\.\\." && in_block {in_block=0}
                      in_block
                    ' "$deps_script" | tr ' ' '\n' | grep '^-D' | grep -Ev '_COMPILER|_PREFIX_PATH|_INSTALL_PREFIX')

                echo "Building $dep_name..."
                cmake -B "build-$dep_name" -S ${WORKDIR}/deps/"$src_name" \
                    -G Ninja \
                    -DCMAKE_C_COMPILER=clang \
                    -DCMAKE_CXX_COMPILER=clang++ \
                    -DCMAKE_EXE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
                    -DCMAKE_MODULE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
                    -DCMAKE_SHARED_LINKER_FLAGS_INIT="-fuse-ld=lld" \
                    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
                    -DCMAKE_INSTALL_PREFIX=/usr \
		    -DSHADERC_SKIP_TESTS=ON \
		    -DSPIRV_CROSS_SHARED=ON \
                    $dep_opts || die
                ninja -C "build-$dep_name" || die
                DESTDIR="${S}/deps" ninja -C "build-$dep_name" install || die
            fi
        done
    done
	# Enforce using clang, gcc is unsupported
	CC="clang"
        CPP="clang-cpp"
        CXX="clang++"
        AR="llvm-ar"
        NM="llvm-nm"
        RANLIB="llvm-ranlib"

	#WORKING_DIR=$(pwd)
	#echo "Building libpng16..."
	#cd ${WORKDIR}/deps/libpng16
	#echo "Patching source..."
	#patch < ${WORKDIR}/duckstation/scripts/deps/libpng-1.6.50-apng.patch -p1
	#cmake -B "build-libpng16" -S ${WORKDIR}/deps/libpng16 \
	# -DPNG_TESTS=OFF || die
	#cd "build-libpng16"
	#make ${MAKEOPTS} || die
	#make install DESTDIR="${S}/deps" || die
	#cd ${WORKING_DIR}
	# Finally build duckstation

	cmake_prepare
	# unbreak the build
        sed -i 's/archlinux/fuck_you_stenzek/g' CMakeModules/DuckStationBuildSummary.cmake
        sed -i '0,/#ifdef __linux__/,/#endif/d' src/core/system.cpp
        sed -i '0,/CMAKE_FIND_ROOT_PATH/d' CMakeModules/DuckStationDependencies.cmake
        sed -i 's/NOT Qt6_DIR MATCHES/Qt6_DIR MATCHES/' CMakeModules/DuckStationDependencies.cmake
	sed -i '0,/#pragma once/a \
	#include "common/types.h"\
	#include <string_view>' \
	src/util/compress_helpers.h
	sed -i '0,/#include "wav_reader_writer.h"/a #include <utility>' \
    src/util/wav_reader_writer.cpp
	sed -i '0,/#include <string>/a #include <optional>' \
    src/util/media_capture.h
	sed -i '0,/^#include /!b;:a;n;/^#include /ba;i#include <optional>' \
    src/util/x11_tools.h
	sed -i '0,/#include/{a\
#include <cstdint>\
#include <ctime>\
#include <functional>\
#include "common/types.h"
}' src/core/gdb_server.h
	sed -i '0,/#include/{a\
#include <ctime>\
#include <functional>
}' src/core/system.h
	sed -i '0,/#include/{a\
#include <span>
}' src/core/cpu_core.h
	sed -i '0,/#include/{a\
#include <string>
}' src/core/gpu_thread.h
	sed -i '0,/#include/{a\
#include <mutex>
}' src/core/system_private.h
	sed -i '0,/#include/{a\
#include <utility>
}' src/core/gpu.h
	sed -i '0,/#include/{a\
#include <utility>
}' src/core/cpu_core.h
	sed -i '0,/#include/{a\
#include <array>
}' src/core/performance_counters.h
	sed -i '0,/#include/{a\
#include "common/types.h"
}' src/core/memory_card_image.h
	sed -i '0,/#include/{a\
#include <QSortFilterProxyModel>
}' src/duckstation-qt/gamelistwidget.cpp
	sed -i '0,/#include/{a\
#include <QTimeZone>
}' src/duckstation-qt/gamelistwidget.h
	sed -i '0,/#include/{a\
#include <QTimeZone>
}' src/duckstation-qt/gamesummarywidget.h
	sed -i '0,/#include/{a\
#include <QSortFilterProxyModel>
}' src/duckstation-qt/gamecheatsettingswidget.h
	sed -i '0,/#include/{a\
#include <QSortFilterProxyModel>
}' src/duckstation-qt/gamelistwidget.h
	sed -i '0,/#include/{a\
#include <QAbstractListModel>
}' src/duckstation-qt/qthost.h
	sed -i '0,/#include/{a\
#include "common/types.h"
}' src/duckstation-qt/setupwizarddialog.h
	sed -i '0,/#include/{a\
#include "common/types.h"
}' src/duckstation-qt/selectdiscdialog.h
	sed -i '0,/#include/{a\
#include <QFile>
}' src/duckstation-qt/qtutils.cpp
	sed -i '0,/#include/{a\
#include <QResource>
}' src/duckstation-qt/qthost.cpp

	local mycmakeargs=(
		-DCMAKE_CXX_STANDARD=20
		-DCMAKE_C_COMPILER=clang
                -DCMAKE_CXX_COMPILER=clang++
                -DCMAKE_EXE_LINKER_FLAGS_INIT="-fuse-ld=lld"
                -DCMAKE_MODULE_LINKER_FLAGS_INIT="-fuse-ld=lld"
                -DCMAKE_SHARED_LINKER_FLAGS_INIT="-fuse-ld=lld"
		-DBUILD_NOGUI_FRONTEND=$(usex nogui)
		-DBUILD_QT_FRONTEND=$(usex qt6)
		-DENABLE_CHEEVOS=$(usex retroachievements 1 0)
		-DENABLE_DISCORD_PRESENCE=$(usex discord 1 0)
		-DENABLE_DRMKMS=$(usex gbm 1 0)
		-DENABLE_EGL=$(usex egl 1 0)
		-DENABLE_EVDEV=$(usex evdev 1 0)
		-DENABLE_FBDEV=$(usex fbdev 1 0)
		-DENABLE_SDL=$(usex gamepad 1 0)
		-DENABLE_WAYLAND=$(usex wayland 1 0)
		-DENABLE_X11=$(usex X 1 0)
		-DCMAKE_PREFIX_PATH="/usr/lib64/cmake/SDL3;/usr/lib64;${S}/deps/usr;${S}/deps/usr/include;${EPREFIX}/usr;/usr/lib64/cmake/Qt6;${S}/deps/usr/local/lib64"
		-Dzstd_INCLUDE_DIR="/usr/include"
		-DWebP_INCLUDE_DIR="/usr/include/webp"
		-DPNG_PNG_INCLUDE_DIR="/usr/include/libpng16"
		-DJPEG_INCLUDE_DIR="/usr/include/"
		-DFREETYPE_INCLUDE_DIRS="/usr/include/freetype2/freetype"
		-Dharfbuzz_DIR="/usr/lib64/cmake/harfbuzz"
		-DQt6_DIR="/usr/lib64/cmake/Qt6"
		-DINCLUDE_DIRS="/usr/include"
		-DBUILD_SHARED_LIBS=OFF
	)
	#-Dspirv_cross_c_shared_DIR="${S}/deps/usr/share/spirv_cross_c/cmake"
	#-DPNG_PNG_INCLUDE_DIR="${S}/deps/usr/local/include/libpng16"
	cmake_src_configure
}

src_install() {
	dodoc README.md

	# Binary and resources files must be in same directory – installing in /opt
	insinto /opt/${PN}
	doins -r "${BUILD_DIR}"/bin/{duckstation-qt,resources,translations}
	doicon -s 512 ${WORKDIR}/duckstation/scripts/packaging/org.duckstation.DuckStation.png
	domenu ${WORKDIR}/duckstation/scripts/packaging/org.duckstation.DuckStation.desktop
	doins "${BUILD_DIR}"/bin/duckstation-qt
	fperms +x /opt/${PN}/duckstation-qt
	insinto /opt/duckstation/libs/
	#doins ${WORKDIR}/duckstation/deps/usr/lib64/libsoundtouch.so.2.3.3
	#dosym -r /opt/duckstation/libs/libsoundtouch.2.3.3 /opt/duckstation/libs/libsoundtouch.so.2
	doins -r ${WORKDIR}/duckstation/deps/usr/lib64/*
	insinto /usr/bin
	doins ${FILESDIR}/duckstation
	fperms +x /usr/bin/duckstation
}
