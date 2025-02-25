% PoD 6b: Friction damping (Classical)
% Code by: Aaron Fairchild
% Original: February 3, 2025
% Latest Update: February 25, 2025
function PoD6b()

m = 2;
k = 5;
mu = 0.05;
omega = 1.581;
g = 9.81;

uo = 3;
vo = 0;

nPts = 300;
tf = 35;
t = linspace(0,tf,nPts);
u = zeros(nPts,1);

% coefficients to simplify equations
th = pi/omega;

a1 = mu*m*g/k;
A = uo - a1;
B = a1;

% initialize
u(1) = uo;
c = -1;

for i = 2:size(t,2)
    n = floor(t(i)/th); % find current interval
    nold = floor(t(i-1)/th); % find interval of last step

    if n ~= nold % if we are at new interval

        % this bit is to account for numerical issues
        uold = A*cos(omega*(t(i-1)-nold*th)) + B;
        if abs(uold) < a1
            u(i:end) = uold;
            break;
        end

        % update for change in velocity sign
        A = -1*(A + c*2*a1);
        B = -B;
        c = -c; %account for sign change
    end

    u(i) = A*cos(omega*(t(i)-n*th)) + B;
end

% Plot results
figure(1); clf; grid on; hold on;
plot(t,u,'b','LineWidth',0.5,...
    'MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',2);
xlabel('t',Interpreter='latex'); ylabel('u(t)',Interpreter='latex')
title('Response vs. Time')

% Print output
fprintf('PoD 6b: Friction damping (Classical)\n\n')
fprintf('  PHYSICAL PROPERTIES\n');
fprintf('  Mass                             %6.3f\n', m);
fprintf('  Stiffness                        %6.3f\n', k);
fprintf('  Coefficient of friction          %6.3f\n', mu);
fprintf('  Natural Frequency                %6.3f\n', omega);
fprintf('  Acceleration of gravity          %6.3f\n\n', g);

fprintf('  INITIAL CONDITIONS\n');
fprintf('  Initial displacement (uo)        %6.3f\n', uo);
fprintf('  Initial velocity (vo)            %6.3f\n\n', vo);

end