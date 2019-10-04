function[] = review( obj, nState )
% Interfaces internal error check with dash
%
% obj.reviewPSM( nState )

% H and unit conversion error checking
if isempty(obj.H)
    error('The PSM does not have sampling indices, H.');
elseif ~isnumeric(H) || ~iscolumn(H) || ~isreal(H) || any(H<0) || any(mod(H,1)~=0) || any(H>nState)
    error('H must be a numeric column vector of integers on the interval [1, %.f].', nState );
elseif ~isempty(obj.addUnit) && ~isequal(size(obj.H),size(obj.addUnit))
    error('addUnit is not the length of H.');
elseif ~isempty(obj.multUnit) && ~isequal(size(obj.H),size(obj.multUnit))
    error('multUnit is not the length of H.');
end

% Error check the bias corrector and specific PSM
obj.biasCorrector.review( obj.H );
obj.errorCheckPSM;

end