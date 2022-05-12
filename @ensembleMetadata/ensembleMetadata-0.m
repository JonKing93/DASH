classdef ensembleMetadata

    properties
        variables_;
        lengths;
        nMembers;
        members_;
    end

    methods
        function[obj] = ensembleMetadata(sv)
            obj.variables_ = sv.variables;
            obj.lengths = sv.lengths;
            obj.nMembers = sv.members;
            obj.members_ = 1:obj.nMembers;
        end
        function[nMembers] = members(obj)
            nMembers = obj.nMembers;
        end
        function[variableNames] = variables(obj)
            variableNames = obj.variables_;
        end
        function[lengths] = length(obj, ~)
            lengths = obj.lengths;
        end
        function[obj] = extract(obj, variables)
            obj.variables_ = variables;
        end
        function[obj] = extractMembers(obj, members)
            obj.members_ = members;
        end
    end

end