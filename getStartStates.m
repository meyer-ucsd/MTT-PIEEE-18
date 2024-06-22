function [ startStates ] = getStartStates( numTargets, radius, speed )
numTargets = round(numTargets);

if(numTargets < 2)
    startStates = zeros(4,1);
    startStates(3) = speed;
else
    startStates = zeros(4,numTargets);
    startStates(:,1) = [0;radius;0;-speed];
    
    stepSize = 2*pi/numTargets;
    
    angle = 0;
    for target = 2:numTargets
        angle = angle + stepSize;
        startStates(:,target) = [sin(angle)*radius;cos(angle)*radius;-sin(angle)*speed;-cos(angle)*speed];
    end
    
end
end

