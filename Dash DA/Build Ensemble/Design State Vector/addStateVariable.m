function[design] = addStateVariable( file, varargin )
%% This intializes a state vector variable in a design struct.
%
% design = addStateVariable( file )
% Initializes a design structure for a new state vector. Names the variable
% after the var field of file metadata.
%
% design = addStateVariable( file, design )
% Adds a new variable to an existing design structure.
%
% design = addStateVariable( ..., 'name', varName )
% Uses a user-specified name for the variable.

% Parse the inputs
[append, name, design] = parseInputs( varargin );

% Get the metadata for the gridfile
[meta, dimID] = metaGridfile( file );

% Get the variable name from the file if it is empty
if isempty(name)
    name = meta.var;
end

% Create the design structure for the variable
newDesign = varDesign( file, dimID );

% Set the output
if append
    design = design.addVar( newDesign, name );
else
    design = stateDesign(newDesign, name);
end

end

%% Helper function to parse inputs
function[append, name, design] = parseInputs( varargin )

% Set defaults
append = false;
name = [];
design = [];

% Check whether values are set
setAppend = false;
setName = false;

% Set whether to skip this val
skip = 0;

% For each input
for v = 1:numel(varargin)
    if ~skip
        inArg = varargin{v};
    
        if isa( inArg, 'stateDesign' ) && ~setAppend
            append = true;
            setAppend = true;
            design = inArg;
        elseif strcmpi( inArg, 'name' ) && ~setName && (ischar(varargin{v+1}) || isstring(varargin{v+1}))
            name = varargin{v+1};
            setName = true;
            skip = 1;
        else
            error('Unrecognized input argument.');
        end
    else
        skip = skip - 1;
    end
end

end