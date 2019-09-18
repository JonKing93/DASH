function[ens] = checkEnsFile( ~, file )
%% Error checks a .ens file and returns a matfile object.

% Check that the file exists and is .ens
checkFile( file, 'extension', '.ens', 'exist', true );

% Load a matfile and check the fields are not corrupted
ens = matfile(file);

fields = who(ens);
if ~ismember('complete', fields) || ~ens.complete
    error('The file "%s" was not written successfully. Try rewriting.', file);
end

requiredFields = ["M", "design", "random","ensSize","hasnan","writenan"];
for f = 1:numel(requiredFields)
    if ~ismember( requiredFields(f), fields )
        error('The file "%s" is missing the "%s" field. It may be corrupted. Consider re-writing.', file, requiredFields(f) );
    end
end
 
end