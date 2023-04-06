clc, clear all, close all


InputFile = "Ether_Channel_2.txt";
%InputFile = "ether.txt";
fileId = fopen(InputFile, 'r');

txt = fread(fileId, 'char*1');
fclose(fileId);
data = DataFinder(txt);

mY=[]
for i = 1:4:length(data)
    A = tonum(data(i));
    B = tonum(data(i+1));
    C = tonum(data(i+2));
    D = tonum(data(i+3));
    mY = [mY,A*2^12 + B*2^8 + C*2^4 + D];
    %C = bitter(A,B);
    %E = bitToVal(C);
    %D = chuffle(C);
end
q= 16;
mY = mod(mY, 2^(q-1)) -(2^(q-1))*floor(mY./(2^(q-1)));
subplot(4,1,1)
plot(mY(1:4:end));
subplot(4,1,2)
plot(mY(2:4:end));
subplot(4,1,3)
plot(mY(3:4:end));
subplot(4,1,4)
plot(mY(4:4:end));

%plot(mY(1:4:length(mY)));


function Strong = DataFinder(A)
r=[];

    for a=20:length(A)
        if A(a) == 13 && A(a-1) == 124
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
        if a > 10000000
            break;
        end
    end
   Strong = r;
end


function A = bitToVal(B)
    b = 0;
    for a=1:8
        if B(a) == 1
            b = b+2^(a-1);
        end
    end
    A = b;
end

function A = chuffle(b)
    a= zeros(8,1);
    a(4) = b(5);
    a(3) = b(6);
    a(2) = b(7);
    a(1) = b(8);
    a(8) = b(1);
    a(7) = b(2);
    a(6) = b(3);
    a(5) = b(4);
    A = a;
end


function A = bitter(num1, num2)
    b = zeros(8,1);
    for a = 4:-1:1
        if num1/(2^(a-1)) >= 1
            b(a) = 1;
            num1 = num1 -(2^(a-1));
        end
        if num2/(2^(a-1)) >= 1
            b(a+4) = 1;
            num2 = num2 -(2^(a-1));
        end
    end
    A = b;
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