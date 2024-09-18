# Set these to the desired values
ARTIFACT_ID=ces-goss
VERSION=0.3.5-2

GOSS_UPSTREAM_VERSION=0.3.5

MAKEFILES_VERSION=4.4.0

.DEFAULT_GOAL:=default

# set PRE_COMPILE to define steps that shall be executed before the go build
# PRE_COMPILE=

# set PRE_UNITTESTS and POST_UNITTESTS to define steps that shall be executed before or after the unit tests
# PRE_UNITTESTS?=
# POST_UNITTESTS?=

# set PREPARE_PACKAGE to define a target that should be executed before the package build
PREPARE_PACKAGE=$(DOWNLOAD)

include build/make/variables.mk

DATA_DIR=${WORKDIR}/build/deb/content/data
DOWNLOAD=${DATA_DIR}/usr/bin/goss

# You may want to overwrite existing variables for pre/post target actions to fit into your project.

include build/make/info.mk
include build/make/clean.mk
include build/make/self-update.mk
include build/make/package-debian.mk
include build/make/deploy-debian.mk
include build/make/digital-signature.mk


default: debian signature

$(DOWNLOAD):
	install -d -m 0755 ${DATA_DIR}/usr/bin
	curl -L https://github.com/aelsabbahy/goss/releases/download/v${GOSS_UPSTREAM_VERSION}/goss-linux-amd64 -o $@
	chmod 0755 $@
