function[] = notifyChangedType( obj, v, d, iscoupled )
% v: The variable index
%
% d: The dimension index
s = "s";
verb = "are";
if numel(d) == 1
    s = "";
    verb = "is";
end

coupled = "Coupled ";
if ~iscoupled
    coupled = "";
end

fprintf([ sprintf('%sVariable %s:', coupled, obj.varName(v)), '\n', ...
          sprintf('\tDimension%s ',s), sprintf('%s, ', obj.var(v).dimID(d)), '\b\b\n', ...
          sprintf('\t%s changing type. Sequence and mean design specifications will', verb) ...
          '\tbe deleted for these dimensions.\n\n' ]);
end