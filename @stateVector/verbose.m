function[varargout] = verbose(obj, verbose)
%% stateVector.verbose  Set or return the verbosity of a stateVector object
% ----------
%   verbose = <strong>obj.verbose</strong>
%   Returns the current verbosity of the stateVector object.
%
%   obj = <strong>obj.verbose</strong>(verbose)
%   Sets the verbosity of a stateVector object.
% ----------
%   Inputs:
%       verbose (scalar logical): The desired verbosity setting for the
%           stateVector object. Set to true for a verbose stateVector, and
%           false for non-verbose. If verbose, ....
%
%   Outputs:
%       verbose (scalar logical): True if the current stateVector is verbose, 
%           and false if not. If verbose, a stateVector will print a
%           notification to the console whenever ...
%       obj (scalar stateVector object): The stateVector object updated
%           with the specified verbosity.
%
% <a href="matlab:dash.doc('stateVector.verbose')">Documentation Page</a>

% Setup
header = "DASH:stateVector:verbose";
dash.assert.scalarObj(obj, header);

% Return current verbosity
if ~exist('verbose','var')
    varargout = {obj.verbose_};
    
% Set verbosity
else
    dash.assert.scalarType(verbose, 'logical', 'verbose', header);
    obj.verbose_ = verbose;
    varargout = {obj};
end

end