function[tf] = hasDuplicateRows(meta)
%% dash.metadata.hasDuplicateRows  True if a metadata field has duplicate rows
% ----------
%   tf = dash.metadata.hasDuplicateRows(meta)  returns true if meta has
%   duplicate rows and false otherwise
% ----------
%   Inputs:
%       meta (matrix - numeric | logical | char | string | datetime): The
%           metadata field being tested
%
%   Outputs:
%       tf (scalar logical): True if meta has duplicate rows
%
%   <a href="matlab:dash.doc('dash.metadata.hasDuplicateRows')">Online Documentation</a>

if size(meta,1) ~= size(unique(meta,'rows'),1)
    tf = true;
else
    tf = false;
end

end