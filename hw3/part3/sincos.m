%sin cos precalc
% input 12-bit theta
% output 16-bit cos and sin
last_val = 2^12;

fileID = fopen("sincos_full.txt","w"); %var1
%fileID = fopen("sincos_quad.txt","w"); %var2
%fileID = fopen("sincos_small.txt","w"); %var3

% cos_check = [];

for i = 0:last_val-1     % var 1
%for i = 0:last_val/4   % var 2
%for i = 0:last_val/8   % var 3, leave only cos

    cs = round(cos(2 * pi * i / last_val) * (2^14)); %var 1 and 2
    %cs = round(cos(4 * pi * i / last_val) * (2^14)); % var 3
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
        fprintf(fileID, "    cos_mem[11'b%s] = 15'b%s;\n", dec2bin(i,12), dec2bin(0,15));
        %fprintf(fileID, "    cos_mem[10'b%s] = 15'b%s;\n", dec2bin(i,11), dec2bin(0,15)); %var 3
%         cos_check(i+1) = 0;
    else
        fprintf(fileID, "    cos_mem[11'b%s] = 15'b%s;\n", dec2bin(i,12), cs_b);
        %fprintf(fileID, "    cos_mem[10'b%s] = 15'b%s;\n", dec2bin(i,11), cs_b); %var 3
%         cos_check(i+1) = bin2dec(cs_b) - (2^16)*bin2dec(cs_b(1));
    end
end

fclose(fileID);