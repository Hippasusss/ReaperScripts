function main()
  
  amountOfSelectedTracks = reaper.CountSelectedTracks(0)
  selectedTracks = {}
  for i  = 0, amountOfSelectedTracks -1 do 
    currentTrack = reaper.GetSelectedTrack( 0, i )
    table.insert(selectedTracks,currentTrack)
  end
  
  for i = 1, #selectedTracks do
    currentTrackItemCount = reaper.GetTrackNumMediaItems( selectedTracks[i] )
    if currentTrackItemCount == 0 then
      reaper.DeleteTrack( selectedTracks[i] )
    end
  end
end

main()
