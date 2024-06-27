% Florian Meyer, 2017, 2020

function [legacyPTs,legacyExistences,legacyLabels] = updatePTs(kappas,iotas,legacyPTs,newPTs,legacyExistences,newExistences,legacyLabels,newLabels,vFactors1)

numTargets = size(vFactors1,2);
numMeasurements = size(vFactors1,1)-1;
numParticles = size(vFactors1,3);

for target = 1:numTargets
    weights = permute(vFactors1(1,target,:),[3,1,2]);
    for measurement = 1:numMeasurements
        weights = weights + kappas(measurement,target)*permute(vFactors1(measurement+1,target,:),[3,1,2]);
    end
    sumWeights = sum(weights);

    isAlive = legacyExistences(target)*sumWeights/numParticles;
    isDead = (1-legacyExistences(target));
    legacyExistences(target) = isAlive/(isAlive+isDead);

    if(sumWeights)
        legacyPTs(:,:,target) = legacyPTs(:,resampleSystematic(1/sumWeights*weights,numParticles),target);
    end
end


% merge new and legacy PTs
legacyPTs = cat(3,legacyPTs,newPTs);

newExistences = iotas.*newExistences./(iotas.*newExistences + 1);
if(isempty(legacyExistences))
    legacyExistences = newExistences;
else
    legacyExistences = cat(1,legacyExistences,newExistences);
end
legacyLabels = cat(2,legacyLabels,newLabels);


end



function indexes = resampleSystematic(weights,numParticles)
indexes = zeros(numParticles,1);
cumWeights = cumsum(weights);

grid = zeros(1,numParticles+1);
grid(1:numParticles) = linspace(0,1-1/numParticles,numParticles) + rand/numParticles;
grid(numParticles+1) = 1;

i = 1;
j = 1;
while( i <= numParticles )
    if( grid(i) < cumWeights(j) )
        indexes(i) = j;
        i = i + 1;
    else
        j = j + 1;
    end
end

end

