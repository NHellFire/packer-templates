TOPDIR := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
PATH := $(TOPDIR)/utils/bats-core/bin:$(PATH)
COMMON_SOURCES := ubuntu.json $(wildcard http/* scripts/* include/*)

CONFIGS := $(sort $(patsubst config/%.json,%,$(wildcard config/*.json)))
BOXES := $(foreach x,$(CONFIGS),$(x).box)

help:
	@echo Available targets:
	@$(foreach x,$(CONFIGS),echo "\t$(x)";)

all: $(BOXES)

$(CONFIGS): %: output/%.box
	@true

%.box: output/%.box
	@true

output/%.box: config/%.json $(COMMON_SOURCES)
	@echo ">>> Building $@"
	mkdir -p logs
	PACKER_KEY_INTERVAL=10ms packer build -var-file=$< ubuntu.json 2>&1 | tee logs/$*.log

test:
	@success=0; total=0; \
	for BOX in $(BOXES); do \
		echo ">>> Testing $$BOX"; \
		export BOX=$${BOX%.box}; \
		export TESTDIR="$(TOPDIR)/tests-data/$$BOX"; \
		mkdir -p "$$TESTDIR"; \
		tests/tests.bats && success=$$((success+1)); \
		printf "\n"; \
		rm -rf "$$TESTDIR"; \
		total=$$((total+1)); \
	done; \
	echo "$$success/$$total boxes passed"

clean:
	$(RM) -R logs output

.PHONY: all clean test
