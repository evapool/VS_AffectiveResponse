function [y] = meanCenter(x)

cent = mean(x);
y = nan(length(x),1);


for e = 1:length(x)
    y(e)  = x(e) - cent;
end

end