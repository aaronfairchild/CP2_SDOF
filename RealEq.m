% Aaron Fairchild
% Looking at a real EQ and approximating it w FFT

% Define file name
filename = 'RSN740_LOMAP_ADL340.AT2';

% Open the file
fid = fopen(filename, 'r');

% Skip the first three lines
for i = 1:3
    fgetl(fid);
end

% Read the fourth line to get NPTS and DT
line = fgetl(fid);
tokens = regexp(line, 'NPTS=\s*(\d+),\s*DT=\s*([\d.]+)', 'tokens');
NPTS = str2double(tokens{1}{1});
DT = str2double(tokens{1}{2});

% Read acceleration values
data = fscanf(fid, '%f');

% Close the file
fclose(fid);

% Generate time vector
t = (0:NPTS-1)' * DT;

% Assign acceleration vector
ag = data;

% Load the data (assuming you've already parsed t and ag)
N = length(ag);   % Number of data points
T = t(2) - t(1);  % Sampling interval (should be equal to DT)
Fs = 1/T;         % Sampling frequency

% Compute Fourier coefficients using FFT
Y = fft(ag); 

% Frequency axis
f = (0:N-1) * (Fs/N); % Frequency range

% Reconstruct signal with a limited number of Fourier coefficients (optional)
k = 100; % Number of terms to keep (adjust for better approximation)

% Extract first k Fourier coefficients
a0 = Y(1)/N; % DC component
a = 2*real(Y(2:k+1))/N; % Cosine coefficients
b = -2*imag(Y(2:k+1))/N; % Sine coefficients
f_k = f(2:k+1); % Corresponding frequencies

% Ensure correct matrix dimensions
[t_grid, f_grid] = meshgrid(t, f_k); % Create matrices for broadcasting

% Compute Fourier series reconstruction
ag_series = a0 + sum(a .* cos(2*pi*f_grid.*t_grid) + b .* sin(2*pi*f_grid.*t_grid), 1);

% Plot Fourier series approximation
figure;
plot(t, ag, 'k', 'DisplayName', 'Original Data');
hold on;
plot(t, ag_series, 'b', 'LineWidth', 1.5, 'DisplayName', 'Fourier Series Approximation');
xlabel('Time (s)');
ylabel('Acceleration (g)');
title('Fourier Series Approximation (Explicit Sum)');
legend;
grid on;

P2 = abs(Y)/N;    % Normalize magnitude
P1 = P2(1:floor(N/2)+1); % Keep only the positive half (symmetry)
P1(2:end-1) = 2*P1(2:end-1); % Double non-DC terms for energy conservation

% Frequency axis
f = Fs * (0:floor(N/2)) / N;

% Convert frequency to period (avoid divide-by-zero for DC component)
valid_idx = f > 0; % Ignore f=0 (infinite period)
T_vals = 1 ./ f(valid_idx); % Convert to period

% Plot Magnitude Spectrum vs. Period
figure;
plot(T_vals, P1(valid_idx), 'b', 'LineWidth', 1.5);
set(gca, 'XScale', 'log'); % Log scale for better visualization
xlabel('Period (seconds)');
ylabel('Magnitude');
title('Fourier Spectrum in Terms of Period');
grid on;
xlim([min(T_vals) max(T_vals)]); % Set reasonable x-axis limits

