

local playState =  reaper.GetPlayState()

local playPositionSeconds = 0.0
if (playState & 1 == 1) or (playState & 4 == 4) then
    playPositionSeconds = reaper.GetPlayPosition()
else
    playPositionSeconds = reaper.GetCursorPosition()
end

local timeCode = reaper.format_timestr_pos(playPositionSeconds, "", 5)

local _, rectag = reaper.GetSetProjectInfo_String(0, "RECTAG","", false)

local clipboardText = ""
if rectag == "" then
    clipboardText = timeCode
else
    clipboardText = rectag .. "\n" .. timeCode
end

reaper.CF_SetClipboard(clipboardText)
