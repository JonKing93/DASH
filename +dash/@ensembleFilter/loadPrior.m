function[X] = loadPrior(obj, p)
%% dash.ensembleFilter.loadPrior  Load prior from an evolving set for a filter object
% ----------
%   X = <strong>obj.loadPrior</strong>(p)
%   Loads the requested prior in the evolving set.
% ----------
%   Inputs:
%       p (scalar linear index): The indices of requested
%           priors in an evolving set.
%  
%   Outputs:
%       X (numeric array [nState x nMembers]): The loaded prior
%
% <a href="matlab:dash.doc('dash.ensembleFilter.loadPrior')">Documentation Page</a>

% Numeric
if obj.Xtype == 0
    X = obj.X(:,:,p);

% Scalar ensemble object
elseif obj.Xtype == 1
    X = obj.X.load(p);

% Vector of ensemble objects
else
    X = obj.X(p).load;
end

end