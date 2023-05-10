clc, clear all, close all


InputFile = "frame1_new8192.mem";
fileId = fopen(InputFile, 'r');
txt = fread(fileId, 'char*1');
fclose(fileId);
i=1;
a = 1;
frame = zeros(8192,1);
pCounter = 1;
while i<length(txt)-8
   b=txt(i:i+5);
   i = i+7;
   a = a+1;
   pCounter = pCounter +1;
   if a == 12
       a=1;
       i=i+1;
   end
   frame(pCounter) = binChar2Dec(b);
end

j=0
frame2d = zeros(128,64);
% frame2d = zeros(64,128);
for i=1:64:length(frame)-1
%     frame2d(floor(i/64) +1, mod(i,128)+1) = frame(i);
    j=j+1;
    frame2d(j,:) = frame(i:i+63);
    %frame2d(mod(i,64)+1, floor(i/128) +1) = frame(i);
end

x=0.5:1:64.5;
y=0.5:1:128.5;
M=meshgrid(x,y);
N=meshgrid(y,x);


surf(frame2d)
hold on
plot(x,N,'b');
plot(M,y,'b')
% grid on

function v=binChar2Dec(bins)
    acc = 0;
    for i=1:length(bins)
        if bins(i) == 49
            acc = acc + 2^(length(bins) -i-1);
        end
    end
    v=acc;
end