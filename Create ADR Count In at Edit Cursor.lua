NUMBEROFBEEPS = 3
SECONDSBETWEENBEEPS = 1
FREQUENCY = 440
BEEPLENGTHS = 0.2
NEWTRACKNAME = "ADR Sync"
UPPERVOLUME = 850 -- magic value a has changed from 1 to 850 as upper bound in reaper 6
LOWERVOLUME = 0

function SetUpTracksForBeeps()
    local numberOfTracks = reaper.CountTracks(0)
    local ADRTrack = nil
    local ADRRenderTrack = nil

    -- Get user input
    local retval, retvals = reaper.GetUserInputs( "beepConfig", 4, "Num Beeps, Sep Time, Freq(Hz), Beep Len", string.format("%d,%.1f,%d,%.1f", NUMBEROFBEEPS, SECONDSBETWEENBEEPS, FREQUENCY, BEEPLENGTHS))
    if retval == false then -- bail if cancel clicked
        return
    end

    reaper.Undo_BeginBlock()

    local vals = {}
    for v in retvals:gmatch("([^,]+)") do
        vals[#vals+1] = tonumber(v)
    end
    NUMBEROFBEEPS = vals[1]
    SECONDSBETWEENBEEPS = vals[2]
    FREQUENCY = vals[3]
    BEEPLENGTHS = vals[4]

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


    --Create temp beep making tonegen track
    reaper.Main_OnCommand(40001, 1) --New Track
    ADRTrack =  reaper.GetSelectedTrack( 0, 0 )
    reaper.TrackFX_AddByName(ADRTrack, "tonegenerator", false, 1)
    reaper.TrackFX_SetParam( ADRTrack, 0, 2, FREQUENCY)
    return ADRTrack, ADRRenderTrack
end

function AddBeepsAtPosition(position)

    local ADRTrack, ADRRenderTrack = SetUpTracksForBeeps()
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

    local cbstart = reaper.GetMediaItemInfo_Value( currentBeepsMediaItem, "D_POSITION" )
    local cbend = cbstart + reaper.GetMediaItemInfo_Value( currentBeepsMediaItem, "D_LENGTH" )
    for i = 0, reaper.CountTrackMediaItems(ADRRenderTrack)-1 do
        local currentItemRenderTrack = reaper.GetTrackMediaItem(ADRRenderTrack, i)
        local crbstart = reaper.GetMediaItemInfo_Value( currentItemRenderTrack, "D_POSITION" )
        local crbend = crbstart + reaper.GetMediaItemInfo_Value( currentItemRenderTrack, "D_LENGTH" )

        -- delete perfect overlaps (Should check for these earlier and just not generate new beeps)
        local floatThreshold = 0.0001
        if math.abs(cbstart - crbstart) < floatThreshold and math.abs(cbend - crbend) < floatThreshold then
            reaper.DeleteTrackMediaItem( ADRRenderTrack, currentItemRenderTrack)
        end

        -- trim right overlaps
        if cbstart < crbend and cbend > crbend then
            reaper.BR_SetItemEdges( currentItemRenderTrack, crbstart, cbstart)
        end
        -- trim left overlaps
        if cbend > crbstart and cbstart < crbstart then
            reaper.BR_SetItemEdges( currentItemRenderTrack, cbend, crbend)
        end
    end

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
