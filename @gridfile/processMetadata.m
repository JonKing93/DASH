function[meta, siz] = processMetadata(meta)
%% Gets the number of metadata rows and converts cellstring metadata to
% string.
%
% [meta, siz] = gridfile.processMetadata(meta)
%
% ----- Inputs -----
%
% meta: A metadata field.
%
% siz: The number of rows in the metadata field.
%
% ----- Outputs -----
%
% meta: A metadata field that is not a cellstring.

if iscellstr(meta) %#ok<ISCLSTR>
    meta = string(meta);
end
siz = size(meta,1);

end