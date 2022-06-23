classdef baymag

    % Description and repository
    properties (Constant)
        description = "A Bayesian model for Mg/Ca of planktic foraminifera";
        repository = "jesstierney/BAYMAG";
        commit = "358de1545d47cbde328fa543c66ab50a20680b00";
        repoComment = "Most recent as of January 22, 2020";
    end

    % Forward model parameters
    properties
        age;
        omega;
        salinity;
        pH;
        clean;
        species;
        options;
    end

end

