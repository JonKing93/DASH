function[R] = setRValues( R, Rpsm, d, t )

% Use the values if they are valid
if isscalar(Rpsm) && ~isnan(Rpsm) && ~isinf(Rpsm) && isreal(Rpsm) && Rpsm>=0
    R( isnan(R) ) = Rpsm;

% Otherwise abort and notify user that R generation failed
else  
    if isnan(t)
        t = find(isnan(R));
        str = sprintf( ['s: \n\t', sprintf('%0.f, ', t), '\b\b\n\n'] );
    else
        str = sprintf(': %0.f\n\n', t);
    end
    
    fprintf(['PSM %0.f failed to generate R.\n', ...
         '\tDash will not use observation %0.f to update the analysis in time step%s'], ...
         d, d, str );
end

end