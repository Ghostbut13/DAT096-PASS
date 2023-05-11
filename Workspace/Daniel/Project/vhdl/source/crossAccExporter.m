clc, close all, clear all
load('crossAccAt28930.mat')

accRes = 16*2 + 14;
res = 32;
crossAcc = crossAcc/ (2^(accRes-res+1));
crossAcc = round(crossAcc);

hold on;
plot(crossAcc(:,1))
plot(crossAcc(:,2))
plot(crossAcc(:,3))

crossAcc(:,1) = mod(crossAcc(:,1), 2^(res-1)) -(2^(res-1))*floor(crossAcc(:,1)./(2^(res-1)));
crossAcc(:,2) = mod(crossAcc(:,2), 2^(res-1)) -(2^(res-1))*floor(crossAcc(:,2)./(2^(res-1)));
crossAcc(:,3) = mod(crossAcc(:,3), 2^(res-1)) -(2^(res-1))*floor(crossAcc(:,3)./(2^(res-1)));

str1="";
str2="";
str3="";
for i=1:length(crossAcc(:,1))
    A = dec2bin(abs(crossAcc(i,1)), res);
    B = dec2bin(abs(crossAcc(i,2)), res);
    C = dec2bin(abs(crossAcc(i,3)), res);
    str1 = str1+A + "\n";
    str2 = str2+B + "\n";
    str3 = str3+C + "\n";
end

fileId = fopen("corr1.txt", 'w');
fprintf(fileId, str1);
fclose(fileId);
fileId = fopen("corr2.txt", 'w');
fprintf(fileId, str2);
fclose(fileId);
fileId = fopen("corr3.txt", 'w');
fprintf(fileId, str3);
fclose(fileId);
