function[obj] = design(obj, varNames, dims, type, indices)
%% Designs a dimension of a stateVectorVariable
%
% obj = obj.design(varNames, dim, type)
% obj = obj.design(varNames, dim, isState)
% Specifies a dimension as a state dimension or ensemble dimension. Uses
% all elements along the dimension as state indices or ensemble reference
% indices, as appropriate.
%
% obj = obj.design(varNames, dim, 's'/'state', stateIndices)
% Specify state indices for a dimension.
%
% obj = obj.design(varNames, dim, 'e'/'ens'/'ensemble', ensIndices)
% Specify ensemble indices for a dimension.
%
% obj = obj.design(varNames, dims, isState/type, indexCell)
% Specify dimension type and indices for multiple dimensions.
%
% ----- Inputs -----
%
% dim: The name of one of the variable's dimensions. A string.
%
% dims: The names of multiple dimensions. A string vector or cellstring
%    vector. May not repeat dimension names.
%
% type: Options are ("state" or "s") to indicate a state dimension, and
%    ("ensemble" / "ens" / "e") to indicate an ensemble dimension. Use a
%    string scalar to specify the same type for all dimensions listed in
%    dims. Use a string vector to specify different options for the
%    different dimensions listed in dims.
%
% isState: True indicates that a dimension is a state dimension. False
%    indicates an ensemble dimension. Use a scalar logical to use the same
%    type for all dimensions listed in dims. Use a logical vector to
%    specify different options for the different dimensions listed in dims.
%
% stateIndices: The indices of required data along the dimension in the
%    variable's .grid file. Either a vector of linear indices or a logical
%    vector the length of the dimension.
%
% ensIndices: The ensemble reference indices. Either a vector of linear
%    indices or a logical vector the length of the dimension.
%
% indexCell: A cell vector. Each element contains the state indices or
%    ensemble reference indices for a dimension listed in dims, as
%    appropriate. Must be in the same order as dims. If an element is an
%    empty array, uses all indices along the dimension.

% Default for indices
if ~exist('indices','var')
    indices = [];
end

% Error check, variable index
v = obj.checkVariables(varNames);

% Update each variable
for k = 1:numel(v)
    obj.variables(v) = obj.variables(v).design(dims, type, indices);
    
    % Find coupled variables not specified by the user. Notify that these
    % will also be updated
    sv = find(obj.coupled(v(k),:));
    sv = sv(~ismember(sv, v));
    notifySecondaryVariables(obj, sv, t);
    
    % Update these variables. Add them to the variable list to prevent
    % redundant updates / notifications
    obj = obj.updateCoupledVariables(v(k), sv);
    v = [v(:); sv(:)];
end

end

% Message
function[] = notifySecondaryVariables(obj, sv, t)

% No message if no secondary variables, or user disabled messages
if ~isempty(sv) && obj.verbose
    
    % Plural vs singular
    plural = ["s", "are", "them"];
    if numel(sv)==1
        plural = ["", "is", "it"];
    end
    
    % Format variable names as string
    names = obj.variableNames;
    template = names(t);
    secondary = dash.messageList( names(sv) );
    
    % Message
    fprintf(['\nVariable%s %s %s coupled to "%s". Updating %s to match the ',...
        'ensemble dimensions of %s.'], plural(1), secondary, plural(2), ...
        template, plural(3), template);
end

end