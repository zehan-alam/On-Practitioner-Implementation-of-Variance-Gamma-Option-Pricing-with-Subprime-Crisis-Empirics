function error = calcErr_nue(params, s0,K,r,T,sigma_prac,nue_bounds, market_price)
    theta = params(1); sigma = params(2);

    optionPrices = VGcall_nue(s0,K,r,T, theta, sigma, sigma_prac,nue_bounds);
    error = optionPrices - market_price;
end