function [ sensorPositions ] = getSensorPositions( numSensors, radius)
numSensors = round(numSensors);

if(numSensors < 2)
    sensorPositions = [0;radius];
else
    sensorPositions = zeros(2,numSensors);
    sensorPositions(:,1) = [0;radius];    
    stepSize = 2*pi/numSensors;
    
    angle = 0;
    for sensor = 2:numSensors
        angle = angle + stepSize;
        sensorPositions(:,sensor) = [sin(angle)*radius;cos(angle)*radius];
    end    
end
end

