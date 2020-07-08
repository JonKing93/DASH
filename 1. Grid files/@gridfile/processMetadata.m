function[meta, siz] = processMetadata(meta)
if iscellstr(meta) %#ok<ISCLSTR>
    meta = string(meta);
end
siz = size(meta,1);
end