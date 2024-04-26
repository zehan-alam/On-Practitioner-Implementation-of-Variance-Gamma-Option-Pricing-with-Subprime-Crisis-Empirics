function regress_coeffs = prac_regress_coeffs(impV,K,T)
n = length(impV);
RHS = ones(n,6);
for cnt =1:n
    RHS(cnt,1) = 1;
    RHS(cnt,2) = K(cnt);
    RHS(cnt,3) = K(cnt)^2;
    RHS(cnt,4) = T(cnt)/365;
    RHS(cnt,5) = (T(cnt)/365)^2;
    RHS(cnt,6) = K(cnt) * T(cnt) /365;
end
regress_coeffs = regress(impV,RHS);
end