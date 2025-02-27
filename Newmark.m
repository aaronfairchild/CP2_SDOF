function [U] = Newmark(h, LoadType, m, c, d, tf, uo, vo, ag, DampType, dParams)
% Compute response to ma - fd + r(u) = p - m*ag by Newmark's method
% d= [Model Type, k, b, So]

% Default to viscous damping if not specified
if nargin < 10 || isempty(DampType)
    DampType = 1;  % Linear viscous damping
end

if nargin < 11
    dParams = [];  % No additional parameters
end

% Set integration parameters;
beta = 0.25;
gamma = 0.5;

% Initialize the internal variable
iv = 0;

% Initialize state {u,v,a} at time 0
t = 0;
uold = uo;
vold = vo;
[r,~,iv] = ConstModel(uo,d,iv);

% Calculate initial damping force
[fd, ~] = DampingForce(vold, uold, DampType, c, dParams);

p = LoadFunction(t,LoadType);
aold = (p - fd - r)/m;

% Numerical parameters
eta = h*(1-gamma);
zeta = h^2*(0.5-beta);

tol = 1.e-8;                % Newton tolerance
nSteps = ceil(tf/h);        % Number of time steps
U = zeros(nSteps,7);        % Storage for results

% Compute response by time stepping
for i = 1:nSteps
    [r,~,iv] = ConstModel(uold,d,iv);
    [fd, ~] = DampingForce(vold, uold, DampType, c, dParams);

    U(i,:) = [t, uold, vold, aold, r, fd, iv];
    t = t + h;
    bn = uold + h*vold + h^2*beta*aold;
    cn = vold + gamma*h*aold;
    p = LoadFunction(t,LoadType);
    anew = aold;

    % Newton
    err = 1;
    while err>tol
        unew = bn + zeta*anew;
        vnew = cn + eta*anew;

        [r,dr,~] = ConstModel(unew,d,iv);
        [fd, dfd] = DampingForce(vnew, unew, DampType, c, dParams);

        g = m*anew - fd + r - p + m*ag(i);
        A = m - eta*dfd + zeta*dr;
        anew = anew - g/A;
        err = norm(g);
    end

    % Update values
    uold = unew;
    vold = vnew;
    aold = anew;

    % Update internal variable
    [~,~,iv] = ConstModel(unew,d,iv);
end

end