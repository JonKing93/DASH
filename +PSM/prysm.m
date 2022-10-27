classdef (Abstract) prysm < PSM.Interface
    %% PSM.prysm  Superclass for forward models in the PRYSM Python package
    % ----------
    %   The PSM.prysm class provides a superclass for the individual
    %   forward models within the PRYSM suite. This superclass is primarily
    %   used to hold information about the PRYSM suite for use with the
    %   PSM.download and PSM information methods.
    %
    %   If you would like to actually implement a PRYSM forward model,
    %   please see the classes for specific PRYSM forward models.
    %   Specifically: PSM.prysm.cellulose, PSM.prysm.coral,
    %   PSM.prysm.icecore, PSM.prysm.speleothem.
    % ----------
    % prysm Methods:
    %
    % Abstract Inherited:
    %   label           - Optionally apply a label to a PSM object
    %   rows            - Indicate the state vector rows required to run a forward model
    %   disp            - Display a PSM object in the console
    %   estimate        - Run a forward model on inputs extracted from a state vector ensemble
    %   name            - Return a name for a PSM object for use in error messages
    %   parseRows       - Process and error check the inputs to the "rows" command
    %
    % <a href="matlab:dash.doc('PSM.prysm')">Documentation Page</a>

    properties (Constant)
        estimatesR = false;                                         % PRYSM modules do not estimate R uncertainties
        hasMemory = false;                                          % PRYSM modules do not retain memory of previous time steps

        repository = "sylvia-dee/PRYSM";                            % Github repository for the PRYSM package
        commit = "13dc4fbc1a4493e86a4568d2d83d8495f6f40fe1";        % Commit hash of the supported version of PRYSM
        commitComment = "Includes all PRYSM sensor modules";        % Details about the supported commit
    end
    properties (Constant, Hidden)
        packageDescription = "The PRYSM suite of Python forward models.";
    end
end