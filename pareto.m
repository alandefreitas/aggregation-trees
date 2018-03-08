function [ y ] = pareto( p, q)
%PARETO Checks for dominance

y = false;
if (sum(p>=q)==size(p,1)*size(p,2))
    if (sum(p==q)~=size(p,1)*size(p,2))
        y=true;
    end
end

end

