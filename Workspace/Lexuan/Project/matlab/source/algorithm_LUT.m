close all

d = ceil(48000/343);
lags=-d:d;
lags(1) = -139.9;
lags(end) = 139.9; % manually enter max lags as ceil is to much but floor would remove them.
% Xs = [];
% Ys = [];

LUT = [];
for i=1:2*d +1
    lag = lags(i);
    delay = 343.*lag./48000;
    
    A = liner(delay, [2,3], 1);
    LUT = addLagArray(LUT, A, 256/20, 10,10);
end
LUT(:,:,1) = [];
% surf(LUT(:,:,1)')
% surf(LUT(:,:,200)')
%%
array = zeros(512,256);
m = 1;
dx = (m+9-1.5)*256/20;
dx = round(dx);
lag = -90;
array(dx:dx+255, :) = array(dx:dx+255, :) + LUT(:,:,lag+141);

m = 2;
dx = (m+9-1.5)*256/20;
dx = round(dx);
lag = 60;
array(dx:dx+255, :) = array(dx:dx+255, :) + LUT(:,:,lag+141);


m = 3;
dx = (m+9-1.5)*256/20;
dx = round(dx);
lag = 100;
array(dx:dx+255, :) = array(dx:dx+255, :) + LUT(:,:,lag+141);


m = 4;
dx = (m+9-1.5)*256/20;
dx = round(dx);
lag = 130;
array(dx:dx+255, :) = array(dx:dx+255, :) + LUT(:,:,lag+141);


surf(array')


function A=addLagArray(array, choords, res, xMax, yMax)
    X = choords(:,1);
    Y = choords(:,2);
    X(Y==0) = [];
    Y(Y==0) = [];
    
    X= round(X*res);
    Y= round(2*Y*res);
    Y=Y+1;

    XY = zeros(2*res*xMax,2*res*yMax);

    for i = 1:length(X)
        if abs(X(i)) < xMax*res && Y(i)> 0 && Y(i) < 2*yMax*res 
            XY( X(i)  + xMax*res,  Y(i) ) = 1+ XY( X(i)  + xMax*res,  Y(i) );
        end
    end

    array(:,:,end+1) = XY;
    A = array;
end


function XY=liner(delay, mics, micD)
    if delay < 0
       delay = -delay;
       mics = [mics(2), mics(1)];
    end
    dx = -(mics(1) - mics(2))*micD;
    n=10000;
    a = linspace(0, 10, n);
    chords= zeros(n,2);
    for i=1:n
        chords(i,:) = choordFinder(a(i), delay, dx);
    end
    hold on
    %plot3(chords(:,1)+mics(1)*micD-2.5, chords(:,2), z*ones(length(chords(:,1)),1) ,color);
    XY = [chords(:,1)+mics(1)*micD-2.5, chords(:,2)];
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

function distrobutionPlot(X,Y)  
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
