%check results 
clear;
complex_result;

A = a / 32768;
B = b / 32768;
E = 2* pi * wn_exp / 4096; %angle
W = exp(1i * E); %fft coef
Xt = x / 16384; %test result
Yt = y / 16384; %test result
Xm = A + B; %matlab result
Ym = (A - B).*W;

%checks
DiffErrEnergyX = difff(Xt, Xm, 'Simulation', 'Matlab');
%DiffErrEnergyY = difff(Yt, Ym, 'Simulation', 'Matlab');