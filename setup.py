from setuptools import setup, find_packages

# setup.py file is used together with configurations in setup.cfg
# Configurations that are common to dev-ops template projects go to setup.py
# Project specific configurations go to setup.cfg

setup(
    # Exclude all subpackages that contain 'tests'
    # Note: top-level tests dir requires directive in MANIFEST.in
    packages=find_packages(exclude=['tests', '*.tests', '*.tests.*']),
    setup_requires=['setuptools >= 40.9.0',
                    'wheel'],
    # Defines dev environment containing additional dependencies
    # (for linting, testing)
    extras_require={'dev': ['nose',
                            'coverage',
                            'bandit',
                            'pylint',
                            'autopep8',
                            'flake8']
                    },
    # Generally do not assume that the package can safely be run as a zip
    # archive
    zip_safe=False
)
