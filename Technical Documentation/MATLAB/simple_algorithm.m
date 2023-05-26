%clc, clear all, close all

run("soundstageSim.m"); 
iY=mY;
close all

iY = abs(iY);

sY = iY;
n=100; % shift register size
iY=[zeros(n, length(iY(1,:))); iY]; % buffer signal with zeros

for i=n:len
    for a = 1:length(iY(1,:))
        sY(i,a) = mean(iY(i-n+1:i,a));
    end
end

% plot power {
    % figure
    % subplot(4,1,1);
    % plot(sY(:,1));
    % subplot(4,1,2);
    % plot(sY(:,2));
    % subplot(4,1,3);
    % plot(sY(:,3));
    % subplot(4,1,4);
    % plot(sY(:,4));
% } end of plot

phase = 2.5;
phaseA = zeros(1, len);
% delta = 0.0001;
delta = 2^-10;
out = zeros(1, len);

for i=1:len
    [A,I] = max(sY(i,:));
    if phase > I
        phase = phase - delta; 
    else
        phase = phase + delta;
    end
    
    if phase < 2
        out(i) = (phase-1)*mY(i,2) + (2-phase)*mY(i,1);
    elseif phase < 3
        out(i) = (phase-2)*mY(i,3) + (3-phase)*mY(i,2);
    else
        out(i) = (phase-3)*mY(i,4) + (4-phase)*mY(i,3);
    end
    phaseA(i) = phase;
end

% plot indexer in orange {
    figure
    plot(0,0) % change color to default matlab red/orange
    hold on
    plot(phaseA);
    xlabel("time (sample)")
    ylabel("Panning indexer")
    grid on
    axis([0,length(phaseA), 0, 4])
    tilte("Indexer")
% } end of plot


% plot indexer with zoomed window {
    figgy = figure;
    plot(phaseA, 'blue');
    grid on;
    tstart= 625000;
    tstop = 650000;
    margint=10000;
    marginY = 0.1;
    xlabel("time [Sample]")
    ylabel("Indexer");
    B = annotation('rectangle', 'LineStyle','--');
    B.Parent = figgy.CurrentAxes;
    B.Position = [tstart-margint, phaseA(tstart)-marginY, tstop-tstart+2*margint, phaseA(tstop) - phaseA(tstart)+2*marginY];
    a2 = axes();
    a2.Position = [0.2 0.65 0.2 0.2]; % xlocation, ylocation, xsize, ysize
    plot(a2,tstart:tstop,phaseA(tstart:tstop), 'blue');
    axis([tstart,tstop,phaseA(tstart)-marginY,phaseA(tstop)+marginY])
    grid on;
    title("Indexer")
% } end of plot



% plot output sound {
    figure
    plot(out);
    xlabel("time (sample)")
    tilte("Final output")
% } end of plot

% play sound:
% sound(mY(:, [1,4]), Fs)


