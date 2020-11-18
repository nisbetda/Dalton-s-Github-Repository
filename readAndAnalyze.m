close all;
clear all;
clc;

threads = 10;
samples = threads*1;

T = readtable('BreathingData10_5sec.txt');

time = table2array(T(1,1:samples));
pos = table2array(T(:,samples+1:samples*2));
dist = zeros(1,samples);
for i = 1:samples
    dist(i) = sqrt(pos(1,i)^2 + pos(2,i)^2 + pos(3,i)^2);
end
vel = table2array(T(:,samples*2+1:samples*3));
fvel = zeros(1,samples);
for i = 1:samples
    fvel(i) = sqrt(vel(1,i)^2 + vel(2,i)^2 + pos(3,i)^2);
end

avgtime = mean(time)
stdtime = std(time)
avgdist = mean(dist)
stddist = std(dist)
avgfvel = mean(fvel)
stdfvel = std(fvel)


