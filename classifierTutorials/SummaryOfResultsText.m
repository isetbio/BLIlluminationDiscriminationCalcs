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
% across all three directions and will be referred to together in this
% summary.  With the Poisson noise, only the orthogonal direction showed
% convergence to fifty percent in high k. 
% 
% In the case of the positive and negative directions, results differed
% from fifty percent significantly.  In the positive dimension, increase in
% dimensionality resulted in an increase of classification accuracy in high
% k, approximately 90% at 10000 dimensions.  The reverse occurred in the
% negative direction, where accuracy reached apprixmately 10% for high k in
% 10000 dimensions.
% 
% Here are the links to the full figures of percents and p values:
% 
% Here is a comparison of when the dimensionality is 10000:
% 
% 
% These results make sense when considering that the Poisson distribution
% scales with the length of the mean.  In the orthogonal case, especially
% in high dimensions, the test vector was not perturbed in a manner that
% would increase its vector length significantly.  This is analogous to
% picking two points on a unit circle.  However, when the test vector was
% either a positive or negative extension of the comparison, its length is
% also scaled according.  Therefore, when the Poisson noise is multiplied by the
% noise factor k, one of the noise distributions must grow faster than the
% other.  This results in extremely skewed accuracy results in high
% dimensions where the growth of the noise is amplified due to the
% dimensionality.
%
% For the SVM, there were to methods to training.  One was to train the SVM
% with data at the adjusted k = 1 value and use the same SVM for
% classifying data from all noise levels.  The second method was to train a
% new SVM for each noise level for classification.  In both the positive
% and negative perturbation directions, the method of training a new SVM
% for each noise level (TpN) performed worse in high dimensions of 1000 and
% 10000.  This is noticeable at k = 100 and k = 10000.  Both the TpN and
% non-TpN show a pattern of increasing classification accuracy as the
% dimensionality increases.  The behavior of the TpN method relative to the
% non-TpN method is different for the orthogonal case.  Here, the TpN
% performs with high classification accuracy at k <= 100 for all
% dimensions, a behavior not present in the positive and negative cases.
% Additionally, while the TpN accuracy increases with dimensionality, the
% non-TpN accuracy actually decreases with increased dimensionality.
