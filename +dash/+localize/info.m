function[T] = info
%% Returns a list of available localization schemes and their descriptions
% as a table.
%
% T = dash.localize.info
%

% Get the list of schemes
schemes = [
    "gc2d", "Gaspari-Cohn 5th order polynomial applied over 2-dimensions with a cutoff radius";...
    ];

% Make the table
T = table(schemes(:,1), schemes(:,2), 'VariableNames', ["Schemes", "Description"]);

end