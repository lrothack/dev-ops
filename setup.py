from setuptools import setup, find_packages
with open("README.md", "r") as fh:
    long_description = fh.read()
# ATTENTION: the name must match the name of the top-level import package
# see Makefile variable MODULE
# naming the project as the top-level import package is also consistent with
# conventions.
setup(name="sampleproject",
      version="0.1",
      # Exclude all subpackages that contain 'tests'
      # Note: top-level tests dir requires directive in MANIFEST.in
      packages=find_packages(exclude=['tests', '*.tests', '*.tests.*']),
      # test_suite='tests',
      # Include scripts/executables for application from 'scripts' directory
      scripts=['scripts/sampleproject'],
      # Generate start script automatically
      # Attention: the generic name of the executable 'entrypoint' is used as
      # an entry point in Docker (see Dockerfile).
      entry_points={'console_scripts':
                    ['entrypoint=sampleproject.sample:main']},
      setup_requires=['wheel'],
      # Define package dependencies
      # install_requires=[],
      # Defines dev environment containing additional dependencies
      # (for linting, testing)
      extras_require={'dev': ['nose',
                              'coverage',
                              'bandit',
                              'pylint',
                              'autopep8',
                              'flake8']
                      },

      # Data files should always be part of the package and you should avoid
      # dependencies to data files outside of the package.
      # find_packages (see above) searches Python packages and includes source
      # files. In order to include data files, too, you can use
      # include_package_data OR package_data
      # Note that package_data will not work when include_package_data=True
      # With include_package_data you must manage your data file includes in
      # MANIFEST.in. With package_data you manage data file includes relative
      # to package key provided in the dictionary.
      # https://setuptools.readthedocs.io/en/latest/setuptools.html#including-data-files
      # include_package_data=True,
      # package_data={
      #     # If any package contains *.txt or *.rst files, include them:
      #     "": ["*.txt", "*.rst"],
      #     # And include any *.msg files found in the "hello" package, too:
      #     "hello": ["*.msg"],
      # },

      # Metadata to display on PyPI
      author="Full Name",
      # author_email="",
      description="This is an Example Package",
      long_description=long_description,
      long_description_content_type='text/markdown',
      # keywords="hello world example examples",
      # url="http://example.com/HelloWorld/",   # project home page, if any
      # project_urls={
      #     "Bug Tracker": "https://bugs.example.com/HelloWorld/",
      #     "Documentation": "https://docs.example.com/HelloWorld/",
      #     "Source Code": "https://code.example.com/HelloWorld/",
      # },
      platforms=['any'],
      license='MIT',
      classifiers=["Programming Language :: Python :: 3",
                   "License :: OSI Approved :: MIT License",
                   #  "License :: Other/Proprietary License",
                   "Operating System :: OS Independent",
                   ],
      # Do not assume that the package can safely be run as a zip archive
      zip_safe=False
      )
