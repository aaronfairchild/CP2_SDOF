function [U] = Newmark(h,LoadType,m,c,d,tf,uo,vo,ag)
% Compute response to ma+cv+r(u) = p - m*ag by Newmark's method
% d= [Model Type, k, b, So]

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
p = LoadFunction(t,LoadType);
aold = (p - c*vold - r)/m;

% Numerical parameters
eta = h*(1-gamma);
zeta = h^2*(0.5-beta);

tol = 1.e-8;                % Newton tolerance
nSteps = ceil(tf/h);        % Number of time steps
U = zeros(nSteps,6);        % Storage for results

% Compute response by time stepping
for i = 1:nSteps
    [r,~,iv] = ConstModel(uold,d,iv);
    U(i,:) = [t,uold,vold,aold,r,iv];
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
        g = m*anew + c*vnew + r - p + m*ag(i);
        A = m + eta*c + zeta*dr;
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