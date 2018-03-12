%sin cos precalc
% input 12-bit theta
% output 16-bit cos and sin
last_val = 2^12;

fileID = fopen("sincos_quad.txt","w"); %var2


for i = 0:last_val/8   % var 2

    cs = round(cos(2 * pi * i / last_val) * (2^14));
    sn = round(sin(2 * pi * i / last_val) * (2^14));
%     cs_b = '';
%     sn_b = '';
    
    %convert cos to 16-bit 2's compl
    if(cs < 0)
        cs_b = dec2bin(abs(cs)-1,14);
        cs_b = strrep(cs_b, '1', 'x');
        cs_b = strrep(cs_b, '0', '1');
        cs_b = strrep(cs_b, 'x', '0');
        cs_b = strcat('1',cs_b);
    else
        cs_b = dec2bin(cs,14);
        cs_b = strcat('0',cs_b);
    end
    
    %convert sin to 16-bit 2's compl
    if(sn < 0)
        sn_b = dec2bin(abs(sn)-1,14);
        sn_b = strrep(sn_b, '1', 'x');
        sn_b = strrep(sn_b, '0', '1');
        sn_b = strrep(sn_b, 'x', '0');
        sn_b = strcat('1',sn_b);
    else
        sn_b = dec2bin(sn,14);
        sn_b = strcat('0',sn_b);
    end
    
    %save values
    if (length(cs_b) ~= 15)
        fprintf("case i=%s (%d), cos=%s requires manual workaround\n",dec2bin(i,12),i,cs_b);
        fprintf(fileID, "    cos_mem[10'b%s] = 15'b%s; sin_mem[10'b%s] = 15'b%s\n", dec2bin(i,10), dec2bin(0,15), dec2bin(i,10), sn_b);
    else
        fprintf(fileID, "    cos_mem[10'b%s] = 15'b%s; sin_mem[10'b%s] = 15'b%s\n", dec2bin(i,10), cs_b, dec2bin(i,10), sn_b);
    end
end

fclose(fileID);