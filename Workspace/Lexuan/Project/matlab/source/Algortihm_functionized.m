clc, clear all, close all
run("soundstage2.m")
close all
% n=1;
% mY(:,1)=[zeros(1,200), sin(linspace(0,n*4000*pi, n*48000)), zeros(1,220)];
% mY(:,2)=[zeros(1,210), sin(linspace(0,n*4000*pi, n*48000)), zeros(1,210)];
% mY(:,3)=[zeros(1,220), sin(linspace(0,n*4000*pi, n*48000)), zeros(1,200)];
% mY(:,4)=[zeros(1,320), sin(linspace(0,n*4000*pi, n*48000)), zeros(1,100)];

%load('movingactor4-1_reading.mat'); % load mY
%load('Ether_Channel_3(1m_80dB_8s).mat');
%load('movingactor4-1_reading.mat');

pY = zeros(length(mY(:,1)),4);
powAcc = zeros(1000,4);
for i = 1:length(mY(:,1))
    powAcc(:,1) = [abs(mY(i,1)); powAcc(1:end-1, 1)];
    powAcc(:,2) = [abs(mY(i,2)); powAcc(1:end-1, 2)];
    powAcc(:,3) = [abs(mY(i,3)); powAcc(1:end-1, 3)];
    powAcc(:,4) = [abs(mY(i,4)); powAcc(1:end-1, 4)]; 
    pY(i,1) = sum(powAcc(:,1));
    pY(i,2) = sum(powAcc(:,2));
    pY(i,3) = sum(powAcc(:,3));
    pY(i,4) = sum(powAcc(:,4));
end

% pY(pY>1000000) = 1000000;
% pY(pY<300000) = 300000;

fc = 1;
[n,d] = butter(2, fc/(48000/2), 'low');
sys = tf(n,d, 1/48000);
fpY(:,1) = lsim(sys, pY(:,1), []);
fpY(:,2) = lsim(sys, pY(:,2), []);
fpY(:,3) = lsim(sys, pY(:,3), []);
fpY(:,4) = lsim(sys, pY(:,4), []);



% ppY = zeros(length(mY(:,1)),4);
% powAcc = zeros(1000,4);
% for i = 1:length(mY(:,1))
%     powAcc(:,1) = [pY(i,1); powAcc(1:end-1, 1)];
%     powAcc(:,2) = [pY(i,2); powAcc(1:end-1, 2)];
%     powAcc(:,3) = [pY(i,3); powAcc(1:end-1, 3)];
%     powAcc(:,4) = [pY(i,4); powAcc(1:end-1, 4)]; 
%     ppY(i,1) = sum(powAcc(:,1))/1000;
%     ppY(i,2) = sum(powAcc(:,2))/1000;
%     ppY(i,3) = sum(powAcc(:,3))/1000;
%     ppY(i,4) = sum(powAcc(:,4))/1000;
% end

npY = pY./max(pY); %normalized pY
%mY = mY./max(abs(mY));

%highpass
fY = zeros(length(mY(:,1)),4);
fc = 2000;
[n,d] = butter(3, fc/(48000/2), 'high');
sys = tf(n,d, 1/48000);
fY(:,1) = lsim(sys, mY(:,1), []);
fY(:,2) = lsim(sys, mY(:,2), []);
fY(:,3) = lsim(sys, mY(:,3), []);
fY(:,4) = lsim(sys, mY(:,4), []);

%lowpass
% fc = 8000;
% [n,d] = butter(2, fc/(48000/2), 'low');
% sys = tf(n,d, 1/48000);
% fY(:,1) = lsim(sys, fY(:,1), []);
% fY(:,2) = lsim(sys, fY(:,2), []);
% fY(:,3) = lsim(sys, fY(:,3), []);
% fY(:,4) = lsim(sys, fY(:,4), []);

mY=fY;

%mY = mY(1:10:end,:);



figure
plot(mY);


figure
plot(pY(:,3));
hold on
plot(fpY(:,3));


