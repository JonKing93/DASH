function[] = prevSyncWarning( varNames, field )

% Switch for coupled vs synced in the warning message
scd = 'synced';
sc = 'sync';

% Get the sync type
if strcmpi(field,'isCoupled')
    sType = 'ensemble';
    scd = 'coupled';
    sc = 'couple';
elseif strcmpi(field,'syncState')
    sType = 'state';
elseif strcmpi(field, 'syncSeq')
    sType = 'sequence';
elseif strcmpi(field, 'syncMean')
    sType = 'mean';
end
   
% Warning message
fprintf(['The %s indices of the variables: ', sprintf('%s, ',varNames{:}), '\b\b\n'], sType);
fprintf('were previously %s to some of the specified variables. Continuing will also %s their\n', scd, sc);
fprintf('%s indices to the specified variables.\n',sType);

% Ask to continue
queryContinue(sc);

end