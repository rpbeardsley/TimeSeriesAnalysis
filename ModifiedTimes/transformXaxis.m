%%%input details%%%
NanoStep = 150; %Nano stepper position (mm)
Rail = 150; %rail position (mm)
Step = 7.2; %step position
%%%end input details%%%

%open the file
DirName = ['DIRECTORY_PATH_HERE\'];
File = num2str(NanoStep);
File2 = num2str(Rail);
FileName = strcat('time_adjusted_interpolated_',File2,'mm_',File,'mm_55ps.dat');
fpath = [DirName, FileName];

%import the data
M = importdata(fpath, '\t');
X = M;
X(:,2) = [];
Y = M;
Y(:,1) = [];

%convert the nanostepper position to a delay in mm
mmDelay = NanoStep + Rail - Step;

%convert the x data from the scope time to mm
NumRow = size(X,1);
X = (X.*6.78777148);

%centre the data on the p-p delay in mm
D = X;
D(:,:) = mmDelay;
X = X + D;

%output the data to a tab separated data file
Name = num2str(NanoStep + Rail);
Outfname = [DirName, Name, 'mm.dat'];
fid = fopen(Outfname, 'w'); 
i = 1;
for i = 1:NumRow
    fprintf(fid, '%d\t', X(i,1));
    fprintf(fid, '%E\n', Y(i,1));
    i = i + 1;
end
status = fclose(fid);