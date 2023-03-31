%clc, clear all, close all

InputFile = "outputLOG.log";
%InputFile = "simMic_2.txt";
fileId = fopen(InputFile, 'r');

txt = fread(fileId, 'char*1');
fclose(fileId);


q=16;
len = length(txt)/(q+2);
dY = zeros(len,1); % create an array with len times indexes with zeroes.


oune = char(49);
zerou = char(48);
for i=1:len
    val = 0;
    for b=1:q
        if txt((i-1)*(q+2) +b) == oune
            val = val + 2^(q-b);
        end
    end
    dY(i) = val;
end

% 2's complement conversion
%dY = mod(dY, 2^(q-1)) -(2^(q-1))*floor(dY./(2^(q-1)));
figure(2)
plot(dY);
dY = dY - mean(dY);
%%
figure(5);
Fs = 48000;
SampleLength=5000;
Overlap = 0.2*SampleLength;
g = bartlett(SampleLength);
F = logspace(0, log10(5000), 256);
[s,f,t] = spectrogram(dY,g,Overlap,F,Fs);
waterplot(s,f,t, 'green');



function waterplot(s,f,t, color)
% Waterfall plot of spectrogram
    P = waterfall(f,t,abs(s)'.^2);
    P.EdgeColor = color;
    set(gca,XDir="reverse",View=[30 50])
    xlabel("Frequency (Hz)")
    ylabel("Time (s)")
end
%sound(out, Fs);

