
function main()
  numberOfTracks = reaper.CountSelectedTracks(0)
  tracksToDuplicate = {}
  
  --Keep a note of the original track selection
  for i = 0, numberOfTracks - 1 do
    currentTrack = reaper.GetSelectedTrack( 0, i )
    table.insert(tracksToDuplicate, currentTrack) 
  end
  
  -- Duplicate Selected Tracks
  reaper.Main_OnCommand( 40062, 1 )
  
  --Select the duplicated tracks by selecting the tracks next to the originals 
  for i = 1, #tracksToDuplicate do
    reaper.SetTrackSelected( tracksToDuplicate[i],  false )
    if tracksToDuplicate[i+1] ~= nil then
      reaper.SetTrackSelected(GetNextTrack(tracksToDuplicate[i]), true)
    end
  end
  
end
  
    
function GetNextTrack(track)
  trackNumber = reaper.GetMediaTrackInfo_Value( track, "IP_TRACKNUMBER" )
  if trackNumber + 1 <= reaper.CountTracks(0) then
    return reaper.GetTrack( 0, trackNumber + 1 )
  end
end

function print(message)
  reaper.ShowConsoleMsg(message.. "\n")
end

main()
