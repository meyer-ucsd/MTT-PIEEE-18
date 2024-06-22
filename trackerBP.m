% Florian Meyer, 2017, 2020

function [estimates, estimatedCardinality, legacyPTs, legacyExistences, legacyLabels ] =  trackerBP( clutteredMeasurements, legacyPTs, legacyExistences, legacyLabels, unknownNumber, unknownParticles, step, parameters  )
numSensors = parameters.numSensors;
detectionThreshold = parameters.detectionThreshold;
thresholdPruning = parameters.thresholdPruning;
lengthStep = parameters.lengthSteps(step);

[legacyPTs,legacyExistences] = performPrediction(legacyPTs,legacyExistences,lengthStep,parameters);

for sensor = 1:numSensors

    measurements = clutteredMeasurements{sensor};
    
    % introduce new PTs
    [newPTs,newLabels,newExistences,xiMessages] = introduceNewPTs(measurements,sensor,step,unknownNumber,unknownParticles,parameters);
    
    % evalute v factors
    [betaMessages,vFactors1] = evaluateMeasurements(legacyPTs,legacyExistences,measurements,parameters,sensor);
    
    % perform iterative data association
    [kappas,iotas] = performDataAssociationBP(betaMessages,xiMessages,20,10^(-5),10^5);
    
    % update PTs
    [legacyPTs,legacyExistences,legacyLabels] = updatePTs(kappas,iotas,legacyPTs,newPTs,legacyExistences,newExistences,legacyLabels,newLabels,vFactors1);

    % perform pruning
    numTargets = size(legacyPTs,3);
    isRedundant = false(numTargets,1);
    for target = 1:numTargets
        if(legacyExistences(target) < thresholdPruning)
            isRedundant(target) = true;
        end
    end
    legacyPTs = legacyPTs(:,:,~isRedundant);
    legacyLabels =  legacyLabels(:,~isRedundant);
    legacyExistences = legacyExistences(~isRedundant);

end
estimatedCardinality = sum(legacyExistences);

% perform estimation
numTargets = size(legacyPTs,3);
detectedTargets = 0;
estimates = [];
for target = 1:numTargets
    if(legacyExistences(target) > detectionThreshold)
        detectedTargets = detectedTargets + 1;
        estimates.state(:,detectedTargets) = mean(legacyPTs(:,:,target),2);
        estimates.label(:,detectedTargets) = legacyLabels(:,target);
    end
end

end