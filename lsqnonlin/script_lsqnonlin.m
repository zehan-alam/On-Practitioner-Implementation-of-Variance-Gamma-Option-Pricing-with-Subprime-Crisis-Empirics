clc;
clear all;
warning('off', 'all');
feature('HotLinks',0);

% ----------------------- Inputs Starts Here -----------------------
% ------------------------------------------------------------------

data_path = 'Data/data09.xlsx'; % excel file's path
min_maturity = 10; % minimum maturity (value included)

mlb = .9; % moneyness lower boundary
mub = 1.1; % moneyness upper boundary
date = '14-Oct-2009'; % date in dd-mmm-yyyy format e.g. 07-Jan-2009


% ----- Black & Scholes Parameters -----
BS_sigma = .1; % Sigma Initial Value

BS_lowerBounds = eps; % Sigma lower bound
BS_upperBounds = 1; % Sigma upper bound


% ----- Variance Gamma Parameters -----
VG_theta=.1; % Theta Initial Value
VG_sigma=.1; % Sigma Initial Value
VG_nue=.1; % Nue Initial Value

VG_lowerBounds = [-Inf,eps,eps]; % Lower Bounds of (Theta, Sigma, Nue)
VG_upperBounds = [Inf,1,1]; % Upper Bounds of (Theta, Sigma, Nue)


% ----- Practitioners Variance Gamma(Sigma) Parameters -----
PVG_S_theta = .1; % Theta Initial Value
PVG_S_nue = .1; % Nue Initial Value

PVG_S_lowerBounds = [-1, eps]; % Lower Bounds of (Theta, Nue)
PVG_S_upperBounds = [1, 1]; % Upper Bounds of (Theta, Nue)

PVG_S_sigma_bounds = [.1,eps,1]; % Sigma's (Initial Value, Lower Bound, Upper Bound)

% ------------------------------------------------------------------
% ------------------------ Inputs End Here -------------------------






% Read Wednesday Data and Filtering
data_wed = readtable(data_path,'Sheet',1,'Range','A:F');
s0 = data_wed.(1);
r = data_wed.(2);
K = data_wed.(3);
T = data_wed.(5);
market_price = data_wed.(4);
trade_date = data_wed.(6);
[s0,r,K,T,market_price,trade_date] = dateFilter(s0,r,K,T,market_price,trade_date,date);
wed_data_cnt = length(s0);
[s0,r,K,T,market_price,trade_date] = maturityFilter(s0,r,K,T,market_price,trade_date,min_maturity);
[s0,r,K,T,market_price,trade_date] = moneynessFilter(s0,r,K,T,market_price,trade_date,mlb,mub);
impV = blsimpv(s0,K,r,T./365,market_price);

% Read Thursday Data and Filtering
data_thur = readtable(data_path,'Sheet',2,'Range','A:F');
s0_thur = data_thur.(1);
r_thur = data_thur.(2);
K_thur = data_thur.(3);
T_thur = data_thur.(5);
market_price_thur = data_thur.(4);
trade_date_thur = data_thur.(6);
[s0_thur,r_thur,K_thur,T_thur,market_price_thur,trade_date_thur] = dateFilter(s0_thur,r_thur, ...
    K_thur,T_thur,market_price_thur,trade_date_thur,datetime(date)+1);
thur_data_cnt = length(s0_thur);
[s0_thur,r_thur,K_thur,T_thur,market_price_thur,trade_date_thur] = maturityFilter(s0_thur,r_thur, ...
    K_thur,T_thur,market_price_thur,trade_date_thur,min_maturity);
[s0_thur,r_thur,K_thur,T_thur,market_price_thur,trade_date_thur] = moneynessFilter(s0_thur,r_thur, ...
    K_thur,T_thur,market_price_thur,trade_date_thur,mlb,mub);
impV_thur = blsimpv(s0_thur,K_thur,r_thur,T_thur./365,market_price_thur);

% Data Status Check
fprintf(['Wednesday(%s):\nData Read: %i\n' ...
    'Data in (%4.2f,%4.2f) Moneyness: %i\n' ...
    'Null ImpV: %i\n' ...
    'Usable Data: %i\n'], ...
    date, wed_data_cnt,mlb,mub,length(s0),sum(isnan(impV)),length(s0)-sum(isnan(impV)))
fprintf(['\nThursday(%s):\nData Read: %i\n' ...
    'Data in (%4.2f,%4.2f) Moneyness: %i\n' ...
    'Null ImpV: %i\n' ...
    'Usable Data: %i\n'], ...
    datetime(date)+1,thur_data_cnt,mlb,mub,length(s0_thur),sum(isnan(impV_thur)),length(s0_thur)-sum(isnan(impV_thur)))

% Cleaning Data for Implied Volatility
[s0,r,K,T,market_price,trade_date,impV] = imp_volFilter(s0,r,K,T,market_price,trade_date,impV);
[s0_thur,r_thur,K_thur,T_thur,market_price_thur,trade_date_thur,impV_thur] = imp_volFilter(s0_thur, ...
    r_thur,K_thur,T_thur,market_price_thur,trade_date_thur,impV_thur);




%% Black and Scholes

fprintf('\n\n<strong>================ Black & Scholes ================</strong>\n\n')
clear sigma;

initialParams = BS_sigma;
lowerBounds = BS_lowerBounds;
upperBounds = BS_upperBounds;

Parameter = "Sigma";
BS_output = table(Parameter,initialParams,lowerBounds,upperBounds);
options = optimoptions('lsqnonlin', 'Display', 'off');
% ----------------------Calibration----------------------
sigma = lsqnonlin(@(sigma) calcErr_BS(sigma, s0,K,r,T, market_price), ...
    initialParams, lowerBounds, upperBounds, [], [], [], [], [],options);
