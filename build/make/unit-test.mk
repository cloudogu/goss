UNIT_TEST_DIR=$(TARGET_DIR)/unit-tests
XUNIT_XML=$(UNIT_TEST_DIR)/unit-tests.xml
UNIT_TEST_LOG=$(UNIT_TEST_DIR)/unit-tests.log
COVERAGE_REPORT=$(UNIT_TEST_DIR)/coverage.out

PRE_UNITTESTS?=
POST_UNITTESTS?=

.PHONY: unit-test
unit-test: $(PRE_UNITTESTS) ${XUNIT_XML} $(POST_UNITTESTS)

${XUNIT_XML}: ${GOPATH}/bin/go-junit-report
	@mkdir -p $(UNIT_TEST_DIR)
	@echo 'mode: set' > ${COVERAGE_REPORT}
	@rm -f $(UNIT_TEST_LOG) || true
	@for PKG in $(PACKAGES) ; do \
    go test -v $$PKG -coverprofile=${COVERAGE_REPORT}.tmp 2>&1 | tee $(UNIT_TEST_LOG).tmp ; \
		cat ${COVERAGE_REPORT}.tmp | tail +2 >> ${COVERAGE_REPORT} ; \
		rm -f ${COVERAGE_REPORT}.tmp ; \
		cat $(UNIT_TEST_LOG).tmp >> $(UNIT_TEST_LOG) ; \
		rm -f $(UNIT_TEST_LOG).tmp ; \
	done
	@cat $(UNIT_TEST_LOG) | go-junit-report > $@
	@if grep '^FAIL' $(UNIT_TEST_LOG); then \
		exit 1; \
	fi

${GOPATH}/bin/go-junit-report:
	@go get -u github.com/jstemmer/go-junit-report
