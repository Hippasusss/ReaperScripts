
local beepCreator = dofile(reaper.GetResourcePath() .. "/Scripts/ADRBeepsModule.lua")
local config = beepCreator.GetBeepConfigFromUser()
local ADRTrack, ADRRenderTrack = beepCreator.SetUpTracksForBeeps(config)
beepCreator.AddBeepsAtPosition(reaper.GetCursorPosition(), ADRTrack, ADRRenderTrack)
beepCreator.CleanupTracks()
reaper.UpdateArrange()

