function[] = errorCheckPSM( obj )
% Error checks a vstempPSM
if ~isnumeric(obj.T1) || ~isnumeric(obj.T2) || ~isscalar(obj.T1) || ~isscalar(obj.T2)
    error('lat, T1, and T2 must all be numeric scalars.');
elseif ~isvector( obj.coord ) || numel(obj.coord)~=2
    error('coord must be a 2 element vector.');
elseif obj.coord(1) > 90 || obj.coord(1) < -90
    error('The latitude of the PSM must be on the interval [-90 90].');
elseif obj.T2 < obj.T1
    error('T2 must be greater than T1.');
elseif ~isvector(obj.intwindow) || numel(obj.intwindow)~=numel(obj.H)
    error('intwindow must be a vector with one element per state index (H)');
end
end