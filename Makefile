# Set these to the desired values
ARTIFACT_ID=goss
VERSION=0.3.5

MAKEFILES_VERSION=1.0.0

.DEFAULT_GOAL:=debian

# set PRE_COMPILE to define steps that shall be executed before the go build
# PRE_COMPILE=

# set PRE_UNITTESTS and POST_UNITTESTS to define steps that shall be executed before or after the unit tests
# PRE_UNITTESTS?=
# POST_UNITTESTS?=

include build/make/variables.mk

PREPARE_PACKAGE=$(BINARY)

$(BINARY):
	@mkdir -p target
	@curl -L https://github.com/aelsabbahy/goss/releases/download/v${VERSION}/goss-linux-amd64 -o $@

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


.PHONY: update-makefiles
update-makefiles:
	@echo Updating makefiles...
	@curl -L --silent https://github.com/cloudogu/makefiles/archive/v$(MAKEFILES_VERSION).tar.gz > $(TMP_DIR)/makefiles-v$(MAKEFILES_VERSION).tar.gz

	@tar -xzf $(TMP_DIR)/makefiles-v$(MAKEFILES_VERSION).tar.gz -C $(TMP_DIR)
	@cp -r $(TMP_DIR)/makefiles-$(MAKEFILES_VERSION)/build/make $(BUILD_DIR)