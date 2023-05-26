clc, clear all, close all
% one actor
[stereoY, Fs] = audioread("test_dialog_mono.wav");
Y = stereoY(:,1);

% two actors
% [stereoY, Fs] = audioread("test_dialog_superStereo.wav");
% Y = stereoY(:,:); 

% test sinewave{
% Fs = 48000;
% f= 440;
% f = 2000;
% f = 10;
% f=4000;
% len = 62767*20;
% Y = sin(linspace(0,f*2*pi*len/Fs, len))';% +0.01*randn(len,1);
% }

m = max(abs(Y));
m = max(m);
Y = Y./(2*m);

% plot original sound file {
    figure
    plot(Y);
    xlabel("Time [sample]");
    ylabel("Amplitude");
    title("Original sound from actors")
% } end of plot

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
actorX = ones(length(Y(:,1)), length(Y(1,:)));
actorY = ones(length(Y(:,1)), length(Y(1,:)));
len= length(actorX(:,1));
for i=1:len
    % actor moving in Y from 3 to 1
%     actorX(i,1) = 0;%-1.5 + 3.*(i/len);
%     actorY(i,1) = 3-2.*(i/len);

    % actor moving in X from -1.5 to 1.5
%     actorX(i,1) = -1.5 + 3.*(i/len);
%     actorY(i,1) = 2;

    % actor moving in X from -2 to 2
    actorX(i,1) = -2 + 4.*(i/len);
    actorY(i,1) = 2;
    
    
    % second actor
    if length(Y(1,:)) > 1
        actorX(i,2) = 2 - 4.*(i/len);
        actorY(i,2) = 1.5 - 0.1*sin((i/len));
    end
end

% plot stage {
    for i=1:length(actorX(1,:))
        plot(actorX(:,1), actorY(:,1), 'xred', 'linewidth', 2);
        if length(Y(1,:)) > 1
            plot(actorX(:,2), actorY(:,2), 'xgreen', 'linewidth', 2);
        end
    end
    quiver(actorX(round(len/3),1),0.2+actorY(round(len/3),1), actorX(round(2*len/3),1)-actorX(round(len/3),1), actorY(round(2*len/3),1)-actorY(round(len/3),1), 'black')
    if length(Y(1,:)) > 1
        quiver(actorX(round(len/3),2),0.2+actorY(round(len/3),2), actorX(round(2*len/3),2)-actorX(round(len/3),2), actorY(round(2*len/3),2)-actorY(round(len/3),2), 'black')
    end
    axis(micDist.*[-2.5, 2.5, -0.5, 2.5])
    title("Stage")
    xlabel("Position [m]");
    ylabel("Position [m]");
    if length(Y(1,:)) > 1
        legend("Microphones","Actor 1" , "Actor 2");
    else
        legend("Microphones","Actor");
    end
    grid on;
% } end plot stage

% plot XY position over time {
    figure
    plot(actorX(:,1));
    hold on
    plot(actorY(:,1));
    grid on
    xlabel("time (sample)")
    ylabel("position (m)")
    legend("X","Y")
    axis([0, len,-3,3])
    title("XY position over time")
% } end of plot



% Simulate stage
mY = zeros(length(Y(:,1)),4);

minAttenuation =0;
att = zeros(len,4);
for b=1:len % for every sample in the sound file

    for i=1:4 % for each microphone
        for a=1:length(Y(1,:)) % for each actor
            distance = (actorX(b,a)-micCordX(i))^2;
            distance = distance + (actorY(b,a)-micCordY(i))^2;
            distance = sqrt(distance);
            delayFs = Fs*distance/343;
%             attenuation =1/ distance; % linear attenuation
            attenuation =1/(distance^2); %square attenuation
            att(b,i) = attenuation;
            if(b+delayFs < len) %linear interpolate the sample when delay is non integer
                mY(b+floor(delayFs),i) = mY(b+floor(delayFs),i)+ (1-mod(delayFs,1))*attenuation*Y(b,a);
                mY(b+ceil(delayFs),i) = mY(b+ceil(delayFs),i)+ (mod(delayFs,1))*attenuation*Y(b,a);
            end
            if(attenuation > minAttenuation)
                minAttenuation = attenuation; 
            end
        end
    end
end

% plot microphone loudness index {
    figure
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
% } end of plot

% plot of output sound{
    figure
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
% } end of plot

% play sound
% sound(mY(:, [1,4]), Fs)



