clear;
addpath('../part1/') %add numppterms
%fir
%coef = [17 -90  241   902  241 -90  17]
%pps      2   4    3     4    3   4   2
%       +16 -64 +256 +1024 +256 -64 +16
%        +1 -32  -16  -128  -16 -32  +1
%            +4   -1    +4   -1  +4
%            +2         -2       +2

%original coefficients
coef = [17 -90 241 902 241 -90 17];

%scaling factor
%scale = 1;
scale = 0.532; %12 pps, coef_r will be [9 -48 128 480 128 -48 9]

%rounded coedficients
coef_r = round( coef * scale );
fprintf("Scale %f Using coefficients [", scale);
fprintf(" %d", coef_r);
fprintf("]\n");

%total number of partial products for FIR
total = 0;

%calculation
for fircoef = 1:7
    total = total + numppterms(coef_r(fircoef));
    fprintf("coef #%d %d, %d partial products\n", fircoef, coef_r(fircoef), numppterms(coef_r(fircoef)));
end

fprintf("In total, need %d partial products\n", total);