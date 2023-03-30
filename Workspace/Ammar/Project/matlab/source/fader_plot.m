clc, clear all, close all

len=1000
indexer = linspace(0,5, len);
microphones = zeros(len,4);

microphones(:,1) = 1-abs(indexer.'-1);
microphones(:,2) = 1-abs(indexer.'-2);
microphones(:,3) = 1-abs(indexer.'-3);
microphones(:,4) = 1-abs(indexer.'-4);

%set negative values to zero
microphones(microphones<0) = 0;

microphones = 100.*microphones;

hold on
plot(indexer,microphones(:,1));
plot(indexer,microphones(:,2));
plot(indexer,microphones(:,3));
plot(indexer,microphones(:,4));
xlabel("Indexer");
ylabel("gain [%]");
legend("F1", "F2", "F3", "F4")
grid on

%
figure(2)
n = 101;
sinTab = 100*sin(linspace(0,pi/2, n));
plot(sinTab);
xlabel("Indexer in");
ylabel("Indexer out");
grid on;

%
figure(3)
microphones(:,1) = sinTab(round(microphones(:,1))+1);
microphones(:,2) = sinTab(round(microphones(:,2))+1);
microphones(:,3) = sinTab(round(microphones(:,3))+1);
microphones(:,4) = sinTab(round(microphones(:,4))+1);

hold on
plot(indexer,microphones(:,1));
plot(indexer,microphones(:,2));
plot(indexer,microphones(:,3));
plot(indexer,microphones(:,4));
xlabel("Indexer");
ylabel("gain [%]");
legend("F1", "F2", "F3", "F4")
grid on;