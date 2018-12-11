To generate bottom level T files, login to a Linux / UNIX shell, and place 
the following files in an empty directory:

b.e11.BLMTRC5CN.f19_g16.002.cam.h0.T.085001-184912.nc
b.e11.BLMTRC5CN.f19_g16.002.cam.h0.T.185001-200512.nc
b.e11.BLMTRC5CN.f19_g16.003.cam.h0.T.085001-184912.nc
b.e11.BLMTRC5CN.f19_g16.003.cam.h0.T.185001-200512.nc
b.e11.BLMTRC5CN.f19_g16.004.cam.h0.T.085001-184912.nc
b.e11.BLMTRC5CN.f19_g16.004.cam.h0.T.185001-200512.nc
b.e11.BLMTRC5CN.f19_g16.005.cam.h0.T.085001-184912.nc
b.e11.BLMTRC5CN.f19_g16.005.cam.h0.T.185001-200512.nc
b.e11.BLMTRC5CN.f19_g16.006.cam.h0.T.085001-184912.nc
b.e11.BLMTRC5CN.f19_g16.006.cam.h0.T.185001-200512.nc
b.e11.BLMTRC5CN.f19_g16.007.cam.h0.T.085001-184912.nc
b.e11.BLMTRC5CN.f19_g16.007.cam.h0.T.185001-200512.nc
b.e11.BLMTRC5CN.f19_g16.008.cam.h0.T.085001-184912.nc
b.e11.BLMTRC5CN.f19_g16.008.cam.h0.T.185001-200512.nc
b.e11.BLMTRC5CN.f19_g16.009.cam.h0.T.085001-184912.nc
b.e11.BLMTRC5CN.f19_g16.009.cam.h0.T.185001-200512.nc
b.e11.BLMTRC5CN.f19_g16.010.cam.h0.T.085001-184912.nc
b.e11.BLMTRC5CN.f19_g16.010.cam.h0.T.185001-200512.nc
b.e11.BLMTRC5CN.f19_g16.011.cam.h0.T.085001-184912.nc
b.e11.BLMTRC5CN.f19_g16.011.cam.h0.T.185001-200512.nc
b.e11.BLMTRC5CN.f19_g16.012.cam.h0.T.085001-184912.nc
b.e11.BLMTRC5CN.f19_g16.012.cam.h0.T.185001-200512.nc
b.e11.BLMTRC5CN.f19_g16.013.cam.h0.T.085001-184912.nc
b.e11.BLMTRC5CN.f19_g16.013.cam.h0.T.185001-200512.nc

These files are availabe on the earth system grid (ESG):
https://www.earthsystemgrid.org/dataset/ucar.cgd.ccsm4.CESM_CAM5_LME.atm.proc.monthly_ave.T.html

Or on the Glade file system.
(Note that the first run ".001" was partially lost, so I did not include it here.)

Next, add the extract_level.sh script to the directory.

Use your favorite text editor (I use vi), to change the index in the 
"lev,index,index" to 30. This is the bottom level of the atmosphere in LME.

Make the script executable: chmod +x extract_level.sh

Run the script: ./extract_level.sh