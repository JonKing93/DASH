function[] = disp(obj)
%% ensemble.disp  Display an ensemble object in the console
% ----------


% Class documentation link
link = '<a href="matlab:dash.doc(''ensemble'')">ensemble</a>';

% Title
fprintf('  %s with properties:\n\n', link);

% File or label, length, members
if ~strcmp(obj.label_, "")
    fprintf('      Label: %s\n', obj.label_);
else
    fprintf('       File: %s\n', obj.file);
end
fprintf('     Length: %.f\n', obj.length);
fprintf('    Members: %.f\n', size(obj.members,1));

fprintf('\n');
end