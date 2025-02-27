function [fd, dfd] = DampingForce(v, u, DampType, c, dParams)
% Calculate damping force and its derivative based on damping model
% Inputs:
%   v - velocity
%   u - displacement (needed for state-dependent models)
%   DampType - Damping model type:
%       1 = Linear viscous (default)
%       2 = Coulomb friction
%       3 = Nonlinear viscous (c*|v|^alpha*sign(v))
%       4 = State-dependent viscous (c(u)*v)
%   c - Standard viscous damping coefficient
%   dParams - Additional damping parameters
%
% Outputs:
%   fd - Damping force
%   dfd - Derivative of damping force with respect to velocity

% Default is linear viscous damping
if nargin < 3 || isempty(DampType)
    DampType = 1;
end

% Handle each damping model type
switch DampType
    case 1  % Linear viscous damping
        % f_d = c*v
        fd = -c * v;
        dfd = -c;

    case 2  % Coulomb (friction) damping
        % f_d = mu*N*sign(v)
        mu = dParams(1);      % Friction coefficient
        N = dParams(2);       % Normal force
        v_reg = 1e-6;         % Regularization parameter (small velocity)

        if nargin > 4 && length(dParams) >= 3
            v_reg = dParams(3);
        end
        fd = -mu * N * tanh(v / v_reg);
        dfd = -mu * N * (1 - tanh(v / v_reg)^2) / v_reg;

    case 3  % Nonlinear viscous damping
        % f_d = c*|v|^alpha*sign(v)
        alpha = dParams(1);   % Exponent
        v_reg = 1e-6;         % Small regularization velocity

        if nargin > 4 && length(dParams) >= 2
            v_reg = dParams(2);
        end

        % Regularized calculation to avoid issues near v=0
        v_eff = sign(v) * max(abs(v), v_reg);
        fd = c * sign(v_eff) * abs(v_eff)^alpha;
        dfd = c * alpha * abs(v_eff)^(alpha-1);

    case 4  % State-dependent damping
        % f_d = c(u)*v
        switch dParams(1)
            case 1  % Linear state dependence: c(u) = c0 + c1*|u|
                c0 = c;          % Base damping coefficient
                c1 = dParams(2); % State multiplier

                c_eff = c0 + c1 * abs(u);
                fd = c_eff * v;
                dfd = c_eff;

            case 2  % Exponential state dependence: c(u) = c0*exp(c1*|u|)
                c0 = c;          % Base damping coefficient
                c1 = dParams(2); % Exponential coefficient

                c_eff = c0 * exp(c1 * abs(u));
                fd = c_eff * v;
                dfd = c_eff;

            case 3  % Custom state dependence function
                % Any other model can be added here
                c_eff = c;  % Default to regular viscous damping
                fd = c_eff * v;
                dfd = c_eff;
        end

    otherwise
        error('Unknown damping model type');
end
end