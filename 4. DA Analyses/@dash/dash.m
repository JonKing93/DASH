classdef (Abstract) dash < handle
    % dash
    % Implements data assimilation. Provides support functions for kalman
    % filters, particle filters, optimal sensor tests, etc.
    %
    % dash Methods:
    %   localizationWeights - Computes distance based localization weights
    %   regrid - Converts a state vector or a matrix of state vectors to a gridded data array.
    %   regridTripolar - Converts a tripolar state vector or matrix of state vectors to a gridded data array.
    %
    %   inflate - Inflates the covariance of an ensemble
    %   decompose - Breaks an ensemble into mean, deviations, and variance
    %   processYeR - Runs PSMs and error checks output
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019
    
    % Interface for analyses
    methods (Abstract)
        
        % Runs a data assimilation test
        run( obj );
        
        % Change the settings for a particular type of test
        settings( obj, varargin);
        
        % Change the data in an existing test object
        setValues( obj, values );
        
    end
    
    % Regridding
    methods (Static)
        
        % Regrids a variable in an ensemble from a state vector.
        [A, meta, dimID] = regrid( A, var, ensMeta, keepSingleton )
        
        % Regrids a tripolar variable
        [rA, dimID] = regridTripolar( A, var, ensMeta, gridSize, notnan, keepSingleton );
        
    end
    
    % General analysis methods
    methods (Static)
        
        % Inflates the covariance matrix
        M = inflate( M, factor );
        
        % Breaks an ensemble into mean and devations. Also variance.
        [Mmean, Mdev, Mvar] = decompose( M );
        
        % Temporal localization weights
        [weights, yloc] = temporalLocalization( siteTime, stateTime, R, scale );
        
        % Spatial localization weights
        [weights, yloc] = spatialLocalization( siteCoord, stateCoord, R, scale );
        
        % Redirect of old method
        [weights, yloc] = localizationWeights( siteCoord, stateCoord, R, scale);
        
        % Error check Ye and R generation on the fly without crashing the analysis
        [Ye, R, use] = processYeR( F, Mpsm, R, t, d );
        
        % Calculate Ye without running a data assimilation
        Ye = calculateYe( M, F );
        
        % Return the current version of dash
        versionString = version;
        
        % Checks if reconstructed indices include all PSM indices
        reconH = checkReconH( recon, F );
        
        % Error propagation for spatial means
        [E, sigma] = uncertainMean( X, Xvar, dim, weights );
        
    end 
    
end