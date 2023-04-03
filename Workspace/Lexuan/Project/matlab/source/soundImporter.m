clc, clear all, close all

%InputFile = "simMic_1.txt";
InputFile = "Correct_DAC.txt";
vhdlFile = 0;
fileId = fopen(InputFile, 'r');

txt = fread(fileId, 'char*1');
fclose(fileId);


q=16;
len = length(txt)/(q+1+ vhdlFile);
dY = zeros(len,1);


oune = char(49);
zerou = char(48);
for i=1:len
    val = 0;
    for b=1:q
        if txt((i-1)*(q+1 + vhdlFile) +b) == oune
            val = val + 2^(q-b);
        end
    end
    dY(i) = val;
end
%dY = mod(dY, 2^(q-1)) -(2^(q-1))*floor(dY./(2^(q-1)));

plot(dY);
grid on;

