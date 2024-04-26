function c = blackScholesPrice(s0, K, r, sigma, T)
    T=T./365;
    d1 = (log(s0./ K) + (r + sigma.^2 ./ 2) .* T) ./ (sigma .* sqrt(T));
    d2 = d1 - sigma .* sqrt(T);

    c = s0.* normcdf(d1) - K.*exp(-r .* T).*normcdf(d2);
end
