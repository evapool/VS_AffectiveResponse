function [liking,intensity] = odorRating (odor,data)

position = findLabelPosition(odor,data.odorLabel);
liking = nan(1,size(position,2));
intensity = nan (1,size(position,2));

for i = 1:size(position,2)
    liking (i) = data.liking(position(i));
end

for i = 1: size(position,2)
    intensity (i)= data.intensity(position(i));
end 

end