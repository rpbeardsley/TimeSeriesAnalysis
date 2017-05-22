%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Adjust the x axis of a scope trace with the position voltage           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%locate the data, input the nanostepper position
DirName = 'DIRECTORY_PATH_HERE\';
DataFileName = '150mm_150mm_55ps.dat';
%NanoStep = 6.75;  %nanostepper position (mm)

%position data file path
fpath = [DirName, DataFileName];
PDfpath = ['C:\Documents and Settings\Ryan\Desktop\081209\55ps\PositionData_55ps2.dat'];

PD = importdata(PDfpath, '\t');
PDX = PD;
PDX(:,2) = [];
PDY = PD;
PDY(:,1) = [];
%Take the X and Y dat and put them in an array
%##method for files with easyplot save header##%
%PDfid = fopen(PDfpath, 'r');
%data = textscan(PDfid, '%f %f','headerlines', 0);
%PDX = data{1};
%PDY = data{2};
%status = fclose(PDfid);
%##method for files with no header##%

%Check for distinct values%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n = size(PDY,1);
o = n;
counter = 0;
for i = 1:n;
    for j = 1:o;
        if PDY(i,1) == PDY(j,1); 
            if i ~= j & j > i;
                counter = counter + 1;
                PDY(j,1) = PDY(j,1)+0.000002; %introduce a fluctuation less 
            end;                              %than the noise to make
        end;                                  %distinct points
    end;
end;
%end check for distinct values%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

M = importdata(fpath, '\t');
X = M;
X(:,2) = [];
Y = M;
Y(:,1) = [];

%plot the XY data to check its shape
figure;
plot (X,Y, '-');
title('Raw data from averaged data file');
xlabel('position (Time from scope)');
ylabel('signal');

%plot the position data to check its shape
figure;
plot(PDX,PDY);
title('Position data from the scan delay');
xlabel('time');
ylabel('position');

%plot the signal against the position to acount for none linear movement
figure;
plot(PDY,Y);
title('Signal against position');
xlabel('position');
ylabel('signal');

%Linearly interpolate the data. Data method 
Xi = -0.619039:0.0001215421:0.596382;
Xi = Xi';
Xs = interp1(PDY,Y,Xi,'linear'); 

figure;
plot(Xi,Xs,'-o');
title('Interpolated transformed data');
xlabel('time');
ylabel('signal');

%output the time adjusted data
%Outfname = [DirName, 'time_adjusted_', DataFileName];
%fid = fopen(Outfname, 'w'); 
%l = size(PDY,1)
%for i = 1:l;
%    fprintf(fid, '%d\t', PDY(i,1));
%    fprintf(fid, '%E\n', Y(i,1));
%    i = i + 1;
%end
%fprintf(fid, '/et    x "Position (mm)"     ;axis title');
%fprintf(fid, '\n');
%fprintf(fid, '/et    y "Phonon Signal / Power (arb. units)"        ;axis title');
%status = fclose(fid);

%output the interpolated time adjusted data 
Outfname = [DirName, 'time_adjusted_interpolated_', DataFileName];
fid = fopen(Outfname, 'w'); 
k = size(Xs,1);
for i = 1:k;
    fprintf(fid, '%d\t', Xi(i,1));
    fprintf(fid, '%E\n', Xs(i,1));
    i = i + 1;
end
%fprintf(fid, '/et    x "Position (mm)"     ;axis title');
%fprintf(fid, '\n');
%fprintf(fid, '/et    y "Phonon Signal / Power (arb. units)"        ;axis title');
status = fclose(fid);
