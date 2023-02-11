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

for i=1:len
    [A,I] = max(sY(i,:));
    if phase > I
        phase = phase - delta; 
    else
        phase = phase + delta;
    end
    
    if phase < 2
        out(i) = (phase-1)*mY(i,2) + (2-phase)*mY(i,1);
    elseif phase < 3
        out(i) = (phase-2)*mY(i,3) + (3-phase)*mY(i,2);
    else
        out(i) = (phase-3)*mY(i,4) + (4-phase)*mY(i,3);
    end
    phaseA(i) = phase;
end
figure(3);
plot(phaseA);

figure(4)
plot(out);
%sound(out, Fs);

