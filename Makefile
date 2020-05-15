# Comments: single '#' for ordinary comments, 
#           '## ' indicates text for 'help' target 
#

# Directory where unittests are located
TESTS=tests
# Directory where to save linting and testing reports
REPDIR=.sonarreports
# Report result files
NOSETESTSREP=$(REPDIR)/nosetests.xml
COVERAGEREP=$(REPDIR)/coverage.xml
PYLINTREP=$(REPDIR)/pylint_report.txt
BANDITREP=$(REPDIR)/bandit_report.json
# Name of the application defined in setup.py
NAME:=$(shell python setup.py --name)
# Version of the application defined in setup.py
VERSION:=$(shell python setup.py --version)
# Name of the directory where application sources are located
PACKAGE=$(NAME)
# Configuration variables for local sonarqube reporting with `make sonar`
# Report to sonar host (when running locally)
SONARHOST=localhost
# Report to sonar port (when running locally)
SONARPORT=9000
# DISABLE/enable whether to include SCM (git) meta info in sonarqube report
SONARNOSCM=False
# Configuration variables for sonarqube reporting within Docker build when
# running `make build_docker`, i.e., variables will be passed to Docker build
# as build arguments
# Enable/disable SonarQube reporting during Docker build
DOCKERSONAR=True
# Report to sonar host (when running in Docker build)
DOCKERSONARHOST=sonarqube
# Report to sonar port (when running in Docker build)
DOCKERSONARPORT=9000
# Docker network for running the Docker build. Sonarqube server must be hosted
# in the same network at $DOCKERSONARHOST:$DOCKERSONARPORT
# Only evaluated if $DOCKERSONAR==True
DOCKERNET=sonarqube_net


## 
## MAKEFILE for building and testing Python package including
## code analysis and reporting to SonarQube in a dockerized build environment
## 
## Targets:
## 

## help:         Print this comment-generated help message
# reads contents of this file and expects that this file is called 'Makefile'
help:
	@sed -n 's/^## //p' Makefile

## clean:        Clean up auto-generated files
clean:
	rm -f $(NOSETESTSREP) $(COVERAGEREP)
	rm -f $(PYLINTREP) $(BANDITREP)

## clean-all:    Clean up auto-generated files and directories
##               (WARNING: do not store user data in auto-generated directories)
clean-all: clean
	rm -rf $(NAME).egg-info
	rm -rf build
	rm -rf dist

## bdist_wheel:  Build a Python wheel with setuptools (based on setup.py)
bdist_wheel:
	python setup.py bdist_wheel

## install_dev:  Install development dependencies (based on setup.py)
##               (installation within a Python virtual environment is
##                recommended)
##               (application sources will be symlinked to PYTHONPATH)
install_dev:
	pip install -r requirements.txt

## test:         Run Python unit tests with nosetests
test:
	nosetests --where $(TESTS)


## sonar:        Report code analysis and test coverage results to SonarQube
##               (requires SonarQube server, run `docker-compose up` in
##                ./sonarqube/)
#                (requires code analysis dependencies, 
#                 intall with `make install_dev`)
#                (requires SonarQube client sonar-scanner, 
#                 install with `brew sonar-scanner` or see ./Dockerfile)
sonar: $(NOSETESTSREP) $(COVERAGEREP) $(PYLINTREP) $(BANDITREP)
	sonar-scanner -Dsonar.host.url=http://$(SONARHOST):$(SONARPORT) \
              -Dsonar.projectKey=$(NAME) \
              -Dsonar.projectVersion=$(VERSION) \
              -Dsonar.sourceEncoding=UTF-8 \
              -Dsonar.sources=$(PACKAGE) \
              -Dsonar.tests=$(TESTS) \
              -Dsonar.scm.disabled=$(SONARNOSCM) \
              -Dsonar.python.xunit.reportPath=$(NOSETESTSREP) \
              -Dsonar.python.coverage.reportPaths=$(COVERAGEREP) \
              -Dsonar.python.pylint.reportPath=$(PYLINTREP) \
              -Dsonar.python.bandit.reportPaths=$(BANDITREP)

## build_docker: Build docker image for Python application including
##               code analysis and reporting to SonarQube (multi-stage build)
##               (WARNING: do not run in Docker, Docker-in-Docker!)
# The if-statement is required in order to determine if we have to run the
# build in the $(DOCKERNET) network
build_docker:
	@echo "WARNING: Do not run this target within a Docker build/container"
ifeq ($(DOCKERSONAR), True)
	@echo "building Docker image within Docker network $(DOCKERNET)"
	@echo "(make sure SonarQube is running in the same network)"
	@echo "(run \`docker-compose -p sonarqube -f sonarqube/docker-compose.yml up -d\`)"
	docker build --rm --network=$(DOCKERNET) -t $(NAME) . \
		--build-arg SONARHOST=$(DOCKERSONARHOST) \
		--build-arg SONARPORT=$(DOCKERSONARPORT)
else
	@echo "building Docker image without reporting to SonarQube"
	docker build --rm -t $(NAME) . --build-arg SONAR=$(DOCKERSONAR)
endif
	@echo "build finished, run the container with \`docker run --rm $(NAME)\`"

# analysis tools can be installed with `make install_dev`
# leading - ignores error codes, make would fail if test case fails
$(NOSETESTSREP):
	mkdir -p $(REPDIR)
	-nosetests --with-xunit --xunit-file=$@ --where $(TESTS)

# analysis tools can be installed with `make install_dev`
# leading - ignores error codes, make would fail if test case fails
$(COVERAGEREP):
	mkdir -p $(REPDIR)
	-nosetests --with-coverage --cover-xml --cover-xml-file=../$@ --where $(TESTS)
	
# analysis tools can be installed with `make install_dev`
# --exit-zero always return exit code 0: make would fail otherwise
$(PYLINTREP): 
	mkdir -p $(REPDIR)
	pylint $(PACKAGE) --exit-zero --reports=n --msg-template="{path}:{line}: [{msg_id}({symbol}), {obj}] {msg}" > $@

# analysis tools can be installed with `make install_dev`
# leading - ignores error codes, make would fail if test case fails
$(BANDITREP):
	mkdir -p $(REPDIR)
	-bandit -r $(PACKAGE) --format json >$@


.PHONY: help clean clean-all bdist_wheel install_dev test sonar build_docker
