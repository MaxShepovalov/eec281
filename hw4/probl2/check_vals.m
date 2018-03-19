%check results 
clear;
complex_result;

A = a / abs(max(a));
B = b / abs(max(b));
E = 2* pi * wn_exp / abs(min(wn_exp)); %angle
W = exp(1i * E); %fft coef
Xt = x / abs(max(x)); %test result
Yt = y / abs(max(y)); %test result
Xm = A + B; %matlab result
Ym = (A - B).*W;

%checks
DiffErrEnergyX = difff(Xt, Xm, 'Simulation', 'Matlab');
%DiffErrEnergyY = difff(Yt, Ym, 'Simulation', 'Matlab');