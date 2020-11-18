close all;
%clear all;
clc;

%Default size: vmass = 7.6e-21, vrad = 120e-9/2
% velChangeMat = load('velChangeDefaultSize.mat');
% velChangeMat = velChangeMat.vz;
rng(1852,'combRecursive')
tic
vmass = 7.6e-21; %up to 1e-17 for a large virus down to 7.6e-21
density = 3e25; %molecules/m^3 - at sea level
airpressure = 101325; %In Pascals
diameter = 120e-9; %Diameter of a Coronavirus Particle
position = [0,0,5.2]; %x,y,z. Must have initial Z > 0.
                      %5.2 = average height of a mouth
velocity = [1.8,0,0]; %x,y,z. Inital direction could be randomized
                      %But so long as it's only in the x,y plane, it's
                      %irrelevant. 1.8 m/s is average for normal breathing
threads = 10; %Update for your computer. Most computers have 2 threads per
              %CPU core.
samples = threads*1; %Sample count must be a multiple of threads
time = zeros(3,samples); %Only 1 column used; must have 3 for writing to .txt
pos = zeros(3,samples);
vel = zeros(3,samples);
t_start = 0; %in seconds
t_end = 1.5;  
t_interval = 4e-11; %Needs to be small for accuracy but the smaller this is, 
                    %the more processing power you need.
points = (t_end - t_start)*1000; %1000 points per second. 
recint = (t_end - t_start)/t_interval/points %The interval needed to record the number of points we want.
posmat = zeros(3, points,samples);

for i = 1:(samples/threads) %Prevents errors in larger data sets. 
    parfor j = (i-1)*threads+1:(i-1)*threads+threads %Has to be this convoluted due to
                                                     %Matlab's parfor restrictions
       [time(:,j),pos(:,j),vel(:,j),posmat(:,:,j)] = particleTracking(vmass,airpressure,diameter,position,velocity,t_start,t_end,t_interval,recint,points);
        disp(j);
    end
end
toc

T = table(time,pos,vel);
writetable(T,'BreathingData.txt');
save('posData.mat','posmat');
%[time1,pos1,vel1] = particleTracking(vmass,density,diameter,position,velocity); %Just to make it run once for tests. Remove later
%[time2,pos2,vel2] = particleTracking(vmass,density,diameter,position,velocity);

function [t_grounded,positionfinal,velocityfinal, posmat] = particleTracking(vmass,airpressure,diameter,position,velocity,t_start,t_end,t_interval,recint,points);

%rho = density; %molecules/m^3 - at sea level - maybe need to change for units?
sigma = pi*(diameter/2)^2; %Cross-section of the particle
%lambda = 1/(sqrt(2)*rho*sigma) Incorrect mean free path calculation -
%where did I even get this from?? - First result on google is wrong. Idk
%why or how.
%Boltzman Constant * Room temp (K)/Cross-sectional Area * airpressure
lambda = 1.38064852e-23*293/(4*pi*sqrt(2)*diameter/2*airpressure); %Mean-free path avg dist between collisions
%t = t_start:t_interval:t_end;
N=(t_end-t_start)/t_interval + 1;
vx = velocity(1);  % Initial velocity in x
vy = velocity(2);   % Initial velocity in y
vz = velocity(3);   % Initial velocity in z
%Ed = 6e-5*cos(2*pi*10e2*t); % E-field
a = -9.81;%q/m*Ed; - effect of an E-field on a % Acceleration in z
%xpos = zeros(1,N); %Preallocation for efficiency.
%ypos = zeros(1,N); %For more flexability but less efficiency, don't do this
%zpos = zeros(1,N);
xpos = position(1); %initial position
ypos = position(2);
zpos = position(3);
counter = 2;
deltadist = 0;
posmat = zeros(3,points);
while(zpos > 0 && counter <= N)
    vz = vz + a*t_interval; %velocity, updated w/ acceleration due to gravity
    %     xpos(counter) = xpos(counter-1) + vx*t_interval; %Store every position
    %     ypos(counter) = ypos(counter-1) + vy*t_interval;
    %     zpos(counter) = zpos(counter-1) + vz*t_interval;
    xpos = xpos + vx*t_interval;
    ypos = ypos + vy*t_interval;
    zpos = zpos + vz*t_interval;
    dist = (vx*t_interval)^2 + (vy*t_interval)^2 + (vz*t_interval)^2;
    if(deltadist + dist >= lambda)
        %oldv = [vx,vy,vz]; %to display/check collisions
        [vx,vy,vz] = collision(vmass,vx,vy,vz,diameter/2);
        %newv = [vx,vy,vz]; %Remove semicolons to test for smaller datasets
        deltadist = deltadist + dist - lambda; %for overflow distance
    else
        deltadist = deltadist + dist;
    end
    if(deltadist >= lambda) %If particle is going >= 2*lambda per t_interval,
        disp("Need smaller time intervals."); %it must be made smaller for accuracy
        [vx vy vz] %For debugging purposes
    end                                       
    if (mod(counter,recint) == 0)  %This section of code records values at set intervals.
        recnum = counter/recint   %Record number (1-points)
        posmat(:,recnum) = [xpos ypos zpos];
    end
    counter = counter + 1;
