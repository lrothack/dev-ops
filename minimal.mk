# Comments: single '#' for ordinary comments, 
#           '## ' indicates text for 'help' target 
#
# ATTENTION: Running `make <target>` is only supported from the project directory
#

# --- Python ---
#
# Define Python package and tests directories
# (lazy variable execution: single =)
#
# Name of the directory where application sources are located
PACKAGE=./
# Directory where unittests are located
TESTS=./tests
#
# Define names of executables used in make targets (and variables)
PYTHON = python
PIP = pip
# Files required by setuptools (python setup.py, pip)
# Note that setuptools can only supports running from the project root
SETUPPY = setup.py
SETUPCFG = setup.cfg


# --- Linting/Testing configuration ---
#
# Executables
PYTEST = pytest
COVERAGE = coverage
PYLINT = pylint
BANDIT = bandit
# Directory where to save linting and testing reports
REPDIR=./.codereports
# Report result files
PYTESTREP=$(REPDIR)/pytest.xml
COVERAGEREP=$(REPDIR)/coverage.xml
PYLINTREP=$(REPDIR)/pylint.txt
BANDITREP=$(REPDIR)/bandit.json


# --- Common targets ---

.PHONY: help clean clean-all dist install-dev test lint

## 
## MAKEFILE for building and testing Python package including
## code analysis and reporting to SonarQube in a dockerized build environment
## 
## ATTENTION: Running `make <target>` is only supported from the project directory
## 
## Targets:
## 

## help:         Print this comment-generated help message
# reads contents of this file 
# Relative path to Makefile (from current working directory)
MKFILE_PATH := $(lastword $(MAKEFILE_LIST))
help: $(MKFILE_PATH)
	@sed -n 's/^## //p' $(MKFILE_PATH)

## clean:        Clean up auto-generated files
clean:
	@rm -f $(PYTESTREP) $(COVERAGEREP)
	@rm -f $(PYLINTREP) $(BANDITREP)

## clean-all:    Clean up auto-generated files and directories
##               (WARNING: do not store user data in auto-generated directories)
clean-all: clean
	@rm -rf .coverage
	@rm -rf .pytest_cache
	@rm -rf ./$(REPDIR)
	@rm -rf *.egg-info
	@rm -rf build
	@rm -rf dist


# --- Python targets ---

# Check if project files exist in current working directory, otherwise stop.
$(PACKAGE):
	$(error "Python project files missing in working directory ($@)")
# Check if test files exist in current working directory, otherwise stop.
$(TESTS):
	$(error "Python test files missing in working directory ($@)")
# Check if setup.py files exist in current working directory, otherwise stop.
$(SETUPPY):
	$(error "Python packaging file missing in working directory ($@)")
# Check if setup.cfg files exist in current working directory, otherwise create file.
$(SETUPCFG):
	@echo "# setup.cfg (https://setuptools.pypa.io/en/latest/userguide/quickstart.html#basic-use)" > $@

## dist:         Build a Python wheel with setuptools (based on setup.py)
dist: $(SETUPPY)
	$(PYTHON) setup.py sdist
	$(PYTHON) setup.py bdist_wheel

## install-dev:  Install development dependencies (based on setup.py)
##               (installation within a Python virtual environment is
##                recommended)
##               (application sources will be symlinked to PYTHONPATH)
install-dev: $(SETUPCFG)
	$(PIP) install wheel
	$(PIP) install pytest pytest-mock coverage bandit pylint autopep8 flake8
	$(PIP) install -e .

## test:         Run Python unit tests with pytest and analyse coverage
# check SETUPTOOLSFILES since setuptools is used to generate the PACKAGE name
test: $(PACKAGE) $(TESTS)
	@echo "\n\nUnit Tests\n----------\n"
	$(COVERAGE) run --source $(PACKAGE) -m $(PYTEST) $(TESTS)
	@echo "\n\nUnit Test Code Coverage\n-----------------------\n"
	$(COVERAGE) report -m

## lint:         Run Python linter (bandit, pylint) and print output to terminal
# check SETUPTOOLSFILES since setuptools is used to generate the PACKAGE name
lint: $(PACKAGE)
	@echo "\n\nBandit Vulnerabilities\n----------------------\n"
	-$(BANDIT) -r $(PACKAGE)
	@echo "\n\nPylint Code Analysis\n--------------------\n"
	$(PYLINT) --output-format=colorized --reports=n --exit-zero $(PACKAGE)

