function [output] = prac_vol(p,K,T)
n = length(K);
output = p(1) +p(2).*K +p(3).*K.^2 +p(4).*(T./365) +p(5).*(T./365).^2 +p(6).*K.*(T./365);
for i=1:n
    if output(i) <0 
        output(i) = 0.01;
    end
end
end