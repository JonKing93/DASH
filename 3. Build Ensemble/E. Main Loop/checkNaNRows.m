function[] = checkNaNRows( fEns, var, varDex )


% Check if a particular row is NaN the entire way.
allnan = all( isnan(fEns.M(varDex,:)), 2 );

% If there is an all-NaN row
if any( allnan )
    
    % Delete the .ens file
    delete( fEns.Properties.Source );
    
    % Throw error
    allNaNRowError( allnan );
end

end

function[] = allNaNRowError

% Get the first row that is all NaN
allnan = find( allnan, 1, 'first' );

% Initialize an error message
msg = '';

% For each state dimension that is not a trailing singleton
for d = 1:numel(var.dimID)
    if var.isState(d) && ~isequal( var.indices{d}, 1 )
        
        % Add a message line for 




error('Every ensemble member has a NaN value for variable %s at the state vector element associated with:
