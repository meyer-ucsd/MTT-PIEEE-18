% Florian Meyer, 2017

function [allMeasurementsCell] = generateClutteredMeasurements(trackMeasurements, parameter)
detectionProbability = parameter.detectionProbability;
numSensors = parameter.numSensors;
meanClutter = parameter.meanClutter;
measurementRange = parameter.measurementRange;
numTargets = size(trackMeasurements,2);


allMeasurementsCell = cell(numSensors,1);
for sensor = 1:numSensors
    
    % determine which target has been detected
    doesExist = ~isnan(trackMeasurements(1,:,sensor)');
    isDetected = rand(numTargets,1) < detectionProbability;
    detectedMeasurements = trackMeasurements(:,doesExist&isDetected,sensor);

    % generate clutter
    numClutter = poissrnd(meanClutter);
    clutter = zeros(2,numClutter);
    clutter(1,:) = measurementRange * rand(1,numClutter);
    clutter(2,:) = 360 * rand(1,numClutter) - 180;
    
    % combine all measurements and perform random permutation
    allMeasurements = [clutter, detectedMeasurements];
    numMeasurements = size(allMeasurements,2);
    allMeasurements = allMeasurements(:,randperm(numMeasurements));

    allMeasurementsCell{sensor} = allMeasurements;
end


end

