# Makefile

The Makefile consists of a configuration section defining variables and a target section defining (PHONY) build targets. It is important that automatic discovery of package name and package version requires the `meta.py` CLI.

For an overview of available make targets run

```bash
make help
```

These make targets support:

- setting up your local development environment
- building a Python package
- building a Docker image with your package
- running code analyses

## Python packaging

Packaging your Python application has the advantage that your
package contents, package dependencies and executables (along with other useful meta information) are stored
in a single file. Applied within a virtual environment, the development and production environment is already
quite independent of your system environment, e.g., independent of your installed system packages, preferred IDE, etc.

Setup a virtual environment for development and deployment in a production environment
(current working directory `dev-ops`):

```bash
python3 -m venv venv
source venv/bin/activate
```

Do not forget to disable to switch back to your system environment by running the `deactivate` command after you are done.

### Development environment

An important advantage of packaging your app is that your application sources will automatically be linked in the `PYTHONPATH`. Since your dependencies will automatically be installed in the `PYTHONPATH` as well, you do not have to manually manage the content of `PYTHONPATH`.

- Define package dependencies in `pyproject.toml`.
- Package dependencies are automatically installed along with development dependencies.

```bash
# installs the package in development mode (package dependencies and development dependencies)
make install-dev
```

Important:

`make install-dev`:

```bash
pip install -e .[dev]
```

Notes:

- `-e`: Editable mode only *links* the sources to the `PYTHONPATH` and does not
 copy the sources to the `PYTHONPATH` (you can make changes to your code without
 having to re-install your app/package).
- `.`: The dot refers to the current working directory where the `pyproject.toml` file is expected.
- `dev`: Refers to the development dependencies of the package which is defined in `pyproject.toml` (see `project.optional-dependencies` section).

### Build package for deployment

The result of building a package from your Python application is a single wheel file (`.whl`) which can
easily be installed in any (virtual) Python environment. The package contents and its behavior are defined in
[`pyproject.toml`](pyproject.toml).

1. After switching to your virtual Python environment build the (binary) wheel (current working directory `dev-ops/`):

   ```bash
   make build
   # executes the setuptools `build` command (see Makefile):
   # python -m build
   ```

2. Install the wheel in a test environment (`deactivate` any active virtual environment, current working directory `dev-ops`):

   ```bash
   # Switch back to your system environment
   deactivate

   # Create a test environment outside the development directory and activate it
   python3 -m venv venv_test
   source venv_test/bin/activate

   # Install package into fresh environment
   pip install dev-ops/dist/sampleproject-0.1-py3-none-any.whl
   ```

3. Test the installed application:

   ```bash
   sampleproject --help
   ```

   Notes:
    - Additional executables with more specific name can be defined in `pyproject.toml`.

## Build Docker image for deployment

The [Dockerfile](Dockerfile) implements a multi-stage Docker image build for
running unit tests, code coverage, code analysis,
building a Python wheel in a first stage as well as installing the wheel in a
minimal image within the second stage. The Dockerfile implements the steps which
are explained [above](#build-package-for-deployment).

1. Start the build process:

   ```bash
   make docker-build
   ```

2. Run the newly built image by (implicitly) creating a container:

   ```bash
   docker run --rm sampleproject
   ```

   Notes:
    - `--rm` deletes the container after the program terminates
    - `sampleproject` specifies the name of the image
    - The container runs the script specified at `ENTRYPOINT` at the end of [Dockerfile](Dockerfile). The default argument is defined at `CMD` and can
    be overwritten the arguments to the `docker run` command above, e.g.,

      ```bash
      docker run --rm sampleproject 45 46
      ```

3. In order to obtain the wheel that was built in the build process, copy the `dist` directory from the container to a local directory, here `dist_sampleproject_container`:

   ```bash
   # Create a container
   docker container create --name sampleproject sampleproject
   # Recursively copy from container to Docker host
   docker cp sampleproject:/dist dist_sampleproject_container
   # Remove container that was created above
   docker container rm sampleproject
   ```

   Notes:
    - `docker cp` does not support wildcards. Since the name of the `whl` file is generated automatically, it is easier to copy a directory with the wheel file than copying the wheel file directly (provided that the directory has a generic name).

  Also have a look at the [Dockerfile](Dockerfile) which contains detailed comments for every step.

## Code analyses

Code analyses consists of running [testing and linting](#testing-and-linting) locally and submitting results to [Sonarqube](#sonarqube) server.

### Testing and linting

The make targets are intended for generating a code quality report locally. This includes running:

- unit test with test coverage
- bandit for vulnerability scanning
- pylint for scanning for code smells and code conventions

```bash
make test
make lint
```

### Sonarqube

Submitting code analyses to Sonarqube requires to define a URL to a running Sonarqube server (`SONARURL`) and
a valid authorization token (`SONARTOKEN` or `SONARTOKENFILE`).

```bash
make sonar
```
