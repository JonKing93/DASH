classdef (Abstract) prysm < PSM.Interface
    %% PSM.prysm  Implements modules in the PRYSM Python package
    % ----------
    %   ...
    % ----------

    properties (Constant)
        estimatesR = false;                                         % PRYSM modules do not estimate R uncertainties
        repository = "sylvia-dee/PRYSM";                            % Github repository for the PRYSM package
        commit = "13dc4fbc1a4493e86a4568d2d83d8495f6f40fe1";        % Commit hash of the supported version of PRYSM
        commitComment = "";                                         % Details about the supported commit
    end

    methods (Static)
        function[info] = description
            % Description of the code suite
            info = "The PRYSM suite of Python forward models";
        end
    end
end