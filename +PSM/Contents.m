%% PSM  Classes and functions that facilitate using forward models to estimate proxy observations
% ----------
%   The PSM package facilitates calculating proxy observation
%   estimates. The package allows users to apply proxy forward models to
%   state vector ensembles in order to estimate proxy values. The package
%   has several main uses. In brief, the PSM package:
%       A. Provides classes that implement proxy forward models
%       B. Downloads the codebases of supported models from Github, and
%       C. Applies forward models to state vector ensembles.
%
%   At its core, the PSM package provides an interface that allows users to
%   run a variety of proxy forward models using the same set of commands.
%   You can learn about the commen set of commands by reading the
%   documentation for PSM.Interface.
%
%   OUTLINE:
%   The following is a outline for using the PSM package.
%       1. Use "info" to learn about the forward models supported by DASH
%       2. Use "download" to download the code for the desired forward models
%       3. Use the forward model interface to design a forward model for 
%          each of the proxy observation sites.
%           a. Use PSM.<model name> to create a new PSM object for a site
%           b. Optionally use "label" to label the forward model
%           c. Use "rows" to indicate which state vector rows hold the
%              inputs for the forward model
%       4. Use "estimate" to apply all the forward models to a state vector
%          ensemble and produce proxy observation estimates.
%
%   Supported Forward models:
%       DASH officially supports the Bay* suite of foraminiferal forward
%       models, general linear forward models, the PRYSM suite of Python
%       forward models, and the Vaganov-Shashkin Lite model of tree ring
%       width. See the documentation on the forward model classes listed
%       below for additional details about these models.
% 
%   Developing new forward models:
%       DASH anticipates that many users will want to develop and use
%       additional forward models for data assimilation. To this end, the
%       PSM package provides a template file that allows users to develop  
%       new forward models without needing to manipulate the internal code
%       of the DASH toolbox. See "PSM.template" and read the documentation
%       within for help adding new PSMs to DASH. 
% 
%       We welcome contributions! If you would like DASH to officially
%       support a new forward model, please send an email to 
%       DASH.toolbox@gmail.com, or submit a pull request to the DASH Github
%       repository.
% ----------
% Information:
%   supported           - Return the names of PSMs supported by the DASH toolbox
%   info                - Return a description of the PSMs supported by DASH
%   githubInfo          - Return information about the codebases of PSMs supported by DASH
%
% Download:
%   download            - Download the codebase of a PSM from Github and add to the active path
%
% Estimate:
%   estimate            - Use PSMs to estimate proxy observations from a state vector ensemble
%
% Forward models:
%   bayfox              - A Bayesian model for d18Oc of planktic foraminifera
%   baymag              - A Bayesian model for Mg/Ca ratios of planktic foraminifera
%   bayspar             - A Baysian model for TEX86
%   bayspline           - A Baysian model for UK'37
%   linear              - General linear models of form:  Y = a1*X1 + a2*X2 + ... an*Xn + b
%   vslite              - The Vaganov-Shashkin Lite model of tree ring width
%
% PRYSM forward models:
%   prysm               - The PRYSM suite of Python forward models
%   prysm.cellulose     - Implement the PRYSM cellulose sensor module
%   prysm.coral         - Implement the PRYSM coral sensor module
%   prysm.icecore       - Implement the PRYSM icecore sensor module
%   prysm.speleothem    - Implement the PRYSM speleothm sensor module
%
% Template:
%   template            - A template file for developing new PSMs
%
% Tests:
%   tests               - Implement unit tests for the PSM package
%
% <a href="matlab:dash.doc('PSM')">Documentation Page</a>