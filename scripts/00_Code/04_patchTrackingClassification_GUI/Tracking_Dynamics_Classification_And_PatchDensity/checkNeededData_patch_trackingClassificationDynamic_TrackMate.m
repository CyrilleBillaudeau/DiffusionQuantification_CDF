function [text_error,i_err]=checkNeededData_patch_trackingClassificationDynamic_TrackMate(pathImg,imgFilename,text_error,i_err,default_pixSize)

path_resTrack='outputTrackmate';%'outputTrackmate\';
curPath=strcat([pathImg,imgFilename]);

if (exist(path_resTrack,'dir')==7)
    
    % spec file has been generated using a simple fiji macros to return
    % pixel size and lagTime. In future, we should fixed how metadata are
    % set in raw acquisition to skip this operation
    specFile=strcat([imgFilename(1:end-4),'_spec.txt']);
    if (exist(specFile,'file')==2)
        specAcq=load(specFile);
        lagTime=specAcq(2);
        pixSize=specAcq(3);
        if (lagTime==0)
            msg_err=strcat(['lagTime = 0 in spec file for: ',curPath]);
            disp(msg_err);
            i_err=i_err+1;
            text_error{i_err}=msg_err;
        end
        if (pixSize~=default_pixSize)
            msg_err=strcat(['Warning: pixel size (',num2str(pixSize,3),' µm) is different than default value in spec file for: ',curPath]);
            disp(msg_err);
            %i_err=i_err+1;
            %text_error{i_err}=msg_err;
        end
        
    else
        msg_err=strcat(['spec file not found for: ',curPath]);
        disp(msg_err);
        i_err=i_err+1;
        text_error{i_err}=msg_err;
    end%if exist spec file
    
    %% Cells mask (area, positions, and others)
    
    filenameMask=strcat([imgFilename(1:end-4),'.txt']);
    if (exist(filenameMask,'file')~=2)
        msg_err=strcat(['missing mask for: ',curPath]);
        disp(msg_err);
        i_err=i_err+1;
        text_error{i_err}=msg_err;
    end%if exist filenameMask
    
    %% Load tracks from uTrack
    cd(path_resTrack)
    
    
    xmlfilename=strcat([imgFilename(1:(end-4)),'_Tracks.xml']);
    if (exist(xmlfilename,'file')~=2)
        msg_err=strcat(['tracking data not found for: ',curPath]);
        disp(msg_err)
        i_err=i_err+1;
        text_error{i_err}=msg_err;
    end
    
    cd(pathImg)
else
        msg_err=strcat(['missing directory with Trackmate tracks: ',path_resTrack]);
        disp(msg_err)
        i_err=i_err+1;
        text_error{i_err}=msg_err;

end%if exist
end%function