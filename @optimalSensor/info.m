Basic optimal sensor loop:

For each sensor
    Compute the index being optimized
    Get the deviations for the index
    
    Get the estimates
    Get the deviations for the estimates
    
    Get the explained variance for each site
        (Uses index deviations and estimate deviations)




    Estimate Ye and get Ydev for all sites
    Assess the skill of each site by computing the change in covariance
    Record the best site
    Remove that site from future consideration
    Update the ensemble using the best site
    Repeat using the updated ensemble.
  