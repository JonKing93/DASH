---
sections:
  - Set up PRYSM for DASH
  - Install Python
  - Install PRYSM dependencies
  - Download PRYSM
  - Install PRYSM
  - Activate a Python session from Matlab
---

# Set up PRYSM for DASH

In order to use any of the PRSYM forward models, you will first need to download and install the PRYSM package in Python. This page provides instructions for this process, and you can find additional instructions in the [PRYSM repository](https://github.com/sylvia-dee/PRYSM).

### Install Python

As a first step, you must [download and install Python](https://www.python.org/downloads/release/python-383/).

Although this conflicts with the installation instructions in the [PRYSM repository](https://github.com/sylvia-dee/PRYSM), we recommend using Python 3.8 when integrating PRYSM with DASH. We specifically recommend the legacy 3.8 Python release, and not a more recent version.

***Note:*** At this time, Matlab does not support Python installed in conda environments. You must install Python directly on your local machine.

### Install PRYSM dependencies

PRYSM uses the [numpy](http://www.numpy.org/), [scipy](http://www.scipy.org/), and [rpy2](http://rpy.sourceforge.net/) Python packages. You must download and install these packages before using PRYSM.

We recommend doing this using a package manager from a terminal. For example, using pip:
```
pip install numpy
pip install scipy
pip install rpy2
```

### Download PRYSM

Next, download the [PRYSM repository](https://github.com/sylvia-dee/PRYSM)

If you have git installed, you can use:
```matlab
PSM.download('prysm')
```
to do this automatically. Alternatively, navigate to the [PRYSM V2.0 Release](https://github.com/sylvia-dee/PRYSM/releases/tag/2.0), and download and unzip the source code.

### Install PRYSM

Next, install PRYSM in the Python environment. In a terminal, navigate to the root directory of the PRYSM package, then do:
```
python setup.py install
```

or
```
python setup.py install --user
```
if you lack root access.

### Activate a Python session from Matlab

Since PRYSM is written in Python, you must activate a Python session from Matlab before using PRYSM with DASH. Use the command:
```matlab
pyenv
```
to initiate a Python session from Matlab. If you have multiple versions of Python installed on your machine, use:
```matlab
pyenv('Version', 3.8);
```
to ensure you are using version 3.8.

If you are already running a Python session using a different version, you will need to restart Matlab to initiate a Python session with version 3.8.
