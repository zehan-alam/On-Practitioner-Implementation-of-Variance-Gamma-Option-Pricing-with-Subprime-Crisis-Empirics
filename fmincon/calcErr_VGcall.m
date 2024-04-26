function error = calcErr_VGcall(params, s0,K,r,T, market_price)
    theta= params(1); sigma = params(2); nue = params(3);

    optionPrices = VGcall_main(s0,K,r,T, theta,sigma, nue);
    error = sum((optionPrices - market_price).^2);
end