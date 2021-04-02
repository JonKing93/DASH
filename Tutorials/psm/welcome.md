---
layout: simple_layout
title: Welcome!
---

# Welcome to the PSM tutorial

This tutorial provides a guide to

1. Creating proxy system models (PSMs), and
2. Estimating proxy observations from a model ensemble

using the PSM class.

### Prerequisites

You can use the PSM class even if you are not familiar with any of the other modules in DASH. However, the PSM class is most often used to estimate values from a state vector ensemble, so familiarity with the [ensembleMetadata module](../ensembleMetadata/welcome) is helpful. Similarly, you may want to see the [stateVector](../stateVector/welcome) and [ensemble](../ensemble/welcome) tutorials to help create state vector ensembles.

If you want to use the PSM module to download external proxy system model packages, you must have ![git installed](https://git-scm.com/downloads).

If you are interested in integrating DASH with the PRySM suite of proxy system modeling tools, you will need to ![install PRySM and its dependencies](https://github.com/sylvia-dee/PRYSM).

DASH requires MATLAB 2018B or higher. If you are using an earlier version, you will need to [upgrade](https://www.mathworks.com/help/install/ug/upgrade-matlab-release.html) your release.

#### Help from the Matlab console

This tutorial covers most commands for PSM classes. However, you can also use
```matlab
help PSM
```
to display an overview of PSM commands to the Matlab console, or
```matlab
help psmName
```
to display commands for a specific PSM.

You can also use
```matlab
help PSM.commandName
help psmName.commandName
```
to display help for a particular command.

Alternatively, use
```matlab
doc PSM
doc PSM.commandName

doc psmName
doc psmName.commandName
```
to display help in the Matlab documentation browser.

Alright, onward to the tutorial.

[Next](object)
