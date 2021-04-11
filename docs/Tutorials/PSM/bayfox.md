---
sections:
  - BayFOX
  - Prerequisites
  - Initialize
  - Run directly
---

# BayFOX

Use the "bayfoxPSM" class to create PSMs that implement BayFOX, a Bayesian forward model for δ<sup>18</sup>O<sub>c</sub> of planktic foraminifera. Find [BayFOX on Github](https://github.com/jesstierney/bayfoxm) or see the paper:

 Malevich, S. B., Vetter, L., & Tierney, J. E. (2019). Global Core Top Calibration of δ18O in Planktic Foraminifera to Sea Surface Temperature. Paleoceanography and Paleoclimatology, 34(8), 1292-1315. [https://doi.org/10.1029/2019PA003576](https://doi.org/10.1029/2019PA003576)

### Prerequisites

You must download the [bayfoxm repository](https://github.com/jesstierney/bayfoxm) and add it to the Matlab active path. If you have git installed, you can use:
```matlab
PSM.download('bayfox');
```
to do this automatically.

### Initialize
Create a new bayfoxPSM object using the "bayfoxPSM" command. The syntax is:
```matlab
mypsm = bayfoxPSM(rows, species);
```
Here, the inputs are as follows

##### rows
An array that indicates the state vector elements needed to run the PSM. This array should have two rows: the first should indicate sea-surface temperatures (in Celsius), and the second should indicate δ<sup>18</sup>O of sea-water (in VSMOW).

##### species
A string indicating the foram species. Options are:

* <code><span style="color:#cc00cc;font-size:0.875em">"bulloides"</span></code>: G. bulloides
* <code><span style="color:#cc00cc;font-size:0.875em">"incompta"</span></code>: N. incompta
* <code><span style="color:#cc00cc;font-size:0.875em">"pachy"</span></code>: N. pachyderma
* <code><span style="color:#cc00cc;font-size:0.875em">"ruber"</span></code>: G. ruber
* <code><span style="color:#cc00cc;font-size:0.875em">"sacculifer"</span></code>: T. sacculifer
* <code><span style="color:#cc00cc;font-size:0.875em">"all"</span></code>: use the pooled annual (non-species specific) model
* <code><span style="color:#cc00cc;font-size:0.875em">"all_sea"</span></code>: use the pooled seasonal (non-species specific) model

### Run Directly

You can run the BayFOX forward model directly using "bayfoxPSM.run". Here, the syntax is:
```matlab
d18Oc = bayfoxPSM.run( SSTs, d18Osw, species );
```
where SSTs is a vector of sea-surface temperatures (in Celsius), d18Osw is a vector of sea-water δ<sup>18</sup>O values (in VSMOW), and species is one of the aforementioned strings.
