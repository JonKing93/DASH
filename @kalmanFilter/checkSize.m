function[] = checkSize(kf, siz, type, dim, inputName)
%% Checks if the size of a dimension of an input matches a particular size
% (nState, nSite, or nTime). Returns a custom error message if not.
%
% kf.checkSize(siz, type, dim, inputName)
%
% ----- Inputs -----
%
% siz: The input size being checked. A scalar integer.
%
% type: Indicates which type of size is being checked
%       1: nState
%       2: nSite
%       3: nTime
%
% dim: Which dimension of the input is this size. 
%
% inputName: The name of the input being checked

% Get the name and required value of each size
if type==1
    type = 'state vector element';
    kfsiz = kf.nState;
elseif type==2
    type = 'observation/proxy site';
    kfsiz = kf.nSite;
elseif type==3
    type = 'time step';
    kfsiz = kf.nTime;
end

% Get the name of the dimension
if dim==1
    dim = "row";
elseif dim==2
    dim = "column";
else
    dim = sprintf('element along dimension %.f', dim);
end

% Check the sizes match. Throw error if not
if kfsiz ~= siz
    error('%s must have one %s per %s (%.f), but instead has %.f', ...
        inputName, dim, type, kfsiz, siz);
end

end
