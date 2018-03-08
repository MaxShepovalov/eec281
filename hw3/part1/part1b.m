StepSize = 0.5;
NumTermsArrayPos = zeros(1, 100/StepSize);
for k = StepSize : StepSize : 100,
    NumTermsArrayPos(k/StepSize) = numppterms(k);
end

fprintf('Total sum for +0.5 - +100.00 = %i\n', sum(NumTermsArrayPos));

figure(1); clf;
plot(StepSize:StepSize:100, NumTermsArrayPos, 'x');
axis([0 101 0 1.1*max(NumTermsArrayPos)]);
xlabel('Input number');
ylabel('Number of partial product terms');