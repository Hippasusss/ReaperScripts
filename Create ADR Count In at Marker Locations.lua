
local beepCreator = dofile(reaper.GetResourcePath() .. "/Scripts/ADRBeepsModule.lua")

local startingCursorPosition = reaper.GetCursorPosition()
local _, numberOfMarkers, _ = reaper.CountProjectMarkers(0)
local config = beepCreator.GetBeepConfigFromUser()
local ADRTrack, ADRRenderTrack = beepCreator.SetUpTracksForBeeps(config)

for i = 1, numberOfMarkers do
    reaper.GoToMarker(0, i, false)
    beepCreator.AddBeepsAtPosition(reaper.GetCursorPosition(), ADRTrack, ADRRenderTrack)
end

beepCreator.CleanupTracks()

reaper.MoveEditCursor(startingCursorPosition - reaper.GetCursorPosition(), false)
reaper.UpdateArrange()
