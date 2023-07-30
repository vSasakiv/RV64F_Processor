DIR := ${CURDIR}
define \n


endef

rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))
VERILOG_FILES := $(call rwildcard, hdl/,*.v)
C_FILES := $(call rwildcard, testbenches/DPI_C_Scripts/,*.c)
VERILOG_TESTS := $(call rwildcard, testbenches/,*.sv) 

compile:
	@iverilog -g2012 -o cpu.out $(VERILOG_FILES) testbenches/$(target)
	@echo Compilação completa 

clear:
	@del work
	@echo Pasta Work foi limpa

prepare:
	@make clear
	@vlib work
	@echo Pasta Word foi Renovada

modules:
	$(foreach var, $(VERILOG_FILES) , @vlog -incr +acc "$(DIR)/$(var)" ${\n})

scripts:
	$(foreach var, $(C_FILES) , @vlog -incr +acc "$(DIR)/$(var)" ${\n})

tests:
	$(foreach var, $(VERILOG_TESTS) , @vlog -incr +acc "$(DIR)/$(var)" ${\n})

all:
	@make modules
	@make scripts
	@make tests

show:
	@echo $(VERILOG_FILES)
	@echo $(VERILOG_TESTS)