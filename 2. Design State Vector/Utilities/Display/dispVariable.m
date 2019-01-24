function[] = dispVariable( design, v, dim, longform )
%% Displays a variable in a state vector design.
%
% dispVariable( design, v, dim, longform )
%
% ----- Inputs -----
%
% design: A state vector design
%
% v: The index of a variable in the design.
%
% dim: The name of a dimension to display or 'all' to display all
%   dimensions.
%
% long: Logical scalar for whether to display indexed dimensional metadata.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get the variables
if strcmp(dim,'all')
    dim = 1:numel(design.var(v).dimID);
end

% Variable name 
fprintf('\t%s\n', design.var(v).name  );

% Reference file
fprintf( '\t\tGridfile: %s\n', design.var(v).file );

% Coupled Varialbes
if any( design.isCoupled(v,:) )
    fprintf( '\t\tCoupled Variables: ' );
    disp( design.varName( design.isCoupled(v,:) ) );
    fprintf('\b');
end

% Synced Variables
if any(design.isSynced(v,:))
    fprintf('\t\tSynced Variables:\n');
    disp( design.varName( design.isSynced(v,:) ) );
    fprintf('\b');
end

% Overlap
if design.var(v).overlap
    overStr = 'Allowed';
else
    overStr = 'Forbidden';
end
fprintf('\t\tEnsemble overlap: %s\n', overStr);

% Dimensions
fprintf('\t\tDimensions:\n');

% Display the dimensions
for k = 1:numel(dim)
    dispDimension( design.var(v), dim(k), longform );
end

end