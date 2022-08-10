function[obj] = finalizeCovariance(obj)
%% kalmanFilter.finalizeCovariance  Finalizes which* properties for covariance options
% ----------
%   obj = <strong>obj.finalizeCovariance</strong>
%   Fills empty which* properties for covariance options. Each which*
%   property is given a value of 1 for each assimilation time step. The
%   finalized covariance properties are whichPrior, whichFactor, whichLoc,
%   whichBlend, and whichSet.
% ----------
%   Outputs:
%       obj (scalar kalmanFilter object): The kalmanFilter object with
%           finalized which* properties for covariance options.
%
% <a href="matlab:dash.doc('kalmanFilter.finalizeCovariance')">Documentation Page</a>

whichFields = ["whichPrior","whichFactor","whichLoc","whichBlend","whichSet"];
for f = 1:numel(whichFields)
    field = whichFields(f);
    if isempty(obj.(field))
        obj.(field) = ones(obj.nTime, 1);
    end
end

end