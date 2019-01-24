function[] = indexGridfile( file, gridData, gridDims, loc, meta )
%% Writes data to specified exisiting indices in a gridded .mat file.
%
% indexGridfile( file, gridData, gridDims, loc )
% Writes data to specified existing indices.
%
% indexGridfile( file, gridData, gridDims, loc, meta )
% Checks that input metadata match the metadata at the write indices. If
% the metadata do not match, aborts the write.
%
% ----- Inputs -----
%
% file: The name of the gridded .mat file. A string.
%
% gridData: A gridded dataset
%
% gridDims: A cell of dimension IDs indicating the order of dimensions in
%       the gridded data.
%
% loc: A (2 x nGridDim) array or (1 x nGridDim) vector specifying the indices at
%      which to writeindices to delete. Each column is one dimension.
%      Columns must be in the same order as gridDims. Format for rows is
%      [START; STRIDE]. START is the index at which to begin writing.
%      STRIDE is the interval spacing between indices. If a vector, STRIDE
%      in each dimension is set to 1.
%
% meta: A metadata structure built for dash. Metadata at the write indices
%       are compared to this structure. If the metadata do not match, the
%       write is aborted.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Error check the file
m = fileCheck(file);
nDim = numel(m.dimID);

% Permute inputs to match the existing file
[gridData, loc] = permuteInputs( m, gridDims, gridData, loc );

% Get the cell of indices
[ic, nAdd] = getIndexCell( m, fullSize(gridData,nDim), loc );

% Error check
if sum( nAdd>0 ) > 0
    dimID = m.dimID;
    error('The %s dimension is being extended. Use extendGridfile.m instead.', dimID{find(nAdd>0,1)} );
elseif exist('meta','var')
    compareMetadata( m, meta, ic );
end

% Add the indexed data
m.gridData( ic{:} ) = gridData;

end
