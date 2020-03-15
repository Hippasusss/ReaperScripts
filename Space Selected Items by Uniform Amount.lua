function main()
    distanceBetweenItems = 0.5
    
    CountMediaItems = reaper.CountSelectedMediaItems(0)

    if CountMediaItems < 1 then goto continue end
    nextPosition = reaper.GetMediaItemInfo_Value(reaper.GetSelectedMediaItem(0, 0), "D_POSITION")
    for j = 0, CountMediaItems-1 do
        currentItem = reaper.GetSelectedMediaItem(0,j);
        reaper.SetMediaItemPosition(currentItem, nextPosition, true)
        nextPosition = reaper.GetMediaItemInfo_Value(currentItem, "D_POSITION") + reaper.GetMediaItemInfo_Value(currentItem, "D_LENGTH") + distanceBetweenItems
    end
    ::continue::
end

main()
