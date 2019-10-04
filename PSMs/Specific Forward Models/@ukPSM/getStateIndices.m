function[] = getStateIndices( obj, ensMeta, sstName, monthMeta, varargin )
% Finds state vector elements needed to run a UK37 PSM
%
% obj.getStateIndices( obj, ensMeta, sstName, monthMeta )
% Finds the closest SST state vector element in each of 12
% months.
%
% obj.getStateIndices( ..., dimN, metaN )
% Search for the closest element along sepcific elements of
% other dimensions. For example, only search the top level of a
% 3D ocean grid. See PSM.getClosestLatLonIndex for details.
%
% ----- Inputs -----
%
% ensMeta: An ensemble metadata object
%
% sstName: The name of the SST variable. A string
%
% monthMeta: Metadata for each of the 12 months. Must have 12
%            rows.
%
% dimN, metaN: Please see PSM.getClosestLatLonIndex for details

% Error check
if ~isstrflag(sstName)
    error('The name of the SST variable must be a string scalar or character row vector.');
elseif size(monthMeta,1) ~= 12
    error('monthNames must have 12 rows (one for each month).';
end

% Finds the closest SST variable in each of the specified months
[~,~,~,~,~,~,time] = getDimIDs;
obj.H = PSM.getClosestLatLonIndex( obj.coord, ensMeta, sstName, time, monthMeta, varargin{:} );

end