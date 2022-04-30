function[useFile] = parseScope(scope, header)
%% ensemble.parseScope  Parse scope inputs
% ----------
%   useFile = ensemble.parseScope(scope)
%   Parses the 'scope" input used in various ensemble methods. Throws an
%   error if the input is not valid.
% ----------

% Default
if ~exist('header','var') || isempty(header)
    header = "DASH:ensemble:parseScope";
end

% Parse. Reduce error stacks
try
    useFile = dash.parse.switches(scope, {["u","used"], ["f","file"]}, 1, 'scope',...
        'recognized scope', header);
catch ME
    throwAsCaller(ME);
end

end