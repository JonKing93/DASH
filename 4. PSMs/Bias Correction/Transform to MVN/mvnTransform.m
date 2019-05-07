function[] = mvnTransform
%% This transforms the columns of a matrix to multivariate normal.
%
% X: A data matrix. Each column is a variable (nSample x nVar)
%
% transform: A string vector holding the transformation type for each
%            variable. (1 x nVar)
%
% params: A cell array holding any parameters needed for transformation 
%         {1 x nVar

% For each variable, apply the appropriate transformation
for v = 1:nVar
    
    % Error check the parameters
    checkParams( params(v), transform(v) );
    
    % Box-Cox
    if strcmp( transform(v), "ebox" )
        lambda = params(v){1};
        X(:,v) = extBoxCox( X(:,v), lambda );
        
    % None
    elseif strcmp( transform(v), "none" )
        % Don't do anything
        
    end
end

end
        

 


