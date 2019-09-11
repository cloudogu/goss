# Set these to the desired values
ARTIFACT_ID=ces-goss
VERSION=0.3.5

GOSS_UPSTREAM_VERSION=${VERSION}

MAKEFILES_VERSION=1.0.6

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
#include build/make/dependencies-glide.mk
#include build/make/build.mk
#include build/make/unit-test.mk
#include build/make/static-analysis.mk
include build/make/clean.mk
include build/make/package-debian.mk
include build/make/digital-signature.mk
#include build/make/yarn.mk
#include build/make/bower.mk

default: debian signature

$(DOWNLOAD):
	install -d -m 0755 ${DATA_DIR}/usr/bin
	curl -L https://github.com/aelsabbahy/goss/releases/download/v${GOSS_UPSTREAM_VERSION}/goss-linux-amd64 -o $@
	chmod 0755 $@

.PHONY: update-makefiles
update-makefiles: $(TMP_DIR)
	@echo Updating makefiles...
	@curl -L --silent https://github.com/cloudogu/makefiles/archive/v$(MAKEFILES_VERSION).tar.gz > $(TMP_DIR)/makefiles-v$(MAKEFILES_VERSION).tar.gz

	@tar -xzf $(TMP_DIR)/makefiles-v$(MAKEFILES_VERSION).tar.gz -C $(TMP_DIR)
	@cp -r $(TMP_DIR)/makefiles-$(MAKEFILES_VERSION)/build/make $(BUILD_DIR)
