%check correctness of an output
clear;
addpath('1'); %select folder
complex_result %add output from simulation

angle = 2 * pi * (output(:,1)) / 4096;
%raw input (read as unsigned integer)
real_r = output(:,2);
imag_r = output(:,3);
%2's compl mask (for negative values)
real_m = real_r >= 32768;
imag_m = imag_r >= 32768;
%properly read 2's complement values
realSim = (real_r - real_m * 65536) / 16384;
imagSim = (imag_r - imag_m * 65536) / 16384;
%number
zSim = realSim + 1i*imagSim;

%Matlab calc
zMat = exp(1i * angle);

%difference
DiffErrEnergy = difff(zSim, zMat, 'Simulation', 'Matlab');