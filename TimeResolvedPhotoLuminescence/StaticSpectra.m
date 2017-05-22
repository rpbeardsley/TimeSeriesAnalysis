clear all
close all

AllFiles = [2 5 8 11 14 17 20 23 26 29 32]; %vector of file names to open (FileParameter)
InTime = [10 10 10 10 10 10 10 10 10 10 10]; %(ms),the integration time of the measurement for normalisation

FileFolder = 'PATH_HERE';
CentralWavLen = 815.2e-9; %m, the central wavelength of the spectrometer

PeakVals = zeros(length(AllFiles),3); %generate the peak magnitude and peak wavelength vs FileParameter matrix 
PeakVals(:,1) = AllFiles'; %put the FileParameter into the matrix (wafer position, laser power, etc...)

for j = 1:length(AllFiles) %loop through each file
    
    FileParameter = num2str(AllFiles(1,j)); %change the file numbers to strings
    IntTime = num2str(InTime(1,j));
    
    %get the spectrum data for each file
    StatSpec = strcat(FileFolder,FileParameter,'mm_',IntTime,'msInt.prn'); %create the address string
    Spec = dlmread(StatSpec,','); %read the spectrum

    %take the x data for the first file only and define the y matrix
    if j == 1
        range = [1:1:length(Spec(:,1))];
        WavLen = (range.*(50e-9/length(Spec(:,1)))) + (CentralWavLen - 25e-9); %adjusted x (wavelength) data
        PhotCntMat = zeros(length(WavLen),length(AllFiles)); %matrix for the y (count) data from all of the files
    end 
    
    %take the y data for each file and add it to the array
    PhotCnt = Spec(:,2); %get y data for this file
    OffSet = mean(PhotCnt(1:600)); %find the background level
    PhotCnt = PhotCnt - OffSet; %remove the background
    PhotCnt = PhotCnt./InTime(1,j); %normalise the count to the integration time
    PhotCntMat(:,j) = PhotCnt; % add it to the matrix
    
    %take the coordinates of the peak and add them to the array
    [M,I] = max(PhotCnt); %find the magnitude and index of the peak value
    PeakVals(j,2) = WavLen(I); %add the wavelength at the peak to the matrix
    PeakVals(j,3) = M; %put the peak value in the matrix
    
end


%Display the signals and the spectra
%%%raw spectrum%%%
figure
plot(WavLen(2:end)./1e-9,PhotCntMat(2:end,:)); %raw data
xlabel('Wavelength (nm)')
ylabel('counts')
title('Raw spectrum data','FontSize',16)

%%%peak magnitude vs FileParameter%%%
figure
plot(PeakVals(:,1),PeakVals(:,3))
xlabel('Distance form the edge of the wafer (mm)')
ylabel('Peak count')
title('Peak magnitude vs wafer position','FontSize',16)

%%%peak wavelength vs FileParameter%%%
figure
plot(PeakVals(:,1),PeakVals(:,2))
xlabel('Distance form the edge of the wafer (mm)')
ylabel('Wavelength of peak (m)')
title('Peak wavelength vs wafer position','FontSize',16)

%%%spectra vs FileParameter%%%
figure
surf(AllFiles,WavLen(2:end),PhotCntMat(2:end,:),'FaceColor','interp','EdgeColor','none')
xlabel('Distance from the edge of the waer (mm)')
ylabel('Wave length (nm)')
zlabel('counts')
title('PL spectra as a function of wafer position','FontSize',16)

%save the data
%%%the spectra%%%
fileID = fopen(strcat(FileFolder,'PLSpecra.dat'),'wt');
B = [WavLen',PhotCntMat];
for ii = 2:size(B,1)
    fprintf(fileID,'%g\t',B(ii,:));
    fprintf(fileID,'\n');
end
fclose(fileID);

%%%peak coordinates vs FileParameter%%%
fileID = fopen(strcat(FileFolder,'Peak.dat'),'w');
A = PeakVals';
fprintf(fileID,'%6.2f %6.4e %6.2f\r\n',A);
fclose(fileID);


