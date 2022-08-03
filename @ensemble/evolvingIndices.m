function[e] = evolvingIndices(obj, ensembles, allowRepeats, header)
%% ensemble.evolvingIndices  Return the indices of ensembles in an evolving set
% ----------
%   e = obj.evolvingIndices(ensembles, allowRepeats)
%   Parse the indices of ensembles in an evolving set. Error checks logical
%   or linear indices and locates evolving labels. Returns linear indices
%   to the specified ensembles. Requires labels refer to unique ensembles.
%   Throw error if ensembles are unrecognized. Optionally throw error if
%   the ensembles include repeated elements
%
%   e = obj.evolvingIndices(ensembles, allowRepeats, header)
%   Customize header in thrown error IDs.
% ----------
%   Inputs:
%       ensembles: The input being parsed. Either array indices or a list
%           of evolving labels.
%       allowRepeats (scalar logical): Whether to allow repeat elements
%           (true), or throw an error for repeat elements (false).
%       header (string scalar): Header for thrown error IDs
%
%   Outputs:
%       e (vector, linear indices): The indices of ensembles in an evolving set
%
% <a href="matlab:dash.doc('ensemble.evolvingIndices')">Documentation Page</a>

% Shortcut for all current ensembles
if isequal(ensembles, -1)
    e = 1:obj.nEvolving;
    return
end

% Default
if ~exist('header','var') || isempty(header)
    header = "DASH:ensemble:evolvingIndices";
end

% If strings, check there are no repeats
try
    labels = obj.evolvingLabels_;
    if dash.is.string(ensembles)
        ensembles = string(ensembles);
        for k = 1:numel(ensembles)
            matching = find(strcmp(ensembles(k), labels));
            if numel(matching) > 1
                id = sprintf('%s:repeatedEvolvingLabels', header);
                error(id, ['Element %.f of labels ("%s") is used for multiple ',...
                    'ensembles in the evolving set (ensembles %s), so it cannot be used to select ',...
                    'ensembles. Consider using ensemble indices instead.'], ...
                    k, ensembles(k), dash.string.list(matching));
            end
        end
    end

    % Get names for error messages
    name = 'ensembles';
    listType = 'evolving labels';
    elementName = 'ensemble';
    collectionName = 'the evolving set';
    
    % Parse the inputs
    e = dash.parse.stringsOrIndices(ensembles, labels, name, elementName, ...
                                        collectionName, listType, header);

    % Check for repeats
    if ~allowRepeats
        dash.assert.uniqueSet(ensembles, 'Ensemble', header);
    end

% Minimize error stack
catch ME
    throwAsCaller(ME);
end

end