function error = calcErr_theta(params, s0,K,r,T,sigma_prac,theta_bounds, market_price)
    sigma = params(1); nue = params(2);

    optionPrices = VGcall_theta(s0,K,r,T, sigma, nue, sigma_prac,theta_bounds);
    error = sum((optionPrices - market_price).^2);
end