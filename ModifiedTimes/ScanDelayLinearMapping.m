%Takes data obtained using the triangle function on the scan delay.  It
%crops the ends of the data and assumes a linear movement in the center.

%locate the data, input the nanostepper position
DirName = 'DIRECTORY_PATH_HERE\';

inputfiles = [15:3:150];
rfe = inputfiles(1,2);
numfiles = size(inputfiles,2);
a = 1;
for a = 1:numfiles


mmVal = num2str(inputfiles(1,a));
DataFileName = ['time_adjusted',mmVal,'mm_17ps_639mm.dat'];


NanoStep =  inputfiles(1,a); %mmVal;          %Nanostepper position (mm)
Bias = 0;                 %the bias
ppStep = 0;           %The position of the step on the nanostepper
Rail = 0;                %mm to add due to the manual rail (half real mm)
LockInSnstvty = 0.020;   %The sensitivity on the lock-in (V)

%file path
fpath = [DirName, DataFileName];

%Take the X and Y dat and put them in an array
%##method for files with easyplot save header##%
%fid = fopen(fpath, 'r');
%data = textscan(fid, '%f %f','headerlines', 5);
%X = data{1};
%Y = data{2};
%status = fclose(fid);
%##method for files with no header##%
M = importdata(fpath, '\t');
X = M;
X(:,2) = [];
Y = M;
Y(:,1) = [];

%XXXfudgeXXX
X(:,:) = X(:,:) + 0.305;
%XXXend fudgeXXX

%plot the XY data to check its shape
%figure;
%plot (X,Y, '-');
%title('Raw data from averaged data file');
%xlabel('position (Time from scope)');
%ylabel('signal');

%crop the ends of the data to leave only the "linear" region
NumRow = size(X, 1);
LowerCrop = NumRow*0.05;
UpperCrop = NumRow - LowerCrop;

X = X(LowerCrop:UpperCrop,:);
Y = Y(LowerCrop:UpperCrop,:);

%plot the XY data to check its shape
%figure;
%plot (X,Y, '-');
%title('Croped raw data from averaged data file');
%xlabel('position (Time from scope)');
%ylabel('signal');

%change the scope time axis into mm on the delay stage (2x real mm)
NumRow = size(X, 1);
LenX = X(NumRow,1) - X(1,1);
Const = 2.25/LenX; %numerator = 2.57 for 17ps scan and 7.8 for 50ps scan
X = X(:,:)*Const;

%account for the lock-in output (sensitivity/10V)
ConFacY = LockInSnstvty/10;
Y = Y(:,:)*ConFacY;

%plot the XY data to check its shape
%figure;
%plot (X,Y, '-');
%title('Data transformed to nanostepper mm and with lock-in sensitivity accounted for');
%xlabel('position (nanostepper mm)');
%ylabel('signal');

%add the nanostepper position and the rail position to make the time axis
%meaningful
X = X(:,:) + NanoStep + Rail;

%plot the XY data to check its shape
%figure;
%plot (X,Y, '-');
%title('Data with nanostepper position accounted for');
%xlabel('position (nanostepper mm)');
%ylabel('signal');

Name = num2str(mmVal);
Name2 = num2str(Bias);

%output the data to a file in two tab seperated columns
Outfname = [DirName,'time_adjusted', Name,'mm_in mm.dat'];%',num2str(mmVal),'.dat'];
fid = fopen(Outfname, 'w'); 
i = 1;
for i = 1:NumRow
    fprintf(fid, '%d\t', X(i,1));
    fprintf(fid, '%E\n', Y(i,1));
    i = i + 1;
end
status = fclose(fid);

%change the data from stage mm into ps
X = (X(:,:) - ppStep)*6.666666666666;

%plot the XY data to check its shape
%figure;
%plot (X,Y, '-');
%title('Data with time');
%xlabel('Time (ps)');
%ylabel('signal');
    
%output the data to a file in two tab seperated columns
Outfname = [DirName,'time_adjusted', Name,'mm_in ps.dat'];%,num2str(mmVal),'.dat'];
fid = fopen(Outfname, 'w'); 
i = 1;
for i = 1:NumRow
    fprintf(fid, '%d\t', X(i,1));
    fprintf(fid, '%E\n', Y(i,1));
    i = i + 1;
end
status = fclose(fid);
a = a + 1;
end