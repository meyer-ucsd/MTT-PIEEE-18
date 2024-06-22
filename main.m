% Florian Meyer, 2017, 2020

% Implementation of BP-based multitarget tracking using particles as presented in [A] and [B].

% [A] F. Meyer, P. Braca, P. Willett, and F. Hlawatsch, "A scalable algorithm for tracking an unknown number of targets using multiple sensors," IEEE Trans. Signal Process., vol. 65, pp. 3478–3493, Jul. 2017.
% [B] F. Meyer, T. Kropfreiter, J. L. Williams, R. A. Lau, F. Hlawatsch, P. Braca, and M. Z. Win, "Message passing algorithms for scalable multitarget tracking," Proc. IEEE, vol. 106, pp. 221–259, Feb. 2018.


clear variables; close all; clc; rng(1); 


% model parameters
numSteps = 200;
parameters.surveillanceRegion = [[-3000; 3000] [-3000; 3000]];
parameters.priorVelocityCovariance = diag([10^2;10^2]);
parameters.drivingNoiseVariance = 0.010;
parameters.lengthSteps = ones(numSteps,1);
parameters.survivalProbability = 0.999;

parameters.numSensors = 2;
parameters.measurementVarianceRange = 25^2;
parameters.measurementVarianceBearing = .5^2;
parameters.detectionProbability = .9;
parameters.measurementRange = 2*parameters.surveillanceRegion(2,2);
parameters.meanClutter = 5;
parameters.clutterDistribution = 1/(360*parameters.measurementRange);


% algorithm parameters
parameters.detectionThreshold = .5;
parameters.thresholdPruning = 1e-4;
parameters.minimumTrackLength = 1;
parameters.numParticles = 10000;


% generate true track and define sensor positions
parameters.targetStartStates = getStartStates( 5, 1000, 10 );
parameters.targetAppearanceFromTo = [[5;155],[10;160],[15;165],[20;170],[25;175]];
[~, numTargets] = size(parameters.targetStartStates);
trueTracks = generateTrueTracks(parameters, numSteps);
parameters.sensorPositions = getSensorPositions( parameters.numSensors, 5000);


% initialize all variables
posteriorBeliefs = zeros(4,parameters.numParticles,0);
posteriorExistences = zeros(0,1);
posteriorLabels = zeros(3,0);
estimatedCardinality = zeros(numSteps,1); 
estimates = cell(numSteps,1);
measurements = cell(numSteps,parameters.numSensors);

% here we define the Poisson point process that models the unknown number
% of targets (i.e., targets that exist but have not generated a measurement yet); 
% as alternative to choosing this process constant, the parameters of the processs 
% can be propagated across time using a zero-measurement PhD filter (see [C] and 
% [D] for details); this strategy is particularly useful if the probability of
% detection depents on target states.

% [C] P. R. Horridge and S. Maskell, "Using a probabilistic hypothesis density filter to confirm tracks in a multi-target environment," in Proc. INFORMATIK, Berlin, Germany, Jul. 2011.
% [D] J. L. Williams, "Marginal multi-Bernoulli filters: RFS derivation of MHT, JIPDA, and association-based MeMBer," IEEE Trans. Aerosp. Electron. Syst., vol. 51, no. 3, pp. 1664–1687, Jul. 2015.
unknownNumber = 0.01;
unknownParticles = zeros(2,parameters.numParticles);
unknownParticles(1,:) = (parameters.surveillanceRegion(2,1)-parameters.surveillanceRegion(1,1))*rand(parameters.numParticles,1)+parameters.surveillanceRegion(1,1);
unknownParticles(2,:) = (parameters.surveillanceRegion(2,2)-parameters.surveillanceRegion(1,2))*rand(parameters.numParticles,1)+parameters.surveillanceRegion(1,2);

% perform BP-based tracking for all time steps
for step = 1:numSteps
    step

    measurements(step,:) = generateClutteredMeasurements(generateTrueMeasurements(trueTracks(:,:,step),parameters),parameters);

    [estimates{step},estimatedCardinality(step),posteriorBeliefs,posteriorExistences,posteriorLabels] = trackerBP( measurements(step,:), posteriorBeliefs, posteriorExistences, posteriorLabels, unknownNumber, unknownParticles, step, parameters );

end
estimatedTracks = trackFormation(estimates, parameters);


% show results
visualizationMode = 1;  %hit ``space'' to start visualization; set visualizationMode=0 for final result and visualizationMode=2 to frame-to-frame by hitting ``space''.
showResults(trueTracks, estimatedTracks, parameters.sensorPositions, measurements, estimatedCardinality, visualizationMode);