%%
len = length(mY(:,1));%48000;
%len = 96000;
d = ceil(48000/343);
signalAcc = zeros(10000,4);
crossAcc = zeros(2*d,3);
lags = zeros(len,3);
choords = zeros(len,2);
choords2 = zeros(len,2);
figure
for i=2:len
    %shift register
    signalAcc(:,1) = [mY(i,1); signalAcc(1:end-1,1)]; 
    signalAcc(:,2) = [mY(i,2); signalAcc(1:end-1,2)]; 
    signalAcc(:,3) = [mY(i,3); signalAcc(1:end-1,3)]; 
    signalAcc(:,4) = [mY(i,4); signalAcc(1:end-1,4)]; 

    %crosscorrelation
    crossAcc(:,1) = mycrossCorre(crossAcc(:,1), signalAcc(:,2),signalAcc(:,1),floor(length(crossAcc(:,1))/2)); % crosscorr mic 2 and 1
    crossAcc(:,2) = mycrossCorre(crossAcc(:,2), signalAcc(:,3),signalAcc(:,2),floor(length(crossAcc(:,2))/2)); % mic 3 and 2
    crossAcc(:,3) = mycrossCorre(crossAcc(:,3), signalAcc(:,3),signalAcc(:,4),floor(length(crossAcc(:,3))/2)); % mic 3 and 4
    %max correlation index
    lags(i,1) = myMax(crossAcc(:,1)) -length(crossAcc(:,1))/2;
    lags(i,2) = myMax(crossAcc(:,2)) -length(crossAcc(:,1))/2;
    lags(i,3) = myMax(crossAcc(:,3)) -length(crossAcc(:,1))/2;
    
    %gateing
%     if pY(i,2) < 25000 && i>1
%         lags(i,1) = lags(i-1,1) + 0.2*(lags(i,1)-lags(i-1,1));
%         lags(i,2) = lags(i-1,2) + 0.2*(lags(i,2)-lags(i-1,2));
%     end
%     if pY(i,3) < 25000 && i>1
%         lags(i,3) = lags(i-1,3) + 0.2*(lags(i,3)-lags(i-1,3));
%         lags(i,2) = lags(i-1,2) + 0.2*(lags(i,2)-lags(i-1,2));
%     end
%     if fpY(i,2) > pY(i,2) && i>1
%         lags(i,1) = lags(i-1,1) + 0.1*(lags(i,1)-lags(i-1,1));
%         lags(i,2) = lags(i-1,2) + 0.1*(lags(i,2)-lags(i-1,2));
%     end
%     if fpY(i,3) > pY(i,3) && i>1
%         lags(i,3) = lags(i-1,3) + 0.1*(lags(i,3)-lags(i-1,3));
%         lags(i,2) = lags(i-1,2) + 0.1*(lags(i,2)-lags(i-1,2));
%     end
%     if (fpY(i,2) > pY(i,2) || pY(i,2) < 20000) && i>1
%         lags(i,1) = lags(i-1,1);% + 0.01*sign(lags(i,1) -lags(i-1,1));
%         lags(i,2) = lags(i-1,2);% + 0.01*sign(lags(i,2) -lags(i-1,2));
%     end
%     if (fpY(i,3) > pY(i,3) || pY(i,3) < 20000) && i>1
%         lags(i,3) = lags(i-1,3);% + 0.01*sign(lags(i,3) -lags(i-1,3));
%         lags(i,2) = lags(i-1,2);% + 0.01*sign(lags(i,2) -lags(i-1,2));
%     end
%     if (fpY(i,2) < fpY(i-1,2) || fpY(i,2) < 300000)&& i>1
%         lags(i,1) = lags(i-1,1);% + 0.01*sign(lags(i,1) -lags(i-1,1));
%         lags(i,2) = lags(i-1,2);% + 0.01*sign(lags(i,2) -lags(i-1,2));
%     end
%     if (fpY(i,3) < fpY(i-1,3)|| fpY(i,3) < 300000)&& i>1
%         lags(i,3) = lags(i-1,3);% + 0.01*sign(lags(i,3) -lags(i-1,3));
%         lags(i,2) = lags(i-1,2);% + 0.01*sign(lags(i,2) -lags(i-1,2));
%     end

    if sum(fpY(i,:)) < sum(fpY(i-1,:))
        lags(i,1) = lags(i-1,1) + 0.01*sign(lags(i,1) -lags(i-1,1));
        lags(i,2) = lags(i-1,2) + 0.01*sign(lags(i,2) -lags(i-1,2));
        lags(i,3) = lags(i-1,3) + 0.01*sign(lags(i,3) -lags(i-1,3));
    end

end
%%
fc = 1;
[n,d] = butter(2, fc/(48000/2), 'low');
sys = tf(n,d, 1/48000);
lags(:,1) = lsim(sys, lags(:,1), []);
lags(:,2) = lsim(sys, lags(:,2), []);
lags(:,3) = lsim(sys, lags(:,3), []);


for i=2:len

    choords(i,:) = positionSolver(lags(i,2),lags(i,3), [3,2], [3,4]); 
    choords(i,1) = choords(i,1) +0.5;
    choords2(i,:) = positionSolver(lags(i,1),-lags(i,2), [2,1], [2,3]); 
    choords2(i,1) = choords2(i,1) -0.5;
 
