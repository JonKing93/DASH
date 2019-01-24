function[] = dispDesign( d, var, dim, longform )
%% Displays information about a state vector design
%
% dispDesign( d )
% Outputs information on every dimension of every variable in a state
% vector design.
%
% dispDesign( d, var )
% Outputs information on every dimension for a specific variable in a state
% vector design.
%
% dispDesign( d, var, dim )
% Outputs information on a specific dimension of a variable in a state
% vector design.
%
% dispDesign( d, var, dim, longform )
% Specifies whether to display all metadata values in the state or ensemble
% indices of a specific dimension of a variable in a state vector design.

% Check the design is a design
if ~isa(d, 'stateDesign')
    error('d must be a stateDesign.');
end

% Get the variable(s)
if ~exist('var','var')
    v = 1:numel(d.var);
elseif ~(ischar(var)&&isvector(var)) && ~(isstring(var)&&isscalar(var))
    error('var must be a char vector or string scalar.');
else
    v = checkDesignVar(d, var);
end

% Get the dimension
if ~exist('dim','var')
    dim = 'all';
elseif ~(ischar(var)&&isvector(var)) && ~(isstring(var)&&isscalar(var))
    error('dim must be a char vector or string scalar.');
else
    dim = checkVarDim(d.var(v), dim);
end

% Get the longform toggle
if ~exist('longform','var')
    longform = false;
elseif ~islogical(longform) || ~isscalar(longform)
    error('longform must be a scalar logical.');
end


%% Output

% Design name
fprintf('State Vector Design: %s\n', d.name);

% Begin variables output
fprintf('Variables:\n');

% Display variables
for k = 1:numel(v)
    dispVariable( d, v(k), dim, longform );
end

end
    
    
