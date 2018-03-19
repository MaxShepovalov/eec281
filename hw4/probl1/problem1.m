%search parameters
clear

min_numtaps = 0;
min_freqs = [];
min_amps = [];
min_scale = 0;

min_area = -1;
min_pps = 0;
min_ripple = 0;
min_minpass = 0;
min_stoplo = 0;
min_stophi = 0;

%passband 8MHz, 12MHz
PB8 = 8 / 100;
PB12 = 12 / 100;
%stopband 16MHz, 19MHz
SB16 = 16 / 100;
SB19 = 19 / 100;

for stopamp = 0:0.05:0.1
	for passamp = 0:0.05:0.1
        for stopfreq = SB16:0.01:SB19
            for passfreq = PB8:0.01:PB12
                for scale = 100:100:2048
                    for numtaps = 31:10:211
                        
                        freqs = [0 passfreq stopfreq 1];
                        amps = [1-passamp 1-passamp stopamp stopamp];
                        
                        coeffs1   = remez(numtaps-1, freqs, amps);
                        coeffs2   = coeffs1*scale;
                        coeffs    = round(coeffs2);
                        [H,W]     = freqz(coeffs);
                        H_norm    = abs(H) ./ abs(H(1));
                        [ripple, minpass, maxstoplo, maxstophi] = lpfirstats(H_norm);

                        if (ripple < 3 && minpass > -4 && maxstoplo < -25 && maxstophi < -28)
                            fprintf("%d numtaps, %d scale, %f pf, %f sf, %f pa, %f sa CONDITION MET\n", numtaps, scale, passfreq, stopfreq, passamp, stopamp);
                            %calculate area
                            n_pps = 0;
                            for c = coeffs
                                n_pps = n_pps + numppterms(c);
                            end
                            area = n_pps + 2 * numtaps;
                            if area < min_area || min_area == -1
                                min_area = area;
                                min_numtaps = numtaps;
                                min_amps = amps;
                                min_scale = scale;
                                min_freqs = freqs;
                                min_pps = n_pps;
                                min_ripple = ripple;
                                min_minpass = minpass;
                                min_stoplo = maxstoplo;
                                min_stophi = maxstophi;
                            end
                        else
                            fprintf("%d numtaps, %d scale, %f pf, %f sf, %f pa, %f sa not met\n", numtaps, scale, passfreq, stopfreq, passamp, stopamp);
                        end
                    end
                end
            end
        end
    end
end

%report numbers
fprintf("%d area, %d taps, %d PPs\n", min_area, min_numtaps, min_pps);
fprintf("%f ripple, %f minpass, %f maxstoplo, %f maxstophi\n", min_ripple, min_minpass, min_stoplo, min_stophi);

%3/17/2018 results
% 132 area, 41 taps, 50 PPs
% 0.616699 ripple, -3.442710 minpass, -25.442571 maxstoplo, -28.018272 maxstophi
%freqs [0   0.09 0.17 1]
%amps  [0.9 0.9  0    0]

report_area = 132;
report_scale = 100;
report_taps = 41;
report_pps = 50;
report_freqs = [0 0.09 0.17 1];
report_amps = [0.9 0.9 0 0];