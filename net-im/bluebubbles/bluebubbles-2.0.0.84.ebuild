# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# NOTE: The comments in this file are for instruction and documentation.
# They're not meant to appear with your final, production ebuild.  Please
# remember to remove them before submitting or committing your ebuild.  That
# doesn't mean you can't add your own comments though.

# The EAPI variable tells the ebuild format in use.
# It is suggested that you use the latest EAPI approved by the Council.
# The PMS contains specifications for all EAPIs. Eclasses will test for this
# variable if they need to use features that are not universal in all EAPIs.
# If an eclass doesn't support latest EAPI, use the previous EAPI instead.
EAPI=8


# inherit lists eclasses to inherit functions from. For example, an ebuild
# that needs the eautoreconf function from autotools.eclass won't work
# without the following line:
inherit git-r3
#
# Eclasses tend to list descriptions of how to use their functions properly.
# Take a look at the eclass/ directory for more examples.

# Short one-line description of this package.
DESCRIPTION="A cross-platform app ecosystem, bringing iMessage to Android, PC (Windows, Linux, & even macOS), and Web!"

# Homepage, not used by Portage directly but handy for developer reference
HOMEPAGE="https://bluebubbles.app"

# Point to any required sources; these will be automatically downloaded by
# Portage.
EGIT_REPO_URI="https://github.com/BlueBubblesApp/bluebubbles-app/"
EGIT_COMMIT="v2.0.0+84-b.7"

# Source directory; the dir where the sources can be found (automatically
# unpacked) inside ${WORKDIR}.  The default value for S is ${WORKDIR}/${P}
# If you don't need to change it, leave the S= line out of the ebuild
# to keep it tidy.
#S="${WORKDIR}/${P}"


# License of the package.  This must match the name of file(s) in the
# licenses/ directory.  For complex license combination see the developer
# docs on gentoo.org for details.
LICENSE="Apache-2.0"

# The SLOT variable is used to tell Portage if it's OK to keep multiple
# versions of the same package installed at the same time.  For example,
# if we have a libfoo-1.2.2 and libfoo-1.3.2 (which is not compatible
# with 1.2.2), it would be optimal to instruct Portage to not remove
# libfoo-1.2.2 if we decide to upgrade to libfoo-1.3.2.  To do this,
# we specify SLOT="1.2" in libfoo-1.2.2 and SLOT="1.3" in libfoo-1.3.2.
# emerge clean understands SLOTs, and will keep the most recent version
# of each SLOT and remove everything else.
# Note that normal applications should use SLOT="0" if possible, since
# there should only be exactly one version installed at a time.
# Do not use SLOT="", because the SLOT variable must not be empty.
SLOT="0"

# Using KEYWORDS, we can record masking information *inside* an ebuild
# instead of relying on an external package.mask file.  Right now, you
# should set the KEYWORDS variable for every ebuild so that it contains
# the names of all the architectures with which the ebuild works.
# All of the official architectures can be found in the arch.list file
# which is in the profiles/ directory.  Usually you should just set this
# to "~amd64".  The ~ in front of the architecture indicates that the
# package is new and should be considered unstable until testing proves
# its stability.  So, if you've confirmed that your ebuild works on
# amd64 and ppc, you'd specify:
# KEYWORDS="~amd64 ~ppc"
# Once packages go stable, the ~ prefix is removed.
# For binary packages, use -* and then list the archs the bin package
# exists for.  If the package was for an x86 binary package, then
# KEYWORDS would be set like this: KEYWORDS="-* x86"
# Do not use KEYWORDS="*"; this is not valid in an ebuild context.
KEYWORDS="~amd64 ~arm64 ~arm"

# Comprehensive list of any and all USE flags leveraged in the ebuild,
# with some exceptions, e.g., ARCH specific flags like "amd64" or "ppc".
# Not needed if the ebuild doesn't use any USE flags.
IUSE=""

# A space delimited list of portage features to restrict. man 5 ebuild
# for details.  Usually not needed.
#RESTRICT="strip"


# Run-time dependencies. Must be defined to whatever this depends on to run.
# Example:
#    ssl? ( >=dev-libs/openssl-1.0.2q:0= )
#    >=dev-lang/perl-5.24.3-r1
# It is advisable to use the >= syntax show above, to reflect what you
# had installed on your system when you tested the package.  Then
# other users hopefully won't be caught without the right version of
# a dependency.
RDEPEND=""

# Build-time dependencies that need to be binary compatible with the system
# being built (CHOST). These include libraries that we link against.
# The below is valid if the same run-time depends are required to compile.
DEPEND="${RDEPEND} dev-lang/flutter-bin media-video/mpv"

# Build-time dependencies that are executed during the emerge process, and
# only need to be present in the native build system (CBUILD). Example:
BDEPEND="sys-apps/gendesk"


# The following src_configure function is implemented as default by portage, so
# you only need to call it if you need a different behaviour.
src_configure() {
	echo 'GIPHY_API_KEY = ""' >> ".env" || die
	#echo 'add_compile_options(-Wno-deprecated-declarations)' >> "linux/CMakeLists.txt"
	sed -i 's/objectbox: ^5.3.1/objectbox: ^5.3.2/g' pubspec.yaml || die
	#sed -i "s|import 'package:tray_manager/tray_manager.dart';|import 'package:tray_manager_workspace/tray_manager.dart';|g" lib/main.dart || die
	awk '{
		if ($0 ~ /^[[:space:]]*tray_manager: \^0\.5\.1[[:space:]]*$/) {
		#print "  name: system_tray"
		print "  tray_manager:"
		print "    git:"
		print "      url: https://github.com/CCF100/tray\_manager.git"
		#print "      ref: main"
		print "      path: packages/tray_manager"
	} else {
		print $0
	}
	}' "${S}/pubspec.yaml" > /var/tmp/pubspec.yaml. && mv /var/tmp/pubspec.yaml. "${S}/pubspec.yaml" || die

	# Create application file
	cd ${WORKDIR}
	gendesk -f -n -q --pkgname="${PN}" \
        --pkgdesc="${DESCRIPTION}" \
        --categories="Network" \
        --name="${PN}" \
        --exec="${PN} %U" || die
	cd ${S}

	# Setup .sh script
	sed -e "
        s/@appname@/${PN}/g
        s/@runname@/${PN}/g
        " "${FILESDIR}/${PN}.sh" >> ${WORKDIR}/${PN} || die
}

# The following src_compile function is implemented as default by portage, so
# you only need to call it, if you need different behaviour.
src_compile() {
	flutter clean || die
	flutter build linux || die
}

# The following src_install function is implemented as default by portage, so
# you only need to call it, if you need different behaviour.
src_install() {
	# You must *personally verify* that this trick doesn't install
	# anything outside of DESTDIR; do this by reading and
	# understanding the install part of the Makefiles.
	# This is the preferred way to install.
	#emake DESTDIR="${D}" install

	arch=$(uname -m)
	if [[ $arch == "x86_64" ]]; then
		folder="x64"
	elif [[ $arch == "aarch64" ]]; then
	        folder="arm64"
	fi

	exeinto /usr/lib/${PN}
	insinto /usr/lib/${PN}
	doexe build/linux/$folder/release/bundle/bluebubbles
	doins -r build/linux/$folder/release/bundle/lib
	doins -r build/linux/$folder/release/bundle/data
	into /usr
	dobin ${WORKDIR}/${PN}
	into /usr/share/applications
	doins ${WORKDIR}/${PN}.desktop
	einstalldocs
}
