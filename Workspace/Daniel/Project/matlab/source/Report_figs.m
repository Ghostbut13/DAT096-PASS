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



