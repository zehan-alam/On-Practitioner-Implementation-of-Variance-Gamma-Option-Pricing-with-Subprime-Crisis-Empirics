function [s0,r,K,T,market_price,trade_date]=moneynessFilter(s0,r,K,T,market_price,trade_date,mlb,mub)
    option_moneyness = s0./K;
    index = (option_moneyness>=mlb & option_moneyness<=mub);
    s0 = s0(index);
    r = r(index);
    K = K(index);
    T = T(index);
    market_price = market_price(index);
    trade_date = trade_date(index);
end