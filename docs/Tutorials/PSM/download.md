---
sections:
  - External PSMs
  - PSM.download
  - Prerequisites
  - Usage
  - Download path
---

# External PSMs
Proxy system models can range in complexity from linear relationships to more sophisticated process-based models. DASH includes a built-in general linear PSM, but also includes support for many external PSMs. These include:

* Bayesian models for planktic foraminifera ([BayFOX](https://github.com/jesstierney/bayfoxm), [BayMAG](https://github.com/jesstierney/BAYMAG), [BaySPAR](https://github.com/jesstierney/BAYSPAR), [BAYSPLINE](https://github.com/jesstierney/BAYSPLINE))
* δ<sup>18</sup>O forward models for multiple proxies via the [PRYSM Python package](https://github.com/sylvia-dee/PRYSM), and
* the [VS-Lite](https://github.com/suztolwinskiward/VSLite) thresholding model of tree ring growth

The code for these models is not included in DASH, so you will need to download any of these external PSMs that you want to work with. Although you can download the code for these PSMs manually, by navigating to their Github repositories, the PSM class provides a command to download this code automatically.

# PSM.download

You can use the "PSM.download" command to download the code for external PSMs and add it to the Matlab active path. This command automatically downloads external code versions that have been error-tested within the DASH framework, so we recommend using "PSM.download" when possible.

### Prerequisites
You must [install git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) in order to use "PSM.download".

### Usage
The basic syntax for "PSM.download" is:
```matlab
PSM.download(psmName);
```
Here, "psmName" is a string indicating the code that should be downloaded. Options are:

* <code><span style="color:#cc00cc;font-size:0.875em">"bayfox"</span></code>: The BayFOX model of foraminiferal δ<sup>18</sup>O<sub>c</sub>
* <code><span style="color:#cc00cc;font-size:0.875em">"baymag"</span></code>: The BayMAG model of foraminiferal Mg/Ca
* <code><span style="color:#cc00cc;font-size:0.875em">"bayspar"</span></code>: The BaySPAR model of foraminiferal TEX<sub>86</sub>
* <code><span style="color:#cc00cc;font-size:0.875em">"bayspline"</span></code>: The BaySPLINE model of foraminiferal U<sup>K'</sup><sub>37</sub>
* <code><span style="color:#cc00cc;font-size:0.875em">"prysm"</span></code>: The PRYSM Python package of δ<sup>18</sup>O models for multiple proxies
* <code><span style="color:#cc00cc;font-size:0.875em">"vslite"</span></code>: The VS-Lite model of thresholding tree ring growth

For example:
```matlab
PSM.download('bayfox');
```
would download the BayFOX PSM and add it to the Matlab active path.

### Download Path

When you use "PSM.download", the git repository for the requested PSM will be downloaded into the current folder. If you would like to download the PSM somewhere else, you can use the second input to specify a download path.
```matlab
PSM.download( psmName, downloadPath );
```
Here, "download" path is a string indicating the desired path. For example, you could use:
```matlab
PSM.download('bayfox', 'Users/myUsername/Matlab/PSM-downloads')
```
to download the BayFOX repository to a custom folder for PSMs.

Once you have downloaded any external code, you can begin designing proxy system models for different proxy sites. In the next section, we will see how to use [PSM objects](object) to do this.
