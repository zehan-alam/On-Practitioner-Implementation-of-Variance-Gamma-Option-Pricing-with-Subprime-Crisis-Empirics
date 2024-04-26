function [c, theta] = VGcall_theta_thur(s0,K,r,T,sigma,nue,sigma_prac,theta_bounds)
initialParams = theta_bounds(1);
lowerBounds = theta_bounds(2);
upperBounds = theta_bounds(3);


options = optimoptions('fmincon', 'Display', 'off');
for i =1:length(sigma_prac)
    theta(i,1) = fmincon(@(theta) sum((sigma_prac(i,1).^2 - (nue.*theta.^2 + sigma.^2)).^2), ...
        initialParams,[],[],[],[],lowerBounds,upperBounds,[],options);
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