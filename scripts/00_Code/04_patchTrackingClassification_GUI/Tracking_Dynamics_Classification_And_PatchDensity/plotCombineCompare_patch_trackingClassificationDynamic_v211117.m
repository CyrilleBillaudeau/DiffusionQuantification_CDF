function plotCombineCompare_patch_trackingClassificationDynamic_v211117(AVERAGING_METHOD_FOR_COMBINE)

switch (AVERAGING_METHOD_FOR_COMBINE)
    case 1
        plotCombineCompare_patch_trackingClassificationDynamic_cellAvg();
    case 2
        plotCombineCompare_patch_trackingClassificationDynamic();
end%switch

end%function