clc, clear all, close all
%hold on

%InputFile = "PALOG.log";
InputFile = "outputLOG.log";
%InputFile = "simMic_1.txt";
%InputFile = "Correct_DAC.txt";
%InputFile = "Correct_PA.txt";
% change to 1 for vhdl, 0 for matlab files
vhdlFile = 1;
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
dY = dY./(2^(q-1)) -1;

sound(dY, 48000)

plot(dY, 'red');
grid on;

