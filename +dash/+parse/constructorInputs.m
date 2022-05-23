function[siz, labels] = constructorInputs(inputs, header)
%% dash.parse.constructorInputs  Parses inputs to a constructor that accepts size and label parameters
% ----------
%   [siz, labels] = dash.parse.constructorInputs(inputs, header)
%   Parse the user inputs. Inputs can be 1. Nothing, 2. Size (for unlabeled
%   object array, 3. Labels (for labeled object array, or 4. Size and
%   labels (for labeled object array with label size checking).
%   Throws error if input syntax is not valid. Otherwise, returns the size
%   of the requested object array, and the labels for the array objects.
% ----------
%   Inputs:
%       inputs (cell vector): The user inputs being parsed
%       header (string scalar): Header for thrown error IDs
%
%   Outputs:
%       siz (row vector, positive integers): The requested size of the
%           object array.
%       labels (string array): Labels for the objects in the array
%
% <a href="matlab:dash.doc('dash.parse.constructorInputs')">Documentation Page</a>   

% Parse inputs
try
    nInputs = numel(inputs);
    if nInputs > 2
        dash.error.tooManyInputs;
    elseif nInputs == 0
        labels = "";
    elseif nInputs==2
        siz = inputs{1};
        labels = inputs{2};
    
    % Parse single input case
    else
        input1 = inputs{1};
        if isnumeric(input1)
            siz = input1;
        elseif dash.is.string(input1)
            labels = input1;
        else
            id = sprintf('%s:invalidInput', header);
            error(id, 'The first input must either be a size vector or a set of labels.');
        end
    end
    
    % Error check size
    if exist('siz','var')
        if ~isrow(siz) || numel(siz)<2
            id = sprintf('%s:invalidSizeVector',header);
            error(id, 'Size vector should be a row vector with at least 2 elements.');
        end
        dash.assert.integers(siz, 'Size vector', header);
        if any(siz<0)
            bad = find(siz<0,1);
            id = sprintf('%s:negativeSize', header);
            error(id, ['Size vector cannot contain values less than 0, but element ',...
                '%.f (%.f) is negative.'], bad, siz(bad));
        end
        dash.assert.defined(siz, 1, 'Size vector', header);
    end
    
    % Default and error check labels
    if ~exist('labels','var')
        labels = strings(siz);
    else
        labels = dash.assert.string(labels, 'labels', header);
    end
    
    % Use size of labels if size is not specified
    if ~exist('siz','var')
        siz = size(labels);
    end

% Minimize error stacks
catch ME
    throwAsCaller(ME);
end

end