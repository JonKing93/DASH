function[obj] = overlap( obj, tf, varNames )
% Sets whether ensemble members of variables can contain partially
% duplicated data.
%
% design = obj.overlap( tf )
% design = obj.overlap( tf, 'all' )
% Sets overlap permission for every variable to true or false.
%
% design = obj.overlap( tf, varNames )
% Sets the overlap permission for specific variables to true or false.
% Coupled variables will also be adjusted.
%
% ----- Inputs -----
%
% tf: A scalar logical indicating whether to allow overlap. By default,
%     variables do not allow overlap.
%
% varNames: A list of variable for which to adjust overlap permissions.
%
% ----- Outputs -----
%
% design: The updated stateDesign object.

% Set defaults, error check
if ~exist('varNames','var') || isempty(varNames)
    varNames = 'all';
end
if ~isscalar(tf) || ~islogical(tf)
    error('tf must be a scalar logical.');
elseif ~isstrlist(varNames)
    error('varNames must be a string vector, cellstring vector, or character row vector.');
elseif any(~ismember(varNames, [obj.varName; "all"]))
    error('"%s" is not a variable in the stateDesign.', varNames(find(~ismember(varNames, obj.varName),1)) );
elseif ismember("all", varNames) && numel(varNames)>1
    error('Cannot use "all" with variable names.');
end

% If "all", just use all variables. Otherwise get the variable indices.
vall = 1:numel(obj.var);
if numel(varNames) > 1 || ~strcmp(varNames,'all')
    v = obj.findVarIndices(varNames);

    % Find coupled variables and notify the user
    [~,vall] = find( obj.isCoupled(v,:) );
    vall = unique( [v; vall], 'stable' );
    obj.notifySecondaryOverlap( v, vall, tf );
end

% Update the overlap permissions
obj.allowOverlap( vall ) = tf;

end