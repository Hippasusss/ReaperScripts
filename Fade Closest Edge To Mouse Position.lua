local editClip = dofile(reaper.GetResourcePath() .. "/Scripts/EditClipsModule.lua")
editClip.CallBackOnClosestEdge(editClip.Fade)
reaper.UpdateArrange()
