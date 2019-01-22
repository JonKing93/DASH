function [uk] = UK_forward_model(ssts, bayes)
%function to model uk'37 from ssts using the BAYSPLINE calibration
%INPUTS:
%ssts = N x 1 vector of ssts
%OUTPUTS:
%uk = N x 1500 ensemble estimates of ssts
%

% Convert to column vector
ssts=ssts(:);

%NOTE: calibration is seasonal for the following regions: North Pacific (Jun-Aug),
%North Atlantic (Aug-Oct), Mediterrenean (Nov-May). If the data lie in the
%following polygons then you should provide seasonal SSTs:

%set up spline parameters with set knots
order=3;%spline order, 3 for quadratic
kn = augknt(bayes.knots,order); %knots

%spmak assembles the b-spline with the given knots and current coeffs
bs_b=spmak(kn,bayes.bdraws);

%fnxtr linearly extrapolates the spline to evaluate values at SSTs
%outside the calibration range (0-30). w/o this, B-spline will return a NaN
%at SSTs out of this range.
bs=fnxtr(bs_b);
%evaluate the mean value of the spline for your SST obs:
mean_now=fnval(bs,ssts);
%draw from the distribution:
uk=normrnd(mean_now,repmat(sqrt(bayes.tau2),1,length(ssts)));

% Convert N x 1500
uk = uk';
end