% Method to generate an isetbio display object with given specifications
function displayObject = generateIsetbioDisplayObjectFromCalStructObject(displayName, calStructOBJ)
    
    % We will need to extract the following fields from the calStructOBJ
    % (1) the display's gammaTable - this is stored in the 'gammaTable' field
    % (2) the measured primary spectral power distributions (SPDs) of the
    % display - this is stored in the 'P_device' field
    % (3) the wavelength sampling employed during the measurement of the
    % SPDs - this needs to be a vector of wavelengths, e.g., [380 382 384 ...]
    % and can be computed from the 'S' field of the calStructOBJ.
    % (4) the screen size of the display in millimeters 
    % (5) the resolution of the display in pixels
    
    % To see what fields are available in the calStructOBJ uncomment the following line
    calStructOBJ.printMappedFieldNames();
    % You will need to extract the following fields: 'gammaTable', 'S', 'P_device', 'screenSizeMM', 'screenSizePixel'
    % To see how to extract fields from a calStruct object type 'doc CalStruct' in Matlab's command window.
    
    
    % Assemble filename for generated display object
    displayFileName = sprintf('%s.mat', displayName);
    
    % check if a display object with the given name exists already
    if (~exist(displayFileName, 'file'))
        
        % Generate an isetbio display object
        % Type 'doc displaySet' in Matlab's command window for some pointers
        
        % Type necesary code to accomplish the following steps:
        
        % (1) generate a display object
        displayObject = displayCreate;
        
        % (2) set the display's name to the input parameter displayName
        displayObject = displaySet(displayObject, 'name', displayFileName);
        
        % (3) set the wavelength sampling at which the primary SPDs were measured
        s = calStructOBJ.get('S');
        top = s(2) * (s(3) - 1) + s(1);
        wave = s(1):s(2):top;
        displayObject = displaySet(displayObject, 'wave', wave);
        
        % (4) set the measured SPDs of the display
        displayObject = displaySet(displayObject, 'spd', calStructOBJ.get('P_device'));
        
        % (5) set the display's gamma table
        displayObject = displaySet(displayObject, 'gTable', calStructOBJ.get('gammaTable'));
        
        % (6) set the display resolution in dots (pixels) per inch
        m = calStructOBJ.get('screenSizeMM');
        p = calStructOBJ.get('screenSizePixel');
        
        m = m/25.4;
        mdiag = sqrt(m(1)^2 + m(2)^2);
        pdiag = sqrt(p(1)^2 + p(2)^2);
        dpi = pdiag / mdiag;
        
        displayObject = displaySet(displayObject, 'dpi', dpi);
        
        % (7) set the viewing distance to 76.4 cm
        displayObject = displaySet(displayObject, 'viewing distance', .764);
        
        % Save display object to file
        fprintf('Saving new display object (''%s'')\n', displayName);
        d = displayObject;
        save(displayFileName, 'd');
    else
        fprintf('Loading extant display object (''%s'')\n', displayName);
        displayObject = displayCreate(displayFileName);
    end 
end
