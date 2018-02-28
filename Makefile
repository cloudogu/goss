UPSTREAM_VERSION=0.3.5

ARTIFACT_ID=ces-goss
VERSION=${UPSTREAM_VERSION}-1

TARGET_DIR=target
CONTROL_DIR=${TARGET_DIR}/control
DATA_DIR=${TARGET_DIR}/data

PACKAGE=${TARGET_DIR}/${ARTIFACT_ID}_${VERSION}.deb
DOWNLOAD=${DATA_DIR}/usr/bin/goss

# deployment
APT_API_BASE_URL=https://apt-api.cloudogu.com/api


build: ${PACKAGE}

${PACKAGE}: ${DOWNLOAD} ${TARGET_DIR}/debian-binary
	install -d -m 0755 ${TARGET_DIR} ${DATA_DIR} ${CONTROL_DIR}
# populating control directory
	sed -e "s/^Version:.*/Version: ${VERSION}/g" debian/control > ${CONTROL_DIR}/control
	chmod 0644 ${CONTROL_DIR}/control
# creating control.tar.gz
	tar cvzf ${TARGET_DIR}/control.tar.gz -C ${CONTROL_DIR} --owner=0 --group=0 .
# creating data.tar.gz
	tar cvzf ${TARGET_DIR}/data.tar.gz -C ${DATA_DIR} --owner=0 --group=0 .
# creating package
	ar rc $@ ${TARGET_DIR}/debian-binary ${TARGET_DIR}/control.tar.gz ${TARGET_DIR}/data.tar.gz
	@echo "... xenial package can be found at $@"

${TARGET_DIR}/debian-binary:
	install -d -m 0755 ${TARGET_DIR}
	echo "2.0" > $@

${DOWNLOAD}:
	install -d -m 0755 ${DATA_DIR}/usr/bin
	curl -L https://github.com/aelsabbahy/goss/releases/download/v${UPSTREAM_VERSION}/goss-linux-amd64 -o $@
	chmod 0755 $@


# deployment
#
deploy:
	@case X"${VERSION}" in *-SNAPSHOT) echo "i will not upload a snaphot version for you" ; exit 1; esac;
	@if [ X"${APT_API_USERNAME}" = X"" ] ; then echo "supply an APT_API_USERNAME environment variable"; exit 1; fi;
	@if [ X"${APT_API_PASSWORD}" = X"" ] ; then echo "supply an APT_API_PASSWORD environment variable"; exit 1; fi;
	@if [ X"${APT_API_SIGNPHRASE}" = X"" ] ; then echo "supply an APT_API_SIGNPHRASE environment variable"; exit 1; fi;
	curl --silent -u "${APT_API_USERNAME}":"${APT_API_PASSWORD}" -F file=@"${PACKAGE}" "${APT_API_BASE_URL}/files/xenial" |jq
	curl --silent -u "${APT_API_USERNAME}":"${APT_API_PASSWORD}" -X POST "${APT_API_BASE_URL}/repos/xenial/file/xenial/${ARTIFACT_ID}_${VERSION}.deb" |jq
	curl --silent -u "${APT_API_USERNAME}":"${APT_API_PASSWORD}" -X PUT -H "Content-Type: application/json" --data '{"Signing": { "Batch": true, "Passphrase": "${APT_API_SIGNPHRASE}"}}' ${APT_API_BASE_URL}/publish/xenial/xenial

undeploy:
	@case X"${VERSION}" in *-SNAPSHOT) echo "i will not upload a snaphot version for you" ; exit 1; esac;
	@if [ X"${APT_API_USERNAME}" = X"" ] ; then echo "supply an APT_API_USERNAME environment variable"; exit 1; fi;
	@if [ X"${APT_API_PASSWORD}" = X"" ] ; then echo "supply an APT_API_PASSWORD environment variable"; exit 1; fi;
	@if [ X"${APT_API_SIGNPHRASE}" = X"" ] ; then echo "supply an APT_API_SIGNPHRASE environment variable"; exit 1; fi;
	PREF=$$(curl --silent -u "${APT_API_USERNAME}":"${APT_API_PASSWORD}" "${APT_API_BASE_URL}/repos/xenial/packages?q=${ARTIFACT_ID}%20(${VERSION})"); \
	curl --silent -u "${APT_API_USERNAME}":"${APT_API_PASSWORD}" -X DELETE -H 'Content-Type: application/json' --data "{\"PackageRefs\": $${PREF}}" ${APT_API_BASE_URL}/repos/xenial/packages
	curl --silent -u "${APT_API_USERNAME}":"${APT_API_PASSWORD}" -X PUT -H "Content-Type: application/json" --data '{"Signing": { "Batch": true, "Passphrase": "${APT_API_SIGNPHRASE}"}}' ${APT_API_BASE_URL}/publish/xenial/xenial


clean:
	rm -rf target

dist-clean: clean


.PHONY: build
.PHONY: clean dist-clean
.PHONY: deploy undeploy
