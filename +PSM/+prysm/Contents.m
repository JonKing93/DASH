%% PSM.prysm  Classes that implement PRYSM sensor models
% ----------
%   The PSM.prysm package implements classes that run PRYSM sensor models.
%   Each class implements a specific PRSYM sensor model - the names of the
%   classes in DASH match the names of the corresponding PSM module in
%   PRYSM. A list of supported PRYSM forward models is given below.
%
%   DOWNLOADING:
%   The PRYSM forward models are all contained in the same package. Thus,
%   if you use the "PSM.download" command to download a specific forward
%   models, then you will also download all the other forward models in the
%   PRYSM suite.
%
%   SETTING UP PRYSM:
%   The PRYSM forward models are written in Python, and so require some
%   extra setup to run in Matlab. You will need to complete the following to
%   run the PRYSM forward models in DASH:
%   1. Install Python 3.7, 3.8, or 3.9 **directly** on your computer. 
%      DO NOT use conda to install python, as Matlab is unable to locate
%      Python within a conda distribution. Instead, download the language
%      from python.org and install it.
%   2. Use pip to install numpy, and scipy. Do this in a terminal (and not
%      the Matlab console). For example:
%      $ pip install numpy
%      $ pip install scipy
%   3. Use pip to install the PRYSM package. Again, this should be in your
%      computer's terminal, and not the Matlab console:
%      $ pip install git+https://github.com/sylvia-dee/PRYSM.git
%   4. Within the Matlab console, initialize your Matlab session's Python 
%      environment using the version of Python that contains PRYSM. Do this
%      using the "pyenv" command. For example, if you are using Python 3.7, do:
%      >> pyenv('Version', '3.7')
%   After completing this steps, the PRYSM forward models should be ready
%   to run in DASH.
%
%   ABSTRACT SUPERCLASS:
%   The individual PRYSM forward model classes inherit from the abstract
%   superclass PSM.prysm.package. The main purpose of this superclass is to
%   hold the Github information for the PRYSM forward models, as all the
%   PRYSM forward models are located in the same Github repository.
% ----------
% Abstract Superclass:
%   package     - Holds repository information for models in the PRYSM suite
%
% Forward Model Classes:
%   cellulose   - Implements the cellulose d18O sensor model from PRYSM
%   coral       - Implements the coral d18O sensor model from PRYSM
%   icecore     - Implements the icecore d18O sensor model from PRYSM
%
% <a href="matlab:dash.doc('PSM.prysm')">Documentation Page</a>