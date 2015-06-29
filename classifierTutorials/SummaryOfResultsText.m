%% Summary of distance based and SVM classification in high dimensions
%
% To help our understanding of how certain methods of classification behave
% in high dimensionality, we created two scripts,
% dimensionalityLinearclassifiers.m and distanceBasedClassifierTutorial.m,
% that investigate such behaviors.  
% 
% In both scripts, randomly generated test data is subjected to the
% addition of noise in the form of draws from a Gaussian distribution,
% Poisson distribution, and a Poisson approximation in the that is a
% Gaussian with the standard deviation set to the square root of the mean.
% The mean of the Gaussian distribution was scaled to the vector length
% between the comparison vector and the test vector.  This is detailed in
% both scripts.
% 
% Additionally, we specified three direction for the test vector that are
% relative to the comparison vector.  The test vector was either a positive
% extension of the comparison, a negative extension of the comparison, or
% orthogonal to the comparison.  The distance between the vectors in all
% three cases was set to be 0.05 * length of comparison vector.
% 
% Classification consisted of two separate draws of noise for the
% comparison vector and one draw for the test vector.  One comparison
% served as the reference.  If the other comparison was chosen, the result
% was considered correct.  In the case of the SVM, correct classification
% into arbitrarily determined classes for the comparison and test vectors
% was considered.
% 
% For the case of the distance based classifier, only the Euclidian measure
% was thoroughly tested, although several other measures of distance are
% coded in to the script and can also be tested if so desired.  
% 
% For the Euclidian measure, across all three directions for the test
% vector (positive, negative, orthogonal) the draw from the Gaussian
% distribution approached fifty percent as the noise factor k increased.
% In all three directions, this happened at k >= 1000 (p > 0.05) with the
% exception of Orthogonal k = 1000 dimensionality = 10000.  The draw from
% the Poisson and the Poisson approximation were agreeable to each other
% across all three directions and will be treated as one result in this
% summary.  With the Poisson noise, only the orthogonal direction showed
% convergence to fifty percent in high k.  Additionally, the p values
% showed more likelihood to be below 0.05 considering only results for k >=
% 1000.  There were 4 cases out of 8 plots (24 values of k >= 1000) for the
% orthogonal Poisson versus 1 case out of 12 plots (36 values) for the
% Gaussian draw.  Additional runs may further clarify this observation.
% In the case of the positive and negative directions, results differed
% from fifty percent significantly.  In the positive dimension, increase in
% dimensionality resulted in an increase of classification accuracy in high
% k, approximately 90% at 10000 dimensions.  The reverse occurred in the
% negative direction, where accuracy reached apprixmately 10% for high k in
% 10000 dimensions.
% 
% These results make sense when considering that the Poisson distribution
% scales with the length of the mean.  In the orthogonal case, especially
% in high dimensions, the test vector was not perturbed in a manner that
% would increase its vector length significantly.  This is analogous to
% picking to points on a unit circle.  However, when the test vector was
% either a positive or negative extension of the comparison, its length is
% also scaled according.  Therefore, the Poisson noise is multiplied by the
% noise factor k, one of the noise distributions must grow faster than the
% other.  This results in extremely skewed accuracy results in high
% dimensions where the growth of the noise is amplified due to the
% dimensionality.
% 
% For the SVM, a training set of 2500 vectors comprising of half comparison
% and half test vector was created for each combination of testing
% conditions.  The training set consisted of vectors with noise draws of an
% adjusted k = 1. Once trained, the SVM was tested with test sets also
% consisting of half comparison and half test vectors.  The SVM approached
% 50% accuracy at k = 10000 in all three directions and noise
% distributions.  Looking at the p values, there were 4 cases out of 72 (36
% plots) where p < 0.05.  As with the Euclidian measure, the percent
% correct between the Poisson and the Poisson approximation were very
% similar.
% 
% This result can explained by the SVM creating a hyperplane using support
% vectors to classify the test sets.  Since this hyperplane is fixed, it is
% expected that increasing the noise distribution will eventually result in
% the case where the distance of the comparison and test vectors to the
% hyperplane is small relative the size of their noise clouds.  In this
% case, a series of random draws should result in an even amount of vectors
% from both sides of the hyperplane.
