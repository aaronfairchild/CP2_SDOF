function [Resp] = ResponseSpectrum(t, h, ag, params, plotConfig)
% Response spectrum for earthquake ground acceleration

if plotConfig.showRespPlots || plotConfig.showTimeHistory
    set(0, 'DefaultTextInterpreter', 'latex');
    set(0, 'DefaultAxesTickLabelInterpreter', 'latex');
    set(0, 'DefaultLegendInterpreter', 'latex');
    set(0, 'DefaultAxesFontSize', 14);
    set(0, 'DefaultTextFontSize', 14);
end

% Extract parameters or use defaults
omegaMin = params.omegaMin;
omegaMax = params.omegaMax;
nPts = params.nPts;
xi = params.xi;

% Optional parameters with defaults
if isfield(params, 'wCheckIdx')
    wCheckIdx = params.wCheckIdx;
else
    wCheckIdx = round(nPts/10); % Default to ~10% of points
end

if isfield(params, 'm')
    m = params.m;
else
    m = 1;
end

if isfield(params, 'uo')
    uo = params.uo;
else
    uo = 0;
end

if isfield(params, 'vo')
    vo = params.vo;
else
    vo = 0;
end

LoadType = 0; % For ground acceleration
tf = t(end);  % Final time from time vector

% frequency range and init
omega = linspace(omegaMin, omegaMax, nPts);
wCheck = omega(wCheckIdx);
Resp = zeros(nPts, 2);

% Create figure if needed
if plotConfig.showRespPlots || plotConfig.showTimeHistory
    figure('Name','Earthquake Response Spectrum'); clf;
    FigSize = [0.5, 0.1, 0.5, 0.75];
    set(gcf, 'Units', 'Normalized', 'OuterPosition', FigSize)
end

for i = 1:nPts
    k = omega(i)^2*m;
    c = 2*xi*omega(i)*m;
    
    d = [1, k, 0, 0]; % d= [Model Type, k, b, So]

    [U] = Newmark(h,LoadType,m,c,d,tf,uo,vo,ag);
    [Umax, idxMax] = max(abs(U(:,2)));
    Resp(i,:) = [omega(i) Umax];

    if i == wCheckIdx && plotConfig.showTimeHistory
        % u vs t for a given natural frequency (omega)
        subplot(2,2,2); grid on; grid minor;  hold on;
        plot(U(:,1),U(:,2),'k-','LineWidth',2);
        plot(U(idxMax,1), U(idxMax,2), 'ko','MarkerFaceColor','white', ...
            'MarkerSize',8);
        xlabel('$t$'); ylabel('$u(t)$')
        wCheckMaxU = Umax;
        text(0.95, 0.95, sprintf('$\\omega = %.2f$\n$n = %d$', wCheck, wCheckIdx), ...
            'Units', 'normalized', 'FontSize', 14, 'Interpreter', 'latex', ...
            'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', ...
            'BackgroundColor', 'white', 'EdgeColor', 'black');
    end
end
if plotConfig.showRespPlots
    % Earthquake acceleration (ag) v time (t)
    subplot(2,2,1); grid on; grid minor; hold on;
    plot(t,ag,'k-','LineWidth',2)
    xlabel('$a_g(t)$ (sec)'); ylabel('$t$')
    
    % max displacement (u_max) vs natural frequency (omega)
    subplot(2,2,3); grid on; grid minor; hold on;
    plot(Resp(:,1),Resp(:,2),'k-','LineWidth',2)
    plot(wCheck,wCheckMaxU,'ko','MarkerFaceColor','white', ...
            'MarkerSize',8)
    xlabel('$\omega$ (rad/sec)'); ylabel('$u_{max}$')
    
    % max displacement (u_max) vs natural period (T)
    subplot(2,2,4); grid on; grid minor; hold on;
    plot((2*pi)./Resp(:,1),Resp(:,2),'k-','LineWidth',2)
    if plotConfig.showTimeHistory
        plot((2*pi)/wCheck,wCheckMaxU,'ko','MarkerFaceColor','white', ...
            'MarkerSize',8)
    end
    xlabel('$T$ (sec)'); ylabel('$u_{max}$')
    xlim([0, max((2*pi)./Resp(:,1))])
end
end