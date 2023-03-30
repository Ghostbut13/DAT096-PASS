clc, clear all, close all

signal=[zeros(1,200), sin(linspace(0,40*pi, 10000))];
figure(1)
plot(signal);
figure(2);

d = ceil(48000/343);
signalAcc = zeros(1000,1);
crossAcc = zeros(2*d,1);
for i=1:1000
    signalAcc = [signal(i); signalAcc(1:end-1)]; 


    crossAcc = mycrossCorre(crossAcc, signalAcc,signalAcc,floor(length(crossAcc)/2));

    hold on;
    plot3(crossAcc, (1:length(crossAcc))-ceil(length(crossAcc)/2),i*ones(length(crossAcc),1), 'black');
    [A,I] = max(crossAcc);
    plot3(A,I-ceil(length(crossAcc)/2),i, 'o');
end





function newAcc = mycrossCorre(acc, X, Y, maxlag)
    for l=1-maxlag:maxlag
        %new = X(lag)*Y(1); % simplification for non negative lag values
        new = X(maxlag+l).*Y(maxlag); % to accept negative lag values we need to delay the signal with the amount of max negative lag
    
        old = X(end-maxlag + l).*Y(end-maxlag);
    
        acc(l+maxlag) = acc(l+maxlag) + new - old;
    end
    newAcc = acc;
end