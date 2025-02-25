function [ag, t] = FakeEq(tf, h, EqOn, plotConfig)
% Generate ground acceleration (ag)

set(0, 'DefaultTextInterpreter', 'latex');
set(0, 'DefaultAxesTickLabelInterpreter', 'latex');
set(0, 'DefaultLegendInterpreter', 'latex');
set(0, 'DefaultAxesFontSize', 14);
set(0, 'DefaultTextFontSize', 14);

% Number of time points and initialize ag
nSteps = ceil(tf/h);
ag = zeros(nSteps,1);
vg = zeros(nSteps,1);
ug = zeros(nSteps,1);
t = linspace(0, tf, nSteps)';

if EqOn == 1

    % EQ parameters
    so = 0.0125;            % Magnitude
    a = 2;                  % Exponent for growth
    b = 0.15;               % Exponent for decay

    Amp = [0.2981 0.4472 0.5963 0.5963];
    Freq = [1 2 5 10];
    Phi = [0 0 0 0];
    N = length(Amp);

    for i = 1:nSteps
        time = t(i);
        s = so * time^a * exp(-b * time);
        for j = 1:N
            ag(i) = ag(i) + s*Amp(j)*sin(Freq(j)*time + Phi(j));
        end
    end

    % Compute vg and ug
    uold = 0;
    vold = 0;
    aold = 0;

    for i=1:nSteps
        ug(i) = uold;
        vg(i) = vold;
        anew = ag(i);
        vnew = vold + 0.5*h*(aold+anew);
        unew = uold + 0.5*h*(vold+vnew);
        uold = unew;
        vold = vnew;
        aold = anew;
    end

    % adjust to make velocity goto zero at tf
    vg = vg - vold;
    ug = ug - vold*t;

    vgFinal = vg(end);

    if plotConfig.showEqPlots
        set(0, 'DefaultTextInterpreter', 'latex');
        set(0, 'DefaultAxesTickLabelInterpreter', 'latex');
        set(0, 'DefaultLegendInterpreter', 'latex');
        set(0, 'DefaultAxesFontSize', 14);
        set(0, 'DefaultTextFontSize', 14);

        figure(3); clf; grid on; hold on;
        FigSize = [0, 0.1, 0.6, 0.5];
        set(gcf, 'Units', 'Normalized', 'OuterPosition', FigSize)

        % Acceleration (ag)
        subplot(1, 3, 1); grid on; grid minor; hold on;
        plot(t, ag, '-', 'Color', 'k', 'LineWidth', 1)
        xlabel('$t$'); ylabel('$\ddot{u}_{g}(t)$');

        % Velocity (vg)
        subplot(1, 3, 2); grid on; grid minor; hold on;
        plot(t, vg, '-', 'Color', 'k', 'LineWidth', 1)
        xlabel('$t$'); ylabel('$\dot{u}_g(t)$');

        % Displacement (ug)
        subplot(1, 3, 3); grid on; grid minor; hold on;
        plot(t, ug, '-', 'Color', 'k', 'LineWidth', 1)
        xlabel('$t$'); ylabel('$u_g(t)$');
    end

    % Print output
    fprintf('FakeEq:\n')
    fprintf('  EARTHQUAKE CHARACTERISTICS\n');
    fprintf('  Earthquake Duration (tD)       %6.3f\n', tf);
    fprintf('  Time increment (dt)             %6.3f\n', h);
    fprintf('  Number of time steps           %7i\n', nSteps);
    fprintf('  Earthquake type                %7s\n', 'unknown');
    fprintf('  Time shape fcn parameters :     %6.3f %6.3f %6.3f\n', a, b, so);
    fprintf('     Amp      Freq      Phase\n');
    for i = 1:size(Amp,2)
        fprintf('  %6.3f    %6.3f     %6.3f\n', Amp(i), Freq(i), Phi(i));
    end

    fprintf('\n  Final velocity: %1.4e\n\n', vgFinal);
end
end