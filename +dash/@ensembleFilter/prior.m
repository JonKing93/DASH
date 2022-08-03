function[outputs, type] = prior(obj, header, X, whichPrior)
%% dash.ensembleFilter.prior  Process the prior for a filter object
% ----------
%   [outputs, type] = obj.prior(header, ...)
%   Processes options for priors for a filter. Returns the outputs for
%   the operations collected in a cell. Also returns a string indicate the
%   type of operation performed.
%
%   [priorCell, 'return'] = obj.prior(header)
%   Returns the current prior and whichPrior.
%
%   [objCell, 'set'] = obj.prior(header, Ye)
%   [objCell, 'set'] = obj.prior(header, Ye, whichPrior)
%   Error checks the input prior and whichPrior and overwrites any
%   previously existing prior. Returns the updated filter object.
%
%   [objCell, 'delete'] = obj.prior('delete')
%   Deletes any current prior and returns the updated filter object.
% ----------
%   Inputs:
%       header (string scalar): Header for thrown error IDs
%       Ye (numeric array [nSite x nMembers x nPrior]): Prior for the filter
%       whichPrior (vector, linear indices [nTime]): Indicates which prior
%           to use in each time step.
%       
%   Outputs:
%       outputs (cell scalar): Varargout-style outputs
%       type ('return'|'set'|'delete'): Indicates the type of operation
%       priorCell (cell vector [2] {X, whichPrior}): The current prior and
%           whichPrior in a cell
%       objCell (cell scalar {obj}): The updated object in a cell
% 
% <a href="matlab:dash.doc('dash.ensembleFilter.prior')">Documentation Page</a>

% Setup
try
    if ~exist('header','var') || isempty(header)
        header = "DASH:ensembleFilter:prior";
    end
    dash.assert.scalarObj(obj, header);
    
    % Return estimates
    if ~exist('X','var')
        outputs = {obj.X, obj.whichPrior};
        type = 'return';
    
    % Delete current prior, don't allow second input
    elseif dash.is.strflag(X) && strcmpi(X, 'delete')
        if exist('whichPrior','var')
            dash.error.tooManyInputs;
        end
    
        % Delete and reset sizes
        obj.X = [];
        obj.Xtype = NaN;
    
        obj.nState = 0;
        if isempty(obj.Ye)
            obj.nMembers = 0;
            obj.nPrior = 0;
            obj.whichPrior = [];
        end
        if isempty(obj.Y) && isempty(obj.whichR) && isempty(obj.whichPrior)
            obj.nTime = 0;
        end
    
        % Collect output
        outputs = {obj};
        type = 'delete';
    
    % Set prior. Get defaults.
    else
        if ~exist('whichPrior','var') || isempty(whichPrior)
            whichPrior = [];
        end
    
        % Don't allow empty array
        if isempty(X)
            emptyPriorError(obj, header);
        end
    
        % If estimates are set, require matching number of members and priors
        siz = NaN(1, 3);
        if ~isempty(obj.Ye)
            siz(2) = obj.nMembers;
            siz(3) = obj.nPrior;
        end
    
        % Numeric array. Require 3D of correct size with well-defined values.
        % Get sizes
        if isnumeric(X)
            dash.assert.blockTypeSize(X, ["single";"double"], siz, 'X', header);
            dash.assert.defined(X, 2, 'X', header);
            [nState, nMembers, nPrior] = size(X, 1:3);
            Xtype = 0;
    
        % Ensemble object. Get sizes
        elseif isa(X, 'ensemble')
            ens = X;
            nState = ens.nRows;
            nMembers = ens.nMembers;
            nPrior = ens.nEvolving;
    
            % If scalar, optionally check nMembers and nPrior
            if isscalar(ens)
                Xtype = 1;
                if ~isnan(siz(2))
                    if nMembers~=obj.nMembers
                        scalarEnsMembersError(ens, nMembers, obj, header);
                    elseif nPrior~=obj.nPrior
                        scalarEnsPriorError(ens, nPrior, obj, header);
                    end
                end
    
            % Otherwise, require a vector with an element per prior
            else
                Xtype = 2;
                dash.assert.vectorTypeN(ens, [], siz(3), 'ens', header);
    
                % Require static ensembles with the same number of state vector
                % elements and ensemble members
                if any(nPrior~=1)
                    evolvingEnsembleError(nPrior, ens, header);
                elseif numel(unique(nState)) ~= 1
                    differentStateError(ens, nState, header);
                elseif numel(unique(nMembers)) ~= 1
                    differentMembersError(ens, nMembers, header);
                end
    
                % Get sizes for vector of objects
                nState = nState(1);
                nMembers = nMembers(1);
                nPrior = numel(ens);
    
                % Optionally check nMembers and nPrior
                if ~isnan(siz(2))
                    if nMembers~=obj.nMembers
                        vectorEnsMembersError(nMembers, obj, header);
                    elseif nPrior ~= obj.nPrior
                        vectorEnsPriorError(nPrior, obj, header);
                    end
                end
            end
        end
    
        % Set sizes
        obj.nState = nState;
        obj.nMembers = nMembers;
        obj.nPrior = nPrior;
    
        % Note if whichPrior is already set by the estimates
        whichIsSet = false;
        if ~isempty(obj.Ye) && ~isempty(obj.whichPrior)
            whichIsSet = true;
        end
    
        % Note whether allowed to set nTime
        timeIsSet = true;
        if isempty(obj.Y) && isempty(obj.whichR) && ~whichIsSet
            timeIsSet = false;
        end
    
        % Error check and process whichPrior
        obj = obj.processWhich(whichPrior, 'whichPrior', obj.nPrior, 'priors',...
                                                timeIsSet, whichIsSet, header);
    
        % Save and build output
        obj.X = X;
        obj.Xtype = Xtype;
        outputs = {obj};
        type = 'set';
    end

