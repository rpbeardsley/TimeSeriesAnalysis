%Plot the FTs as a function of time
%
%Input information
%
%Files should be labled as the stage position at which the FT represents
% method for evenly spaced stage positions
inputfiles = [39.2,51.2,75.2:12:147.2,170:20:210,225];
ppstep = 7;       %pump-probe step position (mm)
MinPeak = 231;       %min peak value for integration
MaxPeak = 303;       %max peak value for integration
%method for random stage positions
%create a vector with the file names in it

DirName = 'DIRECTORY_HERE\';
%
%end input information

fname = [DirName,num2str(inputfiles(1,1)),'mm.dat'];


%0mm_150mm_758nm_43mW_fourier.dat

%take the Y (frequency) data and see how many rows there are
M = importdata(fname, '\t');
Y = M;
Y(:,2) = [];
NumRow = size(Y, 1);
%other input method--------
%fid = fopen(fname, 'r');
%data = textscan(fid, '%f %f','headerlines', 0);
%X = data{1}
%Y = data{2}
%status = fclose(fid);
%end other input method-----

%create the matrix for the X (time) data and for the Z (height) data to be
%wrtiten to
X = inputfiles;
columns = size(X, 2);
Z = zeros(NumRow, columns);

%setup the loop that will add the vectorised Z data in
counter = 1;
%add in the Z data to the Z matrix
for counter = 1:columns
    File =  [num2str(inputfiles(1,counter)),'mm.dat'];
    fname = [DirName, File,];
    M = importdata(fname, '\t');
    M(:,1) = [];
    Z(:,counter) = Z(:,counter) + M;
    counter = counter + 1;
end

Yb = Y;
Xb = X;
Zb = Z;

%resize the arrays to show the region of interest
%X(:,1:24) = [];

Y(1:59,:) = [];
Y(1292:end,:) = [];

Z(1:59,:) = [];    %to match Y
Z(1292:end,:) = []; %to match Y
%Z(:,1:24) = [];    %to match X

%Change the mm delay into ps
X(:,:) = (X(:,:) - ppstep)*6.6666666;

%Z(:,:) = sqrt(Z(:,:));

%make and decorate a surface plot %%%%%%%%%%%%%%%%%%%
figure
F = surf(X,Y,Z);
%set(F,'FaceColor','y','FaceAlpha',1,'edgecolor','none');
shading interp;
brighten(0.6);
xlabel('time (ps)');
ylabel('frequency (GHz)');
zlabel('fourier power spectrum (arb. units)');
hold on

%change the colormap to provide contrast in the right region
cmap=colormap;
contmap=contrast(Z,size(cmap,1));
I=contmap(:,1);
I=round(I*size(cmap,1));
cmap2=cmap(I,:);
cmap3=(cmap2*1 + cmap*2)/3;
colormap(cmap3);

%put a line on the peak of the high frequency
%Yln1 = zeros(size(X,2),1);
%Yln1(:,:) = Y(149,1);
%A = plot3(X,Yln1,Z(149,:),'-r');
%set(A,'LineWidth',2)
%put a second on the low frequency peak
%Yln2 = zeros(size(X,2),1);
%Yln2(:,:) = Y(52,1);
%B = plot3(X,Yln2,Z(52,:),'-k');
%set(B,'LineWidth',2)

%end of surface plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Xc = Xb;
Yc = Yb;
Zc = Yb;
%Integrate under the peak in the FT and put the values in a vector
%Xb(:,:) = (Xb(:,:) - ppstep)*6.6666666;
Xc(:,:) = (Xc(:,:) - ppstep)*6.6666666;


%Zb(:,:) = sqrt(Zb(:,:));

Intg = zeros(columns,1);

for c = 1:columns;
    J = sum(Zb(MinPeak:MaxPeak, c));
    Intg(c,:) = Intg(c,:) + J;
    c = c + 1;
end;

%Plot the integrated values against time
figure;
plot(Xc, Intg, '-');
title('Integral under peak against time');
xlabel('Time (ps)');
ylabel('Integral (arb. units)');

%output the data to a file
Outfname = [DirName, 'Integrated Peak.dat'];
fid = fopen(Outfname, 'w'); 
i = 1;
for i = 1:columns
    fprintf(fid, '%d\t', Xc(1,i));
    fprintf(fid, '%E\n', Intg(i,1));
    i = i + 1;
end
fprintf(fid, '/et    x "time (ps)"     ;axis title');
fprintf(fid, '\n');
fprintf(fid, '/et    y "integrated Peak (arb. units)"        ;axis title');
status = fclose(fid);