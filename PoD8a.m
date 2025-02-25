% PoD 8a: Response Spectrum
% Code by: Aaron Fairchild
% Original: February 10, 2025
% Latest Update: February 25, 2025
function PoD8a()

set(0, 'DefaultTextInterpreter', 'latex');
set(0, 'DefaultAxesTickLabelInterpreter', 'latex');
set(0, 'DefaultLegendInterpreter', 'latex');
set(0, 'DefaultAxesFontSize', 14);
set(0, 'DefaultTextFontSize', 14);

% Input
nomega = 200; wMin = 0.005; wMax = 20;
omega = linspace(wMin,wMax,nomega);

LoadType = 1;

nxi = 1; xiMin = 0.03; xiMax = .03; % currently set to just do benchmark
xi = linspace(xiMin,xiMax,nxi);

m = 1;
k = omega.^2.*m;

tf = 20;
uo = 0;
vo = 0;

% Integration
h = 0.01;
nSteps = ceil(tf/h);
ag = zeros(nSteps, 1); % No earthquake for benchmark


% Initializing
umax = zeros(nxi, nomega);
Sv = zeros(nxi, nomega);
Sa = zeros(nxi, nomega);

% Plot stuff
figure('Name','PoD 8 Benchmark'); clf; hold on; grid on;
figsize = [0,0.5,0.3,0.5];
set(gcf, 'Units','normalized','OuterPosition', figsize)

legendText = strings(1,nxi);
lineStyles = {'-', '--', '-.', ':'};
baseGrey = 0;    % start at black
greyStep = 0.2;  % lightening increment per cycle

% Loop over each damping raito
for j = 1:nxi

    c = 2.*xi(j).*omega.*m;

    % Loop over each natural frequency
    for i = 1:nomega
        d = [1, k(i), 0, 0];
        [U] = Newmark(h,LoadType,m,c(i),d,tf,uo,vo,ag);
        umax(j,i) = max(U(:,2));
    end

    Sv(j,:) = omega.*umax(j,:);      % Psuedo-velocity
    Sa(j,:) = omega.^2.*umax(j,:);   % Psuedo-acceleartion

    % all this is just for fun plotting
    lineStyle = lineStyles{mod(j-1, numel(lineStyles)) + 1};
    cycle = floor((j-1) / numel(lineStyles));
    greyVal = baseGrey + cycle * greyStep;
    greyVal = min(greyVal, 1);  % make sure not past white
    currentColor = [greyVal, greyVal, greyVal];

    plot(omega, Sa(j, :), lineStyle, 'Color', ...
        currentColor, 'LineWidth', 2)
    legendText(j) = sprintf('$\\xi = %.2f$', xi(j));
end

% Finalize the plot
xlabel('$\omega$'); ylabel('$\omega^2u_{max}$')
legend(legendText, 'Location', 'best','Interpreter','latex');

% Print output
fprintf('PoD 8a  Response Spectrum\n\n')
fprintf('  PHYSICAL PROPERTIES\n');
if nxi == 1
    fprintf('  Damping ratio                    %6.3f\n', xi);
elseif nxi > 1
    fprintf('  Initial Damping ratio            %6.3f\n', xiMin)
    fprintf('  Final Damping ratio              %6.3f\n', xiMax)
    fprintf('  Number of Damping ratios         %6i\n', nxi)
end
fprintf('  Mass                             %6.3f\n', m);
fprintf('  Time step (h)                    %6.3f\n\n', h);

fprintf('  RESPONSE SPECTRUM PROPERTIES\n');
fprintf('  Initial frequency                %6.3f\n', wMin);
fprintf('  Final Frequency                  %6.3f\n', wMax);
fprintf('  Number of points in spectrum     %6i\n\n', nomega);
end