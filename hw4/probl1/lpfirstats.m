%lpfirstats(H)

function [ripple, minpass, maxstoplo, maxstophi] = lpfirstats(H)
    %H - frequency responce
    %100MHz sampling
    
    %passband 8MHz, 12MHz
    PB8 = round(length(H) * 8 / 100);
    PB12 = round(length(H) * 12 / 100);
    
    %stopband 16MHz, 19MHz
    SB16 = round(length(H) * 16 / 100);
    SB19 = round(length(H) * 19 / 100);
    
    %param1 ripple. below 8MHz, < 3dB
    ripple = 20*log10(max(H(1:PB8))) - 20*log10(min(H(1:PB8))); %log from level 1
    
    %param2 minpass. below 12MH, > -4dB
    minpass = 20*log10(min(H(1:PB12)));
    
    %param3 maxstoplo. above 16MHz, < -25dB
    maxstoplo = 20*log10(max(H(SB16:length(H))));
    
    %param3 maxstophi. above 19MHz, < -28dB
    maxstophi = 20*log10(max(H(SB19:length(H))));
end