%% Plotting Signal Constellations
% This example, described in the Getting Started chapter of the
% Communications Toolbox documentation, aims to solve the following
% problem:
%
% Plot a 16-QAM signal constellation with annotations that
% indicate the mapping from integers to constellation points.

% Copyright 1996-2009 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2009/07/20 17:37:54 $

%% Initial Plot, Without Gray Coding
M = 16;                     % Number of points in constellation
hMod = modem.qammod(M);     % Modulator
mapping = hMod.SymbolMapping;  % Symbol mapping vector
pt = hMod.Constellation;       % Vector of all points in constellation

% Plot the constellation.
hScatter = commscope.ScatterPlot;           % Create a scatter plot scope
hScatter.Constellation = pt;                % Set expected constellation
hScatter.PlotSettings.Constellation = 'on'; % Display ideal constellation

% Include text annotations that number the points.
text(real(pt)+0.1,imag(pt),dec2bin(mapping));

%% Modified Plot, With Gray Coding
M = 16;                     % Number of points in constellation
hMod = modem.qammod('M',M,'SymbolOrder','Gray'); % Modulator
mapping = hMod.SymbolMapping;  % Symbol mapping vector
pt = hMod.Constellation;       % Vector of all points in constellation

% Plot the constellation.
hScatter = commscope.ScatterPlot;           % Create a scatter plot scope
hScatter.Constellation = pt;                % Set expected constellation
hScatter.PlotSettings.Constellation = 'on'; % Display ideal constellation

% Include text annotations that number the points.
text(real(pt)+0.1,imag(pt),dec2bin(mapping));
