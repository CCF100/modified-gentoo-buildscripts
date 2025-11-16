# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit dkms git-r3
EGIT_REPO_URI="https://github.com/lowell80/vendor-reset.git"
EGIT_BRANCH="master"


DESCRIPTION="Linux kernel vendor specific hardware reset module"
HOMEPAGE="https://github.com/gnif/vendor-reset"

LICENSE="GPL-2"
SLOT="0"

CONFIG_CHECK="FTRACE KPROBES PCI_QUIRKS KALLSYMS FUNCTION_TRACER"

src_compile() {
	local modlist=( vendor-reset )
	local modargs=( KDIR="${KV_OUT_DIR}" )
	dkms_src_compile
}

src_install() {
	dkms_src_install

	insinto /etc/modules-load.d/
	newins "${FILESDIR}"/modload.conf vendor-reset.conf
}
