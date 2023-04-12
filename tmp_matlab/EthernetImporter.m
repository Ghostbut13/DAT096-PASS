clc
clear all
close all


% a = importdata("Ether_Channel_3(1m_80dB).txt") 

%%% READ FILES
InputFile = "Ether_Channel_3(1m_80dB_8s).txt";
%InputFile = "ether.txt";
fileId = fopen(InputFile, 'r');

txt = fread(fileId, 'char*1');
fclose(fileId);
data = DataFinder(txt);

%%% FORMAT TXT->NUM
mY=zeros(length(data)/4,1);
for i = 1:4:length(data)
    A = tonum(data(i));
    B = tonum(data(i+1));
    C = tonum(data(i+2));
    D = tonum(data(i+3));
    mY(ceil(i/4)) = A*2^12 + B*2^8 + C*2^4 + D;
end


%%%  2'S COMPLEMENT -> UNSIGNNED
q= 16;
mY = mod(mY, 2^(q-1)) -(2^(q-1))*floor(mY./(2^(q-1)));
subplot(4,1,1)
plot(linspace(0,length(mY)/(4*48000),length(mY)/4),mY(1:4:end));
subplot(4,1,2)
plot(linspace(0,length(mY)/(4*48000),length(mY)/4),mY(2:4:end));
subplot(4,1,3)
plot(linspace(0,length(mY)/(4*48000),length(mY)/4),mY(3:4:end));
subplot(4,1,4)
plot(linspace(0,length(mY)/(4*48000),length(mY)/4),mY(4:4:end));





%%% FUNCTION
function Strong = DataFinder(A)
r=[];

    for a=20:length(A)-100
        if A(a) == 13 && A(a-1) == '|' && A(a-2) == '0' && A(a-3) == '0' && A(a-4) == '|' && A(a-5) == '0' && A(a-6) == '0'
            t=1+(3*10); %remove crc zeros
            data=A(a-t-(3*8)+1:a-t); % every byte is 3 characters, 2 with data and a | seperator
            DataArr = [];
            for b=1:length(data)
                if mod(b,3) ~= 0
                    DataArr = [ DataArr, data(b)];
                end
            end
            
            r=[r,DataArr];
            %break;
        end
        if a > 1000000000
            break;
        end
    end
   Strong = r;
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