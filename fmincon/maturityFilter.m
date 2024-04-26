function [s0,r,K,T,market_price,trade_date]=maturityFilter(s0,r,K,T,market_price,trade_date,min_maturity)
    index = (T>=min_maturity);
    s0 = s0(index);
    r = r(index);
    K = K(index);
    T = T(index);
    market_price = market_price(index);
    trade_date = trade_date(index);
end