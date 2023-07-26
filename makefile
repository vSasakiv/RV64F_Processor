DIR := ${CURDIR}
define \n

endef
rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))
VERILOG_FILES := $(call rwildcard, hdl/,*.v)

compile:
	@iverilog -o cpu.out $(VERILOG_FILES) testbenches/$(target)
	@echo Compilação completa 

show:
	@echo $(VERILOG_FILES)