clc, clear all, close all
[stereoY, Fs] = audioread("test_dialog_mono.wav");
Y = stereoY(:,1);
m = max(abs(Y));
m = max(m);
Y = Y./(2*m);


figure(1)
title("Original sound from actors")
plot(Y);
xlabel("Time [sample]");
ylabel("Amplitude");

% Setup of stage
figure(2)
micDist = 1; % distance between microphones (meters).
micCordX = micDist.*[-1.5, -0.5, 0.5, 1.5];
micCordY = [ 0,    0,   0,   0];
plot(micCordX, micCordY, 'Xblue', 'linewidth', 2);
hold on
for i=1:4
    text(micCordX(i)-0.3, micCordY(i)-0.2, 'Index: ' + string(i))
end


% Animate actor
actorX = ones(length(Y(:,1)), 2);
actorY = ones(length(Y(:,1)), 2);
len= length(actorX(:,1));
for i=1:len
    actorX(i,1) = -2 + 4.*(i/len);
    actorY(i,1) = 2;% - 0.1*sin((i/len));
    actorX(i,2) = -2 + 4.*(i/len);
    actorY(i,2) = 2 - 0.1*sin((i/len));
    %Y(i,1) = 0.1*sin(440*i/Fs);
end
for i=1:length(actorX(1,:))
    plot(actorX(:,1), actorY(:,1), 'xred', 'linewidth', 2);
end
quiver(actorX(round(len/3),1),0.2+actorY(round(len/3),1), actorX(round(2*len/3),1)-actorX(round(len/3),1), actorY(round(2*len/3),1)-actorY(round(len/3),1), 'black')

axis(micDist.*[-2.5, 2.5, -0.5, 2.5])
title("Stage")
xlabel("Position [m]");
ylabel("Position [m]");
legend("Microphones","Actor");
grid on;

% Simulate stage
mY = zeros(length(Y(:,1)),4);

minAttenuation =0;
figure(3)

att = zeros(len,4);
for b=1:len % for every sample in the sound file

    for i=1:4 % for each microphone
        for a=1:length(Y(1,:)) % for each actor
            distance = (actorX(b,a)-micCordX(i))^2;
            distance = distance + (actorY(b,a)-micCordY(i))^2;
            distance = sqrt(distance);
            delayFs = Fs*distance/343;
            attenuation = distance^-2;
            att(b,i) = attenuation;
            if(b+delayFs < len)
                mY(b+floor(delayFs),i) = mY(b+floor(delayFs),i)+ (1-mod(delayFs,1))*attenuation*Y(b,a);
                mY(b+ceil(delayFs),i) = mY(b+ceil(delayFs),i)+ (mod(delayFs,1))*attenuation*Y(b,a);
            end
            if(attenuation > minAttenuation)
                minAttenuation = attenuation; 
            end
        end
    end
end

for b=1:10000:len

    subplot(3,1,1)
    hold on;
    [A,I] = max(att(b,:));
    plot(b,I, 'xblue');
    att(b,I) = 0;
    subplot(3,1,2)
    hold on;
    [A,I] = max(att(b,:));
    plot(b,I, 'xblue');
    att(b,I) = 0;
    subplot(3,1,3);
    hold on;
    [A,I] = max(att(b,:));
    plot(b,I, 'xblue');
end
subplot(3,1,1);
title("Loudest microphone");
ylabel("# Mic");
xlabel("time [sample]")
grid on;
subplot(3,1,2);
title("Second loudest microphone");
ylabel("# Mic");
xlabel("time [sample]")
grid on;
subplot(3,1,3);
title("Third loudest microphone");
ylabel("# Mic");
xlabel("time [sample]")
grid on;


% mY=mY./minAttenuation; % auto gain

figure(5)
hold on
m=floor(max(max(abs(mY))) * 10)/10;
for i=1:length(mY(1,:))
    subplot(4,1,i);
    plot(mY(:, i), 'blue');
    axis([1,len,-m,m])
    title("#" + i + " Microphone");
    ylabel("Amplitude");
    xlabel("Time [sample]");
    grid on;
end
%sound(mY(:, [1,4]), Fs)

