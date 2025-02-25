function [t, ug, vg, ag] = FakeEq(tf, h, EqOn, plotConfig, eqParams)
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

    % Set default EQ params if not provided
    if nargin < 5 || isempty(eqParams)
        % Default
        so = 0.0125; % Magnitude
        a = 2;       % Exponent for growth
        b = 0.15;    % Exponent for decay
        Amp = [0.2981 0.4472 0.5963 0.5963];
        Freq = [1 2 5 10];
        Phi = [0 0 0 0];
    else
        % if provided
        so = eqParams.so;
        a = eqParams.a;
        b = eqParams.b;
        Amp = eqParams.Amp;
        Freq = eqParams.Freq;
        Phi = eqParams.Phi;
    end
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

    if plotConfig.showEqPlots
        set(0, 'DefaultTextInterpreter', 'latex');
        set(0, 'DefaultAxesTickLabelInterpreter', 'latex');
        set(0, 'DefaultLegendInterpreter', 'latex');
        set(0, 'DefaultAxesFontSize', 14);
        set(0, 'DefaultTextFontSize', 14);

        figure('Name','Artificial Earthquake Ground Motion'); 
        clf; grid on; hold on;
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
end
end