function [c,nue] = VGcall_nue_thur(s0,K,r,T,theta,sigma,sigma_prac,nue_bounds)
initialParams = nue_bounds(1);
lowerBounds = nue_bounds(2);
upperBounds = nue_bounds(3);


options = optimoptions('lsqnonlin', 'Display', 'off');
for i =1:length(sigma_prac)
    nue(i,1) = lsqnonlin(@(nue) sigma_prac(i,1).^2 - (nue.*theta.^2 + sigma.^2), ...
        initialParams,lowerBounds,upperBounds,[],[],[],[],[],options);
end

T=T./365;
alpha =(-theta./sigma);
a=(alpha+sigma).^2;

num = 1 - (nue.*a)./2;
den = 1-(nue.* alpha.^2)./2;

d1 = log(s0./K)./(sigma.*sqrt(T)) +((r+ log(num./den).*(nue.^-1))./sigma +alpha +sigma).*sqrt(T);
d2 = d1 - sigma.*sqrt(T);

c = s0.*exp(a.*T./2).*(num.^(T./nue)).* normcdf(d1) - K.*exp(-r.*T+(alpha.^2).*T.*.5).*(den.^(T./nue).* normcdf(d2));
end