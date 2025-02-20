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

doPoDs = false; % Run the PoD Benchmark cases? (true/false)

if doPoDs
    % Run PoD3, with benchmark parameters
    %PoD3();

    % Run PoD4, with benchmark parameters
    %PoD4();

    % Run PoD5, with benchmark parameters
    %PoD5();
end

elapsedTime = toc; 
fprintf(['Elapsed time since start: %.2f seconds.\n' ...
         'Normal Termination of Program.\n'], elapsedTime);