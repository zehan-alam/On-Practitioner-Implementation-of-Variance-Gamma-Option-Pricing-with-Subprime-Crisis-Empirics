function c = VGcall_main(s0,K,r,T,theta, sigma,nue)

T=T./365;
alpha =(-theta./sigma);
a=(alpha+sigma).^2;

num = 1 - (nue.*a)./2;
den = 1-(nue.* alpha.^2)./2;

d1 = log(s0./K)./(sigma.*sqrt(T)) +((r+ log(num./den).*(nue.^-1))./sigma +alpha +sigma).*sqrt(T);
d1 = real(d1); 
d2 = d1 - sigma.*sqrt(T);

c = s0.*exp(a.*T./2).*(num.^(T./nue)).* normcdf(d1) - K.*exp(-r.*T+ (alpha.^2).*T.*.5).*(den.^(T./nue).* normcdf(d2));
c= real(c);
end