clc, clear all, close all


InputFile = "ether.txt";
fileId = fopen(InputFile, 'r');

txt = fread(fileId, 'char*1');
fclose(fileId);

for i = 1:2:length(txt)
    A = tonum(txt(i))
    B = tonum(txt(i+1))
    
    C = bitter(A,B);
    D = chuffle(C);
    E = bitToVal(D)
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
    end

end