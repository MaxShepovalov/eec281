% plot_one_lpfir.m
%
% 2012/03/14  Added NumSamplesFreqz with default value of 2048, also added
%             line for ripple to show frequency range only
% 2010/02/24  Added "including zero coeffs" to title to emphasize the
%             area to use is the main one, not the one in parentheses.
% 2010/02/22  Updated with Spring 2010 numbers
% 2009/02/13  Parameterized main values so script is easier to adapt
% 2005/02/14  Now calculates effective area which removes "outside" taps
%             that area equal to zero
% 2005/02/14  Written
%
% Todo: 
%   - Add call to function that says whether filters meets specs or not;
%     but this will require some code to check passband ripple.


%=================
function plot_one_lpfir(coeffs)
   % set these values (MHz), and also the "axis" parameters below
   FreqSamp        = 100;
   Ripple          =  3;   Ripple_dB =  3;  % placed at 0 dB for no good reason
   Pass1           =  7;   Pass1_dB =  -4;
   Stop1           = 11;   Stop1_dB = -21;
   Stop2           = 15;   Stop2_dB = -26;
   NumSamplesFreqz = 2^11;                  % 512 is default

   figure(1); clf;

   coeffs_scaled   = coeffs/sum(coeffs);    % scale coeffs so H(0)=1
   len             = length(coeffs);

   freqz(coeffs_scaled, 1, NumSamplesFreqz);% plot freq response
   hold on;                                 % don't erase following plots
   % only a single line for passband ripple because the vertical location
   % depends on the exact filter characteristics
   plot([0     Ripple]      /(FreqSamp/2), [Ripple_dB Ripple_dB], 'm'); % ripple
   plot([0     Pass1]       /(FreqSamp/2), [Pass1_dB Pass1_dB], 'r');  % passbnd
   plot([Stop1 (FreqSamp/2)]/(FreqSamp/2), [Stop1_dB Stop1_dB], 'r');  % stop1
   plot([Stop2 (FreqSamp/2)]/(FreqSamp/2), [Stop2_dB Stop2_dB], 'r');  % stop2

   axis([0 1 -45 10]);                      % set window view

   % Calculate number of partial products
   numpps = 0;
   for k = 1:len,
      numpps = numpps + numppterms(coeffs(k));
   end

   % Calculate area and areaeff
   area    = numpps + 2*len;
   leneff  = len;
   while (coeffs(1) == 0 & coeffs(leneff) == 0),
      coeffs = coeffs(2:(leneff-1));
      leneff = leneff -2;
   end
   areaeff   = numpps + 2*leneff;

   % Generate title on plot
   titlestr = strcat(num2str(leneff), ' (',                     ...
                     num2str(len), ') taps, ',                  ...
                     num2str(numpps), ' partial products,',     ...
                    'area = ', num2str(areaeff),                ...
                    '(', num2str(area), ' including zero coeffs)' );
   title(titlestr);
   hold off;

return;

