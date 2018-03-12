clear;
addpath('../part1/')
%load coefficients
coef = [17 -90 241 902 241 -90 17];

scale = 0.5:0.001:1.0;
npp = zeros(1,501);
for s = 1:501
    Sc = scale(s);
    for i = 1:7
        npp(s) = npp(s) + numppterms(round(Sc * coef(i)));
    end
end

figure(1); clf;
plot(scale, npp, 'x');
axis([0.45 1.05 10 30]);
xlabel('Scaling factor');
ylabel('Number of partial product terms');
title('EEC 281, Hwk/proj 2, Problem 3, Plot of bogus results');