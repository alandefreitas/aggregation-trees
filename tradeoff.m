function tradeoff(X, normalization)

if nargin==0
    X = randn(100,10); %10 objectives and 7 solutions
end
if nargin<2
    normalization = true;
end

n_solutions = size(X,1);
%n_objectives = size(X,2);

if normalization
    % Normalizes X
    minimum = min(X);
    for i=1:size(X,1)
        X(i,:) = X(i,:) - minimum;
    end
    maximum = max(X);
    for i=1:size(X,1)
        X(i,:) = X(i,:) ./ maximum;
    end
end

%plots grey lines
for i=1:size(X,2)
    plot([i,i],[0,1],'--','color',[0,0,0]+0.9);
    hold on;
end
xlim([1,size(X,2)]);

color = {'b','g','r','c','m','y','k'};
if size(X,1) > 7
    % Clustering X
    [clusters,~]  = PSA(X,7); %cluster solutions in 7 groups
    % [clusters,~]  = kmeans(X,7); %cluster solutions in 7 groups

    % Plotting
    for i=1:n_solutions  %for each solution
        plot(X(i,:),color{clusters(i)});
        hold on;
    end
else
    % Plotting
    for i=1:n_solutions  %for each solution
        plot(X(i,:),color{i});
        hold on;
    end
end
% Adding Labels
title('Trade-off Graph');
ylabel('Objective value');
xlabel('Objective number');
if normalization
    set(gca,'ytick',[0,1]);
    set(gca,'yticklabel',{'min' 'max'});
end
set(gca,'xtick',1:size(X,2));

end