%% Tutorial 4: PSMs

% PSMs are stored as part of the PSM class.
%
% In general, you need to know 2 methods to use a PSM
% 1. The method to create a PSM object (which is always the name of the PSM)
% 2. The "getStateIndices" method.

%% New PSM objects
clearvars;
% It is up to the user to know the names of the PSMs they wish to use.
% Current PSMs include
%
% linearPSM: Implements multivariate linear models
% ukPSM: Implements a uk37 forward model
% vstempPSM: Implements temperature-only VS-Lite
%
% Check out PSMs/Specific Forward Models for more

% Here we'll demo with some ukPSMs

% Let's say we have a 5 proxy sites in the northern hemisphere
lats = [1;15;60;22;18];
lons = rand(5,1);
nSites = 5;

% We'll initialize some new ukPSMs, and store them in a cell aary
F = cell(5,1);
for s = 1:nSites
    F{s} = ukPSM( lats(s), lons(s) );
end

% Great! That's the first step to using a PSM. Again, the name of the PSM
% will vary. But you can do
%
% >> help psmName.psmName
%
% to see how to build a new PSM
help ukPSM.ukPSM

% Or
% >> doc psmName
% 
% to see if the PSM has any additional methods.


%% State indices

% The method, "getStateIndices" is used by each PSM to determine which
% state vector elements it requires to run. The inputs will vary by PSM, so
% you will probably want to use
%
% >> help psmName.getStateIndices
%
% for syntax.

help ukPSM.getStateIndices

% We can see that the ukPSM requires knowing ensemble metadata, the name of
% the SST variable, and sequence metadata for all 12 months. We'll use the
% tutorial_sequence.ens ensemble built at the end of the last tutorial.
% Let's pretend that the Tref variables are actually SST variables for
% convenience.
ens = ensemble('tutorial_sequence.ens');
months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]';

for s = 1:nSites
    F{s}.getStateIndices( ens.metadata, "T", months );
end

% Great! The PSMs are ready for use

%% Unit correction

% The ukPSM are written to process data in celsius. But model output is
% often in Kelvin, so it may be necessary to convert units when passing
% data to the PSM.

% You can do this via the "setUnitConversion" method
for s = 1:nSites
    F{s}.setUnitConversion( 'add', -273.15*ones(12,1) );
end

% here, I provided -273.15 twelve times because the ukPSM has 12 inputs
% (SST for each month). However, this will vary by PSM

disp( F{1}.addUnit )
% shows the additive constant being used for unit conversion.

% Let's save these PSMs for the next tutorial
save('tutorial_psms.mat', 'F', 'lats','lons');
%% Bias correction

% You can also have PSMs apply a bias correction to input data. This is
% somewhat of an advanced topic, so see PSM.setBiasCorrector, and the
% biasCorrector classes for comprehensive details.