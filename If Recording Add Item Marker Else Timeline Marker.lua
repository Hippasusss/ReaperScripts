function main()
    insertItemMarker     = 42385
    insertTimelineMarker = 40157
    
    isRecording = reaper.GetPlayState() == 5

    if isRecording then 
        reaper.Main_OnCommand(insertItemMarker, 1)
    else
        reaper.Main_OnCommand(insertTimelineMarker, 1)
    end
end

main()
