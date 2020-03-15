function main() 
  reaper.Undo_BeginBlock()
  command = reaper.NamedCommandLookup("_d48f0f8a7f10e74cbc31aa579bc48495") 

  amountOfSelectedItems = reaper.CountSelectedMediaItems(0)
  itemsToProccess = {}
  
  for i = 0, amountOfSelectedItems-1  do
    currentItem = reaper.GetSelectedMediaItem(0, i) -- Get selected item i
    table.insert(itemsToProccess, currentItem) 
  end
  for i = 1, #itemsToProccess do
    reaper.SelectAllMediaItems( 0, 0 )
    reaper.SetMediaItemSelected(itemsToProccess[i], 1)
    reaper.Main_OnCommand(command, 1)
  
  end
  reaper.Undo_EndBlock("Run Command On Multiple Items", 0)
end
main()
