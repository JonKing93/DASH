function[varargout] = deviations(obj, returnDeviations)
%% kalmanFilter.deviations  Specify whether to return ensemble deviations
% ----------
%   obj = <strong>obj.deviations</strong>(returnDeviations)
%   obj = <strong>obj.deviations</strong>("return"|"r"|true)
%   obj = <strong>obj.deviations</strong>("discard"|"d"|false)
%   Indicate whether to return updated ensemble deviations in the output of
%   "kalmanFilter.run". If "return"|"r"|true, returns the deviations in the
%   output as the field named "Adev". If "discard"|"d"|false, does not
%   return the ensemble deviations in the output. By default, kalmanFilter
%   objects do not return ensemble deviations.
%
%   When assimilating large state vectors over many ensemble members or
%   time steps, the updated deviations can overwhelm computer memory. If
%   this occurs, consider using the "kalmanFilter.percentiles" method to
%   return a smaller subset of the posterior, the "kalmanFilter.variance"
%   method to assess the spread of the posterior, or the
%   "kalmanFilter.index" method to calculate climate indices from the
%   updated posterior without needing to save the full posterior as output.
%
%   returnDeviations = <strong>obj.deviations</strong>
%   Return whether the current Kalman filter will return the ensemble
%   deviations of the posterior.
% ----------
%   Inputs:
%       returnDeviations (string scalar | scalar logical): Indicates
%           whether to return the updated ensemble deviations in the output
%           of the kalmanFilter.run method.
%           ["return"|"r"|true]: Returns the updated ensemble deviations in the output
%           ["discard"|"d"|false (default)]: Does not return the updated deviations
%
%   Outputs:
%       obj (scalar kalmanFilter object): The kalmanFilter object with
%           updated output preferences
%       returnDeviations (scalar logical): True if the Kalman filter will
%           return deviations when run. Otherwise, false.
%
% <a href="matlab:dash.doc('kalmanFilter.deviations')">Documentation Page</a>

% Setup
header = "DASH:kalmanFilter:deviations";
dash.assert.scalarObj(header);

% Return status
if ~exist('returnDeviations','var')
    varargout = {obj.returnDeviations};

% Set status. Parse switches and save
else
    obj.returnDeviations = dash.parse.switches(returnDeviations, ...
        {["d","discard"],["r","return"]}, 1, 'recognized option', header);
    varargout = {obj};
end

end