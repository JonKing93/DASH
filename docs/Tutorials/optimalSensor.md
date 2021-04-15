# Welcome to the optimalSensor tutorial

This tutorial provides a guide to running an optimal sensor experiment using the optimalSensor class. These experiments modify a Kalman Filter to determine sampling sites that most strongly reduce the uncertainty of a reconstruction target. For the method used in these experiments, see [Comboul et al., 2015](https://doi.org/10.1175/JCLI-D-14-00802.1).

### Prerequisites

DASH requires MATLAB 2018B or higher. If you are using an earlier version, you will need to [upgrade](https://www.mathworks.com/help/install/ug/upgrade-matlab-release.html) your release.

You do not need any of the other DASH modules to use the optimalSensor class. However, the [PSM](..\psm\welcome), [stateVector](..\stateVector\welcome), [ensemble](..\ensemble\welcome), and [ensembleMetadata](..\ensembleMetadata\welcome) modules may all prove useful in facilitating particle filter analyses.
