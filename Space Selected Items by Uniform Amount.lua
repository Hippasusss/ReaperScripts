local function main()
    local distanceBetweenItems = 0.5

    CountMediaItems = reaper.CountSelectedMediaItems(0)

    if CountMediaItems < 1 then goto continue end
    local nextPosition = reaper.GetMediaItemInfo_Value(reaper.GetSelectedMediaItem(0, 0), "D_POSITION")
    for j = 0, CountMediaItems-1 do
        local currentItem = reaper.GetSelectedMediaItem(0,j);
        local reaper.SetMediaItemPosition(currentItem, nextPosition, true)
        nextPosition = reaper.GetMediaItemInfo_Value(currentItem, "D_POSITION") + reaper.GetMediaItemInfo_Value(currentItem, "D_LENGTH") + distanceBetweenItems
    end
    ::continue::
end

main()
