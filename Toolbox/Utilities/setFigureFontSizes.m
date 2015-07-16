function setFigureFontSizes(figHandle, varargin)
% setFigureFontSizes(figHandle, varargin)
%
% Method to automatically change the fonts of all labels, legends and titles in a figure
% with handle figHandle.
%
% Example usage: setFigureFontSizes(hFig, 'fontName', 'helvetica', 'FontSize', 14);
%
% 2/26/2015     npc     Wrote it.
% 

    self.fontName = 'Helvetica';
    self.fontSize = 12;
    
    % parse inputs
    parser = inputParser;
    parser.addParamValue('fontName', self.fontName);
    parser.addParamValue('fontSize', self.fontSize);
 
    % Execute the parser to make sure input is good
    parser.parse(varargin{:});
    % Copy the parse parameters to the ExperimentController object
    pNames = fieldnames(parser.Results);
    for k = 1:length(pNames)
       self.(pNames{k}) = parser.Results.(pNames{k}); 
    end
    
    axisHandle = findobj(figHandle,'Type','axes');
    set(axisHandle, 'fontName', self.fontName, 'fontSize', self.fontSize);
    
    labelHandles = get(axisHandle,'xlabel');
    for k = 1:numel(labelHandles)
        if iscell(labelHandles)
            set(labelHandles{k}, 'fontName', self.fontName, 'fontSize', round(self.fontSize*1.20), 'fontWeight', 'b');
        else
             set(labelHandles(k), 'fontName', self.fontName, 'fontSize', round(self.fontSize*1.20), 'fontWeight', 'b');
        end
    end
    
    labelHandles = get(axisHandle,'ylabel');
    for k = 1:numel(labelHandles)
        if iscell(labelHandles)
            set(labelHandles{k}, 'fontName', self.fontName, 'fontSize', round(self.fontSize*1.20), 'fontWeight', 'b');
        else
            set(labelHandles(k), 'fontName', self.fontName, 'fontSize', round(self.fontSize*1.20), 'fontWeight', 'b');
        end
    end
    
    labelHandles = get(axisHandle,'title');
    for k = 1:numel(labelHandles)
        if iscell(labelHandles)
            set(labelHandles{k}, 'fontName', self.fontName, 'fontSize', round(self.fontSize*1.40), 'fontWeight', 'b');
        else
            set(labelHandles(k), 'fontName', self.fontName, 'fontSize', round(self.fontSize*1.40), 'fontWeight', 'b');
        end
    end
        
    legendHandles = findobj(figHandle,'Tag','legend');
    for k = 1:numel(legendHandles)
        if iscell(legendHandles)
            set(legendHandles{k}, 'fontName', self.fontName, 'fontSize', round(self.fontSize*1.1), 'fontWeight', 'b', ...
            'Color', [0.95 0.95 0.8], 'EdgeColor', [0 0 0]);
        else
            set(legendHandles(k), 'fontName', self.fontName, 'fontSize', round(self.fontSize*1.1), 'fontWeight', 'b', ...
            'Color', [0.95 0.95 0.8], 'EdgeColor', [0 0 0]);
        end
    end
end