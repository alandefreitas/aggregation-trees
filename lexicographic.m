function [ y ] = lexicographic(p, q, importance)
%PARETO Checks for dominance

if (nargin < 3)
    importance = 1:size(p,2);
end
y = false;
for i=1:size(p,2)
    if (p(importance(i))>q(importance(i)))
        y=true;
        return;
    elseif (q(importance(i))>p(importance(i)))
        y=false;
        return;        
    end
end

end

