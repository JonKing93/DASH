function[] = prevSyncWarning( var, secondVar, field )

% Switch for coupled vs synced in the warning message
scd = 'synced';
sc = 'sync';

% Get the sync type
if strcmpi(field,'isCoupled')
    scd = 'coupled';
    sc = 'couple';
elseif strcmpi(field, 'isSynced')
    scd = 'synced';
    sc = 'sync';
end
   
% Warning message
fprintf(['Some of the variables ', sprintf('%s, ',var), '\b\b were previously %s '],scd);
fprintf(['to variables ', sprintf('%s, ',secondVar), '\b\b.\nContinuing will also %s '], sc)
fprintf(['variables ', sprintf('%s, ',secondVar), '\b\b to ', sprintf('%s, ',var), '\b\b.\n']);

% Ask to continue
queryContinue(sc);

end