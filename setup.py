#!/usr/bin/python3

from setuptools import find_packages, setup

# from broker import __version__

with open("README.org", "r") as fh:
    long_description = fh.read()

with open("requirements.txt", "r") as f:
    requirements = list(map(str.strip, f.read().split("\n")))[:-1]

setup(
    name="autonomousSoftwareOrg",
    packages=find_packages(),
    setup_requires=["wheel", "ipdb"],
    version="0.0.1",  # don't change this manually, use bumpversion instead
    license="MIT",
    description=(
        "AutonomousSoftwareOrg keep track of software executions along with their input "
        "and output data files to produce data and software execution graphs for analysis."
    ),  # noqa: E501
    long_description=long_description,
    long_description_content_type="text/markdown",
    author="Alper Alimoglu",
    author_email="alper.alimoglu@gmail.com",
    url="https://github.com/ebloc/AutonomousSoftwareOrg",
    keywords=["autonomousSoftwareOrg"],
    install_requires=requirements,
    entry_points={
        "console_scripts": ["auto=_cli.__main__:main"],
    },
    include_package_data=True,
    python_requires=">=3.6,<4",
    classifiers=[
        "Development Status :: 5 - Production/Stable",
        "Intended Audience :: Developers",
        "Topic :: Software Development :: Build Tools",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.6",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
    ],
)
