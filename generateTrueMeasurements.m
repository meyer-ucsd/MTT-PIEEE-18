function [ measurements ] = generateTrueMeasurements(targetTrajectory, parameter)
measurementVarianceRange = parameter.measurementVarianceRange;
measurementVarianceBearing = parameter.measurementVarianceBearing;
numSensors = parameter.numSensors;
sensorPositions = parameter.sensorPositions;
[~, numTargets] = size(targetTrajectory);

measurements = zeros(2, numTargets, numSensors);

for sensor = 1:numSensors    
    for target = 1:numTargets
        measurements(1,target,sensor) = sqrt((targetTrajectory(1,target) - sensorPositions(1,sensor)).^2+(targetTrajectory(2,target) - sensorPositions(2,sensor)).^2) + sqrt(measurementVarianceRange)*randn;
        measurements(2,target,sensor) =  atan2d(targetTrajectory(1,target) - sensorPositions(1,sensor), targetTrajectory(2,target) - sensorPositions(2,sensor)) + sqrt(measurementVarianceBearing)*randn;
    end
end

end

