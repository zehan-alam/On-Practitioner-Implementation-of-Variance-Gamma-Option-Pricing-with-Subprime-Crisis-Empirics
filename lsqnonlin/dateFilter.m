function [s0,r,K,T,market_price,trade_date]=dateFilter(s0,r,K,T,market_price,trade_date,date)
    index = (trade_date==date);
    s0 = s0(index);
    r = r(index);
    K = K(index);
    T = T(index);
    market_price = market_price(index);
    trade_date = trade_date(index);
end