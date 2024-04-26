warning('off', 'all');

nue = .001;
sigma = .2;

initialParams = [sigma nue];
lowerBounds = [eps, eps];
upperBounds = [1-eps,4-eps];

theta_bounds = [.5,-7.4,7.4];

fprintf('    Sigma     Nue      Theta\n====================================\n')
disp([initialParams,theta_bounds(1);lowerBounds,theta_bounds(2);upperBounds,theta_bounds(3)])
options = optimoptions('fmincon', 'Display', 'off');
% ----------------------Calibration----------------------
regress_coeffs = prac_regress_coeffs(impV,K,T);
sigma_prac = prac_vol(regress_coeffs,K,T);
estimatedParams = fmincon(@(params) calcErr_theta(params,s0,K,r,T,sigma_prac,theta_bounds,market_price), ...
    initialParams, [], [], [], [], lowerBounds, upperBounds, [],options);

disp('Estimated parameters using fmincon:');
disp(estimatedParams);
% ----------------------Wednesday RMSE Check----------------------
sigma = estimatedParams(1);
nue = estimatedParams(2);
[c,theta]= VGcall_theta(s0,K,r,T,sigma,nue,sigma_prac,theta_bounds);
% display(transpose(theta))
fprintf("(fmincon)RMSE for theta Wednesday: %f\n",sqrt(mean((market_price - c).^2)))

% ----------------------Thursday RMSE Check----------------------
sigma_prac_thur = prac_vol(regress_coeffs,K_thur,T_thur);
[c_thur,theta_thur]= VGcall_theta_thur(s0_thur,K_thur,r_thur,T_thur,sigma,nue,sigma_prac_thur,theta_bounds);
% display(transpose(theta_thur))
fprintf("(fmincon)RMSE for theta Thursday: %f\n",sqrt(mean((market_price_thur - c_thur).^2)))