%      if mod(i,1000) == 1
%         hold on;
%         n=1;
%         %plot3(crossAcc(:,1), (1:length(crossAcc(:,1)))-ceil(length(crossAcc(:,1))/2),i*ones(length(crossAcc(:,1)),1), 'black');
%         plot3(crossAcc(:,n), (1:length(crossAcc(:,n)))-ceil(length(crossAcc(:,n))/2),(i/48000)*ones(length(crossAcc(:,n)),1), 'color', [npY(i,3), npY(i,3), 0]);
%         [A,I] = max(crossAcc(:,n));
%         plot3(A,I-ceil(length(crossAcc(:,n))/2),i/48000, 'o');
%     end
end



choords(choords > 5) = 5;
choords(choords < -5) = -5;
choords(isnan(choords)) = 0;
choords2(choords2 > 5) = 5;
choords2(choords2 < -5) = -5;
choords2(isnan(choords2)) = 0;

figure
plot(choords);
hold on
plot(choords2)



figure
hold on
plot(lags(:,1))
plot(lags(:,2))
plot(lags(:,3))


% deltaX = 0.0001; % panning accumulator
% deltaY = 0.00001; 
% choords(1,:) = [0, 0];
% for i=2:length(choords(:,1))
%     if choords(i,1) > choords(i-1,1)
%         choords(i,1) = choords(i-1,1) + deltaX;
%     elseif choords(i,1) < choords(i-1,1)
%         choords(i,1) = choords(i-1,1) - deltaX;
%     end
% 
% 
%     if choords(i,2) > choords(i-1,2)
%         choords(i,2) = choords(i-1,2) + deltaY;
%     elseif choords(i,2) < choords(i-1,2)
%         choords(i,2) = choords(i-1,2) - deltaY;
%     end
% end
%%
% choords(choords > 5) = 5;
% choords(choords < -5) = -5;
% choords(isnan(choords)) = 0;
% fc = 1;
% [n,d] = butter(2, fc/(48000/2), 'low');
% sys = tf(n,d, 1/48000);
% choords(:,1) = lsim(sys, choords(:,1), []);
% choords(:,2) = lsim(sys, choords(:,2), []);
% 
spY= zeros(1,len);
for i=1:len
    spY(i) = sum(fpY(i,:));
end
figure(8)
plot(spY)
hold on
plot(mY*10^3)

%%

figure
plot(choords);


figure
distrobutionPlot(choords(:,1), choords(:,2))
hold on
distrobutionPlot(choords2(:,1), choords2(:,2))





% ***************functions*******************

function XY=positionSolver(lag1, lag2, index1, index2)
    delay1 = 343*lag1/48000;
    delay2 = 343*lag2/48000;

    A = index1(2) - index1(1);
    B = (index2(2) - index2(1));

    x = -(B^2/delay2 - delay2- A^2/delay1 + delay1)/(2*(A/delay1 - B/delay2));
    
    %D = ((-2*A-2*B)*x+ A^2 + B^2 - delay1^2 - delay2^2)/(2*(delay1 + delay2));
    D = (-2*x*A + A^2 - delay1^2)/(2*delay1);
       
    y = (D^2 - x^2);
    if y<0
        y = abs(y);
    end
    y = sqrt(y);
    %x = 3 -2.5 + x;

    XY(1) = x;
    XY(2) = y;
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



function Y = myMax(X)
    m = 0;
    i = 0;
    for a=1:length(X)
        if X(a) >= m
            m = X(a);
            i = a;
        end
    end
    Y=i;
end



% plot function

function distrobutionPlot(X,Y)  
    figure(10)
    xMax = 2;
    yMax = 4;
    
    res = 20;
    XY = zeros(res*yMax,2*res*xMax);

    x = round(X.*res);
    y = round(Y.*res);
    %plot(y)
    x(x>xMax*res) = xMax*res;
    x(x<=-xMax*res) = -xMax*res +1;
    x(isnan(x)) = 0;
    y(y>=yMax*res) = yMax*res-1;
    y(y<0) = 0;
    y(isnan(y)) = 0;

    for i=1:length(X)
        x(i);
        y(i);
        XY(y(i)+1,x(i)+xMax*res) = XY(y(i)+1,x(i)+xMax*res)+1;
    end
    sf=surf(XY);
    XD = get(sf, 'XData');
    YD = get(sf, 'YData');
    ZD = get(sf, 'ZData');

    figure(11)
    hold on
    surf(XD/res -xMax, YD/res, ZD)
end
