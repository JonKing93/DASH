function[obj] = append( obj, design )
%% Appends an existing state design to the current design.
%
% newDesign = obj.cat( design )
%
% ----- Inputs -----
%
% design: A second state vector design
%
% ----- Outputs -----
%
% newDesign: The concatenated design

% Check that the input is a state design and that there are no repeat names
if ~isa( design, 'stateDesign' ) || ~isscalar(design)
    error('design must be a scalar stateDesign object.');
elseif any( ismember( design.varName, obj.varName) )
    error('design cannot contain variable names in the current state design.');
end

% Add the new variable data
obj.var = [obj.var; design.var];
obj.varName = [obj.varName; design.varName];
obj.allowOverlap = [obj.allowOverlap, design.allowOverlap];

% Couple all the autocouple variables. Add the new coupling matrix
nNew = numel( design.var );
obj.isCoupled( end+(1:nNew), end+(1:nNew) ) = design.isCoupled;
obj.autoCouple = [obj.autoCouple, design.autoCouple];
obj = obj.couple( obj.varName(obj.autoCouple) );

end