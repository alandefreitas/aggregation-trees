%% Generating an Aggregation Tree
% Loading the data for the example
load example_data;

%% Usual parallel coordinate plot
% tradeoff plot with clusters to facilitate visualization
figure(3);
tradeoff(obj);

%% Aggregation Trees with Polar Graph
% polar graph with clusters to facilitate visualization
figure(1);
AT(obj);

%% Showing help
help AT;