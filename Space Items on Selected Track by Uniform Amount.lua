
function main()
    distanceBetweenItems = 0.5
    countSelectedTracks = reaper.CountSelectedTracks(0)
    if currentSelectedTracks == 0 then return end
    for i = 0, countSelectedTracks - 1 do 

        currentTrack = reaper.GetSelectedTrack(0,i)
        currentTrackNoMediaItems = reaper.GetTrackNumMediaItems(currentTrack)

        if currentTrackNoMediaItems < 1 then goto continue end
        nextPosition = reaper.GetMediaItemInfo_Value(reaper.GetTrackMediaItem(currentTrack, 0), "D_POSITION")
        for j = 0, currentTrackNoMediaItems-1 do
            currentItem = reaper.GetTrackMediaItem(currentTrack,j);
            reaper.SetMediaItemPosition(currentItem, nextPosition, true)
            nextPosition = reaper.GetMediaItemInfo_Value(currentItem, "D_POSITION") + reaper.GetMediaItemInfo_Value(currentItem, "D_LENGTH") + distanceBetweenItems
        end
        ::continue::
    end
end

main()
