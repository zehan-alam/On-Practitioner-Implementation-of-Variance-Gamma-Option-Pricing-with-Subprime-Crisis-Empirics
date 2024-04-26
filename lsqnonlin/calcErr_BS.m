function error = calcErr_BS(sigma, s0,K,r,T, market_price)

    optionPrices = blackScholesPrice(s0, K, r, sigma, T);
    error = optionPrices - market_price;
end