function[] = flipDimWarning( fromDim, toDim, dim, var, d, coupled )
%% Warn user if a coupled variable changes dimension type.

fprintf(['Warning: Dimension %s of variable %s is being converted from a %s to a %s dimension,', ...
         newline], dim, var.name, fromDim, toDim);
fprintf(['but it is coupled to the %s indices of the following variables:', newline], fromDim);
fprintf(['%s',newline], d.varName{coupled});
fprintf(newline)

yn = input( sprintf('Continuing will uncouple %s from these variables. Do you want to continue? (yes/no): ', ...
                     var.name), 's');
                 
while ~ismember(yn, {'y','n','Y','N','yes','no','YES','NO','Yes','No'})
    yn = input('Unrecognized input. Do you want to continue? (yes/no): ','s');
end

if ~yn
    error('Aborting dimension conversion.');
end

end

