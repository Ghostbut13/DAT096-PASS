clc, clear all, close all

%signal=[zeros(1,200), sin(linspace(0,40*pi, 10000))];
%load('movingactor4-1_reading.mat'); % load mY
load('Ether_Channel_3(1m_80dB_8s).mat')

pY = zeros(length(mY(:,1)),4);
powAcc = zeros(1000,4);
for i = 1:length(mY(:,1))
    powAcc(:,1) = [abs(mY(i,1)); powAcc(1:end-1, 1)];
    powAcc(:,2) = [abs(mY(i,2)); powAcc(1:end-1, 2)];
    powAcc(:,3) = [abs(mY(i,3)); powAcc(1:end-1, 3)];
    powAcc(:,4) = [abs(mY(i,4)); powAcc(1:end-1, 4)]; 
    pY(i,1) = mean(powAcc(:,1));
    pY(i,2) = mean(powAcc(:,2));
    pY(i,3) = mean(powAcc(:,3));
    pY(i,4) = mean(powAcc(:,4));
end

pY = pY./max(pY);
%mY = mY./max(abs(mY));

%highpass
fY = zeros(length(mY(:,1)),4);
fc = 200;
[n,d] = butter(2, fc/(48000/2), 'high');
sys = tf(n,d, 1/48000);
fY(:,1) = lsim(sys, mY(:,1), []);
fY(:,2) = lsim(sys, mY(:,2), []);
fY(:,3) = lsim(sys, mY(:,3), []);
fY(:,4) = lsim(sys, mY(:,4), []);

%lowpass
fc = 8000;
[n,d] = butter(2, fc/(48000/2), 'low');
sys = tf(n,d, 1/48000);
fY(:,1) = lsim(sys, fY(:,1), []);
fY(:,2) = lsim(sys, fY(:,2), []);
fY(:,3) = lsim(sys, fY(:,3), []);
fY(:,4) = lsim(sys, fY(:,4), []);

mY=fY;

figure(1)
plot(mY);


figure(2);
len = length(mY(:,1));%48000;
%len = 48000;
d = ceil(48000/343);
signalAcc = zeros(10000,4);
crossAcc = zeros(4*d,3);
lags = zeros(len,3);
for i=1:len
    signalAcc(:,1) = [mY(i,1); signalAcc(1:end-1,1)]; 
    signalAcc(:,2) = [mY(i,2); signalAcc(1:end-1,2)]; 
    signalAcc(:,3) = [mY(i,3); signalAcc(1:end-1,3)]; 
    signalAcc(:,4) = [mY(i,4); signalAcc(1:end-1,4)]; 


    crossAcc(:,1) = mycrossCorre(crossAcc(:,1), signalAcc(:,2),signalAcc(:,4),floor(length(crossAcc(:,1))/2)); % crosscorr mic 2 and 4
    crossAcc(:,2) = mycrossCorre(crossAcc(:,2), signalAcc(:,2),signalAcc(:,3),floor(length(crossAcc(:,2))/2)); % mic 2 and 3
    crossAcc(:,3) = mycrossCorre(crossAcc(:,3), signalAcc(:,3),signalAcc(:,4),floor(length(crossAcc(:,3))/2)); % mic 3 and 4
    [A, lags(i,1)] = max(crossAcc(:,1));
    [A, lags(i,2)] = max(crossAcc(:,2));
    [A, lags(i,3)] = max(crossAcc(:,3));
    if mod(i,1000) == 1
        hold on;
        n=1;
        %plot3(crossAcc(:,1), (1:length(crossAcc(:,1)))-ceil(length(crossAcc(:,1))/2),i*ones(length(crossAcc(:,1)),1), 'black');
        plot3(crossAcc(:,n), (1:length(crossAcc(:,n)))-ceil(length(crossAcc(:,n))/2),(i/48000)*ones(length(crossAcc(:,n)),1), 'color', [pY(i,3), pY(i,3), 0]);
        [A,I] = max(crossAcc(:,n));
        plot3(A,I-ceil(length(crossAcc(:,n))/2),i/48000, 'o');
    end
end

figure(3)
hold on
plot(lags(:,1)-length(crossAcc(:,1))/2)
plot(lags(:,2)-length(crossAcc(:,1))/2)
plot(lags(:,3)-length(crossAcc(:,1))/2)
figure(4)
plot(mY(:,4))

% figure(5)
% for i=1:len
%     delay2 = 343*(delay2+delay1)/48000;
%     delay1 = 343*lags(i,3)/48000;
% 
%     A = 3 - 2;
%     B = 4 - 3;
% 
%     x = -(B^2/delay2 - delay2- A^2/delay1 + delay1)/(2*(A/delay1 - B/delay2));
%     
%     D = ((-2*A-2*B)*x+ A^2 + B^2 - delay1^2 - delay2^2)/(2*(delay1 + delay2));
% 
%     y = sqrt(D^2 - x^2);
% 
%     x = Index1 -2.5 + x;
%     if mod(i,1000) == 1
%         plot(x,y, 'o');
%     end
% 
% end



function newAcc = mycrossCorre(acc, X, Y, maxlag)
    for l=1-maxlag:maxlag
        %new = X(lag)*Y(1); % simplification for non negative lag values
        new = X(maxlag+l).*Y(maxlag); % to accept negative lag values we need to delay the signal with the amount of max negative lag
    
        old = X(end-maxlag + l).*Y(end-maxlag);
    
        acc(l+maxlag) = acc(l+maxlag) + new - old;
    end
    newAcc = acc;
end