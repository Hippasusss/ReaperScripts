function main()
  _,_,_,_,_,_,mouse_scroll  = reaper.get_action_context() 
  if(mouse_scroll < 0) then
    reaper.Main_OnCommand(40155, 1)
    --bigger 40155
  else 
    reaper.Main_OnCommand(40156, 1)
    --smaller 40156
  end
end

main()
  
