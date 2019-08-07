function[obj] = ensDimension( obj, v, d, varargin )
% v: Variable index in state Design
%
% d: Dimension index in varDesign

% Parse inputs. Use pre-existing values as defaults so that multiple calls
% don't overwrite values
[index, seq, seqMeta, mean, nanflag] = parseInputs( varargin, ...
    {'index', 'seq', 'meta', 'mean', 'nanflag'}, ...
    {obj.var(v).index{d}, obj.var(v).seqDex{d}, obj.var(v).seqMeta{d}, ...
     obj.var(v).meanDex{d}, obj.var(v).nanflag{d}} );
 
% Minor error checking. Get defaults for seq and mean (0) when empty.
[seq, mean] = setup( seq, mean, varargin(1:2:end-1) );
 
% Check and set the indices (sorted linear column). Note the 0/1 indexing for seq and mean
obj.var(v).indices{d} = obj.checkIndices( index, v, d );
obj.var(v).seqDex{d} = obj.checkIndices( seq+1, v, d ) - 1;
obj.var(v).meanDex{d} = obj.checkIndices( mean+1, v, d ) - 1;

% Error check sequence metadata. Set default NaN for singleton
obj.var(v).seqMeta{d} = checkSeqMeta( seqMeta, seq );

% Can only take a mean if meanDex has more than 1 element.
obj.var(v).takeMean(d) = true;
if numel(meanDex) == 1
    obj.var(v).takeMean(d) = false;
end

% Finally, implement NaN flag behavior
obj.var(v).nanflag{d} = obj.getNaNflag( v, d, nanflag, varargin(1:2:end-1) );

% If changing dimension type, change for all coupled variables
% Delete coupled sequence and mean, notify user.
if obj.var(v).isState(d)
    obj = obj.changeDimType( v, d );
end
 
end
 
function [seq, mean] = setup( seq, mean, inArgs )
 
% If we switched from a state to an ens dimension, seq could be
% unspecified. Need to set the default. But also don't let a user set 
% and empty seq. Later, we'll want to use checkIndices, but we should first
% block logicals.
if isempty(seq)
    if ismember('seq', inArgs)
        error('Cannot specify empty sequence indices.');
    end
    seq = 0;
elseif islogical(seq)
    error('Sequence indices cannot be a logical.');
end

% If we switched from state to ens, then meanDex could be empty. Give it a
% default value. However, don't let a user specify empty indices. Later, 
% we'll want to use checkIndices, but we should first block logicals.
if isempty(mean)
    if ismember( 'mean', inArgs)
        error('Cannot specify empty mean indices.');
    end
    mean = 0;
elseif islogical(mean)
    error('mean indices cannot be logicals, they must be linear indices.');
end
 
end
 
function[seqMeta] = checkSeqMeta( seqMeta, seq )
 
% If a row vector the length of seq, convert to column
if isrow(seqMeta) && length(seqMeta)==numel(seq)
    seqMeta = seqMeta';
end

% If we switched from state to ens, then seqMeta will be empty -- check if
% the sequence is a single index, if so we can use NaN metadata. But if it
% is more than a single index, throw an error.
%
% Otherwise, heavy error checking on saved / input values.
if isempty(seqMeta)
    if numel(seq) > 1
        error('Must provide sequence metadata.');
    end
    seqMeta = NaN;
    
elseif size(seqMeta,1) ~= numel(seq)
    error('Sequence metadata must have one row per sequence index.');
elseif ~ischar(seqMeta) && ~islogical(seqMeta) && ~isnumeric(seqMeta) && ~iscellstr(seqMeta) && ~isstring(seqMeta)
    error('Sequence metadata must be a numeric, char, string, or cellstring data type.');
elseif isnumeric(seqMeta) && any(isnan(seqMeta(:)))
    error('Sequence metadata may not contain NaN.');
elseif ~ismatrix(seqMeta)
    error('Sequence metadata must be a matrix.');
end

% Use "strings" internally
if ischar(seqMeta) || isstring(seqMeta)
    seqMeta = string(seqMeta);
end

% Check all is unique
if size(seqMeta,1) ~= size( unique(seqMeta,'rows'), 1 )
    error('The sequence metadata contains duplicate values.');
end

end