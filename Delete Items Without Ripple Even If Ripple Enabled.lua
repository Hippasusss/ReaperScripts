

function main()
  
  all = reaper.GetToggleCommandState(40311)
  one = reaper.GetToggleCommandState(40310)
  
  reaper.SetToggleCommandState( 0, 40309, 1)
  

  amountOfSelectedItems = reaper.CountSelectedMediaItems(0)
  itemsToDelete = {}
  
  for i = 0, amountOfSelectedItems-1  do
    currentItem = reaper.GetSelectedMediaItem(0, i) -- Get selected item i
    table.insert(itemsToDelete, currentItem) 
  end
  for i = 1, #itemsToDelete do
    track = reaper.GetMediaItemTrack(itemsToDelete[i])
    reaper.DeleteTrackMediaItem(track, itemsToDelete[i])
  end
    
  if all == 1 then 
    reaper.SetToggleCommandState(0,1, 40311)
    return
  elseif one == 1 then 
    reaper.SetToggleCommandState(0,1, 40310)
    return
  else 
    reaper.SetToggleCommandState(0,1, 40309)
    return
  end 
end

function deleteMediaItem(mediaItem)
  reaper.DeleteTrackMediaItem(reaper.GetMediaItemTrack(mediaItem),mediaItem)
end

function print(message)
  reaper.ShowConsoleMsg(message.. "\n")
end
  
main()
reaper.UpdateArrange()
