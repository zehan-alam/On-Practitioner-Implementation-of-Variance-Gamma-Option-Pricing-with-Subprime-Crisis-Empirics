function error = calcErr_sigma(params, s0,K,r,T,sigma_prac,sigma_bounds, market_price)
    theta = params(1); nue = params(2);

    optionPrices = VGcall_sigma(s0,K,r,T, theta, nue, sigma_prac,sigma_bounds); 
    error = sum((optionPrices - market_price).^2);
end