function[obj] = useVariables(obj, variables, scope)
%% ensemble.useVariables  Indicate which variables should be used by an ensemble object
% ----------
%   obj = obj.useVariables(variableNames)
%   obj = obj.useVariables(v)
%   obj = obj.useVariables(-1)
%   Indicates which variables should be used by the ensemble. The listed
%   variables and indices are interpreted in the context of variables saved
%   in the .ens file. If the index is -1, selects all variables saved in
%   the .ens file.
%
%   After using this command, the ensemble will only load these specified
%   variables when the "ensemble.load" command is used. Unused variables
%   will not be loaded into memory. By default, ensemble objeects load all
%   the variables saved in the .ens file, so use this command when you only
%   want to load a subset of the saved variables.
%
%   This command is most commonly used to design and load assimilation
%   priors. Only the used variables will be loaded and assimilated, so this
%   method can help select a subset of variables as reconstruction targets.
%
%   Calling this command will also affect values returned various ensemble
%   methods. Typcially, ensemble methods will interpret inputs and return
%   values in the context of the variables being used by the ensemble
%   object, rather than the context of variables saved in the .ens file.
%   However, you can change this behavior using the "scope" input of these
%   commands. (Note that the "useVariables" command itself is an exception
%   to this behavior. By default, it interprets inputs in the context of
%   variables saved in the .ens file).
%
%   ***Important***
%   It is usually not necessary to use this command when running the
%   "PSM.estimate" command, because "PSM.estimate" already implements
%   memory optimizations. However, if you *do* apply this command to an
%   ensemble object used as input to "PSM.estimate", then you should call
%   this command BEFORE determining the rows for each forward model.
%   Essentially, you must determine forward models rows with respect to the
%   subset of used variables, rather than the full set of variables saved
%   in the .ens file.
%
%   obj = obj.useVariables(variables, scope)
%   obj = obj.useVariables(variables, "file"|"f"|true)
%   obj = obj.useVariables(variables, "used"|"u"|false)
%   Indicate the scope in which to interpret the input variables. If
%   "file"|"f"|true, behaves identically to the previous syntax and
%   interprets inputs in the context of variables saved in the .ens file.
%   If "used"|"u"|false, interprets inputs in the context of variables
%   being used by the ensemble object.
% ----------
%   Inputs:
%       v (-1 | linear indices | logical vector): The indices of the variables that
%           should be used by the ensemble object. If -1, selects all
%           variables. Depending on scope, these indices are interpreted
%           with respect to either the variables saved in the .ens file, or
%           to the variables already being used by the ensemble.
%       variableNames (string vector): The names of variables for which to
%           return lengths. Depending on scope, these names must either be
%           the names of used variables, or the names of variables saved in
%           the .ens file.
%       scope (string scalar | logical scalar): The scope in which to
%           interpret input variables
%           ["file"|"f|false (default)]: Interpret variables relative to the
%               set of all variables stored in the .ens file.
%           ["used"|"u"|true]: Interpret variables relative to the set of
%               variables already being used by the ensemble.
%
%   Outputs:
%       obj (scalar ensemble object): The ensemble with updated used variables
%
% <a href="matlab:dash.doc('ensemble.useVariables')">Documentation Page</a>

% Setup
header = "DASH:ensemble:useVariables";
dash.assert.scalarObj(obj, header);

% Default
if ~exist('scope','var')
    scope = "file";
end

% Parse indices and scope
v = obj.variableIndices(variables, scope, header);

% Only use the selected variables
obj.use(:) = false;
obj.use(v) = true;

end