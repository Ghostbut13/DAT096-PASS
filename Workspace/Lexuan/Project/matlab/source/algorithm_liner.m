clc,close all, clear all
%run("soundstage2.m")
close all
load("Ether_Channel_3(1m_80dB_8s)");


micDistance = 1; % meters


len = length(mY(:,1));%48000;
%len = 12000;
d = ceil(48000/343);
signalAcc = zeros(1000,4);
crossAcc = zeros(4*d,6);
lags = zeros(len,6);
for i=2:len
    %shift register
    signalAcc(:,1) = [mY(i,1); signalAcc(1:end-1,1)]; 
    signalAcc(:,2) = [mY(i,2); signalAcc(1:end-1,2)]; 
    signalAcc(:,3) = [mY(i,3); signalAcc(1:end-1,3)]; 
    signalAcc(:,4) = [mY(i,4); signalAcc(1:end-1,4)]; 

    %crosscorrelation
    crossAcc(:,1) = mycrossCorre(crossAcc(:,1), signalAcc(:,1),signalAcc(:,2),floor(length(crossAcc(:,1))/2)); % crosscorr mic 1 and 2
    crossAcc(:,2) = mycrossCorre(crossAcc(:,2), signalAcc(:,2),signalAcc(:,3),floor(length(crossAcc(:,2))/2)); % mic 2 and 3
    crossAcc(:,3) = mycrossCorre(crossAcc(:,3), signalAcc(:,3),signalAcc(:,4),floor(length(crossAcc(:,3))/2)); % mic 3 and 4
    crossAcc(:,4) = mycrossCorre(crossAcc(:,4), signalAcc(:,1),signalAcc(:,3),floor(length(crossAcc(:,4))/2)); % crosscorr mic 1 and 3
    crossAcc(:,5) = mycrossCorre(crossAcc(:,5), signalAcc(:,2),signalAcc(:,4),floor(length(crossAcc(:,5))/2)); % mic 2 and 4
    crossAcc(:,6) = mycrossCorre(crossAcc(:,6), signalAcc(:,1),signalAcc(:,4),floor(length(crossAcc(:,6))/2)); % mic 1 and 4
    
    %max correlation index
    lags(i,1) = myMax(crossAcc(d:3*d,1)) -d;
    lags(i,2) = myMax(crossAcc(d:3*d,2)) -d;
    lags(i,3) = myMax(crossAcc(d:3*d,3)) -d;
    lags(i,4) = myMax(crossAcc(:,4)) -2*d;
    lags(i,5) = myMax(crossAcc(:,5)) -2*d;
    lags(i,6) = myMax(crossAcc(:,6)) -2*d;
    
    
end
%%
delta = 0.01;
delay = lags;
for i=2:len
    for a = 1:3
        delay(i,a) = delay(i-1,a) + delta*sign(delay(i,a)-delay(i-1,a));
    end
end
delay = lags;


delay = 343.*delay./48000;

%%
%figure
%hold on
close all
for i=10:1000:length(delay(:,1))
    z=i/length(delay(:,1));
    figure
    A = linePlot3d(delay(i,1), [1,2], micDistance,z, 'r');
    hold on
    B = linePlot3d(delay(i,2), [2,3], micDistance,z, 'g');
    hold on
    C = linePlot3d(delay(i,3), [3,4], micDistance,z, 'b');
    hold on
    %linePlot3d(delay(i,4), [1,3], micDistance,z, 'm');
    hold on
    %linePlot3d(delay(i,5), [2,4], micDistance,z, 'y'); %
    hold on
    %linePlot3d(delay(i,6), [1,4], micDistance,z, 'c'); %
    hold on
    figure
    X = [A(:,1); B(:,1); C(:,1)];
    Y = [A(:,2); B(:,2); C(:,2)];
    distrobutionPlot(X,Y)
    if i > 11
       break; 
    end
end

%axis([-20,20,0,20,0,1])

% figure;
% hold on;
% linePlot(delay(1), [1,2], micDistance);
% linePlot(delay(2), [2,3], micDistance);
% linePlot(delay(3), [3,4], micDistance);

function XY=linePlot3d(delay, mics, micD,z, color)
    if delay < 0
       delay = -delay;
       mics = [mics(2), mics(1)];
    end
    dx = -(mics(1) - mics(2))*micD;
    n=100;
    a = linspace(0.01, 10, n);
    chords= zeros(n,2);
    for i=1:n
        chords(i,:) = choordFinder(a(i), delay, dx);
    end
    hold on
    plot3(chords(:,1)+mics(1)*micD-2.5, chords(:,2), z*ones(length(chords(:,1)),1) ,color);
    XY = [chords(:,1)+mics(1)*micD-2.5, chords(:,2)];
end


function linePlot(delay, mics, micD)
    dx = -(mics(1) - mics(2))*micD;
    n=100;
    a = linspace(0, 10, n);
    chords= zeros(n,2);
    for i=1:n
        chords(i,:) = choordFinder(a(i), delay, dx);
    end
    plot(chords(:,1)+mics(1)*micD -2.5,chords(:,2));
end

function XY=choordFinder(A, delay, micD)
 % https://mathworld.wolfram.com/Circle-CircleIntersection.html
    R = A+delay;
    r = A;
    d= micD;
    x = (d^2 -r^2 + R^2)/(2*d);
    y2 =( 4*d^2 *R^2 -(d^2 - r^2 + R^2)^2 )/(4* d^2);
    y2(y2<0) = 0;
    y = sqrt(y2);
    XY = [micD-x,y];
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

function distrobutionPlot(X,Y)  
    figure(10)
    xMax = 4;
    yMax = 20;
    
    res = 5;
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
