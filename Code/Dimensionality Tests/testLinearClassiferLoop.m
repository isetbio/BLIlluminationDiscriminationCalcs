clear all;

%% Create parameter vectors

c.nDim = [1 2 10 100 1000];
c.dist = [0 10 100 1000];
c.trainingSetSize = [100 1000 10000];
c.k = [1 10 100 1000];
c.uniformDist = [true false];
c.testSampleSize = [100 5000];
c.origin = [1000 10000];
c.uniformOrigin = [true false];
c.originVariation = [10 100];

%% Loop over parameters and run the test
resultMatrix = zeros(3,3,length(c.nDim),length(c.dist),length(c.trainingSetSize),...
    length(c.k),length(c.uniformDist),length(c.testSampleSize),length(c.origin),...
    length(c.uniformOrigin),length(c.originVariation));
tic
for aa = 1:length(c.nDim)
    for bb = 1:length(c.dist)
        for cc = 1:length(c.trainingSetSize)
            for dd = 1:length(c.k)
                for ee = 1:length(c.uniformDist)
                    for ff = 1:length(c.testSampleSize)
                        for gg = 1:length(c.origin)
                            for hh = 1:length(c.uniformOrigin)
                                for ii = 1:length(c.originVariation)
                                    p.nDim = c.nDim(aa);
                                    p.dist = c.dist(bb);
                                    p.trainingSetSize = c.trainingSetSize(cc);
                                    p.k = c.k(dd);
                                    p.uniformDist = c.uniformDist(ee);
                                    p.testSampleSize = c.testSampleSize(ff);
                                    p.origin = c.origin(gg);
                                    p.uniformOrigin = c.uniformOrigin(hh);
                                    p.originVariation = c.originVariation(ii);
                                    
                                    resultMatrix(:,:,aa,bb,cc,dd,ee,ff,gg,hh,ii) = testLinearClassifiers(p);
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
toc
save('Classifier Results/Run1', 'c','resultMatrix');