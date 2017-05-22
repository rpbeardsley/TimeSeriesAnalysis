clear all
close all

AllFiles = [4]; %vector of file names to open (FileParameter)
InTime = [1]; %(ms),the integration time of the measurement for normalisation
BaseWndw = 120:1:290; %window over which to set as 0 counts (the background level)
FitWndw = 360:1:770; %window over which to fit
FileFolder = 'PATH_HERE';

for j = 1:length(AllFiles) %loop through each file
    
    FileParameter = num2str(AllFiles(1,j));
    IntTime = num2str(InTime(1,j));
        
    %get the spectrum data for each file
    TR = strcat(FileFolder,FileParameter,'.asc'); %create the address string
    fid = fopen(TR);
    tline1 = fgetl(fid);    %remove the header
    tline2 = fgetl(fid);
    tline3 = fgetl(fid);
    tline4 = fgetl(fid);
    tline5 = fgetl(fid);
    tline6 = fgetl(fid);
    tline7 = fgetl(fid);
    tline8 = fgetl(fid);
    tline9 = fgetl(fid);
    tline10 = fgetl(fid);
    TRPL = fscanf(fid, '%f', [1 inf]); %take the data
    fclose(fid);
    TRPL = TRPL(1:length(TRPL) - 40);%remove the footer
    %TRPL = TRPL./InTime(1,j); %normalise the count to the integration time
    %TRPL = TRPL(1:(length(TRPL)/2));
    

    %generate time data and create the storage arrays
    if j == 1
        TStep = 100e-9/length(TRPL); %generate the time step from the range (100ns here)
        T = 1:1:length(TRPL); %create time axis
        T = T'.*TStep; %put time step into time axis
        TRPLMat = zeros(length(T),length(AllFiles)); %matrix for the y (raw count) data from all of the files
        TRPLMatSmth = TRPLMat; %matrix for the y (filtered count) data from all of the files
    end 
    
    %analyse the TR data
    TRPLSmth = smooth(TRPL,3); %smooth the data
    OffSet = mean(TRPLSmth(BaseWndw)); %find the background level
    TRPLSmth = TRPLSmth - OffSet; %remove the background
    [M,I] = max(TRPLSmth); %find the index of the peak value
    FitIndicies = I:1:I + round(25e-9/TStep); %take the next 25 ns
    
    %take the y data for each file and add it to the array
    TRPLMat(:,j) = TRPL; % add raw data
    TRPLMatSmth(:,j) = TRPLSmth; %add the analysed data
        
end

TRPLMatSmthFit = TRPLMatSmth(FitIndicies,:); %take the region for fitting and store it
Trace = [BaseWndw(1),FitWndw(end)]; %plot window (start at the beggining of the base line and finish at the end of the fit)

%find the zero time to offset required put t=0 at the peak 
SumTRPL = sum(TRPLMatSmth,2); %add all the filtered traces together
[MaxSumTRPL, MaxSumTRPLIndex]  = max(SumTRPL); %differentiate the sum and find the maximum
TOff = T(MaxSumTRPLIndex); %time offset

figure
plot(T(Trace(1,1):Trace(1,2)),TRPLMat(Trace(1,1):Trace(1,2),:)) %plot in the window
%plot(T,TRPLMat) %plot the whole lot
xlabel('time (sec)')
ylabel('counts')
title('Raw time resolved data','FontSize',16)

figure
plot(T(Trace(1,1):Trace(1,2)) - TOff,TRPLMatSmth(Trace(1,1):Trace(1,2),:)) %plot in the window
%plot(T,TRPLMatSmth) %plot the whole lot
xlabel('time (sec)')
ylabel('counts')
title('Filtered time resolved data','FontSize',16)

%figure
%surf(T(Trace(1,1):Trace(1,2)) - TOff,AllFiles+2,TRPLMatSmth(Trace(1,1):Trace(1,2),:)','FaceColor','interp','EdgeColor','none') %plot the whole lot
%%surf(T,AllFiles+2,TRPLMat','FaceColor','interp','EdgeColor','none') %plot the whole lot
%xlabel('time (sec)')
%ylabel('distance from edge of wafer (mm)')
%zlabel('counts')
%cb = colorbar;
%title(cb,'count')
%colormap jet



%figure
%surf(T(FitIndicies) - TOff,AllFiles+2,TRPLMatSmthFit','FaceColor','interp','EdgeColor','none') %plot the whole lot
%%surf(T,AllFiles+2,TRPLMat','FaceColor','interp','EdgeColor','none') %plot the whole lot
%xlabel('time (sec)')
%ylabel('distance from edge of wafer (mm)')
%cb = colorbar;
%title(cb,'count')
%colormap jet


%save the data%
%%%raw data%%%
fileID = fopen(strcat(FileFolder,'RawTRPL.dat'),'wt');
B = [T(Trace(1,1):Trace(1,2)),TRPLMat(Trace(1,1):Trace(1,2),:)];
for ii = 1:size(B,1)
    fprintf(fileID,'%g\t',B(ii,:));
    fprintf(fileID,'\n');
end
fclose(fileID);

%%%filtered data%%%
fileID = fopen(strcat(FileFolder,'FilteredTRPL.dat'),'wt');
C = [T(Trace(1,1):Trace(1,2)) - TOff,TRPLMatSmth(Trace(1,1):Trace(1,2),:)];
for ii = 1:size(C,1)
    fprintf(fileID,'%g\t',C(ii,:));
    fprintf(fileID,'\n');
end
fclose(fileID);

%%%fitting data%%%
fileID = fopen(strcat(FileFolder,'FitTRPL.dat'),'wt');
D = [T(FitIndicies) - TOff,TRPLMatSmthFit];
for ii = 1:size(D,1)
    fprintf(fileID,'%g\t',D(ii,:));
    fprintf(fileID,'\n');
end
fclose(fileID);





