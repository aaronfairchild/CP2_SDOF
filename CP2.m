%-----------------------------------------------------------------------
%   CP 2 - SDOF
%
%     Author:  Aaron Fairchild
%     Date:    February 20, 2025
%-----------------------------------------------------------------------
tic; clear; clc; 
delete(findall(0, 'Type', 'figure'));
set(0, 'DefaultTextInterpreter', 'latex');
set(0, 'DefaultAxesTickLabelInterpreter', 'latex');
set(0, 'DefaultLegendInterpreter', 'latex');

doPoDs = true; % Run the PoD Benchmark cases? (true/false)

if doPoDs
    % Run PoD6, with benchmark parameters
    %PoD3();

    % Run PoD7, with benchmark parameters
    %PoD4();

    % Run PoD8, with benchmark parameters
    %PoD5();

    % Run PoD9, with benchmark parameters
    %PoD5();

    % Run PoD10, with benchmark parameters
    %PoD5();

    % Run PoD11, with benchmark parameters
    PoD11();
end

elapsedTime = toc; 
fprintf(['Elapsed time since start: %.2f seconds.\n' ...
         'Normal Termination of Program.\n'], elapsedTime);