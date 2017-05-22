%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This M file is for use with data files produced by the Digitiser when  %
%run through the bias sweep control in scan XP (bias subtraction        %
%has been done previously).  It will integrate a gated signal and plot %
%it against the bias.                                                   %
%                                                                       %
%Complete the details below before running the file.                    %
%                                                                       %
Threshold = 0.15;            %the threshold of the mesa (V)             %
%                                                                       %
%Name of directory from which to extract bolometer data files:          %
DirName = 'PATH_HERE\';               %
%Parsing information to load files:                                     % 
intFirstFile = 0.1500;      %-bias of first file (dB)                   %
intLastFile = 0.5650;       %-bias of last file (dB)                    %
intBiasStep = 0.005;        %-bias step (dB)                            %    
%                                                                       %
%Gating the data:                                                       %
intSamplingInterval = 0.2;  %-Interval between samples on Digitiser (ns)%
intTotalTime = 999.8;       %-Total time of measurement (ns)            %
intMinBaseLineGate = 4;    %-Base line gate start value (ns)           %
intMaxBaseLineGate = 270;   %-Base line gate end value (ns)             %
intMinGate = 374;           %-Start value of gate (ns)                  %
intMaxGate = 400;           %-End value of gate (ns)                    %
intMinOpticalGate = 311;    %-Optical background gate start value (ns)  %
intMaxOpticalGate = 363;    %-Optical background gate end value (ns)    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FirstFile = num2str(intFirstFile, '%1.4f');
LastFile = num2str(intLastFile, '%1.4f');
BiasStep = num2str(intBiasStep, '%1.4f');
%
%### COLLECT THE X AND Y DATA INTO ARRAYS ###
%
%the first file to open and import data from
fname = [DirName, '3_', FirstFile, 'V.dat'];

%take the X data and check how many rows there are
M = importdata(fname, '\t');
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
    fname = [DirName, '3_', BiasLevel, 'V.dat'];
    M = importdata(fname, '\t');
    M(:,1) = [];
    M = smooth(M,5);
    intBiasLevel = intBiasLevel + intBiasStep;
    Y(:,counter) = Y(:,counter) + M;
    counter = counter + 1;
end

%plot the unprocessed data
figure;
plot(X, Y, '-');
title('Unprocessed data');
xlabel('time (sec)');
ylabel('Phonon signal (arb. units)');
%
%### DEAL WITH THE GATING AND BASE LINE ADJUSTMENT ###
%
%find the matrix index for all of the (ns) gate values
intMinGateIdx = round(intMinGate/intSamplingInterval);
intMaxGateIdx = round(intMaxGate/intSamplingInterval);
intMaxBaseLineGateIdx = round(intMaxBaseLineGate/intSamplingInterval);
intMinBaseLineGateIdx = round(intMinBaseLineGate/intSamplingInterval);
intMinOpticalGateIdx = round(intMinOpticalGate/intSamplingInterval);
intMaxOpticalGateIdx = round(intMaxOpticalGate/intSamplingInterval);
intNumberOfPointsIdx = round(intTotalTime/intSamplingInterval);

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

%subtract the row vector of baseline values from each row of the Y data
row = 1;
for row = 1:NumRow;
    Y(row,:) = Y(row,:) - (Base);
    row = row + 1;
end

%plot all the Y data after baseline adjustment
figure
plot (X, Y, '-')
title('Phonon signal data after base line adjustment')
xlabel('time (sec)')
ylabel('Phonon signal (arb. units)')
%
%### SUBTRACT THE OPTICAL BACKGROUND ###
%
%preserve Y and X for use later
Yfit = Y;
Xfit = X;

%select the region of data to fit the exponential decay of the optical
%background to
Yfit(intMaxOpticalGateIdx:intNumberOfPointsIdx,:) = [];
Yfit(1:intMinOpticalGateIdx,:) = [];
Xfit(intMaxOpticalGateIdx:intNumberOfPointsIdx,:) = [];
Xfit(1:intMinOpticalGateIdx,:) = [];

%transform the Yfit data to ln scale and make a linear fit
Yfit = log(Yfit);

%create a matrix of the correct size to add the fit data in
FitData = zeros(NumRow,columns);
%add in the fit data
for m = 1:columns;
    FitCoef = polyfit(Xfit,Yfit(:,m),1);
    Fit = polyval(FitCoef, X);
    FitData(:,m) = FitData(:,m) + Fit;
    m = m + 1;
end

%change the fit data to the linear scale of the X data
FitData = exp(FitData);

%plot all the Y data after baseline adjustment
figure
hold on
plot (X, Y, '-')
plot(X, FitData, 'r')
title('Exponential fit to optical background in the phonon signal')
xlabel('time (sec)')
ylabel('Phonon signal (arb. units)')
hold off

%subtract the fitted exponential from the phonon signal
Y(:,:) = Y(:,:) - FitData(:,:);

%plot the phonon signal with the optical background subtracted
figure
plot(X, Y, '-');
title('Phonon signal with exponential decay of optical background subtracted')
xlabel('time (sec)')
ylabel('Phonon signal (arb. units)')

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
title('LA peak against bias')
xlabel('Bias (V)')
ylabel('Integral over LA peak (arb. units)')

%change the bias values into Stark-splitting
%for s = 1:NumCol
    %BiasDat(1,s) = (BiasDat(1,s) - Threshold) / 50; 
    %s = s + 1;                            
%end

%output the data to a .dat file
Outfname = [DirName, 'LA_with_bias2.dat'];
fid = fopen(Outfname, 'w'); 
i = 1;
for i = 1:NumCol
    fprintf(fid, '%d\t', BiasDat(1,i));
    fprintf(fid, '%E\n', H(i,1));
    i = i + 1;
end
fprintf(fid, '/et    x "Bias (V)"     ;axis title');
fprintf(fid, '\n');
fprintf(fid, '/et    y "LA (arb. units)"        ;axis title');
status = fclose(fid);












