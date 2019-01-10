function[design] = addStateVariable( file, varargin )
%% This intializes a state vector variable in a design struct.
%
% design = addStateVariable( file )
% Initializes a state variable design with a first variable. Names the
% variable after the var field of file metadata.
%
% design = addStateVariable( file, design )
% Adds a new variable to an existing state vector design. Names the variable
% after the var field of file metadata.
%
% design = addStateVariable( ..., 'name', varName )
% Uses a user-specified name for the variable.

% Parse the inputs. Get a name, and any prior design object.
[name, design] = parseInputs( varargin{:} );

% Get the metadata for the gridfile
[meta, dimID] = metaGridfile( file );

% Get the variable name from the file if it is empty
if isempty(name)
    name = meta.var;
end

% Create the design structure for the variable
newVar = varDesign( file, dimID );

% Either create a new state vector design
if isempty(design)
    design = stateDesign(newVar, name);
    
% Or add to an existing design
else
    design.addVar( newVar, name );
end

end

%% Helper function to parse inputs
function[name, design] = parseInputs( varargin )

% Set defaults
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
    
        if ~setAppend && isa( inArg, 'stateDesign' )
            setAppend = true;
            design = inArg;
        elseif ~setName && strcmpi( inArg, 'name' )
            if numel(varargin) == v
                error('No variable name is provided.');
            elseif ischar(varargin{v+1}) || isstring(varargin{v+1})
                name = varargin{v+1};
                setName = true;
                skip = 1;
            else
                error('Unrecognized input type for variable name.');
            end
            
        elseif setAppend && isa( inArg, 'stateDesign' )
            error('Cannot add variable to two designs');
        elseif setName && strcmpi( inArg, 'name' )
            error('Cannot set two names for the variable.');
        else
            error('Unrecognized input argument.');
        end
    else
        skip = skip - 1;
    end
end

end