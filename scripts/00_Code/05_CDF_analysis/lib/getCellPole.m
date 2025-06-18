function [all_cellPole]=getCellPole(lst_path)
% return array with cell pole ccordinates for each cells
all_cellPole=[];
%% ATTENTION CONSERVER CELL ID SINON PB ASSIGNATION TRAJ/CELL
nFile=numel(lst_path);
disp('Get cell pole ...')
for iFile=1:nFile
    
    curFile=lst_path{iFile};
    curFolder_parent=strsplit(curFile,strcat('outputTrackmate',filesep));
    xmlfile=curFolder_parent{2};
    curFolder_parent=curFolder_parent{1};
    cd(curFolder_parent);
    imgFilename=replace(xmlfile,'_Tracks.xml','.tif');
    disp(imgFilename)

    % curFolder=lst_path{iFile};
    % cd(curFolder);
    
    filenameMask=strcat([imgFilename(1:end-4),'.txt']);
    imgCell=load(filenameMask);
    %imgCell=load('cellMsk_label.txt');
    imgCell_skel=bwskel(imgCell>0);
    lstCell=unique(imgCell(:));lstCell(lstCell==0)=[];
    %figure(50);clf;imshow(imgCell,[])
    %figure(50);clf;imshow(imgCell>0,[])
    %figure(51);clf;imshow(bwskel(imgCell>0))
    
    for iCell=1:numel(lstCell)
        cellID=lstCell(iCell);
        cur_cell=(imgCell==cellID);
        cur_skel=imgCell_skel;
        cur_skel(imgCell~=cellID)=0;
        %figure(52);clf;imshow(cur_skel)
        
        [iiS,ijS]=find(cur_skel);
        skelW=NaN(numel(iiS),1);
        for iS=1:numel(iiS)
            ii=(iiS(iS)-1):(iiS(iS)+1);
            ij=(ijS(iS)-1):(ijS(iS)+1);
            skelW(iS)=sum(sum(cur_skel(ii,ij)))-1;
        end%for
        %figure(50);hold on;plot(ijS(skelW==1),iiS(skelW==1),'+')
        ptExt=[ijS(skelW==1),iiS(skelW==1)];
        
        if (size(ptExt,1)==2)
            pto1 = ptExt(1,:);
            pto2 = ptExt(2,:);
            
            % A vector along the ray from pto1 to pto2...
            V = pto2 - pto1;
            % The distance between the points would be:
            %   dist12 = norm(V);
            % but there is no need to compute it.
            % which will be extended (by 20% in this case) here
            
            % Extend the ray
            %             factor_distance = 1.2;
            %             pext2 = pto1 + V*factor_distance;
            %             pext1 = pto2 - V*factor_distance;
            
            for factor_distance = 1:0.01:2
                pext2 = pto1 + V*factor_distance;
                pext2=floor(pext2);
                if ((max(pext2)<max(size(cur_cell)))&(min(pext2)>0))
                    if cur_cell(pext2(2), pext2(1))
                        pol2=pext2;
                    end%if
                end%if
            end
            
            for factor_distance = 1:0.01:2
                pext1 = pto2 - V*factor_distance;
                pext1=floor(pext1);
                if ((max(pext1)<max(size(cur_cell)))&(min(pext1)>0))
                    if cur_cell(pext1(2), pext1(1))
                        pol1=pext1;
                    end%if
                end%if
            end
            %figure(50);hold on; plot([pol1(1),pol2(1)],[pol1(2),pol2(2)],'ro')
        end%for
        all_cellPole=[all_cellPole;[iFile,iCell,pol1,pol2]];
    end%for
    %pause()
end%for iFolder

disp('Get cell done!')

end%function