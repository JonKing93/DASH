function[] = notifyChangedType( obj, v, d )
% v: The variable index
%
% d: The dimension index
fprintf([ sprintf('Variable %s:', obj.varName(v)), '\n', ...
          '\tDimensions ', sprintf('%s, ', obj.var(v).dimID(d)), '\b\b\n', ...
          '\tare changing type. Sequence and mean design specifications will', ...
          '\tbe deleted for these dimensions.\n\n' ]);
end

