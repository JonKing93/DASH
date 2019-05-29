function[X] = invMvnTransform( X, transform, params )
%% This is an interface that calls the appropriate inverse MVN transformation
% functions for bias-corrected variables in a data assimilation.
%
% X = mvnTransformInv( Xmvn, transform, params )
%
% ----- Inputs -----
%
% Xmvn: A data matrix that has been transformed to multivariate normal. (nSample x nVar)
%
% transform: A string vector holding the transformation type for each
%            variable. (1 x nVar)
%
%    Supported transforms:
%        'boxcox': Extended box-cox
%        'none': No transform is applied
%
% params: A cell array holding any parameters needed for transformation 
%         {1 x nVar}
%       
%      Parameter types:
%        'boxcox': params = {lambda}
%                       lambda: The box-cox parameter. (1 x 1)
%
%        'none': params = {[]}
%
%
% ----- Outputs -----
%
% X: The inversely transformed data matrix. (nSample x nVar)

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Error checking.
transform = errCheck( X, transform, params );

% For each variable, apply the appropriate inverse transformation
for v = 1:size(X,2)
    
    % Error check the parameters
    checkNumParams( transform(v), params{v} );
    
    % Box-Cox
    if strcmp( transform(v), "boxcox" )
        lambda = params{v}(1);
        X(:,v) = invExtBoxCox( X(:,v), lambda );
        
    % None
    elseif strcmp( transform(v), "none" )
        % Don't do anything
        
    end
end

end

function[] = checkNumParams( transform, params )

% Box Cox
if strcmp(transform, "boxcox")
    if numel(params) ~= 1
        error('The boxcox transform has a single parameter.');
    end
    
% No transformation
elseif strcmp(transform, "none") || strcmp(transform, "")
    if ~isempty(params)
        error('Parameters were specified for a null transformation.');
    end
end

end 

function[transform] = errCheck(X, transform, params)
        
    if ~ismatrix(X)
        error('X must be a matrix.');
    end
    N = size(X,2);

    if iscellstr(transform)
        transform = string(transform);
    end

    if ~isvector(transform) || ~isstring(transform) || length(transform)~=N
        error('transform must be a string vector with one element for each column of X.');
    end
    
    supported = ["boxcox","","none"];
    if any( ~ismember( transform, supported ) )
        error('Unrecognized transform');
    end
    
    if ~isvector(params) || ~iscell(params) || length(params)~=N
        error('params must be a cell vector with one element for each column of X.');
    end
end