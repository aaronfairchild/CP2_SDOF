function [ag] = FakeEq(tf,h,EqOn)
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

if EqOn == 1

    % EQ parameters
    so = 0.0125;            % Magnitude
    a = 2;                  % Exponent for growth
    b = 0.15;               % Exponent for decay

    Amp = [0.2981 0.4472 0.5963 0.5963];
    Freq = [1 2 5 10];
    Phi = [0 0 0 0];
    N = length(Amp);
    time = linspace(0,tf,nSteps);

    for i = 1:nSteps
        t = time(i);
        s = so*t^a*exp(-b*t);
        for j = 1:N
            ag(i) = ag(i) + s*Amp(j)*sin(Freq(j)*t + Phi(j));
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
    ug = ug - vold*time';

    vgFinal = vg(end);
    
    % Plotting
    figure(3); clf; grid on; hold on;
    FigSize = [0,0.1,0.6,0.5];
    set(gcf,'Units','Normalized','OuterPosition',FigSize)
    
    % Acceleration (ag)
    subplot(1,3,1); grid on; grid minor; hold on;
    plot(time,ag,'-','Color','k','LineWidth',1)
    xlabel('$t$'); ylabel('$\ddot{u}_{g}(t)$');
    
    % Velocity (vg)
    subplot(1,3,2); grid on; grid minor; hold on;
    plot(time,vg,'-','Color','k','LineWidth',1)
    xlabel('$t$'); ylabel('$\dot{u}_g(t)$');
    
    % Displacement (ug)
    subplot(1,3,3); grid on; grid minor; hold on;
    plot(time,ug,'-','Color','k','LineWidth',1)
    xlabel('$t$'); ylabel('$u_g(t)$');

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