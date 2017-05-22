%take the FFT of the input signal and output the Absolute, real and imaginary parts

%import the data for the input pulse
DirName = 'DIRECTORY_PATH_HERE\';
fpath = [DirName, 'Gaussian_pulse.dat'];
M = importdata(fpath, '\t');

%take X and Y parts of signal
X = M;
X(:,2) = [];
Y = M;
Y(:,1) = [];

%check the parameters for fft calculation
sample_period = X(2)-X(1); 
sample_freq = 1/sample_period;
N = length(Y); %number of points in the input signal
NFFT = 2^nextpow2(N); % next power of 2 from length of Y
Y(1) = [];

%take the FFT and get the frequency axis
FourTrans = fft(Y,NFFT)/N; %FT%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%this could be wrong maybe normalise it to sample_freq or N*sampl_freq
FT = 2*abs(FourTrans(1:NFFT/2+1)); %FT for plotting
realFT = 2*real(FourTrans(1:NFFT/2+1)); %real part of FT for plotting
imagFT = 2*imag(FourTrans(1:NFFT/2+1)); %imaginary part of FT for plotting
Freq = sample_freq/2*linspace(0,1,NFFT/2+1); %frequency axis

%plot the result
figure;
hold on
plot(Freq,realFT,'r-x');
plot(Freq,imagFT,'g-x');
plot(Freq,FT,'-x');

%output the data to a file to the input file directory
OutfnameAbs = [DirName, 'AbsFT.dat'];
OutfnameRe = [DirName, 'ReFT.dat'];
OutfnameIm = [DirName, 'ImFT.dat'];
fidAbs = fopen(OutfnameAbs, 'w');
fidRe = fopen(OutfnameRe, 'w');
fidIm = fopen(OutfnameIm, 'w');
i = 1;
for i = 1:length(Freq);
    fprintf(fidAbs, '%d\t', Freq(1,i));
    fprintf(fidAbs, '%E\n', FT(i,1));
    fprintf(fidRe, '%d\t', Freq(1,i));
    fprintf(fidRe, '%E\n', realFT(i,1));
    fprintf(fidIm, '%d\t', Freq(1,i));
    fprintf(fidIm, '%E\n', imagFT(i,1));
    i = i + 1;
end    
status = fclose(fidAbs);
status = fclose(fidRe);
status = fclose(fidIm);
    

        



