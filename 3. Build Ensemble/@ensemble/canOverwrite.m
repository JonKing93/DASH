function[] = canOverwrite( obj, tf )
%% Specify whether an ensemble object can overwrite pre-exisiting files.
%
% obj.canOverwrite( tf )
% Select whether overwriting is allowed.
%
% ----- Inputs -----
%
% tf: True or false. A scalar logical.

if ~isscalar(tf) || ~islogical(tf)
    error('tf must be a scalar logical.');
end
obj.overwrite = tf;

end