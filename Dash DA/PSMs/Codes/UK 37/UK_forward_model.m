function [uk] = UK_forward_model(ssts, b_draws_final, knots, tau2_draws_final)
%function to model uk'37 from ssts using the BAYSPLINE calibration
%INPUTS:
%ssts = sea surface temperatures
%OUTPUTS:
%uk = N x 1500 ensemble estimates of ssts
%

%NOTE: calibration is seasonal for the following regions: North Pacific (Jun-Aug),
%North Atlantic (Aug-Oct), Mediterrenean (Nov-May). If the data lie in the
%following polygons then you should provide seasonal SSTs:

% %med poly
% poly_m=[...
%     -5.5 36.25
%     3 47.5
%     45 47.5
%     45 30
%     -5.5 30];
% %natl poly
% poly_a=[...
%     -55 48
%     -50 70
%     20 70
%     10 62.5
%     -4.5 58.2
%     -4.5 48];
% %npac poly
% poly_p=[...   
%     135 45
%     135 70
%     250 70
%     232 52.5
%     180 45];

% Record initial size
iSize = size(ssts);

% Ensure is a column vector. 
ssts = ssts(:);

%set up a matrix for the output
uk=NaN(size(ssts,1),length(tau2_draws_final));

%set up spline parameters with set knots
order=3;%spline order, 3 for quadratic
kn = augknt(knots,order); %knots

%spmak assembles the b-spline with the given knots and current
%coefficients:
bs_b=spmak(kn,b_draws_final);
%fnxtr linearly extrapolates the spline to evaluate values at SSTs
%outside the calibration range (0-30). w/o this, B-spline will return a NaN
%at SSTs out of this range.
bs=fnxtr(bs_b);
%evaluate the mean value of the spline for your SST obs:
mean_now=fnval(bs,ssts);
%draw from the distribution:
uk=normrnd(mean_now,repmat(sqrt(tau2_draws_final),1,length(ssts)));

% Get the ensemble mean
uk = mean(uk,1);

% Revert to original dimensions / size
uk = reshape( uk, iSize );

end