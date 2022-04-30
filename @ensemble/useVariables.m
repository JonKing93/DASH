function[] = useVariables(obj, variables)
%% ensemble.useVariables  Indicate which variables should be used by an ensemble object
% ----------
%   obj = obj.useVariables(v)
%   obj = obj.useVariables(variableNames)
%   Indicates which variables should be used by the ensemble. The ensemble
%   will only load these used variables when the "ensemble.load" command
%   is called. Unused variables will not be loaded into memory. By default,
%   ensemble objects load all the variables in the .ens file, so use this
%   command when you only want to load a subset of the saved variables.
%
%   This command is most commonly used to design and load assimilation
%   priors. Only the used variables will be assimilated, so this method can
%   help select a subset of variables as reconstruction targets.
%
%   Calling this command will also affect values returned by the following
%   ensemble methods: variables, length, and metadata. By default, these
%   methods will return values relative to the subset of used variables,
%   rather than the full set of variables saved in the .ens file. However,
%   you can change this behavior using the "scope" input of these methods.
%
%   ***Important***
%   It is usually not necessary to use this command when running the
%   "PSM.estimate" command, because "PSM.estimate" already implements a
%   memory optimizations. However, if you *do* apply this command to an
%   ensemble object used as input to "PSM.estimate", then you should call
%   this command BEFORE determining the rows for each forward model.
%   Essentially, you must determine forward models rows with respect to the
%   subset of used variables, rather than the full set of variables saved
%   in the .ens file.
%
%   obj = obj.useVariables(-1)
%   Indicates that the ensemble object should use all variables saved in
%   the .ens file.
% ----------

% Setup
header = "DASH:ensemble:useVariables";
dash.assert.scalarObj(obj, header);

% Parse the variable indices
v = obj.variableIndices(variables, true, header);

% Use the selected variables
obj.use(v) = true;

end