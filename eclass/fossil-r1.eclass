fossil-r1_fetch() {
    local distdir=${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}
    EFOSSIL_STORE_DIR=${distdir}/fossil-r1-src
    einfo "local distdir: ${distdir}"
    einfo "EFOSSIL_STORE_DIR: ${EFOSSIL_STORE_DIR}"
    if [[ ! -d ${EFOSSIL_STORE_DIR} && ! ${EVCS_OFFLINE} ]]; then
            (
                addwrite /
                mkdir -vp "${EFOSSIL_STORE_DIR}"
            ) || die "Unable to create ${EFOSSIL_STORE_DIR}"
	fi

	einfo "Downloading sources from fossil repository..."
	if [ ${PV} == "9999" ]; then
	einfo "Using 9999 package, building directly from the latest commit"
	fi

    [[ ${EFOSSIL_REPO_URI} ]] || die "No URI provided and EFOSSIL_REPO_URI unset"


	addwrite ${EFOSSIL_STORE_DIR}
	cd ${EFOSSIL_STORE_DIR}
	fossil clone ${EFOSSIL_REPO_URI} --no-open || einfo "Source is already downloaded."
	einfo "Sources downloaded."
	ls ${FOSSIL_STORE_DIR}
	tree ${FOSSIL_STORE_DIR}
}

fossil-r1_src_unpack() {
    fossil-r1_fetch

    einfo "FOSSIL_SOURCES_DIR: ${EFOSSIL_STORE_DIR}"
    einfo "Sources will be opened to:  ${WORKDIR}/${P}"
    ls -lah ${WORKDIR} || die "Sources aren't there?"
    fossil open "${EFOSSIL_STORE_DIR}/${PN}.fossil" --workdir ${WORKDIR}/${P} || die
}

EXPORT_FUNCTIONS src_unpack
