% Run the PSM
function[Ye,R] = runForwardModel( obj, M, ~, ~ )

    % Infill missing months with NaN
    T = NaN( 12, size(M,2) );
    T( obj.intwindow, : ) = M;

    % Run the model
    Ye = vstempPSM.vstemp( obj.coord(1), obj.T1, obj.T2, T, 'intwindow', obj.intwindow );
    R = NaN;
end