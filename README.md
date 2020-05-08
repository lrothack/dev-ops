
# Python DevOps Template

This project is intended to be used as a template in order to set up a simple dev-ops pipeline for your Python code.

Features:

 - [Project structure following common conventions](#python-project-structure)
 - [Setting up a development environment with setuptools](#development-environment)
 - [Running code analyses and reporting results to SonarQube](reporting-to-sonarqube)
 - [Build a Python wheel package with setuptools](#build-python-wheel)
 - [Implementing this process in a multi-stage Docker build](#build-docker-image)
 - [Easily adapt the template for your own project](#adapt-this-template-for-your-project)

The following sections serve as a quickstart guide. More detailed documentation:
 - [Python packaging and docker deployment](docs/)
 - [SonarQube](sonarqube/)

## Python project structure

The project structure follows ideas discussed on [stackoverflow](https://stackoverflow.com/questions/193161/what-is-the-best-project-structure-for-a-python-application). Most importantly for the following top-level components:

 - Use a `README.md` file (this file).
 - Use a `requirements.txt` file for setting up development environment (refers to `setup.py`).
 - Use a `setup.py` file for defining the app's pip deployment package (including dependencies). 
 - Use a `MANIFEST.in` file for advanced pip package build directives.
 - Use a `LICENSE` for defining users' rights and obligations.
 - Don't use an `src` directory (redundant) but a top-level Python import package (here `sampleproject` directory).
 - Use a `tests` directory for unit tests (directory is a Python import package).
 - Use a `scripts` directory for storing scripts/binaries that are directly executable.
 - Use a `Makefile` for setting up development environment, building, testing, code quality reporting, deployment (run `make help` for an overview)
 - Use a `Dockerfile` that defines how to build and deploy the app in a container.

Documentation:
 
 - [Best practices](https://docs.python-guide.org/writing/structure/)
 - [Python packaging documentation](https://packaging.python.org/guides/distributing-packages-using-setuptools/)
 - An exemplary Python project is found on [github](https://github.com/pypa/sampleproject) 

## Development environment

Automatically install dependencies and symlink your sources to your Python environment.

Prerequisites: 
 - Current working directory `dev-ops` 

```bash
# virtual environment
python3 -m venv venv
source venv/bin/activate
# install dependencies and symlink sources to PYTHONPATH
make install_dev 
# run application
sampleproject --help
```
## Reporting to SonarQube

Start a SonarQube server, run code analysis in your local Python development environment and report the results to SonarQube.

Prerequisites: 
 - Current working directory `dev-ops` 
 - [Installed development environment and activated virtual environment](#development-environment)

```bash
# start SonarQube Server
docker-compose -p sonarqube -f sonarqube/docker-compose.yml up -d
# wait until SonarQube has started at http://localhost:9000
# run code analyses and report to SonarQube
make sonar
```

## Build Python wheel

Build a Python wheel package for your application that can easily be installed (sources and dependecies) in another Python environment.

Prerequisites: 
 - Current working directory `dev-ops`

```bash
# build the wheel
make bdist_wheel
```
Test the package:
 - Set up a virtual environment outside the development directory (`dev-ops`) and activate it. 
 - Install the wheel package in `dev-ops/dist` with `pip install`.

## Build Docker image

Build a Docker image in two stages. The first stages runs unit tests, code analyses, reports results to SonarQube and builds a Python wheel package. The second stage installs the wheel from the first stage and is ready for deployment.
Note that the build process in the first stage is independent from your local development environment.

Prerequisites: 
 - Current working directory `dev-ops`
 - [SonarQube server is running](#reporting-to-sonarqube) 
```bash
# build the Docker image
make build_docker
# run container
docker run --rm sampleproject
```

## Adapt this template for your project

If you are fine with the conventions that have been followed in the template, you can easily adapt the template for your own project:

 - Pick a `<name>` for your project (here `sampleproject`).
 - Put your code in a directory called `<name>`. Directory must contain `__init__.py`. This will be your top-level import package (e.g., `import <name>`)
 - Put your unit tests in the `tests` directory. Directory must contain `__init__.py`.
 - Put your executable Python scripts in the `scripts` directory. Not required necessarily because you can define entry points based on Python functions in `setup.py`
 - Adapt `setup.py` to your needs. 
   - Change the `name` to `<name>`. It is important that the name matches the name of the top-level import directory.
   - Set a package version (here 0.1).
   - Define your (executable) entry points with `scripts` and/or `entry_points`.
   - Add package dependencies with `install_requires`.
   - Set package meta data, like license, author, etc.

