data_path = 'Data/data09.xlsx'; % excel file's path
min_maturity = 10; % minimum maturity (value included)

mlb = .9; % moneyness lower boundary
mub = 1.1; % moneyness upper boundary
date = '19-Aug-2009'; % date in dd-mmm-yyyy format e.g. 07-Jan-2009

% Read Wednesday Data and Filtering
data_wed = readtable(data_path,'Sheet',1,'Range','A:F');
s0 = data_wed.(1);
r = data_wed.(2);
K = data_wed.(3);
T = data_wed.(5);
market_price = data_wed.(4);
trade_date = data_wed.(6);
[s0,r,K,T,market_price,trade_date] = dateFilter(s0,r,K,T,market_price,trade_date,date);
[s0,r,K,T,market_price,trade_date] = maturityFilter(s0,r,K,T,market_price,trade_date,min_maturity);
[s0,r,K,T,market_price,trade_date] = moneynessFilter(s0,r,K,T,market_price,trade_date,mlb,mub);
impV = blsimpv(s0,K,r,T./365,market_price);
[s0,r,K,T,market_price,trade_date,impV] = imp_volFilter(s0,r,K,T,market_price,trade_date,impV);

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
[s0_thur,r_thur,K_thur,T_thur,market_price_thur,trade_date_thur] = maturityFilter(s0_thur,r_thur, ...
    K_thur,T_thur,market_price_thur,trade_date_thur,min_maturity);
[s0_thur,r_thur,K_thur,T_thur,market_price_thur,trade_date_thur] = moneynessFilter(s0_thur,r_thur, ...
    K_thur,T_thur,market_price_thur,trade_date_thur,mlb,mub);
impV_thur = blsimpv(s0_thur,K_thur,r_thur,T_thur./365,market_price_thur);
[s0_thur,r_thur,K_thur,T_thur,market_price_thur,trade_date_thur,impV_thur] = imp_volFilter(s0_thur, ...
    r_thur,K_thur,T_thur,market_price_thur,trade_date_thur,impV_thur);

% Calculates Practitioner's Implied Volatility
regress_coeffs = prac_regress_coeffs(impV,K,T);

prac_impV = prac_vol(regress_coeffs,K,T);
prac_impV_thur = prac_vol(regress_coeffs,K_thur,T_thur);

% Generates Graph
figure('Position',[100,700,1200,540]);
sgtitle('Comparison of Implied Volatility of Different Models');

% Wednesday
subplot(1,2,1)
plot(impV,'k')
hold on
plot(prac_impV,'r--')
legend('BS Implied Vol', 'PBS Implied Vol');
title('In-samples')
xlabel('Options')
ylabel('Implied Vol')
hold off

% Thursday
subplot(1,2,2)
plot(impV_thur,'k')
hold on
plot(prac_impV_thur,'r--')
legend('BS Implied Vol', 'PBS Implied Vol');
title('Out-samples')
xlabel('Options')
ylabel('Implied Vol')
hold off

% Saves Graph
% saveas(gcf,'impV-lsq-reg-2Sep.png')