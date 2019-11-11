function[] = errorCheckPSM( obj )
% Error checks a UK37 PSM

% Need 12 state vector elements
if ~isvector( obj.H) || length(obj.H)~=12
    error('H must contain 12 elements.');
elseif isempty( obj.bayesFile )
    error('Missing bayesian posterior file.');
end

end
