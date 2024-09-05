NUMBEROFBEEPS = 3
SECONDSBETWEENBEEPS = 1
FREQUENCY = 300
BEEPLENGTHS = 0.2
NEWTRACKNAME = "ADR Sync"
UPPERVOLUME = 850 -- magic value a has changed from 1 to 850 as upper bound in reaper 6
LOWERVOLUME = 0

function AddBeepsAtPosition(position)
    local numberOfTracks = reaper.CountTracks(0)
    local ADRTrack = nil
    local ADRRenderTrack = nil

    reaper.Undo_BeginBlock()
    local retval, retvals_csv = reaper.GetUserInputs( "beepConfig", 4, "Num Beeps, Sep Time, Freq(Hz), Beep Len", string.format("%d,%.1f,%d,%.1f", NUMBEROFBEEPS, SECONDSBETWEENBEEPS, FREQUENCY, BEEPLENGTHS))
    if retval == false then
        return
    end

    --Check and see if the track is already there and just use it if it is
    local newTrack = true
    for i = 0, numberOfTracks - 1 do
        local track = reaper.GetTrack( 0, i )
        local _, trackName =  reaper.GetSetMediaTrackInfo_String( track, "P_NAME", "", false)
        if NEWTRACKNAME == trackName then
            ADRRenderTrack = track
            newTrack = false
            break
        end
    end

    --Set the new track for the beeps up if it isn't already there
    if newTrack then
        reaper.Main_OnCommand(40001, 1) --New Track
        ADRRenderTrack = reaper.GetSelectedTrack( 0, 0 )
        reaper.GetSetMediaTrackInfo_String( ADRRenderTrack, "P_NAME", NEWTRACKNAME, true)
    end

    reaper.Main_OnCommand(40001, 1) --New Track
    ADRTrack =  reaper.GetSelectedTrack( 0, 0 )
    reaper.TrackFX_AddByName(ADRTrack, "tonegenerator", false, 1)

    reaper.SetOnlyTrackSelected( ADRTrack )
    local volumeEnvelope = reaper.GetTrackEnvelopeByChunkName( ADRTrack, "<VOLENV2" )
    ModifyEnvelope(volumeEnvelope, true, true)
    reaper.SetCursorContext(2, volumeEnvelope)

    reaper.SetMediaTrackInfo_Value(ADRTrack, "B_MUTE", 1)--Mute it to stop popping

    local startPoint, endPoint
    -- Automation 
    endPoint = reaper.GetCursorPosition()
    for _ = 0, NUMBEROFBEEPS - 1 do
        --Bottom left point
        reaper.MoveEditCursor( -SECONDSBETWEENBEEPS, false )
        reaper.InsertEnvelopePoint( volumeEnvelope,  reaper.GetCursorPosition(), LOWERVOLUME, 0, 0, false)

        --Top left point    
        reaper.MoveEditCursor( 0.01, false )
        reaper.InsertEnvelopePoint( volumeEnvelope,  reaper.GetCursorPosition(), UPPERVOLUME, 0, 0, false)

        --Top right point        
        reaper.MoveEditCursor( BEEPLENGTHS -0.02 , false )
        reaper.InsertEnvelopePoint( volumeEnvelope,  reaper.GetCursorPosition(), UPPERVOLUME, 0, 0, false)

        --Bottom right point    
        reaper.MoveEditCursor( 0.01, false )
        reaper.InsertEnvelopePoint( volumeEnvelope,  reaper.GetCursorPosition(), LOWERVOLUME, 0, 0, false)

        reaper.MoveEditCursor( -BEEPLENGTHS, false )
    end
    startPoint = reaper.GetCursorPosition()
    reaper.SetMediaTrackInfo_Value(ADRTrack, "B_MUTE", 0)--Unmute

    reaper.Main_OnCommand(40888, 1)--Show All Active Automation Lanes
    ModifyEnvelope(volumeEnvelope, true, true)

    reaper.GetSet_LoopTimeRange(true, false, startPoint, endPoint, false)
    reaper.Main_OnCommand(41718, 1)--Render Selected Area of Selected Tracks To Mono (Post Fade)

    local currentRenderTrack = reaper.GetSelectedTrack( 0, 0)
    local currentBeepsMediaItem = reaper.GetTrackMediaItem( currentRenderTrack, 0)
    reaper.MoveMediaItemToTrack( currentBeepsMediaItem, ADRRenderTrack)
    reaper.DeleteTrack(currentRenderTrack)
    reaper.DeleteTrack(ADRTrack)

    reaper.SetEditCurPos( position, false, false )
    reaper.Undo_EndBlock("Added ADR Sync Beeps Using Cursor",0)
end

function ModifyEnvelope(envelope, activate, visible)
    local _, rppxml = reaper.GetEnvelopeStateChunk(envelope, "", true)
    if activate then rppxml = string.gsub(rppxml, "ACT 0", "ACT 1") end
    if visible then
        rppxml = string.gsub(rppxml, "VIS 0", "VIS 1")
        rppxml = string.gsub(rppxml, "ARM 0", "ARM 1")
    end
    reaper.SetEnvelopeStateChunk(envelope, rppxml, true)
end


AddBeepsAtPosition(reaper.GetCursorPosition())
reaper.UpdateArrange()
