%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This M file is for use with data files produced by the Digitiser or the%
%scope when run through the pulse attenuator control in scan XP         %
%(bias subtraction has been done previously).  It will integrate a     %
%gated signal and plot it against the level of attenuation and the      %
%voltage of the pulse.                                                  %
%                                                                       %
%Complete the details below before running the file.                    %
%                                                                       %
Threshold = 0;              %The threshold of the mesa                  %
%                                                                       %
%Name of directory from which to extract bolometer data files:          %
DirName = 'PATH_HERE\';    %
%Name of the dierectory from which to extract the pulse data files:     %
DirNameP = 'PATH_HERE\';%
%                                                                       %
%Parsing information to load files:                                     %
intFirstFile = 0;           %Attenuation of first file (dB)             %
intLastFile = 18;           %Attenuation of last file (dB)              %
intAttStep = 1;             %Attenuation step (dB)                      %    
%                                                                       %
%Bolometer data:                                                        %
intSamplingInterval = 0.2;  %-Interval between samples on scope (ns)    %
intTotalTime = 1000;        %-Total time of measuremnt (ns)             %
intMinBaseLineGate = 10;    %-Base line gate start value (ns)           %
intMaxBaseLineGate = 175;   %-Base line gate end value (ns)             %
intMinGate = 300;           %-Start value of gate (ns)                  %
intMaxGate = 340;           %-End value of gate (ns)                    %
%                                                                       %
%Pulse data                                                             %
intSamplingIntervalP = 0.2;  %-Interval between samples on scope (ns)   %
intTotalTimeP = 1000;        %-Total time of measuremnt (ns)            %
intOutPulse = 173;           %-time of the outbound pulse (ns)          %
intReflectPulse = 275;       %-time of the reflected pulse              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FirstFile = int2str(intFirstFile);
LastFile = int2str(intLastFile);
AttStep = int2str(intAttStep);
%
%### COLLECT THE X AND Y DATA INTO ARRAYS ###
%
%the first file to open and import data from
fname = [DirName, ' ', FirstFile, ' dB attenuation.dat'];

%take the X data and check how many rows there are
M = importdata(fname, ',');
X = M;
X(:,2) = [];
NumRow = size(X, 1);

%create the matrix for the Y data to be wrtiten to
AttDat = intFirstFile:intAttStep:intLastFile;
columns = size(AttDat, 2);
Y = zeros(NumRow, columns);

%setup the loop that will add the vectorised Y data in
intAttLevel = intFirstFile;
AttLevel = int2str(intAttLevel);
counter = 1;
%add in the Y data to the Y matrix
for counter = 1:columns
    AttLevel = int2str(intAttLevel);    
    fname = [DirName, ' ', AttLevel, ' dB attenuation.dat'];
    M = importdata(fname, ',');
    M(:,1) = [];
    intAttLevel = intAttLevel + intAttStep;
    Y(:,counter) = Y(:,counter) + M;
    counter = counter + 1;
end
%    
%### DEAL WITH THE GATING AND SUBTRACT THE BASELINE VALUE FROM Y DATA ###
%### AND INTERGRATE ###
%
%find the matrix index for all of the (ns) gate values
intMinGateIdx = round(intMinGate/intSamplingInterval);
intMaxGateIdx = round(intMaxGate/intSamplingInterval);
intMaxBaseLineGateIdx = round(intMaxBaseLineGate/intSamplingInterval);
intMinBaseLineGateIdx = round(intMinBaseLineGate/intSamplingInterval);

%create a row vector to put baseline summed values in and put them in it
NumCol = size(Y, 2);  %-the number of Y data columns (input files) 
L = zeros(1,NumCol);  %dictates the number of rows

col = 1;
for col = 1:NumCol;
    K = sum(Y(intMinBaseLineGateIdx:intMaxBaseLineGateIdx, col));
    L(:,col) = L(:,col) + K;
    col = col + 1;
end

%divide each element by the number of Y points in the baseline gate 
NumYPoint = (intMaxBaseLineGateIdx - intMinBaseLineGateIdx);
Base = imdivide(L, NumYPoint);

%subtract the row vector of baseline values from each row of the Y data
row = 1;
for row = 1:NumRow;
    Y(row,:) = Y(row,:) - Base;
    row = row + 1;
end

%plot all the Y data after baseline adjustment
figure
plot (X,Y, '-')
title('Phonon signal data after base line adjustment')
xlabel('time (sec)')
ylabel('Phonon signal (arb. units)')

