function[] = queryContinue(opStr)
% opStr: String for the operation being aborted

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