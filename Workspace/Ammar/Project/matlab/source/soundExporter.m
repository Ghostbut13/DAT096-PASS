clc, clear all, close all
%run("soundstage2.m"); 
%mY = linspace(0, 2^18, 100000);
mY = 1:100000;
mY = mod(mY,2^15);
%mY= [0.8*mY.', mY.', 0.8*mY.', 0.6*mY.'];
mY= [0*mY.', mY.', 0*mY.', 0*mY.'];
%plot(mY)
len = length(mY(:,1));

% close all

%normalize signal
m = max(abs(mY));
m = max(m);
mY = mY./(2*m);
%plot(mY);


%quantize signal
q = 16;
mY = round((2^q -1)*(mY) -0.5);
%plot(mY)
%min(mY)
%max(mY)

% convert to 2s compliment
mY = mod(mY, 2^(q-1)) -(2^(q-1))*floor(mY./(2^(q-1)));
plot(mY); hold on;

%%
%Bit converter
Bits = zeros(len, 4, q);
oune = char(49);
zerou = char(48);
for m = 1:4
    fileId = fopen("simMic_" + string(m) + ".txt", 'w');
    megaStr = char(len*(q+2));
    for i=1:len
        for b = 1:q
            if mY(i,m)/ 2^(q-b) >=1
                Bits(i,m,b) = 1;
                mY(i,m) = mY(i,m) -2^(q-b);
                megaStr((i-1)*(q+2) +b) = oune;
            else
                megaStr((i-1)*(q+2) +b) = zerou;
            end
        end
            megaStr((i-1)*(q+2) +q+1) = "\";
            megaStr((i-1)*(q+2) +q+2) = "n";
    end

    fprintf(fileId, megaStr);
    fclose(fileId);
end
%plot(Bits(:,1,2));

%  %   %   %
%importer

%q= 16
%mY = mod(mY, 2^(q-1)) -(2^(q-1))*floor(mY./(2^(q-1)));
%plot(mY);