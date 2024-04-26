function [s0,r,K,T,market_price,trade_date,impV]=imp_volFilter(s0,r,K,T,market_price,trade_date,impV)
    index = ~isnan(impV);
    s0 = s0(index);
    r = r(index);
    K = K(index);
    T = T(index);
    market_price = market_price(index);
    trade_date = trade_date(index);
    impV = impV(index);
end