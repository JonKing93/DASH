function[tf] = hasDuplicateRows(meta)
%% Checks if a metadata field contains duplicate rows.
%
% tf = gridfile.duplicateRows( meta )
%
% ----- Inputs -----
%
% meta: A metadata field
%
% ----- Outputs -----
%
% tf: A scalar logical indicating whether the field has duplicate rows
%    (true) or not (false)

tf = false;

if iscellstr(meta) %#ok<ISCLSTR>
    meta = string(meta);
end
if size(meta,1) ~= size(unique(meta,'rows'),1)
    tf = true;
end

end