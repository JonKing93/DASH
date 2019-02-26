function[] = queryContinue(opStr)
%% Asks the user if they want to continue
%
% opStr: String for the operation being continued / aborted
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

yn = input('Do you want to continue? (yes/no): ', 's');

while ~ismember(yn, {'y','n','Y','N','yes','no','YES','NO','Yes','No'})
    yn = input('Unrecognized input. Do you want to continue? (yes/no): ','s');
end

if ismember( yn, {'n','N','no','NO','No'} )
    error('Aborting %s.', opStr);
else
    fprintf('\n');
end
end