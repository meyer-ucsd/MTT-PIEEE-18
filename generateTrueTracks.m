function [targetTracks] = generateTrueTracks(parameters,numSteps)
lengthSteps = parameters.lengthSteps;
drivingNoiseVariance = parameters.drivingNoiseVariance;
targetAppearanceFromTo = parameters.targetAppearanceFromTo;
targetStartStates = parameters.targetStartStates;
[~, numTargets] = size(targetStartStates);

targetTracks = nan(4,numTargets,numSteps);
for target = 1:numTargets
    currentState = targetStartStates(:,target);

    for step=2:numSteps

        [A, W] = getTransitionMatrices(lengthSteps(step));
        currentState = A*currentState + W*sqrt(drivingNoiseVariance)*randn(2,1);

        if(targetAppearanceFromTo(1,target) <= step && step <= targetAppearanceFromTo(2,target))
            targetTracks(:,target,step) = currentState;
        end

    end
end

end


function [ A, W ] = getTransitionMatrices( scanTime )

A = diag(ones(4,1));
A(1,3) = scanTime;
A(2,4) = scanTime;

W = zeros(4,2);
W(1,1) = 0.5*scanTime^2;
W(2,2) = 0.5*scanTime^2;
W(3,1) = scanTime;
W(4,2) = scanTime;

end

