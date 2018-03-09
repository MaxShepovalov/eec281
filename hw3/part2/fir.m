%fir
%coef = [17 -90  241   902  241 -90  17]
%pps      2   4    3     4    3   4   2
%       +16 -64 +256 +1024 +256 -64 +16
%        +1 -32  -16  -128  -16 -32  +1
%            +4   -1    +4   -1  +4
%            +2         -2       +2

%scale = 0.532 %12 pps
%coef_r are [9 -48 128 480 128 -48 9]


%original coefficients
coef = [17 -90 241 902 241 -90 17];

%scaling factor
%scale = 0.75;

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
end

fprintf("Need %d partial products\n", total);

%find solution
% tpp = zeros(1,5001);
% x = zeros(1,5001);
% for i = 1:5000
%     scale = (i + 5000) / 10000;
%     fir
%     tpp(i) = total;
%     x(i) = scale;
% end
% plot(x,tpp);