% Minimize error stack
catch ME
    if startsWith(ME.identifier, "DASH")
        throwAsCaller(ME);
    else
        rethrow(ME);
    end
end

end

% Error messages
function[] = emptyPriorError(obj, header)
id = sprintf('%s:emptyPrior', header);
ME = MException(id, 'The prior for %s cannot be empty.', obj.name);
throwAsCaller(ME);
end
function[] = scalarEnsMembersError(ens, nMembers, obj, header)
id = sprintf('%s:wrongNumberMembers', header);
ME = MException(id, ['The number of ensemble members implemented by %s ',...
    '(%.f) does not match the number of ensemble members for %s (%.f).'],...
    ens.name, nMembers, obj.name, obj.nMembers);
throwAsCaller(ME);
end
function[] = scalarEnsPriorError(ens, nPrior, obj, header)
id = sprintf('%s:wrongNumberPriors', header);
ME = MException(id, ['The number of evolving priors implemented by %s (%.f) ',...
    'does not match the number of priors for %s (%.f).'],...
    ens.name, nPrior, obj.name, obj.nPrior);
throwAsCaller(ME);
end
function[] = vectorEnsMembersError(nMembers, obj, header)
id = sprintf('%s:wrongNumberMembers', header);
ME = MException(id, ['The number of ensemble members implemented by the ensemble ',...
    'objects (%.f) does not match the number of ensemble members for %s (%.f).'],...
    nMembers, obj.name, obj.nMembers);
throwAsCaller(ME);
end
function[] = vectorEnsPriorError(nPrior, obj, header)
id = sprintf('%s:wrongNumberPriors', header);
ME = MException(id, ['The number of priors implemented by the ensemble ',...
    'objects (%.f) does not match the number of priors for %s (%.f).'],...
    nPrior, obj.name, obj.nPrior);
throwAsCaller(ME);
end
function[] = evolvingEnsembleError(nPrior, ens, header)
bad = find(nPrior~=1);
label = '';
if ~strcmp(ens(bad).label_, "")
    label = sprintf(' (%s)', ens(bad).label_);
end
badValue = nPrior(bad);

id = sprintf('%s:evolvingEnsemble', header);
ME = MException(id, ['When you use a vector of ensemble objects ',...
    'to implement an evolving prior, each individual ensemble object ',...
    'must implement a static ensemble. However, ensemble object %.f%s implements ',...
    'an evolving ensemble with %.f ensembles.'], bad, label, badValue);
throwAsCaller(ME);
end
function[] = differentStateError(ens, nState, header)
[~, loc] = unique(nState);
bad1 = nState(loc(1));
bad2 = nState(loc(2));

label1 = '';
if ~strcmp(ens(loc(1)).label_, "")
    label1 = sprintf(' (%s)', ens(loc(1)).label_);
end
label2 = '';
if ~strcmp(ens(loc(2)).label_, "")
    label2 = sprintf(' (%s)', ens(loc(2)).label_);
end

id = sprintf('%s:differentStateVectorLength', header);
ME = MException(id, ['When you use a vector of ensemble objects to implement ',...
    'an evolving ensemble, each individual ensemble object must implement an ',...
    'ensemble with the same number of state vector rows. However, ensemble objects ',...
    '%.f%s and %.f%s have different numbers of rows (%.f and %.f, respectively).'],...
    loc(1), label1, loc(2), label2, bad1, bad2);
throwAsCaller(ME);
end
function[] = differentMembersError(ens, nMembers, header)
[~, loc] = unique(nMembers);
bad1 = nMembers(loc(1));
bad2 = nMembers(loc(2));

label1 = '';
if ~strcmp(ens(loc(1)).label_, "")
    label1 = sprintf(' (%s)', ens(loc(1)).label_);
end
label2 = '';
if ~strcmp(ens(loc(2)).label_, "")
    label2 = sprintf(' (%s)', ens(loc(2)).label_);
end

id = sprintf('%s:differentNumberOfMembers', header);
ME = MException(id, ['When you use a vector of ensemble objects to implement ',...
    'an evolving ensemble, each individual ensemble object must implement an ',...
    'ensemble with the same number of ensemble members. However, ensemble objects ',...
    '%.f%s and %.f%s have different numbers of members (%.f and %.f, respectively).'],...
    loc(1), label1, loc(2), label2, bad1, bad2);
throwAsCaller(ME);
end
