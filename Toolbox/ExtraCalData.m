classdef ExtraCalData
    % ExtraCalData holds auxillary information, such as display distance,
    % that is not contained in Brainard Lab calibration files
    % 
    %   Currently, the only data present is the distance with default value
    %   of 0.5
    %
    % 3/2/2015 xd wrote file
    
    properties
        distance = 0.5;
    end
    
    methods
        function obj = set.distance(obj, distance)
            if (distance <= 0)
                error('Distance must be greater than 0')
            end
            if ~(isnumeric(distance))
                error('Distance must be numeric')
            end
        obj.distance = distance;
        end
    end
    
end

