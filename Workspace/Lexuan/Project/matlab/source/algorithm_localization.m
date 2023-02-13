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
openfig('soundstage.fig');

for j=1:10000:len-10000
    r = zeros(1,4);
    d = zeros(1,4);
    [A,I] = max(sY(j,:));
    for i=1:4
        if i~=I
         [A, B]=xcorr(mY(j:1000+j,I), mY(j:1000+j,i));
         [r(i), IND] = max(A(1:1000));
         d(i) = B(IND);
        end
    end
    [maxr,index] = max(r);
    r(index) = 0;
    [secondMaxr, secondIndex] = max(r);
    

    deltaD1 = 343*d(index) ./48000;
    deltaD2 = 343*d(secondIndex) ./48000;


    syms x y
    [solvex,solvey] = vpasolve([sqrt((x-(I-2.5))^2+y^2)-sqrt((x-index+2.5)^2+y^2) == deltaD1, sqrt((x-I+2.5)^2+y^2)-sqrt((x-secondIndex+2.5)^2+y^2) == deltaD2])
    hold on;
    plot(solvex,solvey,'o');

    ang = zeros(1,4);
    for i=1:4
        if(solvex )
        ang(i) = atan(solvey/abs(solvex-i+2.5));
    end
    

%     subplot(4,1,1);
%     hold on;
%     plot(j,index,'o');
%     subplot(4,1,2);
%     hold on;
%     plot(j,I,'o');
%     subplot(4,1,3);
%     plot(j,d(index),'o');
%     subplot(4,1,4);
%     plot(j,d(secondIndex),'o');
    
 %   hold on;
end
%sound(out, Fs);

