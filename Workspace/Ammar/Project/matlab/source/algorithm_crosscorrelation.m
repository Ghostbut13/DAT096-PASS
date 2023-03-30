clc, clear all, close all

run("soundstage2.m"); 
Y=mY;
close all

Y = abs(Y);
subplot(4,1,1);
plot(Y(:,1));
subplot(4,1,2);
plot(Y(:,2));
subplot(4,1,3);
plot(Y(:,3));
subplot(4,1,4);
plot(Y(:,4));

sY = Y;
n=100;
Y=[zeros(n, length(Y(1,:))); Y];

for i=n:len
    for a = 1:length(Y(1,:))
        sY(i,a) = mean(Y(i-n+1:i,a));
    end
end

figure(2)
subplot(4,1,1);
plot(sY(:,1));
subplot(4,1,2);
plot(sY(:,2));
subplot(4,1,3);
plot(sY(:,3));
subplot(4,1,4);
plot(sY(:,4));



phase = 2.5;
phaseA = zeros(1, len);
delta = 0.0001
out = zeros(1, len);

figure(3);

for j=1:1000:len-1000
    r = zeros(1,4);
    [A,I] = max(sY(j,:));
    for i=1:4
        if i~=I
        r(i) = max(xcorr(sY(j:1000+j,I), sY(j:1000+j,i)));
        end
    end
    [maxr,index] = max(r);

    subplot(2,1,1);
    hold on;
    plot(j,index,'o');
    subplot(2,1,2);
    plot(j,I,'o');
    
    hold on;
end
%sound(out, Fs);

