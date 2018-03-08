
function [mpp] = numppterms(num)
    mpp = 0; %partial product counter. if returned 0, something is wrong
    %searching first power of 2 that is larger than |num|
    rem = num; %remainer
    %add_negative = 0; %==1 if need to account +1 for subtractions
    while (rem ~= 0 && mpp < 10)
        %display("rem " + rem + " mpp " + mpp);
        for i = -1:10
            if 2^i >= abs(rem)
                mpp = mpp + 1;
                if (2^i - abs(rem) < abs(rem) - 2^(i-1))
                    %display(mpp + "--> 2^" + i + " = " + 2^i + " > |" + rem + "|; rem <- " + (abs(rem) - 2^i));
                    rem = abs(rem) - 2^i;
                else
                    %display(mpp + "--> 2^" + (i-1) + " = " + 2^(i-1) + " > |" + rem + "|; rem <- " + (abs(rem) - 2^(i-1)));
                    rem = abs(rem) - 2^(i-1);
                end
            break;
            end
        end
    end
end