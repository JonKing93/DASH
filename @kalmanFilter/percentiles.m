function[kf] = percentiles(kf, percs)
%% Specicy to calculate percentiles of the updated posterior
%
% kf = kf.percentiles(percs)
%
% ----- Inputs -----
%
% percs: The percentiles to calculate. A vector with elements on the 
%    interval [0, 100].
%
% ----- Outputs -----
%
% kf: The updated kalman filter object

% Find location in calculations array
name = dash.posteriorCalculation.percentiles.outputName;
[haspercentiles, k] = ismember( name, kf.Qname);
if ~haspercentiles
    k = numel(kf.Q) + 1;
end

% If the user provided percentiles, add or replace in the calculations array
isvar = exist('percs','var') && ~isempty(percs);
if isvar
    kf.Q{k,1} = dash.posteriorCalculation.percentiles(percs);
    kf.Qname(k,1) = name;
    
% If the percentiles are empty, and percs were previously specified, then
% delete from the calculations array
elseif ~isvar && haspercentiles
    kf.Q(k,:) = [];
    kf.Qname(k,:) = [];
end

end