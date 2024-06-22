% Florian Meyer, 2017, 2020

function [newPTs,newLabels,newExistences,xiMessages] = introduceNewPTs(newMeasurements,sensor,step,unknownNumber,unknownParticles,parameters)
numParticles = parameters.numParticles;
detectionProbability = parameters.detectionProbability;
clutterIntensity = parameters.meanClutter*parameters.clutterDistribution;
sensorPositions = parameters.sensorPositions(:,sensor);
numMeasurements = size(newMeasurements,2);

% compute unknown intensity and perform update step for unknown targets
unknownIntensity = unknownNumber/((parameters.surveillanceRegion(1,1)-parameters.surveillanceRegion(2,1))*(parameters.surveillanceRegion(1,2)-parameters.surveillanceRegion(2,2)));
unknownIntensity = unknownIntensity*(1-detectionProbability)^(sensor-1);

if(numMeasurements)
    constants = calculateConstantsUniform(sensorPositions, newMeasurements, unknownParticles, parameters);
end

% introduce new PTs and compute xi messages
newPTs = zeros(4,numParticles,numMeasurements);
newLabels = zeros(3,numMeasurements);
xiMessages = zeros(numMeasurements,1);
for measurement = 1:numMeasurements
    newPTs(:,:,measurement) = sampleFromLikelihood(newMeasurements(:,measurement), sensor, numParticles, parameters);
    newLabels(:,measurement) = [step;sensor;measurement];
    xiMessages(measurement) = 1 + (constants(measurement) * unknownIntensity * detectionProbability)/clutterIntensity;
end

newExistences = xiMessages - 1;

end



function [constants] = calculateConstantsUniform(sensorPosition, newMeasurements, particles, parameters)
measurementVarianceRange = parameters.measurementVarianceRange;
measurementVarianceBearing = parameters.measurementVarianceBearing;
numMeasurements = size(newMeasurements,2);
numParticles = size(particles,2);

constantWeight = 1/((parameters.surveillanceRegion(1,1)-parameters.surveillanceRegion(2,1))*(parameters.surveillanceRegion(1,2)-parameters.surveillanceRegion(2,2)));

predictedRange = sqrt((particles(1,:) - sensorPosition(1)).^2+(particles(2,:) - sensorPosition(2)).^2);
predictedBearing = atan2d(particles(1,:) - sensorPosition(1), particles(2,:) - sensorPosition(2));
constantLikelihood = 1/(2*pi*sqrt(measurementVarianceBearing*measurementVarianceRange));

constants = zeros(numMeasurements,1);
for measurement = 1:numMeasurements
    constants(measurement) = sum(1/numParticles*constantLikelihood*exp((-1/2)*(repmat(newMeasurements(1,measurement),1,numParticles) - predictedRange).^2/(measurementVarianceRange)).*exp((-1/2)*(repmat(newMeasurements(2,measurement),1,numParticles) - predictedBearing).^2/(measurementVarianceBearing)));
end
constants = constants/constantWeight;
end


function [ samples ] = sampleFromLikelihood(measurement, sensorIndex, numParticles, parameters)
sensorPosition = parameters.sensorPositions(:,sensorIndex);
measurementVarianceRange = parameters.measurementVarianceRange;
measurementVarianceBearing = parameters.measurementVarianceBearing;
priorVelocityCovariance = parameters.priorVelocityCovariance;

samples = zeros(4,numParticles);

randomRange = measurement(1)+sqrt(measurementVarianceRange)*randn(1,numParticles);
randomBearing = measurement(2)+sqrt(measurementVarianceBearing)*randn(1,numParticles);
samples(1:2,:) = [sensorPosition(1) + randomRange.*sind(randomBearing); sensorPosition(2) + randomRange.*cosd(randomBearing)];
samples(3:4,:) = sqrtm(priorVelocityCovariance) * randn(2,numParticles);
end

