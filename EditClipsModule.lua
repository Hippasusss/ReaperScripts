local M = {}

function M.CallBackOnClosestEdge(callback)
    if not callback then return end
    local item, mousePosition = reaper.BR_ItemAtMouseCursor()
    if item ~= nil then
        callback(item, mousePosition)
    else
        local track
        track, _, mousePosition = reaper.BR_TrackAtMouseCursor()
        if track == nil then return end
        callback(M.GetClosestItemToPointInTrack(mousePosition, track), mousePosition)
    end
end

function M.GetClosestItemToPointInTrack(point, track)
    local numberOfTrackItems = reaper.CountTrackMediaItems( track )
    local previousItemEnd = 0

    for i = 0, numberOfTrackItems - 1 do
        local currentItem =  reaper.GetTrackMediaItem( track, i )
        local nextItem =  reaper.GetTrackMediaItem( track, i+1 )
        if i+1 == numberOfTrackItems then return currentItem end

        local currentItemStart, currentItemEnd = M.GetStartAndEndOfItem(currentItem)
        local nextItemStart, nextItemEnd = M.GetStartAndEndOfItem(nextItem)

        if previousItemEnd < point and point < nextItemEnd then
            if M.AisCloserToPointThanB(currentItemStart, nextItemStart, point) or
                M.AisCloserToPointThanB(currentItemEnd, nextItemStart, point)then
                return currentItem
            end
        end
        previousItemEnd = currentItemEnd
    end
end

local function getItemTrimData(item, position)
    if item ~= nil then
        local itemStart, itemEnd = M.GetStartAndEndOfItem(item)
        local itemLength = itemEnd - itemStart
        local itemCenter = itemStart + (itemLength/ 2)
        local actionStart = position < itemCenter
        return itemStart, itemEnd, actionStart
    end
end

function M.Fade(item, position)
    local itemStart, itemEnd, fadeStart = getItemTrimData(item, position)
    if fadeStart then reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN", position - itemStart)
    else reaper.SetMediaItemInfo_Value(item, "D_FADEOUTLEN", itemEnd - position)
    end
end

function M.Trim(item, position)
    local itemStart, itemEnd, trimStart = getItemTrimData(item, position)
    if trimStart then reaper.BR_SetItemEdges(item, position, itemEnd )
    else reaper.BR_SetItemEdges( item, itemStart, position )end --trimEnd  
end

function M.GetStartAndEndOfItem(item)
    local itemStart = reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
    local itemLength = reaper.GetMediaItemInfo_Value( item, "D_LENGTH")
    local itemEnd = itemStart + itemLength
    return itemStart, itemEnd
end

function M.AisCloserToPointThanB(a, b, point)
    if math.abs(point - a) < math.abs(point - b) then return true
    else return false end
end
return M

