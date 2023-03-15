clc, clear all, close all

InputFile = "simMic_1.txt";

fileId = fopen(InputFile, 'r');

txt = fread(fileId, 'char*1');
fclose(fileId);


q=16;
len = length(txt)/(q+1);
dY = zeros(len,1);


oune = char(49);
zerou = char(48);
for i=1:len
    val = 0;
    for b=1:q
        if txt((i-1)*(q+1) +b) == oune
            val = val + 2^(q-b);
        end
    end
    dY(i) = val;
end


plot(dY);