end
t_grounded = counter*t_interval;
positionfinal = [xpos ypos zpos];
velocityfinal = [vx vy vz];
end
% while (counter < N) %Unnecessary given t_grounded and a plot that ends
% there
%     xpos(counter) = xpos(counter-1); %So the particle stays in place
%     ypos(counter) = ypos(counter-1); %once it touches ground.
%     zpos(counter) = zpos(counter-1);
%     counter = counter + 1;
% end
%     % Motion within the capacitor
%     for k=1:t_grounded/t_interval,
%         %plot([L L],[-10 10],'g','LineWidth',3);hold on; Syntax to print
%         %lines
%         plot3(xpos(k),ypos(k),zpos(k),'o','LineWidth',2,'MarkerFaceColor','c','MarkerSize',8);
%         hold off;grid;
%         axis([0 L 0 L 0 L]); %Assuming particle won't go to a negative
%         position
%         xlabel('Horizontal distance, m');
%         ylabel('Vertical distance, m');
%         zlabel('Z distance, m');
%         text(0.3,7,['Time = ',num2str(t(k)),'s']);
%         %text(0.3,9,['Velocity in y = ',num2str(eval(V_num(k))),'m/s']);
%         pause(0.0001);
%     end

%Yexit=eval(Y_pos_num(N));
%Vexit=eval(V_num(N));

% Motion outside the capacitor

% t2=linspace(0,(L-w)/v0x,N);
%     for k=1:N,
%         x=v0x*t2(k)+w;
%         y=Yexit+Vexit*t2(k);
%         plot([L L],[-10 10],'g','LineWidth',3);hold on;
%         plot([0 w],[4 4],'k','LineWidth',3);hold on;
%         plot([0 w],[-4 -4],'k','LineWidth',3);hold on;
%         plot(x,y,'o','LineWidth',2,'MarkerFaceColor','c','MarkerSize',8);
%         hold off;grid;
%         axis([0 L -10 10]);
%         xlabel('Horizontal distance, m');
%         ylabel('Vertical distance, m');
%         text(0.3,7,['Time = ',num2str(t2(k)),'s']);
%         text(0.3,9,['Velocity in y = ',num2str(Vexit),'m/s']);
%         pause(0.0001);
%     end
function [x,y,z] = collisionQuicker(vm,velx,vely,velz,vrad,velChangeMat)  
i = randi(10000000);
velvir = [velx vely velz];
if (i > 10000000 || i < 1)
    disp(i);
