%%
clc ,clear all, close all


ActorX = -0.9;
ActorY = 2.5;
d=1;
MicrophonesX = d.*[-1.5, -0.5, 0.5, 1.5];
MicrophonesY = [0, 0, 0, 0];

plot(MicrophonesX, MicrophonesY, 'x', 'linewidth', 2, 'color', 'black');

hold on;
plot(ActorX, ActorY, 'x', 'linewidth', 2, 'color', 'black');

plot([ActorX, MicrophonesX(1)],[ActorY, MicrophonesY(1)], 'color', 'red');
plot([ActorX, MicrophonesX(2)],[ActorY, MicrophonesY(2)], 'color', 'green');
plot([ActorX, MicrophonesX(3)],[ActorY, MicrophonesY(3)], 'color', 'cyan');

axis([-2,2,-0.5,3])

text(MicrophonesX(2) -0.25,MicrophonesY(2) -0.2, 'Loudest microphone')
text(MicrophonesX(1) -0.25,MicrophonesY(1) -0.2, '2nd loudest microphone')
text(MicrophonesX(3) -0.25,MicrophonesY(3) -0.2, '3rd loudest microphone')
%%


clc ,clear all, close all


ActorX = -0.9 +0.5;
ActorY = 2.5;
d=1;
MicrophonesX = d.*[-1.5, -0.5, 0.5, 1.5] +0.5;
MicrophonesY = [0, 0, 0, 0];


hold on
plot([ActorX, MicrophonesX(2)],[ActorY, MicrophonesY(2)], 'color', 'red');
plot([ActorX, MicrophonesX(1)],[ActorY, MicrophonesY(1)], 'color', 'green');
plot([ActorX, MicrophonesX(3)],[ActorY, MicrophonesY(3)], 'color', 'cyan');
legend('D','D + \Delta1','D + \Delta2', 'AutoUpdate', 'off')


plot(MicrophonesX, MicrophonesY, 'x', 'linewidth', 2, 'color', 'black');

plot(ActorX, ActorY, 'x', 'linewidth', 2, 'color', 'black');
text(ActorX +0.05 , ActorY +0.1, '(x,y)')


axis([-2,2,-0.5,3])

text(MicrophonesX(2) -0.25,MicrophonesY(2) -0.2, 'Loudest microphone')
text(MicrophonesX(2) +0.05,MicrophonesY(2) +0.1, '(0,0)')
text(MicrophonesX(1) -0.25,MicrophonesY(1) -0.2, '2nd loudest microphone')
text(MicrophonesX(1) +0.05 ,MicrophonesY(1) +0.1, '(M2 - M1,0)')
text(MicrophonesX(3) -0.25,MicrophonesY(3) -0.2, '3rd loudest microphone')
text(MicrophonesX(3) +0.05 ,MicrophonesY(3) +0.1, '(M3 - M1,0)')
text(MicrophonesX(4) -0.25,MicrophonesY(4) -0.2, '4th ignored')
xlabel('relative position [m]')
ylabel('relative position [m]')

%%
%Circle intersection
clc, clear all, close all
hold on
[x,y]= circle(0,0,0.75, 1000);
plot(x,y, 'r')
quiver(0,0,0.75*cos(pi/4),0.75*sin(pi/4), 0, 'r')
plot(0,0, 'kx')
[x,y]= circle(1,0,0.5, 1000);
plot(x,y, 'g')
quiver(1,0,0.5*cos(pi/4),0.5*sin(pi/4), 0, 'g')
plot(1,0, 'kx')
axis equal
grid on
XY = choordFinder(0.5, 0.25, 1);
plot(1-XY(1), XY(2), 'x', 'linewidth', 2, 'color', 'black');


text(0 +0.2,0+0.3, 'R')
text(1+0.2,0+0.3,'r')


%%
% LUT 1
clc ,clear all, close all


ActorX = -0.2;
ActorY = 1.5;
d=1;
MicrophonesX = d.*[-1.5, -0.5, 0.5, 1.5];
MicrophonesY = [0, 0, 0, 0];
d1 = sqrt( (MicrophonesX(2) -ActorX)^2 +(MicrophonesY(2) -ActorY)^2 );
d2 = sqrt( (MicrophonesX(3) -ActorX)^2 +(MicrophonesY(3) -ActorY)^2 );
lag = d2-d1;

hold on;

plot([ActorX, MicrophonesX(2)],[ActorY, MicrophonesY(2)], 'color', 'red');
plot([ActorX, MicrophonesX(3)],[ActorY, MicrophonesY(3)], 'color', 'green');


axis equal
axis([-1,1,-0.5,2])
grid on

text(MicrophonesX(2) -0.175,MicrophonesY(2) -0.2, 'Microphone 1')
text(MicrophonesX(3) -0.175,MicrophonesY(3) -0.2, 'Microphone 2')
text(ActorX -0.08, ActorY +0.2, 'Actor')

c = d1;
[x,y] = circle(ActorX,ActorY,c,1000);
plot(x,y, '--r');
[x,y] = circle(ActorX,ActorY,c+lag,1000);
plot(x,y, '--g');

