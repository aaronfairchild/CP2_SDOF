function CompareResponseSpectra(fourier_terms)
% CompareResponseSpectra - Compare response spectra for different configurations
%   CompareResponseSpectra(fourier_terms) generates and plots response
%   spectra for different structural models and damping types on the same
%   plot for easy comparison.
%
% Inputs:
%   fourier_terms - Number of terms to use in Fourier approximation
%                  (optional, default = 200)
%
% Example:
%   CompareResponseSpectra(200);
%
% By Aaron Fairchild
% Date: February 27, 2025

% Set default Fourier terms if not provided
if nargin < 1
    fourier_terms = 300;
end

% Start timing
tic;

% Set plotting preferences
set(0, 'DefaultTextInterpreter', 'latex');
set(0, 'DefaultAxesTickLabelInterpreter', 'latex');
set(0, 'DefaultLegendInterpreter', 'latex');
set(0, 'DefaultAxesFontSize', 14);
set(0, 'DefaultTextFontSize', 14);

fprintf('Generating earthquake response spectra for comparison...\n');

% Configuration 1: Linear Elastic with Linear Viscous damping
fprintf('\n--- Configuration 1: Linear Elastic with Linear Viscous Damping ---\n');
[T1, Sa1] = EarthquakeResponseSpectrum(1, 1, [], fourier_terms);

% Configuration 2: Elastoplastic with Linear Viscous damping
fprintf('\n--- Configuration 2: Elastoplastic with Linear Viscous Damping ---\n');
[T2, Sa2] = EarthquakeResponseSpectrum(4, 1, [], fourier_terms);

% Configuration 3: Elastoplastic with Coulomb Friction damping
fprintf('\n--- Configuration 3: Elastoplastic with Coulomb Friction Damping ---\n');
mu = 0.05; N = 9.81; % Friction coefficient and normal force
coulomb_params = [mu, N, 0.001]; % Regularization parameter = 0.001
[T3, Sa3] = EarthquakeResponseSpectrum(4, 2, coulomb_params, fourier_terms);

% Create a new figure for comparison
figure('Name', 'Response Spectra Comparison');
figSize = [0.2, 0.2, 0.7, 0.7];
set(gcf, 'Units', 'normalized', 'OuterPosition', figSize);

% Plot all spectra on the same axes
subplot(2,1,1); grid on; hold on;
p1 = plot(T1, Sa1, 'b-', 'LineWidth', 2);
p2 = plot(T2, Sa2, 'r-', 'LineWidth', 2);
p3 = plot(T3, Sa3, 'g-', 'LineWidth', 2);

% Add labels and legend
xlabel('Period $T$ (s)');
ylabel('Pseudo-acceleration $S_a = \omega^2 u_{max}$');
title(sprintf('Response Spectra Comparison (Fourier terms: %d)', fourier_terms));
legend([p1, p2, p3], ...
       {'Linear Elastic, Linear Viscous Damping', ...
        'Elastoplastic, Linear Viscous Damping', ...
        'Elastoplastic, Coulomb Friction'}, ...
        'Location', 'northeast');

xlim([min(T1), max(T1)]);

% Show ratio of elastoplastic to elastic response
subplot(2,1,2); grid on; hold on;
plot(T1, Sa2./Sa1, 'r-', 'LineWidth', 2);
plot(T1, Sa3./Sa1, 'g-', 'LineWidth', 2);
plot(T1, ones(size(T1)), 'k--', 'LineWidth', 1);

xlabel('Period $T$ (s)');
ylabel('Ratio to Linear Elastic Response');
title('Effect of Nonlinearity and Damping Type');
legend({'Elastoplastic/Linear, Viscous Damping', ...
        'Elastoplastic/Linear, Coulomb Friction'}, ...
        'Location', 'northeast');

xlim([min(T1), max(T1)]);
ylim([0, 2]);

% Print total execution time
total_time = toc;
fprintf('\nComparison completed in %.2f seconds.\n', total_time);

end