function [xTraj,yTraj,timeTraj]=extract_singleTrajCoordinates(lstTraj,iTraj)
curTraj=lstTraj(iTraj).tracksCoordAmpCG;curTraj=curTraj';
xTraj=curTraj(1:8:end);yTraj=curTraj(2:8:end);ampl=curTraj(4:8:end);
%xTraj_std=curTraj(5:8:end);yTraj_std=curTraj(6:8:end);ampl_std=curTraj(8:8:end);
timeTraj=lstTraj(iTraj).seqOfEvents;
end%