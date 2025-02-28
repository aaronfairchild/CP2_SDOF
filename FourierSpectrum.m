function [f, P1, T_vals] = FourierSpectrum(t, ag, plotResults)
% FourierSpectrum - Generate and plot Fourier spectrum of earthquake data
% Author: Aaron Fairchild
% Date: February 27, 2025
% Modified: Added PSD calculation and plot
%
% INPUTS:
%   t - time vector
%   ag - acceleration data
%   plotResults - boolean flag to plot results
%
% OUTPUTS:
%   f - frequency vector (Hz)
%   P1 - magnitude spectrum
%   T_vals - period values (seconds)
%   PSD - Power Spectral Density

% Compute FFT parameters
N = length(ag);          % Number of data points
T = t(2) - t(1);         % Sampling interval
Fs = 1/T;                % Sampling frequency

% Compute Fourier coefficients using FFT
Y = fft(ag); 

% Compute magnitude spectrum
P2 = abs(Y)/N;           % Normalize magnitude
P1 = P2(1:floor(N/2)+1); % Keep only the positive half (symmetry)
P1(2:end-1) = 2*P1(2:end-1); % Double non-DC terms for energy conservation

% Frequency axis
f = Fs * (0:floor(N/2)) / N;

% Convert frequency to period
valid_idx = f > 0;       % Ignore f=0 (infinite period)
T_vals = 1 ./ f(valid_idx); % Convert to period

% Plot results if requested
if plotResults
    figure('Name', 'Fourier Spectrum Analysis', ...
        'Position', [100, 100, 1000, 300]);
    
    % Magnitude Spectrum vs. Period
    plot(T_vals, P1(valid_idx), 'b', 'LineWidth', 1.5);
    set(gca, 'XScale', 'log'); % Log scale for better visualization
    xlabel('Period (seconds)');
    ylabel('Magnitude');
    title('Fourier Spectrum in Terms of Period');
    grid on;
    xlim([min(T_vals) max(T_vals)]); % Set reasonable x-axis limits
    
end
end