end
velmol = [velChangeMat(i,1,1) velChangeMat(i,1,2) velChangeMat(i,1,3)];
n = [velChangeMat(i,2,1) velChangeMat(i,2,2) velChangeMat(i,2,3)];
output = [velChangeMat(i,3,1) velChangeMat(i,3,2) velChangeMat(i,3,3)];
finalv = velvir + output*dot((velvir-velmol),n);
x = finalv(1);
y = finalv(2);
z = finalv(3);
end
function [x,y,z] = collision(vm,velx,vely,velz,vrad) %Importing an updated
%vm to allow for a potentially changing mass
moltype = .8; %rand; %Will allow for more molecule types
molspeed = 500; %speed of a molecule in m/s @ room temperature
%theta = 90;% rand*2*pi; %Random angle in on one plane
%phi = 90; %rand*2*pi; %Random angle in the other, perpendicular plane
if (moltype <= .789)
    molmass = 2.3244e-26; %mass in kg - nitrogen
    molrad = 720e-12; %in meters - want to look into collision radii
else
    molmass = 2.65676E-26; %mass in kg - oxygen
    molrad = 304e-12; %in meters
end
totalmass = molmass + vm;
% The following is not currently used but saved in case a use comes up
%     momx = vm*velx; %virus momentum
%     momy = vm*vely;
%     momz = vm*velz;
%     momx2 = molmass*molspeed*sin(theta)*cos(phi); %Particle momentum
%     momy2 = molmass*molspeed*sin(theta)*sin(phi);
%     momz2 = molmass*molspeed*cos(theta);
%     totkenx = momx^2/(2*vm) + momx2^2/(2*molmass); %Total Kinetic Energy
%     totkeny = momy^2/(2*vm) + momy2^2/(2*molmass);
%     totkenz = momz^2/(2*vm) + momz2^2/(2*molmass);
velvir = [velx vely velz];
% velmol = [molspeed*sin(theta)*cos(phi)...
%     molspeed*sin(theta)*sin(phi)...
%     molspeed*cos(theta) + 10]; %Add to each component to create a draft or breeze
                               
unit = randn(1,3);
%unit(3) = abs(unit(3)) + 1000; %Creates a stress towards the positive z direction
                        %>1 guarentees upward particle motion
unit = unit./sum(sqrt(unit.*unit)); %Creates a unit vector in a random direction
velmol = [molspeed*unit(1) molspeed*unit(2) molspeed*unit(3)]; %Increases speed in z direction - may be positive OR negative
                                       %based on direction of unit vector.
e = 1; %1 for perfectly elastic collisions, 0 for inelastic. Need a
%ratio of final vs initial velocities anywhere in between
CoM = vm*(totalmass); %Center of mass in direction of the point of collision
%Value is on axis with mol = 0.
Imol = molmass*CoM^2; %Inertias
Ivir = vm*(vrad+molrad-CoM)^2;
% rmol = [CoM*sin(theta)*cos(phi) CoM*sin(theta)*sin(phi) CoM*cos(theta)];
rmol = [CoM*unit(1) CoM*unit(2) CoM*unit(3)];
% rvir = [(vrad+molrad-CoM)*sin(theta)*cos(phi)...
%     (vrad+molrad-CoM)*sin(theta)*sin(phi)...
%     (vrad+molrad-CoM)*cos(theta)]; %Radii to center of mass
rvir = [(vrad+molrad-CoM)*unit(1)...
    (vrad+molrad-CoM)*unit(2)...
    (vrad+molrad-CoM)*unit(3)]; 
% u = [sin(theta)*cos(phi)... %Unit vector between the center of the virus
%     sin(theta)*sin(phi)... %and the molecule
%     cos(theta)];
u = unit;
n = u + vrad; %Assumes the center of the virus particle to be at (0,0)
%If the center were another point n = norm(u*vrad - center);
Jmag = -(1+e)*dot((velvir-velmol),n)/(1/vm + 1/molmass + ... %Impulse generated from the collision
    dot(cross(rmol,n),1/Imol*cross(rmol,n)) + ...
    dot(cross(rvir,n),1/Ivir*cross(rvir,n)));
finalv = velvir + Jmag*n/vm; %The final term is to fix the direction that is changed in the impulse calculation
x = finalv(1); %New velocities for return
y = finalv(2); 
z = finalv(3);
end



