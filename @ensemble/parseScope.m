function[useFile] = parseScope(scope, header)
%% ensemble.parseScope  Parse scope inputs
% ----------
%   useFile = ensemble.parseScope(scope)
%   Parses the 'scope" input used in various ensemble methods. Throws an
%   error if the input is not valid.
% ----------
%   Inputs:
%       scope (any data type): The input being checked
%
%   Outputs:
%       useFile (scalar logical): Indicates whether to interpret values in
%           the scope of the saved .ens file (true), or in the scope of the
%           values used by the ensemble object (false).
%
% <a href="matlab:dash.doc('ensemble.parseScope')">Documentation Page</a>

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