# Regression suite: tests/<name>.tcl runs through the tool, diffed against
# tests/<name>.ok. Add a test with a new .tcl file + `make regen-<name>`.
#
# Calls the binary directly, not its wrapper script (wrapper's `stty sane`
# breaks the exit code on a non-interactive shell).

# Falls back to LibreEDA_INSTALL_DIR so you don't have to set the path twice.
LIBREEDA_ROOT ?= $(LibreEDA_INSTALL_DIR)

# Tries LibreEDA, then falls back to older build names (ThesSTA, pathviz).
# Override LIBREEDA_BIN directly if needed.
LIBREEDA_BIN ?= $(firstword $(wildcard $(LIBREEDA_ROOT)/LibreEDA $(LIBREEDA_ROOT)/ThesSTA $(LIBREEDA_ROOT)/pathviz))

TEST_DIR    := tests
DATA_DIR    := $(abspath testcase-data)
RESULT_DIR  := $(TEST_DIR)/results

TESTS := $(basename $(notdir $(wildcard $(TEST_DIR)/*.tcl)))

export TESTCASE_DATA := $(DATA_DIR)

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help message
	@echo "LibreEDA regression suite and design-flow templates."
	@echo
	@echo "Usage: make <target> [VAR=value ...]"
	@echo
	@echo "Targets:"
	@grep -hE '^[a-zA-Z0-9_.%-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-26s\033[0m %s\n", $$1, $$2}'
	@echo
	@echo "Common variables:"
	@echo "  LIBREEDA_ROOT   required for any target that runs the tool -- path to your build"
	@echo "                 (defaults to \$$LibreEDA_INSTALL_DIR if that's already set; auto-detects"
	@echo "                 a LibreEDA/ThesSTA/pathviz binary inside it -- set LIBREEDA_BIN to override)"
	@echo "  DESIGN_CONFIG  which Designs/*/config.mk to use (default: Designs/aes_sky130hs/config.mk)"
	@echo "  PDK_ROOT       where to find PDK/ (default: ./PDK)"
	@echo "  TIMING_DRIVEN  =1 to pull in Liberty for global_placement"
	@echo "  INTERACTIVE    =1 to drop to the tool's prompt instead of exiting"
	@echo "  GUI            =1 to open the GUI (show_gui) first -- implies INTERACTIVE=1"
	@echo "  RESULTS_DIR    where *-script output + driver scripts land (default: results/<platform>/<design>)"
	@echo "  LOG_DIR        where run logs land (default: logs/<platform>/<design>)"
	@echo "  REPORTS_DIR    where report_timing's .rpt copy lands (default: reports/<platform>/<design>)"
	@echo
	@echo "Examples:"
	@echo "  make test LIBREEDA_ROOT=/path/to/LibreEDA"
	@echo "  make report_timing LIBREEDA_ROOT=/path/to/LibreEDA DESIGN_CONFIG=Designs/aes_cipher_top/config.mk"
	@echo "  make report_timing-script"

.PHONY: all test clean check-libreeda $(TESTS)

all: test ## Alias for test

test: $(TESTS) ## Run the CI regression suite (tests/*.tcl vs tests/*.ok)

check-libreeda:
	@if [ -z "$(LIBREEDA_ROOT)" ]; then \
		echo "FAIL: LIBREEDA_ROOT is not set (and LibreEDA_INSTALL_DIR isn't either) -- point it at your build, e.g. make test LIBREEDA_ROOT=/path/to/LibreEDA"; \
		exit 1; \
	fi
	@if [ -z "$(LIBREEDA_BIN)" ] || [ ! -x "$(LIBREEDA_BIN)" ]; then \
		echo "FAIL: no LibreEDA binary found under $(LIBREEDA_ROOT) (looked for LibreEDA, ThesSTA, pathviz) -- check LIBREEDA_ROOT, or set LIBREEDA_BIN directly if your build uses a different binary name"; \
		exit 1; \
	fi

$(RESULT_DIR):
	@mkdir -p $(RESULT_DIR)

$(TESTS): % : $(TEST_DIR)/%.tcl check-libreeda | $(RESULT_DIR)
	@$(LIBREEDA_BIN) -no_gui -qamode -f $< < /dev/null > $(RESULT_DIR)/$@.raw 2>&1; \
	STATUS=$$?; \
	./normalize_log.sh $(RESULT_DIR)/$@.raw $(DATA_DIR) > $(RESULT_DIR)/$@.log; \
	if [ $$STATUS -ne 0 ]; then \
		echo "FAIL (exit $$STATUS): $@"; \
		tail -n 20 $(RESULT_DIR)/$@.log; \
		exit 1; \
	fi; \
	if ! diff -u $(TEST_DIR)/$@.ok $(RESULT_DIR)/$@.log > $(RESULT_DIR)/$@.diff; then \
		echo "FAIL (output mismatch): $@"; \
		cat $(RESULT_DIR)/$@.diff; \
		exit 1; \
	fi; \
	echo "PASS: $@"

# Inspect the diff before committing the regenerated golden file.
regen-%: check-libreeda | $(RESULT_DIR) ## Regenerate a golden file, e.g. `make regen-load_lef`
	@$(LIBREEDA_BIN) -no_gui -qamode -f $(TEST_DIR)/$*.tcl < /dev/null > $(RESULT_DIR)/$*.raw 2>&1; \
	./normalize_log.sh $(RESULT_DIR)/$*.raw $(DATA_DIR) > $(TEST_DIR)/$*.ok; \
	echo "Regenerated golden output: $(TEST_DIR)/$*.ok"

clean: clean_run ## Remove everything generated (test results + design-flow output)
	rm -rf $(RESULT_DIR)

# ==============================================================================
# Design flow. Pick a design via DESIGN_CONFIG, then run named stages.
# Not part of `make test` -- needs the real PDK on disk (PDK/, git-ignored).
# Every target reloads PDK + design from scratch (no checkpoint between
# stages).
#
#   make load
#   make report_timing DESIGN_CONFIG=Designs/aes_cipher_top/config.mk
#   make global_placement TIMING_DRIVEN=1
#   make global_placement GUI=1
#   make report_timing INTERACTIVE=1
#   make report_timing-script          # write the tcl instead of running it
#
# Defaults to aes_sky130hs (PDK vendored, nothing to fetch). aes_cipher_top
# (asap7) needs the ASAP7 submodule -- check-pdk tells you what to run.

DESIGN_CONFIG ?= Designs/aes_sky130hs/config.mk
include $(DESIGN_CONFIG)

DESIGN_DIR := $(patsubst %/,%,$(dir $(DESIGN_CONFIG)))

PDK_ROOT      ?= $(abspath PDK)
RESULTS_DIR   ?= results/$(PLATFORM)/$(DESIGN_NAME)
LOG_DIR       ?= logs/$(PLATFORM)/$(DESIGN_NAME)
REPORTS_DIR   ?= reports/$(PLATFORM)/$(DESIGN_NAME)
OBJECTS_DIR   ?= $(RESULTS_DIR)/.objects
PLATFORM_DIR  := platforms/$(PLATFORM)

INTERACTIVE      ?=
GUI              ?=
TIMING_DRIVEN    ?=

# GUI=1 with no explicit INTERACTIVE would open the GUI and then finish.tcl
# would immediately exit (INTERACTIVE defaults off), closing it right back
# up -- so GUI implies interactive unless the user explicitly turned it off.
ifeq ($(GUI),1)
  INTERACTIVE := 1
endif

export GUI
export INTERACTIVE
# named GP_TIMING_DRIVEN so it's clear it's read specifically by global_place.tcl
export GP_TIMING_DRIVEN := $(TIMING_DRIVEN)

# LOAD_LIB tells load_design.tcl whether Liberty was loaded this session
# (and so whether sourcing the SDC will produce meaningful numbers); set
# per target below via GNU Make target-specific variables.
export LOAD_LIB

export VERILOG_FILE
export SDC_FILE
export DESIGN_NAME
export CORE_UTILISATION
export CORE_ASPECT_RATIO
export PDK_ROOT

# Batch runs need -qamode + closed stdin, otherwise an unattended `exit`
# blocks forever re-prompting "Are you sure you want to exit?" against EOF.
# Interactive/GUI runs need the opposite: a real terminal attached, and no
# -qamode (it would abort the prompt loop on the first typo).
ifneq (,$(filter 1,$(INTERACTIVE) $(GUI)))
  LIBREEDA_MODE_FLAGS :=
  LIBREEDA_STDIN      :=
else
  LIBREEDA_MODE_FLAGS := -qamode
  LIBREEDA_STDIN      := < /dev/null
endif

# GUI=1 needs the binary launched without -no_gui, or finish.tcl's show_gui
# has nothing to open.
ifeq ($(GUI),1)
  LIBREEDA_GUI_FLAG :=
else
  LIBREEDA_GUI_FLAG := -no_gui
endif

# $(1) = stage list (paths under flows/, no .tcl suffix), $(2) = output tcl
# file. Always finishes with stages/finish.tcl (handles GUI/INTERACTIVE).
define COMPOSE_STAGES
	@mkdir -p $(dir $2)
	@rm -f $2
	@$(foreach s,$1,echo "source flows/$(s).tcl" >> $2;)
	@echo "source flows/stages/finish.tcl" >> $2
endef

# $(1) = stage list, $(2) = log file.
define RUN_STAGES
	@mkdir -p $(LOG_DIR) $(OBJECTS_DIR)
	$(call COMPOSE_STAGES,$1,$(OBJECTS_DIR)/driver.tcl)
	$(LIBREEDA_BIN) $(LIBREEDA_GUI_FLAG) $(LIBREEDA_MODE_FLAGS) -f $(OBJECTS_DIR)/driver.tcl $(LIBREEDA_STDIN) 2>&1 | tee $2
endef

LOAD_STAGES              := $(PLATFORM_DIR)/load_lef stages/load_design
REPORT_TIMING_STAGES     := $(PLATFORM_DIR)/load_lef $(PLATFORM_DIR)/load_lib stages/load_design stages/report_timing
FLOORPLAN_STAGES         := $(PLATFORM_DIR)/load_lef stages/load_design stages/floorplan
GLOBAL_PLACEMENT_STAGES  := $(PLATFORM_DIR)/load_lef $(if $(filter 1,$(TIMING_DRIVEN)),$(PLATFORM_DIR)/load_lib) stages/load_design stages/floorplan stages/global_place

# Platforms pulled in as git submodules (asap7) have an empty directory
# until fetch_asap7_pdk.sh runs; this file only exists once that's actually
# happened. Vendored platforms (sky130hs) don't need an entry here since
# their files are always present.
PDK_MARKER_asap7 := $(PDK_ROOT)/ASAP7/techlef_misc

.PHONY: check-pdk
check-pdk:
	@marker="$(PDK_MARKER_$(PLATFORM))"; \
	if [ -n "$$marker" ] && [ ! -e "$$marker" ]; then \
		echo "FAIL: PDK data for platform '$(PLATFORM)' not found ($$marker missing)."; \
		if [ "$(PLATFORM)" = "asap7" ]; then \
			echo "  ASAP7 hasn't been fetched yet. Run:"; \
			echo "    make pdk-asap7"; \
			echo "  then re-run this target."; \
		else \
			echo "  Check PDK_ROOT (currently $(PDK_ROOT))."; \
		fi; \
		exit 1; \
	fi

.PHONY: pdk-asap7
pdk-asap7: ## Fetch + extract only the ASAP7 files this repo uses (needs p7zip)
	./fetch_asap7_pdk.sh

.PHONY: load
load: LOAD_LIB := 0
load: check-libreeda check-pdk ## Load LEF + netlist only (no Liberty, no SDC)
	$(call RUN_STAGES,$(LOAD_STAGES),$(LOG_DIR)/load.log)

.PHONY: report_timing
report_timing: LOAD_LIB := 1
report_timing: check-libreeda check-pdk ## Load LEF+LIB+netlist+SDC, then report_timing
	$(call RUN_STAGES,$(REPORT_TIMING_STAGES),$(LOG_DIR)/report_timing.log)
	@mkdir -p $(REPORTS_DIR)
	@cp $(LOG_DIR)/report_timing.log $(REPORTS_DIR)/report_timing.rpt

.PHONY: floorplan
floorplan: LOAD_LIB := 0
floorplan: check-libreeda check-pdk ## `load` + initialise_floorplan + io_place
	$(call RUN_STAGES,$(FLOORPLAN_STAGES),$(LOG_DIR)/floorplan.log)

.PHONY: global_placement
global_placement: LOAD_LIB := $(if $(filter 1,$(TIMING_DRIVEN)),1,0)
global_placement: check-libreeda check-pdk ## `floorplan` + global_place (TIMING_DRIVEN=1 for timing-driven)
	$(call RUN_STAGES,$(GLOBAL_PLACEMENT_STAGES),$(LOG_DIR)/global_placement.log)

# *-script targets write the composed driver script instead of running it --
# useful for inspecting/editing/sharing exactly what a target would execute,
# or feeding it into the tool by hand later (<binary> -no_gui -f <script>).
.PHONY: load-script report_timing-script floorplan-script global_placement-script

load-script: ## Write load's driver tcl instead of running it
	$(call COMPOSE_STAGES,$(LOAD_STAGES),$(RESULTS_DIR)/load.tcl)
	@echo "Wrote $(RESULTS_DIR)/load.tcl"

report_timing-script: ## Write report_timing's driver tcl instead of running it
	$(call COMPOSE_STAGES,$(REPORT_TIMING_STAGES),$(RESULTS_DIR)/report_timing.tcl)
	@echo "Wrote $(RESULTS_DIR)/report_timing.tcl"

floorplan-script: ## Write floorplan's driver tcl instead of running it
	$(call COMPOSE_STAGES,$(FLOORPLAN_STAGES),$(RESULTS_DIR)/floorplan.tcl)
	@echo "Wrote $(RESULTS_DIR)/floorplan.tcl"

global_placement-script: ## Write global_placement's driver tcl instead of running it
	$(call COMPOSE_STAGES,$(GLOBAL_PLACEMENT_STAGES),$(RESULTS_DIR)/global_placement.tcl)
	@echo "Wrote $(RESULTS_DIR)/global_placement.tcl"

.PHONY: clean_run
clean_run: ## Remove only design-flow output (results/logs/reports for current DESIGN_CONFIG)
	rm -rf $(RESULTS_DIR) $(LOG_DIR) $(REPORTS_DIR)
