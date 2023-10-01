function main()
  amountOfSelectedItems = reaper.CountSelectedMediaItems(0)
  for i =0, amountOfSelectedItems -1 do
    currentItem = reaper.GetSelectedMediaItem( 0, i)
    if currentItem ~= nil then
      if reaper.GetMediaTrackInfo_Value( reaper.GetMediaItem_Track( currentItem ), "I_SELECTED" ) == 0 then
        reaper.SetMediaItemSelected(  currentItem, false )
      end
    end
  end 
end

main()

