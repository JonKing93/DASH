Basic optimal sensor loop:

Decompose the prior

For each additional sensor
    Estimate Ye and get Ydev for all sites
    Assess the skill of each site by computing the change in covariance
    Record the best site
    Remove that site from future consideration
    Update the ensemble using the best site
    Repeat using the updated ensemble.
  