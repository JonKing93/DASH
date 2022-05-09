function[] = dispEvolving(obj)
%% ensemble.dispEvolving  Display the labels of evolving ensembles in the console
% ----------
%   obj.dispEvolving
%   Prints a numbered list of evolving ensemble labels to the console. If
%   an evolving ensemble has no label uses <no label> for that ensemble. If
%   none of the ensembles have labels, does not print anything.
% ----------
%   Outputs:
%       Prints a numbered list of evolving ensemble labels to the console.
%
% <a href="matlab:dash.doc('ensemble.dispEvolving')">Documentation Page</a>

% Collect labels
labels = obj.evolvingLabels;

% If there are labels, prepare to display. Use placeholder for no label
if ~all(strcmp(labels, ""))
    nLabels = numel(labels);
    labels(strcmp(labels,"")) = '<no label>';

    % Format display
    countLength = strlength(string(nLabels));
    format = sprintf('        %%%.f.f. %%s', countLength);

    % Print each label. Use <missing> for no label
    for k = 1:nLabels
        if strcmp(labels(k), "")
            labels(k) = missing;
        end
        fprintf([format,'\n'], k, labels(k));
    end
    fprintf('\n');
end

end