classdef ensembleMetadata

    properties
        variables_;
        lengths;
        nMembers;
    end

    methods
        function[obj] = ensembleMetadata(sv)
            obj.variables_ = sv.variables;
            obj.lengths = sv.lengths;
            obj.nMembers = sv.members;
        end
    end

end