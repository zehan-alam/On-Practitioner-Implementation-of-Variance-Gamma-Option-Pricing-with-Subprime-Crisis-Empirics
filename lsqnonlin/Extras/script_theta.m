warning('off', 'all');

nue = .1;
sigma = .1;

initialParams = [sigma nue];
lowerBounds = [eps, eps];
upperBounds = [1,Inf];

theta_bounds = [.1,-1,1];

fprintf('    Sigma     Nue      Theta\n====================================\n')
disp([initialParams,theta_bounds(1);lowerBounds,theta_bounds(2);upperBounds,theta_bounds(3)])
options = optimoptions('lsqnonlin', 'Display', 'off');
% ----------------------Calibration----------------------
regress_coeffs = prac_regress_coeffs(impV,K,T);
sigma_prac = prac_vol(regress_coeffs,K,T);
estimatedParams = lsqnonlin(@(params) calcErr_theta(params,s0,K,r,T,sigma_prac,theta_bounds,market_price), ...
    initialParams, lowerBounds, upperBounds, [], [], [], [], [],options);

disp('Estimated parameters using lsqnonlin:');
disp(estimatedParams);
% ----------------------Wednesday RMSE Check----------------------
sigma = estimatedParams(1);
nue = estimatedParams(2);
[c,theta]= VGcall_theta(s0,K,r,T,sigma,nue,sigma_prac,theta_bounds);
display(transpose(theta))
fprintf("(lsqnonlin)RMSE for theta Wednesday: %f\n",rmse(market_price,c))

% ----------------------Thursday RMSE Check----------------------
sigma_prac_thur = prac_vol(regress_coeffs,K_thur,T_thur);
[c_thur,theta_thur]= VGcall_theta_thur(s0_thur,K_thur,r_thur,T_thur,sigma,nue,sigma_prac_thur,theta_bounds);
% display(transpose(theta_thur))
fprintf("(lsqnonlin)RMSE for theta Thursday: %f\n",rmse(market_price_thur,c_thur))