function main()
  item, mousePosition = reaper.BR_ItemAtMouseCursor()
  if item ~= nil then
    trim(item)
  else
    track, context, mousePosition = reaper.BR_TrackAtMouseCursor()
    if track == nil then return end
    trim(getClosestItemToPositiontInTrack(mousePosition, track))
  end
end

function getClosestItemToPositiontInTrack(position, track)
  numberOfTrackItems = reaper.CountTrackMediaItems( track ) 
  previousItemEnd = 0
  
  for i = 0, numberOfTrackItems - 1 do
    currentItem =  reaper.GetTrackMediaItem( track, i )
    nextItem =  reaper.GetTrackMediaItem( track, i+1 )
    if i+1 == numberOfTrackItems then return currentItem end

    currentItemStart, currentItemEnd = getStartAndEndOfItem(currentItem)
    nextItemStart, nextItemEnd = getStartAndEndOfItem(nextItem)
        
    if previousItemEnd < position and position < nextItemEnd then
      if AisCloserToPointThanB(currentItemStart, nextItemStart, position) or
         AisCloserToPointThanB(currentItemEnd, nextItemStart, position)then
         return currentItem
       end
    end
    previousItemEnd = currentItemEnd
  end
end

function trim(item)
  if item ~= nil then
    itemStart, itemEnd =  getStartAndEndOfItem(item)
    itemLength = itemEnd - itemStart
    itemCenter = itemStart + (itemLength/ 2)
    trimStart = mousePosition < itemCenter  
      
    if trimStart then reaper.BR_SetItemEdges( item, mousePosition, itemEnd )
    else reaper.BR_SetItemEdges( item, itemStart, mousePosition )end --trimEnd  
  end
end

function getStartAndEndOfItem(item)
  itemStart = reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
  itemLength = reaper.GetMediaItemInfo_Value( item, "D_LENGTH")
  itemEnd = itemStart + itemLength
  return itemStart, itemEnd
end

function AisCloserToPointThanB(a, b, point)
  if math.abs(point - a) < math.abs(point - b) then return true
  else return false end
end


function print(message)
  reaper.ShowConsoleMsg(message.. "\n")
end

main()
reaper.UpdateArrange()
    
