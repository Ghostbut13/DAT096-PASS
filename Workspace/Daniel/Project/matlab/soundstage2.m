clc, clear all, close all
[stereoY, Fs] = audioread("test_dialog_mono.wav");
Y = stereoY(:,1);

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
plot(micCordX, micCordY, 'X', 'linewidth', 2);
hold on

% Animate actor
actorX = ones(length(Y(:,1)), 2);
actorY = ones(length(Y(:,1)), 2);
len= length(actorX(:,1));
for i=1:len
    actorX(i,1) = -2 + 4.*(i/len);
    actorY(i,1) = 1 - 0.1*sin((i/len));
    actorX(i,2) = -2 + 4.*(i/len);
    actorY(i,2) = 1 - 0.1*sin((i/len));
    %Y(i,1) = 0.1*sin(440*i/Fs);
end
for i=1:length(actorX(1,:))
    plot(actorX(:,i), actorY(:,i), 'X', 'linewidth', 2);
end
axis(micDist.*[-2.5, 2.5, -0.5, 1.5])
title("Stage")
xlabel("Position [m]");
ylabel("Position [m]");
legend("Microphones","Actor");

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
    plot(b,I, 'ro');
    att(b,I) = 0;
    subplot(3,1,2)
    hold on;
    [A,I] = max(att(b,:));
    plot(b,I, 'ro');
    att(b,I) = 0;
    subplot(3,1,3);
    hold on;
    [A,I] = max(att(b,:));
    plot(b,I, 'ro');
end
subplot(3,1,1);
title("Loudest microphone");
ylabel("# Mic");
subplot(3,1,2);
title("Second loudest microphone");
ylabel("# Mic");
subplot(3,1,3);
title("Third loudest microphone");
ylabel("# Mic");

mY=mY./minAttenuation; % auto gain
figure(4)
hold on
for i=1:length(mY(1,:))
    subplot(4,1,i);
    plot(mY(:, i));
    axis([1,len,-0.1,0.1])
    title("#" + i + " Microphone");
    ylabel("Amplitude");
    xlabel("Time [sample]");
end
%sound(mY(:, [1,4]), Fs)

