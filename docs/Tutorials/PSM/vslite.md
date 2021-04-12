---
sections:
  - VS-Lite
  - Prerequisites
  - Initialize
  - Run directly
---

# VS-Lite
Use the vslitePSM class to create PSMs that implement the Vaganov-Shashkin Lite (VS-Lite) model of tree ring growth. Find [VS-Lite on Github](https://github.com/suztolwinskiward/VSLite), or see the paper:

Tolwinski-Ward, S. E., Evans, M. N., Hughes, M. K., and Anchukaitis, K. J.: An efficient forward model of the climate controls on interannual variation in tree-ring width (2011) Clim. Dynam., 36, 2419–2439. [https://doi.org/10.1007/s00382-010-0945-5](https://doi.org/10.1007/s00382-010-0945-5)

### Prerequisites
You must download the [VS-Lite repository](https://github.com/suztolwinskiward/VSLite) and add it to the Matlab active path. If you have git installed, you can use:
```matlab
PSM.download('vslite');
```
to do this automatically.

### Initialize
Create a new vslitePSM object using the "vslitePSM" command. The syntax is:
```matlab
mypsm = vslitePSM( rows, phi, T1, T2, M1, M2, options )
```
where the inputs are as follows:

##### rows
An array indicating the state vector elements needed to run the PSM. This array should have 24 rows. Rows 1-12 should indicate mean monthly temperatures (in Celsius) ordered from January to December. Rows 13-24 should indicate monthly precipitation (in mm) ordered from January to December.

##### phi
A scalar indicating the latitude of the site in decimal degrees.

##### T1
A scalar indicating the temperature threshold (in Celsius) below which growth is zero.

##### T2
A scalar indicating the temperature threshold (in Celsius) above which growth is zero.

##### M1
A scalar indicating the soil moisture threshold (in v/v) below which growth is zero.

##### M2
A scalar indicating the soil moisture threshold (in v/v) above which growth is zero.

##### options
An optional input specifying additional options for the model. A cell vector whose elements alternate as "name", value pairs. Option names include: "lbparams", "intwindow", and "hydroclim". Please see the documentation in the "VSLite_v2_3" function for allowed values associated with these options.

### Run Directly
You can run the VS-Lite forward model directly using "vslitePSM.run". Here, the syntax is:
```matlab
trw = vslitePSM.run(phi, T1, T2, M1, M2, T, P, options);
```
Here, T is a matrix of monthly temperatures (in Celsius) with 12 rows ordered from January to December. P is a matrix of monthly precipitation values (in mm) with 12 rows ordered from January to December. The remaining inputs are as described above.
