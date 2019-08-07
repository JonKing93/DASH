function[obj] = ensDimension( obj, v, d, varargin )
% v: Variable index in state Design
%
% d: Dimension index in varDesign

% Parse inputs. Use pre-existing values as defaults so that multiple calls
% don't overwrite values
[index, seq, seqMeta, mean, nanflag, overlap] = parseInputs( varargin, ...
    {'index', 'seq', 'meta', 'mean', 'nanflag', 'overlap'}, ...
    {obj.var(v).index{d}, obj.var(v).seqDex{d}, obj.var(v).seqMeta{d}, ...
     obj.var(v).meanDex{d}, obj.var(v).nanflag{d}, obj.var(v).overlap}  );
 
 % Error check and set the non-indices
 errCheck( seqMeta, nanflag, overlap );
 
 error('seqMeta is more complex than this. Need to auto write NaN for singleton.');
 obj.var(v).seqMeta{d} = seqMeta;
 obj.var(v).nanflag{d} = nanflag;
 obj.var(v).overlap = overlap;
 
 % Error check, process, and record indices. (Sorted column, linear).
 % Note the switch between 0 and 1 indexing for seq and mean.
 obj.var(v).indices{d} = obj.checkIndices( index, v, d );
 
 error('The check indices bit is bad -- logical seq or mean.');
 obj.var(v).seqDex{d} = obj.checkIndices( seq+1, v, d ) - 1;
 obj.var(v).meanDex{d} = obj.checkIndices( mean+1, v, d ) - 1;
 
 % Set ensemble properties
 
 