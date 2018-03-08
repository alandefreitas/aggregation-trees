function [ members ] = polargraph( X, obj_order )
%POLARGRAPH of coordinates of the points and pareto points in X
% Points has a row for each point and a column for each objective
% obj_order is the order of the objectives in the plot
% 
% Reference:
% Aggregation Trees for Visualization and Dimension Reduction in Many-Objective Optimization
% ARR de Freitas, PJ Fleming, FG Guimarães - Information Sciences, 2014 - Elsevier
%
% Example:
% $Author: Alan de Freitas $    $Date: 2014/06/11 $    $Revision: 1.2 $
%
%
% This work is licensed under a Creative Commons 
% Attribution-NonCommercial 3.0 Unported License.
% http://creativecommons.org/licenses/by-nc/3.0/deed.en_US
%
% Copyright: 2012
% 

% Initializes variables
n_obj = size(X,2);
n_points = size(X,1);
central_offset = 0.2; % this is how far (from 0 to 1) the minimum will be from the center
if nargin == 1
    obj_order = 1:n_obj;
elseif nargin == 2
    X = X(:,obj_order);
else
    disp('Please send 1 or 2 inputs');
end

% Identify which solutions are Pareto-dominant
[members] = paretofronts(X, ones(1,n_obj),'pareto',0);
%members = ones(1,n_points);

%% Normalizes all the values from 0 to 1 in X2
minimum = min(X);
for i=n_points:-1:1
    X2(i,:) = X(i,:) - minimum; %all values from 0 to max
end
maximum_text = max(X);
maximum = max(X2);

for i=1:n_obj
    if maximum(i) == 0
        maximum(i) = 0.5;
    end
end
%disp('máximotext');
%disp(maximum_text);
%disp('máximo');
%disp(maximum);
%disp('mínimo');
%disp(minimum);
for i=n_points:-1:1
    X2(i,:) = X2(i,:)./maximum; %all values from 0 to 1
end
%disp(X2);
%maximum = max(X);

%Supposing we want to minimize all the points, 0 should be become 1 and 1
%become 0. That is, minimum will be 1 to be on the outter part of the
%circle and facilitate visualization
X2 = -X2 + 1;

% Moving extreme solutions from the center of the circle
X2 = X2+central_offset;




%% Creates the background of the polar plot
resolution = 70; % how many points form the circle
% Plot the outter line (values = 1+central_offset)
%theta = linspace(0,2*pi,resolution );
theta = linspace(0,2*pi,n_obj+1);
%r = ones(1,resolution )+central_offset;
r = ones(1,size(X2,2)+1)+central_offset;
x=r.*cos(theta);
y=r.*sin(theta);
figure;
plot(x,y,'-k','LineWidth',2);
hold on;
% Plot the inner line (value = central_offset)
%theta = linspace(0,2*pi,resolution );
theta = linspace(0,2*pi,n_obj+1);
%r = zeros(1,resolution)+central_offset;
r = zeros(1,size(X2,2)+1)+central_offset;

x=r.*cos(theta);
y=r.*sin(theta);
plot(x,y,'-k','LineWidth',15);
axis equal;
xlim([-2.5,2.5])
set(gca,'ytick',[]);
set(gca,'xtick',[]);
% Objective lines (theta is like a straight axis that will be curved by the
% cos and sin operations)
theta = linspace(0,2*pi,n_obj+1);
for i=1:n_obj
    %Draws the straight lines for the objectives
    theta_2 = [theta(i),theta(i)];
    r = [central_offset, 1+central_offset*2];
    x=r.*cos(theta_2);
    y=r.*sin(theta_2);
    plot(x,y,'--k');
    % Draws the objective title
    theta_2 = theta(i);
    r = 1+central_offset*2+0.2;
    x=r.*cos(theta_2);
    y=r.*sin(theta_2);
    text(x, y, [num2str(maximum_text(i)),char(10),'f_{',num2str(obj_order(i)),'}',char(10),num2str(minimum(i))], 'Color', 'k', 'HorizontalAlignment','center','Rotation',theta_2*360/(2*pi)+90);
end
% Title
title('Polar coordinates trade-off graph','FontSize',12);

    
%% Clusters the solutions into 5 groups of colors
if (n_obj < size(X2,1))
    [clusters,centers] = PSA(X2,5);
    % the kmeans syntax would be the same
    % clusters = kmeans(X2,5);
end
colors = {'b','g','r','c','m'};

%% Plots each solution
theta = linspace(0,2*pi,n_obj+1);
for i=randperm(n_points)
    r = [X2(i,:),X2(i,1)];
    x=r.*cos(theta);
    y=r.*sin(theta);
    if (members(i))
        if (n_obj < size(X2,1))
            plot(x,y,colors{mod((clusters(i))-1,5)+1},'LineWidth',1);
        else
            plot(x,y,colors{mod(i-1,5)+1},'LineWidth',1);
        end
    else
        plot(x,y,'--y');
    end
    hold on;
end

for i=randperm(length(centers))
    r = [X2(centers(i),:),X2(centers(i),1)];
    x=r.*cos(theta);
    y=r.*sin(theta);
    if (members(i))
        if (n_obj < size(X2,1))
            plot(x,y,colors{mod((clusters(centers(i)))-1,5)+1},'LineWidth',2);
        else
            plot(x,y,colors{mod(centers(i)-1,5)+1},'LineWidth',2);
        end
    else
        plot(x,y,'--y');
    end
    hold on;
end



end
