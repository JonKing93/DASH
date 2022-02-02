function[sizes, dimNames] = ensembleSizes(obj)
%% dash.stateVectorVariable.ensembleSizes  Returns the sizes and names of ensemble dimensions
% ----------
%   [sizes, names] = obj.ensembleSizes
%   Return the sizes and names of ensemble dimensions.
% ----------
%   Outputs:
%       sizes (vector, positive integers [nEnsembleDims]): The size of 
%           each ensemble dimension in the variable.
%       names (string vector [nEnsembleDims]): The name of each ensemble
%           dimension in the variable.
%
% <a href="matlab:dash.doc('dash.stateVectorVariable.ensembleSizes')">Documentation Page</a>

ensDims = ~obj.isState;
sizes = obj.ensSize(ensDims);
dimNames = obj.dims(ensDims);

end
