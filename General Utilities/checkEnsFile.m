function[m] = checkEnsFile( file )
%% Error checks a .ens file and returns a matfile object.

% Check that the file exists and is .ens
checkFile( file, 'extension', '.ens', 'exist', true );

% Load a matfile and check the fields are not corrupted
m = matfile(file);

fields = who(m);
if ~ismember('complete', fields) || ~m.complete
    error('The file "%s" was not written successfully. Try rewriting.', file);
end

requiredFields = ["M", "design", "ensSize", "hasnan"];
for f = 1:numel(requiredFields)
    if ~ismember( requiredFields(f), fields )
        error('The file "%s" is missing the "%s" field. It may be corrupted. Consider re-writing.', file, requiredFields(f) );
    end
end
 
end