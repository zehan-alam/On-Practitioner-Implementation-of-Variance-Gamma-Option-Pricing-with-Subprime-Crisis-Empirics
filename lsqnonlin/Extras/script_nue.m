warning('off', 'all');

theta = .1;
sigma = .1;

initialParams = [theta sigma];
lowerBounds = [-1+eps, eps];
upperBounds = [1-eps, 1-eps];

nue_bounds = [.1,eps,1-eps];

fprintf('    Theta      Sigma      Nue\n====================================\n')
disp([initialParams,nue_bounds(1);lowerBounds,nue_bounds(2);upperBounds,nue_bounds(3)])
options = optimoptions('lsqnonlin', 'Display', 'off');
% ----------------------Calibration----------------------
regress_coeffs = prac_regress_coeffs(impV,K,T);
sigma_prac = prac_vol(regress_coeffs,K,T);
estimatedParams = lsqnonlin(@(params) calcErr_nue(params,s0,K,r,T,sigma_prac,nue_bounds,market_price), initialParams, ...
    lowerBounds, upperBounds, [], [], [], [], [],options);

disp('Estimated parameters using lsqnonlin:');
disp(estimatedParams);
% ----------------------Wednesday RMSE Check----------------------
theta = estimatedParams(1);
sigma = estimatedParams(2);
[c,nue]= VGcall_nue(s0,K,r,T,theta,sigma,sigma_prac,nue_bounds);
display(transpose(nue))
fprintf("(lsqnonlin)RMSE for nue Wednesday: %f\n",rmse(market_price,c))

% ----------------------Thursday RMSE Check----------------------
sigma_prac_thur = prac_vol(regress_coeffs,K_thur,T_thur);
[c_thur,nue_thur]= VGcall_nue_thur(s0_thur,K_thur,r_thur,T_thur,theta,sigma,sigma_prac_thur,nue_bounds);
% display(transpose(nue_thur))
fprintf("(lsqnonlin)RMSE for nue Thursday: %f\n",rmse(market_price_thur,c_thur))