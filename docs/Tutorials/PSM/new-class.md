# Create a new PSM class
You may want to use forward models not included in DASH to estimate observations for data assimilation. If this is the case, you may be interested in creating a new PSM class. This way, you can automate proxy estimates for the forward model using the "PSM.estimate" command.

DASH includes a template for creating new PSM classes. To access this template, do:
```matlab
edit templatePSM
```

This should open a file name "templatePSM" in the Matlab editor. Follow the instructions in this template to create your new PSM.
