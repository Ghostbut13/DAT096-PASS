clc, clear all, close all

% choose input file and output file name {
    InputFile = "movingactor4-1_reading_70dB_lecroom.txt";
    OutputFile = "movingactor4-1_reading_70dB_lecroom";
% }

% read file
fileId = fopen(InputFile, 'r');
txt = fread(fileId, 'char*1');
fclose(fileId);

% extract samples
data = DataFinder(txt);

mY=zeros(length(data)/4,1);
for i = 1:4:length(data)
    A = tonum(data(i));
    B = tonum(data(i+1));
    C = tonum(data(i+2));
    D = tonum(data(i+3));
    mY(ceil(i/4)) = A*2^12 + B*2^8 + C*2^4 + D;
    %C = bitter(A,B);
    %E = bitToVal(C);
    %D = chuffle(C);
end
q= 16;
mY = mod(mY, 2^(q-1)) -(2^(q-1))*floor(mY./(2^(q-1))); % 2s compliment conversion
mY = [mY(1:4:end), mY(2:4:end), mY(3:4:end), mY(4:4:end)]; % Dividing long sample vector in to channels
subplot(4,1,1)
plot(mY(:,1));
title("#1 Microphone")
subplot(4,1,2)
plot(mY(:,2));
title("#2 Microphone")
subplot(4,1,3)
plot(mY(:,3));
title("#3 Microphone")
subplot(4,1,4)
plot(mY(:,4));
title("#4 Microphone")
save(OutputFile, "mY")


function Strong = DataFinder(A)
r=zeros(length(A),1);
i = 1;

    for a=20:length(A)
        if A(a) == 13 & A(a-19:a-1) ==  double(['|'; '0'; '0'; '|'; '0'; '0'; '|'; '0'; '0'; '|'; '0'; '0'; '|'; '0'; '0'; '|'; '0'; '0'; '|'])
            t=1+(3*10); %remove crc zeros
            data=A(a-t-(3*8)+1:a-t); % every byte is 3 characters, 2 with data and a | seperator
            DataArr = [];
            for b=1:length(data)
                if mod(b,3) ~= 0
                    DataArr = [ DataArr, data(b)];
                end
            end
            
            r(i:i+15) = DataArr;
            i = i+16;
        end
    end
   Strong = r(1:i-1,:);
end


function A = tonum(charA)
    if charA>47 && charA<58
        A = charA - 48;
    elseif charA>64 && charA<71
        A = charA -65+10;
    elseif charA>96 && charA <103
        A = charA -97 +10;
    end

end