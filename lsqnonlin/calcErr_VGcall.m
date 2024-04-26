function error = calcErr_VGcall(params, s0,K,r,T, market_price)
    theta= params(1); sigma = params(2); nue = params(3);

    optionPrices = VGcall_main(s0,K,r,T, theta,sigma, nue);
    error = optionPrices - market_price;
end