%create a vector of the correct size into which the integrated values are
%to be placed
H = zeros(NumCol,1);

%Integrate within the gate.  Add the summed values into the column vector H
col = 1;
for col = 1:NumCol;
    J = sum(Y(intMinGateIdx:intMaxGateIdx, col));
    H(col,:) = H(col,:) + J;
    col = col + 1;
end
%
%### READ IN THE VOLTAGE PULSES AND CALCULATE THE APPLIED VOLTAGE AND  ###
%### POWER DISSIPATED IN THE DEVICE ### 
%
%the first file to open and import data from
fnameP = [DirNameP, ' ', FirstFile, ' dB attenuation.dat'];

%take the X data and check how many rows there are
MP = importdata(fname, ',');
XP = MP;
XP(:,2) = [];
NumRowP = size(XP, 1);

%create the matrix for the YP- data to be wrtiten to
AttDatP = intFirstFile:intAttStep:intLastFile;
columnsP = size(AttDatP, 2);
YP = zeros(NumRow, columns);

%setup the loop that will add the vectorised YP data in
intAttLevel = intFirstFile;
AttLevelP = int2str(intAttLevel);
counter = 1;
%add in the YP data to the YP matrix
for counterP = 1:columnsP
    AttLevelP = int2str(intAttLevel);
    fnameP = [DirNameP, ' ', AttLevelP, ' dB attenuation.dat'];
    MP = importdata(fnameP, ',');
    MP(:,1) = [];
    intAttLevel = intAttLevel + intAttStep;
    YP(:,counterP) = YP(:,counterP) + MP;
    counterP = counterP + 1;
end

%get the index of the outbound and reflected voltage maxima
intOutPulseIdx = round(intOutPulse/intSamplingInterval);
intReflectPulseIdx = round(intReflectPulse/intSamplingInterval);

%create row vectors to put the voltage values for both pulses in
NumColP = size(YP, 2);  %the number of Y data columns (input files) 
Vout = zeros(1,NumColP);  %dictates the number of rows
Vref = Vout;
Vdev = Vout;

%put in the voltages
colP = 1;
for colP = 1:NumColP;
    Vout(:,colP) = Vout(:,colP) + YP(intOutPulseIdx,colP);
    Vref(:,colP) = Vref(:,colP) + YP(intReflectPulseIdx,colP);
    colP = colP + 1;
end

%calculate the fractional cable loss per cable pass
%FracLoss = (Vref(1,1)./Vout(1,1)).^0.5;
%pulse after 1 cable pass = 0.9 pulse before 1 cable pass

%adjust the outbound and reflected pulses for the cable loss
%Vout = Vout.*(0.9);
%Vref = Vref./(0.9);

%get the amplitude at the device
Vdev = Vout + Vref;

%plot the LA against the voltage applied to the device
figure;
plot(Vdev, H);
title('LA against applied voltage')
xlabel('applied voltage (V)')
ylabel('sum over LA rising edge (a.u.)')

%calculate the power dissipated in the device
P = ((Vout.^2)./50) - ((Vref.^2)./50);

%plot the power dissipated in the device against the applied voltage
figure;
plot(Vdev, P)
title('Power dissipated in the device as a function of applied voltage')
xlabel('applied voltage (V)')
ylabel('Power dissipated (W)')
%
%### NORMALISE THE SIGNAL TO THE POWER AND PLOT THE RESULTS ###
%
%normalise the LA to the power dissipated in the device
P = P';
LAnorm = H./P;

%plot the normalised LA against the applied voltage
figure;
plot(Vdev, LAnorm)
title('The LA normalised to the power dissipated in the device as a function of the applied voltage')
xlabel('applied voltage (V)')
ylabel('LA normalised to the power')

%output the data to a .dat file
OutfnameP = [DirName, 'Normalised phonon signal no cable loss.dat'];
fid = fopen(OutfnameP, 'w'); 
i = 1;
for i = 1:NumCol
    fprintf(fid, '%d\t', Vdev(1,i));
    fprintf(fid, '%E\n', LAnorm(i,1));
    i = i + 1;
end
fprintf(fid, '/et    x "applied voltage (V)"     ;axis title');
fprintf(fid, '\n');
fprintf(fid, '/et    y "Phonon Signal / Power (a.u.)"        ;axis title');
status = fclose(fid);

