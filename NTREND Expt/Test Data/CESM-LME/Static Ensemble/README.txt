These are functions to build a sample stack of model temperature states.
The sample set of states is selected from the first control run of the
CESM-LME.

Github doesn't like to manage large data files, so you will need to build
your own .mat file. Do this by running buildSampleStack.m in a directory
containing the two files:

b.e11.B1850C5CN.f19_g16.0850cntl.001.cam.h0.T.085001-184912.nc
b.e11.B1850C5CN.f19_g16.0850cntl.001.cam.h0.T.185001-200512.nc

from the CESM-LME output. These are available on NCAR's Earth System Grid,
and also on NCAR's glade server.