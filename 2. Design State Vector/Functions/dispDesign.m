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
%
% ----- Inputs -----
%
% d: A state vector design
%
% var: The name of a variable in the design
%
% dim: The name of a dimension in the variable
%
% longform: A scalar logical. If true, displays all dimension metadata at
%       the state or ensemble indices.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019



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
    
    
