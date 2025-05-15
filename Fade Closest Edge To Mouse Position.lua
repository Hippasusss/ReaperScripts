local function main()
  local item, mousePosition = reaper.BR_ItemAtMouseCursor()
  if item ~= nil then
    Fade(item)
  else
    local track
    track, _, mousePosition = reaper.BR_TrackAtMouseCursor()
    if track == nil then return end
    Fade(GetClosestItemToPositiontInTrack(mousePosition, track))
  end
end

function GetClosestItemToPositiontInTrack(position, track)
  local numberOfTrackItems = reaper.CountTrackMediaItems( track )
  local previousItemEnd = 0

  for i = 0, numberOfTrackItems - 1 do
    local currentItem =  reaper.GetTrackMediaItem( track, i )
    local nextItem =  reaper.GetTrackMediaItem( track, i+1 )
    if i+1 == numberOfTrackItems then return currentItem end

    local currentItemStart, currentItemEnd = GetStartAndEndOfItem(currentItem)
    local nextItemStart, nextItemEnd = GetStartAndEndOfItem(nextItem)

    if previousItemEnd < position and position < nextItemEnd then
      if AisCloserToPointThanB(currentItemStart, nextItemStart, position) or
         AisCloserToPointThanB(currentItemEnd, nextItemStart, position)then
         return currentItem
       end
    end
    previousItemEnd = currentItemEnd
  end
end

function Fade(item)
  if item ~= nil then
    local itemStart, itemEnd =  GetStartAndEndOfItem(item)
    local itemLength = itemEnd - itemStart
    local itemCenter = itemStart + (itemLength/ 2)
    local fadeStart = mousePosition < itemCenter


    if fadeStart then reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN", mousePosition - itemStart)
    else reaper.SetMediaItemInfo_Value(item, "D_FADEOUTLEN", itemEnd - mousePosition)
    end
  end
end

function GetStartAndEndOfItem(item)
  local itemStart = reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
  local itemLength = reaper.GetMediaItemInfo_Value( item, "D_LENGTH")
  local itemEnd = itemStart + itemLength
  return itemStart, itemEnd
end

function AisCloserToPointThanB(a, b, point)
  if math.abs(point - a) < math.abs(point - b) then return true
  else return false end
end

main()
reaper.UpdateArrange()
