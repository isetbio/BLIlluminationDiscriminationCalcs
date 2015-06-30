function newCalcParam = updateCalcParamFields(oldCalcParam)
% newCalcParam = updateCalcParamFields(oldCalcParam)
% 
% This is a utility function that updates the fields of the calcParams
% struct as new things are added.  If a field has its name changed, this
% function will set the old values to the new field as well as keep the old
% field for any function that calls it.  If a previous version of a new
% field does not exist, it will be set to the default values.  This will
% allow older simulations to still be analyzed without much hassle in
% regarding changes to older code.
%
% 6/29/15  xd  wrote it

% Set the field numKgSamples to 1 if nonexistant, this is to allow older
% simulations to still work
if ~isfield(oldCalcParam, 'numKgSamples')
    oldCalcParam.numKgSamples = 1;
    oldCalcParam.startKg = 0;
    oldCalcParam.KgInterval = 1;
end

% Convert old k fields to Kp fields
if ~isfield(oldCalcParam, 'numKpSamples')
    oldCalcParam.numKpSamples = oldCalcParam.numKValueSamples;
    oldCalcParam.startKp = oldCalcParam.startK;
    oldCalcParam.KpInterval = oldCalcParam.kInterval;
end

newCalcParam = oldCalcParam;

end

