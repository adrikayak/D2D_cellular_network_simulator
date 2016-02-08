function [dist] = distance(a, b, users1, users2 )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

dist = zeros(a,b);

for i = 1:a
    for j = 1:b
        dist(i,j) = norm(users1(:,i) - users2(:,j));
    end
end

end

