function[e] = evolvingIndices(obj, ensembles, allowRepeats, header)

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

end