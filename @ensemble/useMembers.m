function[obj] = useMembers(obj, varargin)
%% ensemble.useMembers  Select which ensemble members should be used by an ensemble
% ----------
%   obj = <strong>obj.useMembers</strong>(staticMembers)
%   Indicates which ensemble members should be used by a static ensemble.
%   The elements of "members" list the indices of ensemble members saved in
%   the .ens file. After using this command, the ensemble will only load
%   these specified ensemble members when using the "ensemble.load"
%   command. Unused ensemble members will not be loaded into memory. By
%   default, ensemble objects load all the ensemble members saved in the
%   .ens file, so use this command when you want to load a subset of the
%   saved ensemble members.
%
%   obj = <strong>obj.useMembers</strong>(-1)
%   obj = <strong>obj.useMembers</strong>('all')
%   Indicates that a static ensemble should use all ensemble members saved 
%   in the .ens file. This syntax cannot be used if the ensemble object
%   implements an evolving ensemble.
%
%   obj = <strong>obj.useMembers</strong>(evolvingMembers)
%   Select the ensemble members that should be used by an evolving
%   ensemble. Note that this syntax cannot be used to initialize an
%   evolving ensemble - instead, it updates the ensemble members used by an
%   existing evolving ensemble. (See the "ensemble.evolving" command to
%   initialize a new evolving ensemble). Each column of the input holds the
%   ensemble members for an ensemble in the evolving set. The number of
%   rows must match the current number of ensemble members used by each
%   ensemble in the existing evolving set.
%
%   obj = <strong>obj.useMembers</strong>(labels, evolvingMembers)
%   obj = <strong>obj.useMembers</strong>(e, evolvingMembers)
%   obj = <strong>obj.useMembers</strong>(-1, evolvingMembers)
%   Select ensemble members for specific ensembles in the evolving set. The
%   second input must have one column per selected ensemble. If the first
%   input is -1, selects all ensembles in the evolving set. This syntax is
%   provided as a convenience, but in general, we recommend instead using
%   the "ensemble.evolving" command to select members for an evolving ensemble.
% ----------
%   Inputs:
%       staticMembers (logical vector | vector, linear indices): Indicates which
%           ensemble members should be used by the ensemble. If a logical
%           vector, must have one element per saved ensemble member. If
%           using linear indices, elements should list the indices of
%           ensemble members saved in the .ens file.
%       evolvingMembers (matrix, linear indices [nMembers x nEnsembles] | logical [nSavedMembers x nEnsembles]):
%           The ensemble members to use for the ensembles in the evolving
%           set. Each column indicates the ensemble members to use for a
%           particular ensemble. If using linear indices, elemebts list the
%           indices of ensemble members saved in the .ens file. If using
%           logical indices, must have one row per saved ensemble members,
%           and the sum of each column must be the same.
%       e (-1 | logical vector | linear indices): The indices of ensembles
%           in an existing evolving ensemble. If a logical vector, must
%           have one element per ensemble in the evolving set. If a linear
%           vector, cannot include repeat indices. If -1, selects all
%           ensemble members in the current evolving set.
%       labels (string vector [nEnsembles]): The labels of ensembles in the
%           evolving set. Must have one element per column in members and
%           cannot contain duplicate elements. You can only use labels to 
%           select ensembles that have unique labels. If multiple
%           ensembles in the evolving set share the same label, reference
%           them using indices instead.
%
%   Outputs:
%       obj (scalar ensemble object): The ensemble with updated ensemble members
%
% <a href="matlab:dash.doc('ensemble.useMembers')">Documentation Page</a>

% Setup
header = "DASH:ensemble:useMembers";
dash.assert.scalarObj(obj, header);

% Check for the correct number of inputs
nInputs = numel(varargin);
if nInputs==0
    dash.error.notEnoughInputs;
elseif nInputs>2
    dash.error.tooManyInputs;

% Update static members
elseif nInputs==1 && ~obj.isevolving
    obj.members_ = obj.assertStaticMembers(varargin{1}, 'staticMembers', header);

% If updating evolving members, don't allow static options
elseif nInputs==2 || obj.isevolving
    if nInputs==1
        input1 = varargin{1};
        if isequal(input1, -1) || isequal(input1, 'all')
            staticOptionError(obj, input1, header);
        end

    % Parse the inputs
        members = input1;
        ensembles = -1;
    else
        ensembles = varargin{1};
        members = varargin{2};
    end

    % Get evolving indices. Check and update evolving members
    e = obj.evolvingIndices(ensembles, false, header);
    obj.members_(:,e) = obj.assertEvolvingMembers(members, obj.nMembers, ...
                                      numel(e), 'evolvingMembers', header);
end

end

%% Error message
function[] = staticOptionError(obj, input1, header)
if isequal(input1, -1)
    input1 = "-1";
else
    input1 = '"all"';
end

id = sprintf('%s:invalidOption', header);
ME = MException(id, ['You cannot use %s as the only input to "useMembers" because ',...
    '%s is an evolving ensemble.'], input1, obj.name);
throwAsCaller(ME);
end