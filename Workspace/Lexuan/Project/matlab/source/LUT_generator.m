clc, clear all, close all

maxD = 5;
res=2^6;

%calculate the max vector size needed.
maxElem = 0;
for lag = 0.5:1/281:0.8
    AB = VectorLUT(lag, res/maxD, 1, maxD);
    if length(AB(:,1)) > maxElem
       maxElem = length(AB(:,1));
    end
end

%generate vectors
hold on
LUTv = zeros(maxElem, 2, 281);
for lag = -140:140
    
    delay = 343*lag/48000;
    AB = VectorLUT(delay, res/maxD, 1, maxD);
    LUTv(1:length(AB(:,1)), :, lag+141) = AB;
    plot(LUTv(:,1,lag+141),LUTv(:,2,lag+141));
end

save("LUTv", "LUTv")
%%
n=1; 
megaStr = "memory_initialization_radix=2; \n memory_initialization_vector = \n";%char(length(A)*140*95);
for lag=1:140
   if lag>1
        megaStr = megaStr + ", \n";
   end
   for i=1:95
        A = LUTv(i, 1, lag);
        B = LUTv(i, 2, lag);
        if A <0
            A = res-A;
        end
        if B <0
            B = res-A;
        end
        A(A>=res) = res-1;
        B(B>=res) = res-1;
        A = dec2bin(A, 6);
        B = dec2bin(B,6);
        if length(A) > 6
           Report = "AHHH"
           break;
        end
        if length(B) > 6
           Report = "BAHHH"
           break;
        end
        megaStr = megaStr + A + B;
   end
end

fileId = fopen("LUT.coe", 'w');
fprintf(fileId, megaStr);
fclose(fileId);


function XY=VectorLUT(delay, resolution, micD, maxD)
    AB = liner(delay, micD, maxD);
    AB = round(resolution*AB);%/resolution;
    XYv = [[0,0]];
    for a=1:length(AB(:,1))
        exist = 0;
        for b =1:length(XYv(:,1))
            if XYv(b,1) == AB(a,1) && XYv(b,2) == AB(a,2) 
                exist = 1;
            end
        end
        if exist == 0
            XYv = [XYv; AB(a,:)];
        end
    end
    XYv(XYv(:,1) > resolution*maxD, :) = [];
    XYv(XYv(:,1) < -resolution*maxD, :) = [];
    XY = XYv;
    
end



function XY=liner(delay, micD, maxD)
% creates vector with coordinates corrisponding to the 'valid' line
    dx = micD;
    if delay < 0
       delay = -delay;
       dx = -dx;
    end
    n=10000;
    a = linspace((micD-delay)/2, maxD, n);
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
    xMax = 6;
    yMax = 6;
    
    res = 8;
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


