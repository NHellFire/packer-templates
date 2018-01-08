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

clean:
	$(RM) -R logs output

.PHONY: all clean
