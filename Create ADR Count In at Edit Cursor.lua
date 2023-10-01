function main()
  cursorPosition = reaper.GetCursorPosition() 
  numberOfTracks = reaper.CountTracks(0)
  numberOfSelectedTracks = reaper.CountSelectedTracks(0)
  numberOfRegionsAndMarkers, numberOfMarkers, numberOfRegions = reaper.CountProjectMarkers(0)
  numberOfBeeps = 3
  secondsBetweenBeeps = 1
  beepLengthS = 0.2
  newTrackName = "ADR Sync"
  newTrack = true
<<<<<<< HEAD
  upperVolume = 1
=======
  upperVolume = 850 -- magic value a has changed from 1 to 850 as upper bound in reaper 6
>>>>>>> 4c1d8e8f40b1c58360a599a8842b825750556ab5
  lowerVolume = 0
  ADRTrack = nil
  
  
  reaper.Undo_BeginBlock()
  
  --Check and see if the track is already there and just use it if it is
  for i = 0, numberOfTracks - 1 do
    track = reaper.GetTrack( 0, i )
    nope, trackName =  reaper.GetSetMediaTrackInfo_String( track, "P_NAME", "", false)
    if newTrackName == trackName then
      ADRtrack = track
      newTrack = false
      break
    end
  end
  

  --Set the new track for the beeps up if it isn't already there
  if newTrack then
    reaper.Main_OnCommand(40001, 1) --New Track
    ADRtrack =  reaper.GetSelectedTrack( 0, 0 )
    reaper.TrackFX_AddByName(ADRtrack, "tonegenerator", false, 1)
    reaper.GetSetMediaTrackInfo_String( ADRtrack, "P_NAME", newTrackName, true)
  end
  
  reaper.SetOnlyTrackSelected( ADRtrack )
  volumeEnvelope = reaper.GetTrackEnvelopeByChunkName( ADRtrack, "<VOLENV2" ) 
  modifyEnvelope(volumeEnvelope, true, true)
  reaper.SetCursorContext(2, volumeEnvelope)
  
  reaper.SetMediaTrackInfo_Value(ADRtrack, "B_MUTE", 1)--Mute it to stop popping
  AutomateBeeps(beepLengthS,numberOfBeeps, volumeEnvelope)
  reaper.SetMediaTrackInfo_Value(ADRtrack, "B_MUTE", 0)--Unmute
  
  reaper.SetEditCurPos( cursorPosition, false, false )
  reaper.Main_OnCommand(40888, 1)--Show All Active Automation Lanes
  modifyEnvelope(volumeEnvelope, true, true) 
  
  reaper.Undo_EndBlock("Added ADR Sync Beeps Using Cursor",0)
  
end

function AutomateBeeps(length, number, envelope)
  for j = 0, number - 1 do
    --Bottom left point
    reaper.MoveEditCursor( -secondsBetweenBeeps, false )
    reaper.InsertEnvelopePoint( envelope,  reaper.GetCursorPosition(), lowerVolume, 0, 0, false)
    
    --Top left point    
    reaper.MoveEditCursor( 0.01, false )
    reaper.InsertEnvelopePoint( envelope,  reaper.GetCursorPosition(), upperVolume, 0, 0, false)
    
    --Top right point        
    reaper.MoveEditCursor( length -0.02 , false )
    reaper.InsertEnvelopePoint( envelope,  reaper.GetCursorPosition(), upperVolume, 0, 0, false)
     
    --Bottom right point    
    reaper.MoveEditCursor( 0.01, false )
    reaper.InsertEnvelopePoint( envelope,  reaper.GetCursorPosition(), lowerVolume, 0, 0, false)
        
    reaper.MoveEditCursor( -length, false )
  end
end 

function modifyEnvelope(envelope, activate, visible)
  local env, ret, rppxml
  ret, rppxml = reaper.GetEnvelopeStateChunk(envelope, "", true)
  if activate then rppxml = string.gsub(rppxml, "ACT 0", "ACT 1") end
  if visible then 
    rppxml = string.gsub(rppxml, "VIS 0", "VIS 1") 
    rppxml = string.gsub(rppxml, "ARM 0", "ARM 1")
  end
  reaper.SetEnvelopeStateChunk(envelope, rppxml, true)
end

main()
reaper.UpdateArrange()
