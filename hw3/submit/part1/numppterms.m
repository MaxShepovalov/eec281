
function [mpp] = numppterms(num)
    mpp = 0;
    rem = num;
    while (rem ~= 0 && mpp < 10)
        for i = -1:10
            if 2^i >= abs(rem)
                mpp = mpp + 1;
                if (2^i - abs(rem) < abs(rem) - 2^(i-1))
                    rem = abs(rem) - 2^i;
                else
                    rem = abs(rem) - 2^(i-1);
                end
            break;
            end
        end
    end
end