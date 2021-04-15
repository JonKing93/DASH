# Run an optimal sensor experiment

Before running an optimal sensor experiment, you must provide all essential inputs. To recap, these are:
1. X: A prior ([prior command](prior))
2. J: A target reconstruction metric ([metric command](metric)), and
3. Ye: Observation Estimates or PSMs ([estimates or psms command](estimates))

Once you have done so, you are ready to run an optimal sensor experiment. Do this using the "optimalSensor.run" command. Here, the syntax is:
```matlab
[bestSites, expVar] = os.run(N)
```
where N is a positive scalar integer that indicates how many optimal sensors to find. The "bestSites" output is the index of the best sampling sites from the initial list of potential sites, and "expVar" is the percent variance of the reconstruction metric explained by the sampling site.

For example:
```matlab
N = 5;
[bestSites, expVar] = os.run(N);
```
will find the five sampling sites that most reduce the variance of the reconstruction target. Both "bestSites" and "expVar" will have five elements. The first element of bestSites will be the sampling site that causes the greatest reduction in reconstruction uncertainty. The second element will be the site the most reduces uncertainty *after* accounting for the first site, the third element will be the optimal site after accounting for the first two sites, etc. The five elements of "expVar" will indicate the percent reconstruction uncertainty explained by each of the five sites. 
