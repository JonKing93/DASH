function[] = userContinueQuery(nEns)
%% Asks the user if they wish to keep searching

fprintf(['It is difficult to find %0.f non-overlapping sequences.', newline], nEns);
fprintf(['Would you like to continue searching through all possible sequences?', newline]);
yn = input( '(This could take a while). [yes / no]: ', 's');

while ~ismember( yn, {'yes','no','YES','NO','Yes','No','y','n','Y','N'} )
    fprintf(['Unrecognized input. Please enter ''yes'' or ''no'' (without quotes).', newline]);
    yn = input('Would you like to continue? (yes / no): ', 's');
end

if ismember(yn, {'no','NO','No','n','N'})
    error('Aborting search for non-overlapping sequences.');
end

end
