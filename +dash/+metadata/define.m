function[meta] = define(varargin)
%% dash.metadata.define  Creates a metadata structure for a gridded dataset
% ----------
%   meta = dash.define.metadata(dim1, meta1, dim2, meta2, ..., dimN, metaN)
%   returns a metadata structure for a gridded dataset
% ----------
%   Inputs:
%       dimN (string scalar): The name of a dimension of a gridded dataset
%       metaN (matrix - numeric | logical | char | string | cellstring |
%           datetime): The metadata for the dimension. Cannot have NaN or
%           NaT elements. All rows must be unique.
%
%   Outputs:
%       meta (scalar structure): The metadata structure for the gridded
%           dataset. The fields of the structure are the dimension names.
%           Each field holds the associated metadata field. Cellstring
%           metadata are converted to string metadata.
%
%   Throws:
%
%   
%   <a href="matlab:dash.doc('dash.metadata.define')">Online Documentation</a>

