function [ag_series, error_metrics] = CompareFourierApprox(t, ag, k, plotResults)
% CompareFourierApprox - Compare original acceleration with Fourier approximation

% Compute FFT parameters
N = length(ag);          % Number of data points
T = t(2) - t(1);         % Sampling interval
Fs = 1/T;                % Sampling frequency

% Compute Fourier coefficients using FFT
Y = fft(ag); 

% Frequency axis for all coefficients
f = (0:N-1) * (Fs/N);    % Frequency range

% Extract Fourier coefficients for reconstruction
a0 = Y(1)/N;             % DC component
a = 2*real(Y(2:k+1))/N;  % Cosine coefficients
b = -2*imag(Y(2:k+1))/N; % Sine coefficients
f_k = f(2:k+1);          % Corresponding frequencies

% Ensure correct matrix dimensions for broadcasting
[t_grid, f_grid] = meshgrid(t, f_k);

% Compute Fourier series reconstruction
ag_series = a0 + sum(a .* cos(2*pi*f_grid.*t_grid) + b .* sin(2*pi*f_grid.*t_grid), 1);

% Calculate error metrics
error = ag - ag_series';
rmse = sqrt(mean(error.^2));
max_error = max(abs(error));
mean_error = mean(abs(error));
relative_error = 100 * rmse / (max(ag) - min(ag)); % Percent of range

% Create error metrics structure
error_metrics = struct('RMSE', rmse, 'MaxError', max_error, ...
                       'MeanError', mean_error, 'RelativeError', relative_error);

% Plot results if requested
if plotResults
    figure('Name', 'Fourier Series Approximation');
    
    % Plot time series comparison
    subplot(2,1,1);
    plot(t, ag, 'k', 'DisplayName', 'Original Data');
    hold on;
    plot(t, ag_series, 'b', 'LineWidth', 1.5, 'DisplayName', ['Fourier Series (', num2str(k), ' terms)']);
    xlabel('Time (s)');
    ylabel('Acceleration (g)');
    title('Fourier Series Approximation of Earthquake Acceleration');
    legend('Location', 'best');
    grid on;
    
    % Plot error
    subplot(2,1,2);
    plot(t, error, 'r', 'LineWidth', 1.2);
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
end
end