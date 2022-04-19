function[] = defined(X, type, name, header)
%% dash.assert.defined  Throw error if numeric array contains undefined values
% ----------
%   dash.assert.defined(X)
%   Throw error if X contains NaN, Inf, or complex-valued elements.
%
%   dash.assert.defined(X, type)
%   Optionally allow NaN or Inf values.
%
%   dash.assert.defined(X, type, name, header)
%   Customize thrown error IDs.
% ----------
%   Inputs:
%       X (numeric array): The array being checked
%       type (scalar integer): Indicates what special values are allowed
%           [1 (default)]: No special values are allowed
%           [2]: NaN values are allowed
%           [3]: Inf values are allowed
%           [4]: NaN and Inf values are allowed
%       name (string scalar): The name of the input in thrown error IDs
%       header (string scalar): Header for thrown error IDs.
%
% <a href="matlab:dash.doc('dash.assert.defined')">Documentation Page</a>

% Defaults
if ~exist('type','var') || isempty(type)
    type = 1;
end
if ~exist('name','var') || isempty(name)
    name = 'input';
end
if ~exist('header','var') || isempty(header)
    header = 'DASH:assert:defined';
end

% Complex valued
try
    if ~isreal(X)
        id = sprintf('%s:inputIsComplex', header);
        error(id, '%s is complex-valued.', name);
    end
    
    % NaN elements
    if type==1 || type==3
        nans = isnan(X);
        if any(nans, 'all')
            bad = find(nans,1);
            id = sprintf('%s:inputContainsNaN', header);
            error(id, '%s cannot contain NaN values, but element %.f is NaN.', ...
                name, bad);
        end
    end
    
    % Inf elements
    if type==1 || type==2
        infs = isinf(X);
        if any(infs, 'all')
            bad = find(infs, 1);
            id = sprintf('%s:inputContainsInf', header);
            error(id, '%s cannot contain infinite values, but element %.f is infinite.',...
                name, bad);
        end
    end

% Minimize error stack
catch ME
    throwAsCaller(ME);
end

end