plot(MicrophonesX(2:3), MicrophonesY(2:3), 'x', 'linewidth', 2, 'color', 'black');
plot(ActorX, ActorY, 'x', 'linewidth', 2, 'color', 'black');

xlabel("Position [m]")
ylabel("Position [m]")

%%
% LUT 2
clc ,clear all, close all


ActorX = -0.2;
ActorY = 1.5;
d=1;
MicrophonesX = d.*[-1.5, -0.5, 0.5, 1.5];
MicrophonesY = [0, 0, 0, 0];
d1 = sqrt( (MicrophonesX(2) -ActorX)^2 +(MicrophonesY(2) -ActorY)^2 );
d2 = sqrt( (MicrophonesX(3) -ActorX)^2 +(MicrophonesY(3) -ActorY)^2 );
lag = d2-d1;

hold on;

plot([ActorX, MicrophonesX(2)],[ActorY, MicrophonesY(2)], 'color', 'red');
plot([ActorX, MicrophonesX(3)],[ActorY, MicrophonesY(3)], 'color', 'green');


axis equal
axis([-1,1,-0.5,2])
grid on

text(MicrophonesX(2) -0.175,MicrophonesY(2) -0.2, 'Microphone 1')
text(MicrophonesX(3) -0.175,MicrophonesY(3) -0.2, 'Microphone 2')
text(ActorX -0.08, ActorY +0.2, 'Actor')

c = d1;
[x,y] = circle(MicrophonesX(2),MicrophonesY(2),c,1000);
plot(x,y, '--r');
[x,y] = circle(MicrophonesX(3),MicrophonesY(3),c+lag,1000);
plot(x,y, '--g');

plot(MicrophonesX(2:3), MicrophonesY(2:3), 'x', 'linewidth', 2, 'color', 'black');
plot(ActorX, ActorY, 'x', 'linewidth', 2, 'color', 'black');

xlabel("Position [m]")
ylabel("Position [m]")

%%
% LUT 3
clc ,clear all, close all


ActorX = -0.2;
ActorY = 1.5;
d=1;
MicrophonesX = d.*[-1.5, -0.5, 0.5, 1.5];
MicrophonesY = [0, 0, 0, 0];
d1 = sqrt( (MicrophonesX(2) -ActorX)^2 +(MicrophonesY(2) -ActorY)^2 );
d2 = sqrt( (MicrophonesX(3) -ActorX)^2 +(MicrophonesY(3) -ActorY)^2 );
lag = d2-d1;

hold on;

plot([ActorX, MicrophonesX(2)],[ActorY, MicrophonesY(2)], 'color', 'red');
plot([ActorX, MicrophonesX(3)],[ActorY, MicrophonesY(3)], 'color', 'green');


axis equal
axis([-1,1,-0.5,2])
grid on

text(MicrophonesX(2) -0.175,MicrophonesY(2) -0.2, 'Microphone 1')
text(MicrophonesX(3) -0.175,MicrophonesY(3) -0.2, 'Microphone 2')
text(ActorX -0.08, ActorY +0.2, 'Actor')

c = d1;
[x,y] = circle(MicrophonesX(2),MicrophonesY(2),c,1000);
plot(x,y, '--r');
[x,y] = circle(MicrophonesX(3),MicrophonesY(3),c+lag,1000);
plot(x,y, '--g');

s = 0.2;
c = c-s;
while c >= (1-lag)/2
    [x,y] = circle(MicrophonesX(2),MicrophonesY(2),c,1000);
    plot(x,y, '--m');
    [x,y] = circle(MicrophonesX(3),MicrophonesY(3),c+lag,1000);
    plot(x,y, '--c');
    XY=choordFinder(c, lag,1);
%     plot(XY(1)-0.5, XY(2), 'ko');
    plot(XY(1)-0.5, XY(2), 'kx');
    c = c -s;
end

XY = liner(lag,1);
plot(XY(:,1), XY(:,2), 'k--');

plot(MicrophonesX(2:3), MicrophonesY(2:3), 'x', 'linewidth', 2, 'color', 'black');
plot(ActorX, ActorY, 'x', 'linewidth', 2, 'color', 'black');

xlabel("Position [m]")
ylabel("Position [m]")

%%
% attenuation compensation
close all
y = linspace(0, 64, 1000);
g = y*bin2dec("1000");
g(g<bin2dec("000110010")) = 2^6;
plot(5*y/64,100*g/2^6)
xlabel("y (m)");
ylabel("gain (%)");

%%

function [x,y] = circle(X,Y,r,res)
    phi = linspace(0,2*pi,res);
    x = X + r*cos(phi);
    y = Y + r*sin(phi);
    
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

function XY=liner(delay, micD)
% creates vector with coordinates corrisponding to the 'valid' line
    dx = micD;
    if delay < 0
       delay = -delay;
       dx = -dx;
    end
    n=10000;
    a = linspace((micD-delay)/2, 12, n);
    %a(a<0) = [];
    chords= zeros(n,2);
    for i=1:length(a)
        chords(i,:) = choordFinder(a(i), delay, micD);
        chords(i,1) = chords(i,1)*sign(dx);
    end
    hold on
    XY = [chords(:,1)-dx/2, chords(:,2)];
end