BS_output.OptimalValues = sigma;
disp(BS_output)
% ----------------------Wednesday RMSE Check----------------------
c= blackScholesPrice(s0, K, r, sigma, T);
fprintf("(lsqnonlin)RMSE for BS Wednesday: %f\n",sqrt(mean((market_price - c).^2)))
% ----------------------Thursday RMSE Check----------------------
c_thur = blackScholesPrice(s0_thur, K_thur, r_thur, sigma, T_thur);
fprintf("(lsqnonlin)RMSE for BS Thursday: %f\n",sqrt(mean((market_price_thur - c_thur).^2)))




%% Variance Gamma

fprintf('\n\n<strong>================ Variance Gamma ================</strong>\n\n')
clear theta sigma nue;

theta= VG_theta;
sigma= VG_sigma;
nue= VG_nue;

initialParams = [theta sigma nue];
lowerBounds = VG_lowerBounds;
upperBounds = VG_upperBounds;

% ----------------------Calibration----------------------
options = optimoptions('lsqnonlin', 'Display', 'off');
estimatedParams = lsqnonlin(@(params) calcErr_VGcall(params,s0,K,r,T,market_price), ...
    initialParams, lowerBounds, upperBounds, [], [], [], [],[],options);

% ----------------------Print Output---------------------
Parameter = ["Theta";"Sigma";"Nue"];
VG_output = table(Parameter);
VG_output.initialParams = transpose(initialParams);
VG_output.lowerBounds = transpose(lowerBounds);
VG_output.upperBounds = transpose(upperBounds);
VG_output.OptimalValues = transpose(estimatedParams);
disp(VG_output)
% ----------------------Wednesday RMSE Check----------------------
theta = estimatedParams(1);
sigma = estimatedParams(2);
nue= estimatedParams(3);
c= VGcall_main(s0,K,r,T,theta,sigma,nue);
fprintf("(lsqnonlin)RMSE for main VGcall Wednesday: %f\n",sqrt(mean((market_price - c).^2)))

% ----------------------Thursday RMSE Check----------------------
c_thur = VGcall_main_thur(s0_thur,K_thur,r_thur,T_thur,theta, sigma,nue);
fprintf("(lsqnonlin)RMSE for main VGcall Thursday: %f\n",sqrt(mean((market_price_thur - c_thur).^2)))




%% Practitioners Black and Scholes

fprintf('\n\n<strong>================ Practitioner Black & Scholes ================</strong>\n\n')
regress_coeffs = prac_regress_coeffs(impV,K,T);
% Reg_Coefs = ["alpha0";"alpha1";"alpha2";"alpha3";"alpha4";"alpha5"];
% regCoefs = table(Reg_Coefs);
% regCoefs.values = regress_coeffs;
% disp(regCoefs)

% Wednesday
prac_impV = prac_vol(regress_coeffs,K,T);
c = blackScholesPrice(s0, K, r, prac_impV, T);
fprintf("RMSE for PBS(Wednesday): %f\n",sqrt(mean((market_price - c).^2)))

% Thursday
prac_impV_thur = prac_vol(regress_coeffs,K_thur,T_thur);
c_thur = blackScholesPrice(s0_thur, K_thur, r_thur, prac_impV_thur, T_thur);
fprintf("RMSE for PBS(Thursday): %f\n",sqrt(mean((market_price_thur - c_thur).^2)))




%% Practitioner's Variance Gamma Sigma

fprintf('\n\n<strong>================ Practitioners Variance Gamma (Sigma) ================</strong>\n\n')
clear theta sigma nue;

theta = PVG_S_theta;
nue = PVG_S_nue;

initialParams = [theta, nue];
lowerBounds = PVG_S_lowerBounds;
upperBounds = PVG_S_upperBounds;

sigma_bounds = PVG_S_sigma_bounds;

% ----------------------Calibration----------------------
regress_coeffs = prac_regress_coeffs(impV,K,T);
sigma_prac = prac_vol(regress_coeffs,K,T);
options = optimoptions('lsqnonlin', 'Display', 'off');
estimatedParams = lsqnonlin(@(params) calcErr_sigma(params,s0,K,r,T,sigma_prac,sigma_bounds,market_price), ...
    initialParams,lowerBounds, upperBounds,[], [], [], [],[],options);

Parameter = ["Theta";"Nue";"Sigma"];
PVG_output = table(Parameter);
PVG_output.initialParams = transpose([initialParams,sigma_bounds(1)]);
PVG_output.lowerBounds = transpose([lowerBounds,sigma_bounds(2)]);
PVG_output.upperBounds = transpose([upperBounds,sigma_bounds(3)]);
PVG_output.OptimalValues = transpose([estimatedParams,0]);
disp(PVG_output)
% ----------------------Wednesday RMSE Check----------------------
theta = estimatedParams(1);
nue = estimatedParams(2);
[c,sigma]= VGcall_sigma(s0,K,r,T,theta,nue,sigma_prac,sigma_bounds);
% display(transpose(sigma))
fprintf("(lsqnonlin)RMSE for PVG Sigma Wednesday: %f\n",sqrt(mean((market_price - c).^2)))

% ----------------------Thursday RMSE Check----------------------
sigma_prac_thur = prac_vol(regress_coeffs,K_thur,T_thur);
[c_thur,sigma_thur]= VGcall_sigma_thur(s0_thur,K_thur,r_thur,T_thur,theta,nue,sigma_prac_thur,sigma_bounds);
% display(transpose(sigma_thur))
fprintf("(lsqnonlin)RMSE for PVG Sigma Thursday: %f\n",sqrt(mean((market_price_thur - c_thur).^2)))