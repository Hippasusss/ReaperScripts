function main()

    CountMediaItems = reaper.CountSelectedMediaItems(0)

    if CountMediaItems < 1 then goto continue end

    for j = 0, CountMediaItems-1 do
        if j+1 >= CountMediaItems then goto continue end
        currentItem = reaper.GetSelectedMediaItem(0,j);
        reaper.SetMediaItemInfo_Value( currentItem, "B_LOOPSRC", 1)
        nextItem = reaper.GetSelectedMediaItem(0, j+1)
        length =  reaper.GetMediaItemInfo_Value(nextItem, "D_POSITION")- reaper.GetMediaItemInfo_Value(currentItem, "D_POSITION")
        reaper.SetMediaItemLength(currentItem,length, true)
    end
    currentItem = reaper.GetSelectedMediaItem(0,CountMediaItems - 1);
    reaper.SetMediaItemInfo_Value( currentItem, "B_LOOPSRC", 1)
    ::continue::
end

main()
