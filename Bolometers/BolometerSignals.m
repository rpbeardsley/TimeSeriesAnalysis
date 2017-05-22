%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This M file is for use with data files produced by the Digitiser when  %
%run through the bias sweep control in scan XP (bias subtraction        %
%has been done previously).  It will intergrate a gated signal and plot %
%it against the bias.                                                   %
%                                                                       %
%Complete the details below before running the file.                    %
%                                                                       %
Threshold = 0;              %the threshold of the mesa                  %
%                                                                       %
%Name of directory from which to extract bolometer data files:          %
DirName = 'PATH_HERE\';%
%Parsing information to load files:                                     % 
intFirstFile = -1;          %bias of first file (dB)                    %
intLastFile = 0.95;         %bias of last file (dB)                     %
intBiasStep = 0.05;         %bias step (dB)                             %    
%                                                                       %
%Gating the data:                                                       %
intSamplingInterval = 5;    %-Interval between samples on Digitiser (ns)%
intTotalTime = 1280;        %-Total time of measuremnt (ns)             %
intMinBaseLineGate = 55;    %-Base line gate start value (ns)           %
intMaxBaseLineGate = 170;   %-Base line gate end value (ns)             %
intMinGate = 210;           %-Start value of gate (ns)                  %
intMaxGate = 255;           %-End value of gate (ns)                    %
intPulse = 1;               %-pulse amplitude (V)                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FirstFile = num2str(intFirstFile, '%1.4f');
LastFile = num2str(intLastFile, '%1.4f');
BiasStep = num2str(intBiasStep, '%1.4f');
%
%### COLLECT THE X AND Y DATA INTO ARRAYS ###
%
%the first file to open and import data from
fname = [DirName, 'Sweep_2_', FirstFile, 'V.dat'];

%take the X data and check how many rows there are
M = importdata(fname, ',');
X = M;
X(:,2) = [];
NumRow = size(X, 1);

%create the matrix for the Y data to be wrtiten to
BiasDat = intFirstFile:intBiasStep:intLastFile;
columns = size(BiasDat, 2);
Y = zeros(NumRow, columns);

%setup the loop that will add the vectorised Y data in
intBiasLevel = intFirstFile;
BiasLevel = num2str(intBiasLevel, '%1.4f');
counter = 1;
%add in the Y data to the Y matrix
for counter = 1:columns
    BiasLevel = num2str(intBiasLevel, '%1.4f');    
    fname = [DirName, 'Sweep_2_', BiasLevel, 'V.dat'];
    M = importdata(fname, ',');
    M(:,1) = [];
    intBiasLevel = intBiasLevel + intBiasStep;
    Y(:,counter) = Y(:,counter) + M;
    counter = counter + 1;
end

%### DEAL WITH THE GATING ###
%
%find the matrix index for all of the (ns) gate values
intMinGateIdx = (intMinGate/intSamplingInterval) - 10; % - 10 as the time (ns)
intMaxGateIdx = (intMaxGate/intSamplingInterval) - 10; %doesn't start at 0
intMaxBaseLineGateIdx = (intMaxBaseLineGate/intSamplingInterval) - 10;
intMinBaseLineGateIdx = (intMinBaseLineGate/intSamplingInterval) - 10;

%create a row vector to put baseline summed values in and put them in it
NumCol = size(Y, 2);  %the number of Y data columns (input files) 
L = zeros(1,NumCol);  %dictates the number of rows

col = 1;
for col = 1:NumCol;
    K = sum(Y(intMinBaseLineGateIdx:intMaxBaseLineGateIdx, col));
    L(:,col) = L(:,col) + K;
    col = col + 1;
end

%divide each element by the number of Y points in the baseline gate to get 
%the averaged baseline 
NumYPoint = (intMaxBaseLineGateIdx - intMinBaseLineGateIdx + 1); % + 1 due to the length of K
Base = imdivide(L, NumYPoint);

%preserve Y for method 2
Yb = Y;

%############################### Method 1 #################################

%subtract the row vector of baseline values from each row of the Y data
row = 1;
for row = 1:NumRow;
    Y(row,:) = Y(row,:) - (Base);
    row = row + 1;
end

%plot all the Y data after baseline adjustment
figure
plot (Y, '-')
title('Phonon signal data')
xlabel('Sample number')
ylabel('Phonon signal (arb. units)')
%
%### INTERGRATE THE Y DATA IN THE GATE AND PLOT IT AGAINST THE X DATA ###
%
%create a vector of the correct size into which the integrated values are
%to be placed 
H = zeros(NumCol,1);

%Integrate within the gate; add the summed values into the column vector H
col = 1;
for col = 1:NumCol;
    J = sum(Y(intMinGateIdx:intMaxGateIdx, col));
    H(col,:) = H(col,:) + J;
    col = col + 1;
end

figure
plot(BiasDat, H, '-')
title('LA peak against bias (method 1)')
xlabel('Bias (V)')
ylabel('Integral over LA peak (arb. units)')

%change the bias values into Stark-splitting
%for s = 1:NumCol
    %BiasDat(1,s) = (BiasDat(1,s) - Threshold) / 50; 
    %s = s + 1;                            
%end

%output the data to a .dat file
Outfname = [DirName, 'LA_peak with bias.dat'];
fid = fopen(Outfname, 'w'); 
i = 1;
for i = 1:NumCol
    fprintf(fid, '%d\t', BiasDat(1,i));
    fprintf(fid, '%E\n', H(i,1));
    i = i + 1;
end
fprintf(fid, '/et    x "Bias (V)"     ;axis title');
fprintf(fid, '\n');
fprintf(fid, '/et    y "Interal over LA peak (arb. units)"        ;axis title');
status = fclose(fid);




%############################### Method 2 #################################

%subtract the baseline gate averaged values for each bias signal from
%the points in the signal gate in the corresponding signal
row = 1;
for row = intMinGateIdx:intMaxGateIdx;
    Yb(row,:) = Yb(row,:) - (Base);
    row = row + 1;
end

%Intergrate the region in which the difference between the background and
%the signal has been taken i.e. in the signal gate
P = zeros(NumCol,1);

col = 1;
for col = 1:NumCol;
    O = sum(Yb(intMinGateIdx:intMaxGateIdx, col));
    P(col,:) = P(col,:) + O;
    col = col + 1;
end

%plot the intergrated values against the bias
figure
plot(BiasDat, P, '-')
title('LA peak against bias (method 2)')
xlabel('Bias (V)')
ylabel('Integral over LA peak (arb. units)')













