# PSM Overview

The PSM class implements proxy system models, forward models that transform climate variables into climate proxy values. In the context of data assimilation, these are most commonly used to estimate proxy observations (Ye) for a state vector ensemble.

The typical workflow for using the PSM class to estimate proxy observations is to:
1. Download any external code implementing proxy system models,
2. Design a PSM for each proxy site, and
3. Use the "PSM.estimate" command to estimate proxy values for a state vector ensemble.

The next pages of this tutorial will examine each of these steps in detail, and the [Advanced Topics page](advanced) includes details for working with specific proxy system models.
