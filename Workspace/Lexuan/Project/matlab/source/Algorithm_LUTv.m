clc, close all
load("LUTv");
load("movingactorYaxis4_reading_70dB_lecroom");

% HIGHPASS Filter
fY = zeros(length(mY(:,1)),4);
fc = 1000;
[n,d] = butter(3, fc/(48000/2), 'high');
sys = tf(n,d, 1/48000);
fY(:,1) = lsim(sys, mY(:,1), []);
fY(:,2) = lsim(sys, mY(:,2), []);
fY(:,3) = lsim(sys, mY(:,3), []);
fY(:,4) = lsim(sys, mY(:,4), []);
mY = fY;


micDistance = 1; % meters
len = length(mY(:,1));%48000;
%len = 48000;
d = ceil(48000/343);
signalAcc = zeros(10000,4);

crossAcc = zeros(2*d,3);
crossAcc2 = zeros(2*2*d,2);
crossAcc3 = zeros(3*2*d,1);
choords= zeros(2,len);
for i=2:len
    %BRAM
    signalAcc(:,1) = [mY(i,1); signalAcc(1:end-1,1)]; 
    signalAcc(:,2) = [mY(i,2); signalAcc(1:end-1,2)]; 
    signalAcc(:,3) = [mY(i,3); signalAcc(1:end-1,3)]; 
    signalAcc(:,4) = [mY(i,4); signalAcc(1:end-1,4)]; 

    %crosscorrelation
    crossAcc(:,1) = mycrossCorre(crossAcc(:,1), signalAcc(:,1),signalAcc(:,2),floor(length(crossAcc(:,1))/2)); % crosscorr mic 1 and 2
    crossAcc(:,2) = mycrossCorre(crossAcc(:,2), signalAcc(:,2),signalAcc(:,3),floor(length(crossAcc(:,2))/2)); % mic 2 and 3
    crossAcc(:,3) = mycrossCorre(crossAcc(:,3), signalAcc(:,3),signalAcc(:,4),floor(length(crossAcc(:,3))/2)); % mic 3 and 4
    crossAcc2(:,1) = mycrossCorre(crossAcc2(:,1), signalAcc(:,1),signalAcc(:,3),floor(length(crossAcc2(:,1))/2)); % crosscorr mic 1 and 3
    crossAcc2(:,2) = mycrossCorre(crossAcc2(:,2), signalAcc(:,2),signalAcc(:,4),floor(length(crossAcc2(:,2))/2)); % mic 2 and 4
    crossAcc3(:,1) = mycrossCorre(crossAcc3(:,1), signalAcc(:,1),signalAcc(:,4),floor(length(crossAcc3(:,1))/2)); % mic 1 and 4
    
    res = 64;
    Array1 = zeros(res*2+2, res+1);
    for lag=-d:d-1
        val = crossAcc(lag+d+1,1);
        for a  = 1:length(LUTv(:,1,1))
            x=LUTv(a, 1, lag+d+1);
            y=LUTv(a, 2, lag+d+1);
            if val > Array1(x+res+1,y+1)
                Array1(x+res+1,y+1) = val;
            end
        end
    end
    
    Array2 = zeros(res*2+2, res+1);
    for lag=-d:d-1
        val = crossAcc(lag+d+1,2);
        for a  = 1:length(LUTv(:,1,1))
            x=LUTv(a, 1, lag+d+1);
            y=LUTv(a, 2, lag+d+1);
            if val > Array2(x+res+1,y+1)
                Array2(x+res+1,y+1) = val;
            end
        end
    end
    
    Array3 = zeros(res*2+2, res+1);
    for lag=-d:d-1
        val = crossAcc(lag+d+1,3);
        for a  = 1:length(LUTv(:,1,1))
            x=LUTv(a, 1, lag+d+1);
            y=LUTv(a, 2, lag+d+1);
            if val > Array3(x+res+1,y+1)
                Array3(x+res+1,y+1) = val;
            end
        end
    end
    
    SumArray = zeros(res*4+2, res+1);
    xZero = round(res+1 -res/maxD);
    SumArray(xZero:xZero+2*res+1, :) = SumArray(xZero:xZero+2*res+1, :) + Array1;
    xZero = res+1;
    SumArray(xZero:xZero+2*res+1, :) = SumArray(xZero:xZero+2*res+1, :) + Array2;
    xZero = round(res+1 +res/maxD);
    SumArray(xZero:xZero+2*res+1, :) = SumArray(xZero:xZero+2*res+1, :) + Array3;
    
    [A,X] = max(SumArray');
    [~,Y] = max(A);
    X = X(Y);
    choords(1,i) = X;
    choords(2,i) = Y;
end
%%
close all
load("choords.mat")
A= choords(1,:);
B = choords(2,:);
choords = [B;A];

fChoords = choords;
fc = 1;
[n,d] = butter(3, fc/(48000/2), 'low');
sys = tf(n,d, 1/48000);
fChoords(1,:) = lsim(sys, choords(1,:), []);
fChoords(2,:) = lsim(sys, choords(2,:), []);



plot(maxD*(fChoords(1,:)-2*res)/res)
hold on
plot(maxD*fChoords(2,:)/res)
grid on
plot(mY./max(mY))
figure
hold on
surf(SumArray');




function newAcc = mycrossCorre(acc, X, Y, maxlag)
    for l=1-maxlag:maxlag
        %new = X(lag)*Y(1); % simplification for non negative lag values
        new = X(maxlag+l).*Y(maxlag); % to accept negative lag values we need to delay the signal with the amount of max negative lag
    
        old = X(end-maxlag + l).*Y(end-maxlag);
    
        acc(l+maxlag) = acc(l+maxlag) + new - old;
    end
    newAcc = acc;
end
