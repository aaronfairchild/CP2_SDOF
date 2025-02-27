%-----------------------------------------------------------------------
%   CP 2 - SDOF
%
%     Author:  Aaron Fairchild
%     Date:    February 27, 2025
%-----------------------------------------------------------------------
tic; clear; clc; 
delete(findall(0, 'Type', 'figure')); % gets rid of all open figures
set(0, 'DefaultTextInterpreter', 'latex');
set(0, 'DefaultAxesTickLabelInterpreter', 'latex');
set(0, 'DefaultLegendInterpreter', 'latex');

doPoDs = false; % Run the PoD Benchmark cases? (true/false)

if doPoDs
    % Run PoD6 (a and b), with benchmark parameters
    PoD6a();
    PoD6b();

    % Run PoD7, with benchmark parameters
    PoD7();

    % Run PoD8( a and b), with benchmark parameters
    PoD8a();
    PoD8b();

    % Run PoD9, with benchmark parameters
    PoD9();

    % Run PoD10, with benchmark parameters
    PoD10();

    % Run PoD11, with benchmark parameters
    PoD11();
end

% VERIFICATION 

% Real the earthquake, using Loma Prieta
[t, ag] = RealEq();

% Generate and plot Fourier approx spectrum
[f, P1, T_vals] = FourierSpectrum(t, ag, true); % last input (plot: T/F)

% Compare real eq data with Fourier series approx
term_counts = [50, 100, 200, 500];
results = cell(length(term_counts), 1);

for i = 1:length(term_counts)
    k = term_counts(i);
    
    [ag_approx, error_metrics] = CompareFourierApprox(t, ag, k, false);
    
    % Store results
    results{i} = struct('TermCount', k, 'Approximation', ...
        ag_approx, 'Metrics', error_metrics);
end

% Plot comparison
figure('Name', 'Comparison of Approximation Accuracy', 'Position', ...
    [100, 100, 1000, 600]);

% Plot time series for a segment of data
subplot(2,1,1);
endTime = 10; % time to stop plot, (sec)
end_idx = find(t >= endTime, 1);
if isempty(end_idx), end_idx = length(t); end % its there, but just incase

plot(t(1:end_idx), ag(1:end_idx), 'k', 'LineWidth', 1.5, ...
    'DisplayName', 'Original');
hold on;
colors = {'b', 'r', 'g', 'm'};
for i = 1:length(results)
    plot(t(1:end_idx), results{i}.Approximation(1:end_idx), ...
        colors{mod(i-1,4)+1}, 'LineWidth', 1, ...
        'DisplayName', sprintf('%d terms', results{i}.TermCount));
end
xlabel('Time (s)');
ylabel('Acceleration (g)');
% MAKE SURE TO CHANGE TITLE IF YOU CHANGE ENDTIME PLZ
title('Time Domain Comparison (First 10 seconds)');
legend('Location', 'best');
grid on;

% Plot error metrics vs. num  of terms
subplot(2,1,2);
term_counts = cellfun(@(x) x.TermCount, results);
rmse_values = cellfun(@(x) x.Metrics.RMSE, results);
rel_errors = cellfun(@(x) x.Metrics.RelativeError, results);

yyaxis left;
semilogy(term_counts, rmse_values, 'bo-', 'LineWidth', 1.5);
ylabel('RMSE');

yyaxis right;
plot(term_counts, rel_errors, 'rs-', 'LineWidth', 1.5);
ylabel('Relative Error (\%)');

xlabel('Number of Fourier Terms');
title('Error Metrics vs. Number of Terms');
grid on;

% Start study
CompareResponseSpectra(200);


elapsedTime = toc; 
fprintf(['Elapsed time since start: %.2f seconds.\n' ...
         'Normal Termination of Program.\n'], elapsedTime);