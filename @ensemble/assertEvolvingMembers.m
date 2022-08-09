function[members] = assertEvolvingMembers(obj, members, nRows, nCols, name, header)
%% ensemble.assertEvolvingMembers  Throw error if input is not members for an evolving ensemble
% ----------
%   members = <strong>obj.assertEvolvingMembers</strong>(members, nRows, nCols)
%   Checks that the input members is a matrix of indices, where each column
%   describes a set of indices. Requires the same number of indices along
%   each column. Converts logical indices to linear indices for each
%   column. Optionally checks that the number of members matches the
%   current number of members, and that the number of evolving ensembles
%   matches the current number of evolving ensembles.
%
%   members = <strong>obj.assertEvolvingMembers</strong>(member, nRows, nCols, name, header)
%   Customize error messages and IDs.
% ----------
%   Inputs:
%       members (any data type): The input being checked
%       nRows (scalar positive integer | []): The required number of members per
%           column. If empty, allows any number.
%       nCols (scalar positive integer | []): The required number of
%           columns/sets of indices. If empty, allows any number.
%       name (string scalar): The name of the input for use in error messages
%       header (string scalar): Header for thrown error IDs
%
%   Outputs:
%       members (matrix, linear indices): The members as linear indices
%
% <a href="matlab:dash.doc('ensemble.assertEvolvingMembers')">Documentation Page</a>

% Defaults
if ~exist('name','var') || isempty(name)
    name = 'members';
end
if ~exist("header",'var') || isempty(header)
    header = 'DASH:ensemble:assertEvolvingMembers';
end

% Check members is matrix and allowed data type
try
    if ~ismatrix(members)
        id = sprintf('%s:membersNotMatrix', header);
        error(id, '%s must be a matrix', name);
    elseif isempty(members)
        id = sprintf('%s:notEnoughMembers', header);
        error(id, '%s cannot be empty', name);
    end
    
    % Check logical members
    if islogical(members)
        [nLogicalRows, nEnsembles] = size(members);
    
        % Require one row per saved ensemble member
        if nLogicalRows ~= obj.totalMembers
            id = sprintf('%s:logicalMembersWrongLength', header);
            error(id, ['Since %s is logical, it must have one row per saved ',...
                'ensemble member (%.f), but it has %.f rows instead.'], ...
                name, obj.totalMembers, nRows);
        end
    
        % Require columns to have the same number of members
        nMembers = sum(members, 1);
        bad = find(nMembers~=nMembers(1));
        if any(bad)
            id = sprintf('%s:differentNumberOfMembers', header);
            error(id, ['Since %s is logical, the number of true elements in ',...
                'each column must be the same. However, column 1 has %.f true elements ',....
                'whereas column %.f has %.f true elements'], ...
                name, nMembers(1), bad, nMembers(bad));
        end
    
        % Optionally require a specific number of members
        if ~isempty(nRows) && nMembers(1)~=nRows
            id = sprintf('%s:changedNumberOfMembers', header);
            error(id, ['Since you are updating the existing evolving ensemble, you cannot ',...
                'change the number of members per ensemble (%.f). Thus, since %s is ',...
                'logical, the columns of %s must each have %.f true elements. However, ',...
                'the columns of %s have %.f true elements instead.\n\nIf you would ',...
                'like to change the number of members per ensemble, you will need to design a ',...
                'new evolving ensemble.'],...
                nRows, name, name, nRows, name, nMembers(1));
        end
    
        % Convert to linear
        [r, ~] = find(members);
        members = reshape(r, [], nEnsembles);
    
    % Check numeric are positive integers...
    elseif isnumeric(members)
        [isvalid, bad] = dash.is.positiveIntegers(members);
        if ~isvalid
            id = sprintf('%s:invalidLinearIndices', header);
            error(id, ['Since %s is numeric, it must consist of linear indices ',...
                '(positive integers). However, element %.f (%f) is not a positive integer.'],...
                name, bad, members(bad));
        end
    
        % ...and not too large...
        [maxMember, loc] = max(members);
        if maxMember > obj.totalMembers
            id = sprintf('%s:linearIndicesTooLarge', header);
            error(id, ['Element %.f of %s (%.f) is greater than the number ',...
                'of saved members (%.f).'], loc, name, maxMember, obj.totalMembers);
    
        % ...and have the correct number of members
        elseif ~isempty(nRows)
            nMembers = size(members,1);
            if nRows ~= nMembers
                id = sprintf('%s:changeNumberOfMembers', header);
                error(id, ['Since you are updating the existing evolving ensemble, you cannot ',...
                    'change the number of members per ensemble (%.f). Thus, since %s consists ',...
                    'of linear indices, %s must have %.f rows. However, %s has %.f rows ',...
                    'instead.\n\nIf you would like to change the number of members per ensemble, you will ',...
                    'need to design a new evolving ensemble.'],...
                    nRows, name, name, nRows, name, nMembers);
            end
        end
    
    % All other data types are invalid
    else
        id = sprintf('%s:invalidMembers', header);
        error(id, '%s must either be a matrix of linear indices, or a logical matrix', name);
    end
    
    % Optionally check the number of columns
    if ~isempty(nCols) && nEnsembles~=nCols
        id = sprintf('%s:membersWrongNumberColumns', header);
        error(id, ['The "%s" input must have %.f columns (one per ensemble). ',...
            'However, "%s" has %.f columns instead.'], name, nCols, name, nEnsembles);
    end

% Minimize error stack
catch ME
    throwAsCaller(ME);
end

end