% Florian Meyer, 2017, 2020

function [betaMessages,vFactors1] = evaluateMeasurements(alphas,alphasExistence,measurements,parameters,sensorIndex)

clutterDistribution = parameters.clutterDistribution;
meanClutter = parameters.meanClutter;
detectionProbability = parameters.detectionProbability;
measurementVarianceRange = parameters.measurementVarianceRange;
measurementVarianceBearing = parameters.measurementVarianceBearing;
sensorPositions = parameters.sensorPositions;
numParticles = parameters.numParticles;

numMeasurements = size(measurements,2);
numTargets = size(alphas,3);

% evaluate v factors
betaMessages = zeros(numMeasurements+1,numTargets);
vFactors1 = zeros(numMeasurements+1,numTargets,numParticles);
if(numTargets)
    vFactors1(1,:,:) = (1-detectionProbability);
    constantFactor = 1/(2*pi*sqrt(measurementVarianceBearing*measurementVarianceRange))*detectionProbability/(meanClutter*clutterDistribution);
    for target =  1:numTargets
        predictedRange = sqrt((alphas(1,:,target) - sensorPositions(1,sensorIndex)).^2+(alphas(2,:,target) - sensorPositions(2,sensorIndex)).^2)';
        predictedBearing = atan2d(alphas(1,:,target) - sensorPositions(1,sensorIndex), alphas(2,:,target) - sensorPositions(2,sensorIndex))';

        for measurement = 1:numMeasurements
            vFactors1(measurement+1,target,:) = constantFactor* (exp(-1/(2*measurementVarianceRange)*(measurements(1,measurement)-predictedRange).^2)) .* (exp(-1/(2*measurementVarianceBearing)*wrapTo180(measurements(2,measurement)-predictedBearing).^2));
        end
    end
    vFactors0 = zeros(numMeasurements+1,numTargets);
    vFactors0(1,:) = 1;

    existence = repmat(permute(alphasExistence,[2,1]),[numMeasurements+1 1]);
    betaMessages = existence.*mean(vFactors1,3) + (1-existence).*vFactors0;
end


end

