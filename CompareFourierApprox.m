function [ag_series, error_metrics, t_out] = CompareFourierApprox(t, ag, k, plotResults, h)
% CompareFourierApprox - Compare original acceleration with Fourier approximation
%
% INPUTS:
%   t - Original time vector
%   ag - Original acceleration data
%   k - Number of Fourier terms to use
%   plotResults - Boolean flag to plot results (optional, default=false)
%   h - Custom time step for output (optional, if omitted, original time vector is used)
%
% OUTPUTS:
%   ag_series - Fourier series approximation
%   error_metrics - Structure containing error metrics
%   t_out - Output time vector (same as input if h not specified)

% Default for plotting
if nargin < 4 || isempty(plotResults)
    plotResults = false;
end

% Compute FFT parameters
N = length(ag);          % Number of data points
T = t(2) - t(1);         % Original sampling interval
Fs = 1/T;                % Original sampling frequency

% Compute Fourier coefficients using FFT
Y = fft(ag); 

% Frequency axis for all coefficients
f = (0:N-1) * (Fs/N);    % Frequency range

% Extract Fourier coefficients for reconstruction
a0 = Y(1)/N;             % DC component
a = 2*real(Y(2:k+1))/N;  % Cosine coefficients
b = -2*imag(Y(2:k+1))/N; % Sine coefficients
f_k = f(2:k+1);          % Corresponding frequencies

% Determine if we're using the original time vector or a new one
if nargin < 5 || isempty(h)
    % Use original time vector
    t_out = t;
else
    % Create new time vector with specified step size
    t_out = (0:h:t(end))';
end

% Ensure correct matrix dimensions for broadcasting
[t_grid, f_grid] = meshgrid(t_out, f_k);

% Compute Fourier series reconstruction
ag_series = a0 + sum(a .* cos(2*pi*f_grid.*t_grid) + b .* sin(2*pi*f_grid.*t_grid), 1);

% Transpose to get column vector
ag_series = ag_series';

% Calculate error metrics if we're using the original time vector
if isequal(t_out, t)
    error = ag - ag_series;
    rmse = sqrt(mean(error.^2));
    max_error = max(abs(error));
    mean_error = mean(abs(error));
    relative_error = 100 * rmse / (max(ag) - min(ag)); % Percent of range
else
    % For a different time vector, interpolate original data to new time points
    ag_interp = interp1(t, ag, t_out, 'linear');
    
    % Calculate error metrics against interpolated original data
    error = ag_interp - ag_series;
    rmse = sqrt(mean(error.^2));
    max_error = max(abs(error));
    mean_error = mean(abs(error));
    relative_error = 100 * rmse / (max(ag_interp) - min(ag_interp)); % Percent of range
end

% Create error metrics structure
error_metrics = struct('RMSE', rmse, 'MaxError', max_error, ...
                       'MeanError', mean_error, 'RelativeError', relative_error);

% Plot results if requested
if plotResults
    figure('Name', 'Fourier Series Approximation');
    
    % Plot time series comparison
    subplot(2,1,1);
    if isequal(t_out, t)
        % Using original time vector
        plot(t, ag, 'k', 'DisplayName', 'Original Data');
    else
        % Using new time vector - plot interpolated original data
        plot(t_out, ag_interp, 'k', 'DisplayName', 'Original Data (Interpolated)');
    end
    hold on;
    plot(t_out, ag_series, 'b', 'LineWidth', 1.5, 'DisplayName', ['Fourier Series (', num2str(k), ' terms)']);
    xlabel('Time (s)');
    ylabel('Acceleration (g)');
    title('Fourier Series Approximation of Earthquake Acceleration');
    legend('Location', 'best');
    grid on;
    
    % Plot error
    subplot(2,1,2);
    plot(t_out, error, 'r', 'LineWidth', 1.2);
    xlabel('Time (s)');
    ylabel('Error (g)');
    title(['Approximation Error (RMSE = ', num2str(rmse, '%.4e'), ', Relative Error = ', num2str(relative_error, '%.2f'), '%)']);
    grid on;
    
    % Display error metrics in command window
    fprintf('\nFourier Series Approximation Results (k = %d terms):\n', k);
    fprintf('  RMSE:                   %.6e\n', rmse);
    fprintf('  Maximum Absolute Error: %.6e\n', max_error);
    fprintf('  Mean Absolute Error:    %.6e\n', mean_error);
    fprintf('  Relative Error:         %.2f%%\n', relative_error);
    
    if ~isequal(t_out, t)
        fprintf('  Using custom time step:   %.6f s\n', h);
        fprintf('  Original number of points: %d\n', length(t));
        fprintf('  New number of points:      %d\n', length(t_out));
    end
end
end