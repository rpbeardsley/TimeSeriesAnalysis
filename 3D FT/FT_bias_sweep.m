%3D plot for bias' that are not evenly spaced (plots the FTs as a function
%of bias)
%
%put the FT file names to be plotted in a vector
inputfiles = [100,130,150,160,175,180,190,200,210,220];
MinPeak = 68;        %min peak value for integration
MaxPeak = 158;       %max peak value for integration

%create the X (bias) data which is to be plotted
X = inputfiles;

%directory the files are in
DirName = 'DIRECTORY_HERE\';

FirstFile = num2str(inputfiles(1,1));
fname = [DirName, FirstFile, 'mV.dat'];

%take the Y (frequency) data and see how many rows there are
M = importdata(fname, '\t');
Y = M;
Y(:,2) = [];
NumRow = size(Y, 1);
columns = size(X, 2);

%create the Z matrix
Z = zeros(NumRow,columns);

%setup the loop to add in the data
counter = 1;
for counter = 1:columns
    File = num2str(inputfiles(1,counter));
    fname = [DirName, File, 'mV.dat'];
    M = importdata(fname, '\t');
    M(:,1) = [];
    Z(:,counter) = Z(:,counter) + M;
    counter = counter + 1;
end

Z(:,:) = sqrt(Z(:,:));

%resize the arrays to plot only the required region
%Y(1:500,:) = [];
Y(300:end,:) = [];
%Z(1:500,:) = [];
Z(300:end,:) = [];

%plot the FTs as a function of time
figure
F = surf(X,Y,Z);
shading interp;
xlabel('Bias (mV)','FontSize',12);
ylabel('Frequency (GHz)','FontSize',12);
zlabel('Z (arb. units)','FontSize',12);

%Integrate under the peak in the FT and put the values in a vector
Intg = zeros(columns,1);

for c = 1:columns;
    J = sum(Z(MinPeak:MaxPeak, c));
    Intg(c,:) = Intg(c,:) + J;
    c = c + 1;
end;

%Plot the integrated values against time
figure;
plot(X, Intg, '-');
title('Integral under peak against time');
xlabel('Time (ps)');
ylabel('Integral (arb. units)');

%Output the integrated peak
Outfname = [DirName, 'Integrated Peak.dat'];
fid = fopen(Outfname, 'w'); 
i = 1;
for i = 1:columns
    fprintf(fid, '%d\t', X(1,i));
    fprintf(fid, '%E\n', Intg(i,1));
    i = i + 1;
end
fprintf(fid, '/et    x "bias (mV)"     ;axis title');
fprintf(fid, '\n');
fprintf(fid, '/et    y "integrated Peak (arb. units)"        ;axis title');
status = fclose(fid);





