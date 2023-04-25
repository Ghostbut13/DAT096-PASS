clc, close all, clear all


res=8;
xMax = 10;
yMax = 10;

d = ceil(48000/343);
lags=-d:d;
lags(1) = -139.9;
lags(end) = 139.9; % manually enter max lags as ceil is to much but floor would remove them.

LUT = generateLUT(xMax, yMax,res, lags, 1);

d = 2*ceil(48000/343);
lags=-d:d;
lags(1) = 2*-139.9;
lags(end) = 2*139.9; % manually enter max lags as ceil is to much but floor would remove them.

LUT2 = generateLUT(xMax, yMax,res, lags, 2);


% surf(LUT(:,:,1)')
% surf(LUT(:,:,200)')

%%
load("Ether_Channel_3(1m_80dB_8s)");


micDistance = 1; % meters
len = length(mY(:,1));%48000;
len = 12000;
d = ceil(48000/343);
signalAcc = zeros(1000,4);
crossAcc = zeros(4*d,6);
lags = zeros(len,6);
XY = zeros(len,2);
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
    
    
    [XYc, ~] = LUTCoordinate(lags(i, 1:5), res, LUT, LUT2, xMax, yMax);
    XY(i,:) = XYc;
end


plot(XY(:,1), XY(:,2));
%%

distributionPlot(XY(:,1), XY(:,2))



%% 18    74   105    89   177   193
% [XY, array] = LUTCoordinate([18, 74, 105, 89, 177, 193], res, LUT, LUT2, xMax, yMax);
% plotArray(array', xMax, yMax, res)


%
% close all
% A = LUT(:,:,1);
% for i= 2:length(LUT(1,1,:))
%     A = A + LUT(:,:,i);
% end
% surf(A);
% figure
% A = LUT2(:,:,1);
% for i= 2:length(LUT2(1,1,:))
%     A = A + LUT2(:,:,i);
% end
% surf(A);

function [XY, array]=LUTCoordinate(delay, res, LUT, LUT2, xMax, yMax)
    array = zeros(2*2^res,2^res);
    m = -1;
    array = addLineArray(array, LUT, delay(1)-1, m, res, xMax, 140);
    m = 0;
    array = addLineArray(array, LUT, delay(2)-1, m, res, xMax, 140);
    m = 1;
    array = addLineArray(array, LUT, delay(3)-1, m, res, xMax, 140);
    m = -0.5;
    array = addLineArray(array, LUT2, delay(4)-1, m, res, xMax, floor(length(LUT2(1,1,:))/2));
    m = 0.5;
    array = addLineArray(array, LUT2, delay(5)-1, m, res, xMax, floor(length(LUT2(1,1,:))/2));

    % Get coordinates from max point in array
    [A,X] = max(array);
    [A,Y] = max(A);
    X = X(Y);
    X = (X/(2^res))*xMax -xMax;
    Y = (Y/(2^res))*yMax;
    
    XY = [2*X, Y];
    array = array;
end

function plotArray(array, xMax, yMax, res)
    figure(100)
    sf=surf(array);
    XD = get(sf, 'XData');
    YD = get(sf, 'YData');
    ZD = get(sf, 'ZData');
    close
    %figure(11)
    hold on
    surf(2*XD/(2^res) * xMax -2*xMax, YD/(2^res) * yMax, ZD)
end


function A=addLineArray(array, LUT, lag, m,res, xMax, maxLag)
    dx = (m+xMax)*(2^res / (2*xMax)) +1;
    dx = floor(dx);
    array(dx:dx+(2^res -1), :) = array(dx:dx+(2^res -1), :) + LUT(:,:,lag+maxLag +1);
    A = array;
end


function A=generateLUT(xMax, yMax, res, lags, micD)
    
    LUT = [];
    for i=1:length(lags)
        lag = lags(i);
        delay = 343.*lag./48000;
    
        B = liner(delay, micD);
        LUT = addLagLUT(LUT, B, res, xMax,yMax);
    end
    LUT(:,:,1) = [];
    A = LUT;
end


function A=addLagLUT(array, choords, res, xMax, yMax)
   %takes coordinate vector and assembles it down to a fixed
   %resoultion grid, aka rasterize the coordinate vector.

    res = 2^res;
    X = choords(:,1);
    Y = choords(:,2);

    % remove zeros
    X(Y==0) = [];
    Y(Y==0) = [];

    Y(abs(X)>=xMax) = [];
    X(abs(X)>=xMax) = [];
    X(Y>=yMax) = [];
    Y(Y>=yMax) = [];
    X(Y<0) = [];
    Y(Y<0) = [];
    


    % normalize
    X=(X/xMax +1)/2;
    Y=Y/yMax; 

    X= floor(X*(res-1)+1);
    Y= floor(Y*(res-1)+1);
    %X=X+1;
    %Y=Y+1;

    XY = zeros(res,res);

    for i = 1:length(X)
        XY(X(i),  Y(i)) = 1+ XY(X(i),  Y(i));
    end

    array(:,:,end+1) = XY;
    A = array;
end


function XY=liner(delay, micD)
% creates vector with coordinates corrisponding to the 'valid' line
    dx = micD;
    if delay < 0
       delay = -delay;
       dx = -dx;
    end
    n=10000;
    a = linspace(micD/2-delay, 12, n);
    %a(a<0) = [];
    chords= zeros(n,2);
    for i=1:length(a)
        chords(i,:) = choordFinder(a(i), delay, micD);
        chords(i,1) = chords(i,1)*sign(dx);
    end
    hold on
    XY = [chords(:,1)-dx/2, chords(:,2)];
end

function XY=choordFinder(A, delay, micD)
 % https://mathworld.wolfram.com/Circle-CircleIntersection.html
    R = A+delay;
    r = A;
    d= micD;
    x = (d^2 -r^2 + R^2)/(2*d);
    y2 =( 4*d^2 *R^2 -(d^2 - r^2 + R^2)^2 )/(4* d^2);
    if y2<0 
        y2 = 0;
        x = 0;
    end
    y = sqrt(y2);
    XY = [micD-x,y];
end

function distributionPlot(X,Y)  
    figure(100)
    xMax = 11;
    yMax = 11;
    
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
    close
    %figure(11)
    hold on
    surf(XD/res -xMax, YD/res, ZD)
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

