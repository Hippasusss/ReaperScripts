
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
  upperVolume = 1
  lowerVolume = 0
  ADRTrack = nil
  
  reaper.Undo_BeginBlock()
 
  --Check and see if the track is already there and just use it if it is
  for i = 0, numberOfTracks - 1 do
    track = reaper.GetTrack( 0, i )
    nope, trackName =  reaper.GetSetMediaTrackInfo_String( track, "P_NAME", "", false)
    if newTrackName == trackName then
      ADRtrack = track
      reaper.TrackFX_AddByName(ADRtrack, "tonegenerator", false, 1)
      newTrack = false
      break
    end
  end
  
  --Set the new track for the beeps up if it isn't already there
  if newTrack then
    reaper.Main_OnCommand(40001, 1) --New Track
    ADRtrack = reaper.GetSelectedTrack( 0, 0 )
    reaper.TrackFX_AddByName(ADRtrack, "tonegenerator", false, 1)
    reaper.GetSetMediaTrackInfo_String( ADRtrack, "P_NAME", newTrackName, true)
  end
   
  --Select the track and prepare it
  reaper.SetOnlyTrackSelected( ADRtrack )
  volumeEnvelope = reaper.GetTrackEnvelopeByChunkName( ADRtrack, "<VOLENV2" ) 
  modifyEnvelope(volumeEnvelope, true, true)
  
  
  reaper.SetCursorContext(2, volumeEnvelope)
  reaper.Main_OnCommand(40332, 1)--Select All Automation Points
  reaper.Main_OnCommand(40333, 1)--Clear Selected Automation Points

  reaper.SetMediaTrackInfo_Value(ADRtrack, "B_MUTE", 1)--Mute it to stop popping
  --Automate Beeps
  reaper.SetEditCurPos( 0, false, false )
  reaper.InsertEnvelopePoint( volumeEnvelope,  reaper.GetCursorPosition(), lowerVolume, 0, 0, false)
  for i = 1, numberOfMarkers do 
    reaper.GoToMarker(0, i, false)
    AutomateBeeps(beepLengthS, numberOfBeeps, volumeEnvelope)
  end  
  reaper.SetMediaTrackInfo_Value(ADRtrack, "B_MUTE", 0)--Unmute
  
  --return the edit cursor position to whereit started and unmute
  reaper.SetEditCurPos( cursorPosition, false, false )
  reaper.Main_OnCommand(40888, 1)--Show All Active Automation Lanes
  modifyEnvelope(volumeEnvelope, true, true) 
  reaper.Undo_EndBlock("Added ADR Sync Beeps Using Markers",0)
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

function print(message)
  reaper.ShowConsoleMsg(message)
end

main()
reaper.UpdateArrange()
