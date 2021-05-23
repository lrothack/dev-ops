
# Python DevOps Template

This project is intended to be used as a template in order to set up a simple dev-ops pipeline for your Python code.

Features:

- [Project structure following common conventions](#python-project-structure)
- [Setting up a development environment with setuptools](#development-environment)
- [Running code analyses and reporting results to SonarQube](#reporting-to-sonarqube)
- [Build a Python wheel package with setuptools](#build-python-wheel)
- [Implementing this process in a multi-stage Docker build](#build-docker-image)
- [Easily adapt the template for your own project](#adapt-this-template-for-your-project)

These use cases are accessible through a `Makefile`. A summary of the most important make targets can be obtained by running

```bash
make help
```

The following sections serve as a quickstart guide. More detailed documentation:

- [Python packaging and Docker deployment](docs/)
- [Dockerized SonarQube server](sonarqube/)

## Python project structure

The project structure follows ideas discussed on [stackoverflow](https://stackoverflow.com/questions/193161/what-is-the-best-project-structure-for-a-python-application). Most importantly for the following top-level components:

- Use a `README.md` file (this file).
- Use a [`requirements.txt`](requirements.txt) file for setting up development environment (refers to [`setup.py`](setup.py)).
- Use a [`setup.py`](setup.py) file for defining the app's pip deployment package (including development dependencies).
- Use a [`MANIFEST.in`](MANIFEST.in) file for advanced pip package build directives.
- Use a [`LICENSE`](LICENSE) for defining users' rights and obligations.
- Don't use an `src` directory (redundant) but a top-level Python import package (here [`sampleproject`](sampleproject/) directory).
- Use a [`tests`](tests/) directory for unit tests (directory is a Python import package).
- Use a [`scripts`](scripts/) directory for storing scripts that are directly executable.
- Use a [`Makefile`](Makefile) for setting up development environment, building, testing, code quality reporting, deployment (run `make help` for an overview).
- Use a [`Dockerfile`](Dockerfile) that defines how to build and deploy the app in a container.

Documentation:

- [Best practices](https://docs.python-guide.org/writing/structure/)
- [Python packaging documentation](https://packaging.python.org/guides/distributing-packages-using-setuptools/)
- An exemplary Python project is found on [github](https://github.com/pypa/sampleproject)

## Development environment

Automatically install dependencies and symlink your sources to your Python environment.
Note that also development dependencies will be installed automatically.
Development dependencies, like linter and test tools, can be managed in addition to runtime dependencies.

Prerequisites:

- Current working directory `dev-ops`

```bash
# virtual environment
python3 -m venv venv
source venv/bin/activate
# install dependencies and symlink sources to PYTHONPATH
make install-dev
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

More details on how to set up a SonarQube server in a dockerized environment can be found [here](sonarqube/).

## Build Python wheel

Build a Python wheel package for your application that can easily be installed (sources and runtime dependencies) in another Python environment.

Prerequisites:

- Current working directory `dev-ops`

```bash
# build the wheel
make dist
```

Test the installation of the package:

- Set up a virtual environment outside the development directory (`dev-ops`) and activate it.
- Install the wheel package in `dev-ops/dist` with `pip install`.

More details on Python packaging can be found [here](docs/).

## Build Docker image

Build a Docker image in two stages. The first stage runs unit tests, code analyses, (optionally) reports results to SonarQube and builds a Python wheel package. The second stage installs the wheel from the first stage and is ready for deployment.

Notes:

- The build process in the first stage as well as the runtime environment in the second stage are independent from your local development environment.
- Reporting analysis results to SonarQube in the first stage is disabled by default and can be enabled with make argument `DOCKERSONAR=True`

Prerequisites:

- Current working directory `dev-ops`
- [SonarQube server is running](#reporting-to-sonarqube) (only if `DOCKERSONAR=True`)

```bash
# build the Docker image without reporting to SonarQube
make docker-build
# alternatively the Docker image can be built with reporting to SonarQube
make docker-build DOCKERSONAR=True
# run container
docker run --rm sampleproject
```

Reporting to SonarQube within the two-stage build process, requires an active Docker network during the build. This is unsupported with BuildKit.

More details on Docker deployment can be found [here](docs/).

## Adapt this template for your project

If you are fine with the conventions that have been followed in the template, you can easily adapt the template for your own project.

### Command-line tools

- [Cookiecutter template](https://github.com/lrothack/cookiecutter-pydevops)
- [devopstemplate command-line interface](https://github.com/lrothack/dev-ops-admin)

### Manual

- Pick a `<name>` for your project (here `sampleproject`).
- Put your code in a directory called `<name>`. Directory must contain `__init__.py`. This will be your top-level import package (e.g., `import <name>`).
- Define the package version in `<name>/__init__.py` (default is `__version__ = '0.1.0'`).
- Put your unit tests in the [`tests`](tests/) directory. Directory must contain `__init__.py`.
- Put your executable Python scripts in the [`scripts`](scripts/) directory. Not required necessarily because you can define entry points based on Python functions in [`setup.py`](setup.py).
- Change [`setup.py`](setup.py) to your needs.
  - Change the `name` to `<name>`. Important: The name must match the name of the top-level import directory.
  - Define the package sources. `find_packages` will recursively search the `include` directory, i.e., the top-level import directory.
  - Define your (executable) entry points with `scripts` and/or `entry_points`. Important: One executable must be called `<name>` ([see below](#docker-entrypoint)).
  - Add package dependencies with `install_requires`.
  - Add additional (non source) files in `package_data` as needed.
  - Set package meta data, like license, author, etc.
  - Change development dependencies in `extras_require` as needed or define additional build targets.
- Change [`Dockerfile`](Dockerfile) to your needs. This should be uncommon since the definitions/configurations are rather generic.
  - Change the `ENTRYPOINT` / `CMD` definition. Set the definition according to your own defaults (scripts/executables).
  - Change the runtime environment. The application is currently run as user `user` in working directory `/home/user/app`.

### Docker ENTRYPOINT

[`Dockerfile`](Dockerfile) uses the bash script [`entrypoint.sh`](entrypoint.sh) as `ENTRYPOINT`.
For this purpose, it is expected that an executable `<name>` exists on the `PATH` in your Docker container.

- [`entrypoint.sh`](entrypoint.sh) executes the application `<name>` with all command-line arguments provided to `docker run`.
- The `<name>` of the application is obtained through an environment variable. The environment variable is defined in the Docker container, see [`Dockerfile`](Dockerfile).
- The value of the environment variable is obtained in [`Makefile`](Makefile) with `setuptools` and passed as a `build-arg` to [`Dockerfile`](Dockerfile).
