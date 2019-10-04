function[] = setBiasCorrector( obj, type, varargin )
% Selects a bias corrector
%
% obj.setBiasCorrector( 'none' )
% Does not apply any bias correction during DA. The default setting.
%
% obj.setBiasCorrector( 'mean', inArgs )
% Uses a mean adjustment bias corrector. Please see the constructor for
% meanCorrector for input arguments.
%
% obj.setBiasCorrector( 'renorm', inArgs )
% Uses a renormalization bias corrector. Please see the constructor of
% renormCorrector for input arguments.

% Null corrector
if strcmpi( type, 'none' )
    obj.biasCorrector = nullCorrector;
    
% Mean adjustment
elseif strcmpi( type, 'mean' )
    obj.biasCorrector = meanCorrector( varargin{:} );
    
% Renormalization
elseif strcmpi(type, 'renorm')
    obj.biasCorrector = renormCorrector( varargin{:} );
    
else
    error('Unrecognized bias corrector.');
end

end