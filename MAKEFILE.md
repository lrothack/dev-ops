# Documentation

- [Python packaging with pip](#python-packaging-with-pip)
- [Build Docker image for deployment](#build-docker-image-for-deployment)

## Python packaging with pip

Packaging your Python application with pip has the advantage that pip stores your
package contents, package dependencies and executables (along with other useful meta information)
in a single file. Applied within a virtual environment, the development and production environment is already
quite independent of your system environment, e.g., independent of your installed system packages, preferred IDE, etc.

Setup a virtual environment for development and deployment in a production environment
(current working directory `dev-ops`):

```bash
python3 -m venv venv
source venv/bin/activate
```

Do not forget to disable to switch back to your system environment by running the `deactivate` command after you are done.

### Setup development environment

An important advantage of packaging your app with `setup.py` (pip), in contrast to specifying your app's dependencies in the `requirements.txt` file *only*, is that pip will automatically link your application sources in the `PYTHONPATH`. Since your dependencies will automatically be installed in the
`PYTHONPATH`, you do not have to manually manage the `PYTHONPATH` anymore.

- Define package dependencies in `requirements.txt`.
- `setup.py` installs package dependencies along with development dependencies.

```bash
# installs the package in development mode (package dependencies and development dependencies)
make install-dev
# installs package dependencies only (for a source code deployment of the package in production)
pip install -r requirements.txt
```

Important:

`setup.py` loads package dependencies from `requirements.txt` which is expected to be
found in the current working directory.

`make install-dev`:

```bash
pip install -e .[dev]
```

Notes:

- `-e`: Editable mode only *links* the sources to the `PYTHONPATH` and does not
 copy the sources to the `PYTHONPATH` (you can make changes to your code without
 having to re-install your app/package).
- `.`: The dot refers to the current working directory where the `setup.py` file is expected.
- `[dev]`: Refers to the `dev` variant/environment of the package which is defined in `setup.py` (see `extras_require`).

Discussions on how to use `setup.py` and `requirements.txt` are found on:

- [stackoverflow](https://stackoverflow.com/questions/14399534/reference-requirements-txt-for-the-install-requires-kwarg-in-setuptools-setup-py)
- [Python Packaging User Guide](https://packaging.python.org/discussions/install-requires-vs-requirements/)

Note: Python package deployments that do not use `setup.py` typically define dependencies with `requirements.txt` only. The approach described above

- is fully compatible with projects that only use `requirements.txt` for dependency management,
- separates production dependencies from development dependencies.

### Build pip package for deployment

The result of building a package from your Python application is a single wheel file (`.whl`) which can
easily be installed in any (virtual) Python environment. The package contents and its behavior are defined in
[`setup.py`](../setup.py).

1. After switching to your virtual Python environment build the (binary) wheel (current working directory `dev-ops/`):

   ```bash
   make dist
   # executes the setuptools `bdist_wheel` command (see Makefile):
   # python setup.py bdist_wheel
   ```

   Notes on [`setup.py`](../setup.py) (project specific):
    - `name`: The name of the pip/Python package must match the name of the top-level import package in order to let the [Makefile](../Makefile) work correctly.
    - `version`: Either define your project version here or generate it accordingly. The version has to follow a defined [pattern](https://packaging.python.org/guides/distributing-packages-using-setuptools/#choosing-a-versioning-scheme).  
    - `packages`: Defines how to include/exclude Python import packages. Can be specified manually or with [find_packages](https://setuptools.readthedocs.io/en/latest/setuptools.html#using-find-packages). Projects using an `src` directory ([bad practice](https://docs.python-guide.org/writing/structure/#the-actual-module)) can *include* the `src` directory only. Otherwise, you have to *exclude* everything you do not want to ship with your deployment package.
    - `scripts`: Provides executables for accessing the functionalities provided by the package. Executables are automatically installed on the `PATH`.
    - `entry_points`: Automatically generate executables by Python package.module:function. Executables are installed on the `PATH`.
    - `install_requires`: Python package dependencies (loads definitions from `requirements.txt`).
    - `package_data`: Non-python files that should be included in the package have to be declared specifically. Further inclusion patterns can be defined in `MANIFEST.in`.

   Notes on [`setup.py`](../setup.py) (common to most dev-ops template projects):
    - `tests` directory contains unit tests which are typically not part of the deployment package. Excluding tests requires `exclude` [definitions](https://setuptools.readthedocs.io/en/latest/setuptools.html#using-find-packages) and [directives](https://stackoverflow.com/questions/8556996/setuptools-troubles-excluding-packages-including-data-files/11669299#11669299) in the `MANIFEST.in` file.
    - `setup_requires`: Python package dependencies required before running setup.
    - `extras_require`: Defines different environments with different dependencies, e.g., for development/testing. Specific environments can be installed by appending `[<env>]` to the installation target (where `<env>` is replaced by the environment key, here `dev`), see [setuptools documentation](https://setuptools.readthedocs.io/en/latest/setuptools.html#declaring-dependencies).

2. Install the wheel in a test environment (`deactivate` any active virtual environment, current working directory `dev-ops`):

   ```bash
   # Switch back to your system environment
   deactivate

   # Create a test environment outside the development directory and activate it
   cd ..
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
    - Additional executables with more specific name can be defined in `setup.py`.

Documentation:

- [Setuptools documentation](https://setuptools.readthedocs.io/en/latest/setuptools.html)
- [Setuptools documentation on `setup.cfg`](https://setuptools.readthedocs.io/en/latest/setuptools.html#configuring-setup-using-setup-cfg-files)
- [Python packaging guide](https://packaging.python.org/guides/distributing-packages-using-setuptools/#setup-args)
- Blog post for building a [bdist_wheel](https://dzone.com/articles/executable-package-pip-install)
- Commented [setup.py](https://github.com/pypa/sampleproject/blob/master/setup.py) (reference)
- [Stackoverflow](https://stackoverflow.com/questions/1471994/what-is-setup-py) on what is `setup.py`

## Build Docker image for deployment

The [Dockerfile](../Dockerfile) implements a multi-stage Docker image build for
running unit tests, code coverage, code analysis,
building a Python wheel in a first stage as well as installing the wheel in a
minimal image within the second stage. The Dockerfile implements the steps which
are explained [above](#build-pip-package-for-deployment).

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
    - The container runs the script specified at `ENTRYPOINT` at the end of [Dockerfile](../Dockerfile). The default argument is defined at `CMD` and can
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

  Also have a look at the [Dockerfile](../Dockerfile) which contains detailed comments for every step.
