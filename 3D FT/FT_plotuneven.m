%3D plot for stage positions that are not evenly spaced

%files should be labeled as the stage position at which the FT is taken
%
%put the FT file names to be plotted in a vector
inputfiles = [2.5:3:149.5, 150, 162:6:450];
ppstep = 0;  %the step position of the pump-probe trace (mm)

%create the X data which is to be plotted
X = inputfiles;
X(:,:) = (X(:,:) - ppstep)*6.6666666;

%directory the files are in
DirName = 'DIRECTORY_HERE\';

FirstFile = num2str(inputfiles(1,1));
fname = [DirName, FirstFile, 'mm.dat'];

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
    fname = [DirName, File, 'mm.dat'];
    M = importdata(fname, '\t');
    M(:,1) = [];
    Z(:,counter) = Z(:,counter) + M;
    counter = counter + 1;
end

Z(:,:) = sqrt(Z(:,:));

%resize the arrays to plot only the required region
%Y(1:500,:) = [];
%Y(1000:end,:) = [];
%Z(1:500,:) = [];
%Z(1000:end,:) = [];

%plot the FTs as a function of time
figure
F = surf(X,Y,Z);
shading interp;
xlabel('Time delay (ps)','FontSize',12);
ylabel('Frequency (GHz)','FontSize',12);
zlabel('Z (arb. units)','FontSize',12);





