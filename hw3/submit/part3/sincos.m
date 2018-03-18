%sin cos precalc
% input 12-bit theta
% output 16-bit cos and sin
last_val = 2^12;

fileID = fopen("sincos_full.txt","w");

for i = 0:last_val-1

    cs = round(cos(2 * pi * i / last_val) * (2^14));
    cs_b = '';
    
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
    
    %save values
    if (length(cs_b) ~= 15)
        fprintf("case i=%s (%d), cos=%s require manual workaround\n",dec2bin(i,12),i,cs_b);
        fprintf(fileID, "    cos_mem[12'b%s] = 15'b%s;\n", dec2bin(i,12), dec2bin(0,15));
    else
        fprintf(fileID, "    cos_mem[12'b%s] = 15'b%s;\n", dec2bin(i,12), cs_b);        
    end
end

fclose(fileID);