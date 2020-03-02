ifndef .config.mk
.config.mk := $(abspath $(lastword $(MAKEFILE_LIST)))

SHELL := bash
.ONESHELL:

.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
.DEFAULT_GOAL := help

ifeq ($(OS),Windows_NT)
else
	OS := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		OS := Linux
	endif
	ifeq ($(UNAME_S),Darwin)
		OS := Darwin
	endif
endif

endif # .config.mk
