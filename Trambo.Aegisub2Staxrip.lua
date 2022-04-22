script_name="@TRAMBO: Aegisub2Staxrip"
script_description="Import working Aegisub files to StaxRip"
script_author="TRAMBO"
script_version="1.0"

-- Staxrip folder contains StaxRip.exe, Apps, Settings,...
-- For example: 
-- staxrip_path = C:\TRAMBO\Applications\StaxRip-v2.6.0-x64

trambo = aegisub.decode_path("?user") .. "\\Trambo"
path_file = trambo .. "\\Aegisub2Staxrip_path.txt"
err_ok = "                     OK                     "
err_cancel = "                     Cancel                     "
err_buttons = {err_ok,err_cancel}

function main(sub, sel, act)
  staxrip_path = check_path()
  ADP = aegisub.decode_path
  sf = string.format
  video = aegisub.project_properties().video_file; 
  subtitles = ADP("?script") .. "\\" .. aegisub.file_name();
  bat = trambo .. [[\Aegisub2Staxrip.bat]]
  f = io.open(bat,"w")
  s = sf("cd %s",staxrip_path)
  f:write(s)
  f:write("\n")
  s = sf([[StaxRip "%s" -AddFilter:true,"Aegisub2Staxrip","Subtitles","LoadPlugin(\"%s\") TextSubMod(\"%s\")"]],video,"%%app:VSFilterMod%%",subtitles)
  f:write(s)
  f:write("\n")
  f:write("exit")
  f:write("\n")
  f:close()
  os.execute(sf([[start /MIN %s]],bat))
  return sel
end

function update_staxrip_path()
  get_staxrip_path(2)
end


function get_staxrip_path(mode)
  ok = "OK"
  cancel = "Cancel"
  buttons = {}

  gui = {}
  if mode == 1 then
    gui = {
      {x=0,y=0,height=1,width=1,class="label",label="You need to update your StaxRip folder path:"},
      {x=0,y=1,height=1,width=1,class="edit",text="",name="path"}
    }
    ok = "            OK            "
    cancel = "            Cancel            "
  elseif mode == 2 then
    gui = {
      {x=0,y=0,height=1,width=1,class="label",label="Paste your StaxRip folder path here:"},
      {x=0,y=1,height=1,width=1,class="edit",text="",name="path", hint="The folder that contains StaxRip.exe, Apps, Settings,..."}
    }
    ok = "       OK       "
    cancel = "       Cancel       "
  end
  buttons = {ok,cancel}
  choice,res = aegisub.dialog.display(gui,buttons)
  if choice == ok then
    while not found(res.path .. [[\StaxRip.exe]]) do
      choice,res = get_err_GUI()
      if choice ~= err_ok then
        break
      end
    end
    if found(res.path .. [[\StaxRip.exe]]) then
      f=io.open(path_file,"w")
      f:write(res.path)
      f:close()
    end
  end
  return res.path
end

function found(file)
  local res, err, code = os.rename(file, file)
  return res
end

function check_path()
  if not found(trambo) then
    os.execute("mkdir -p " .. trambo)
  end
  staxrip_path = ""
  f=io.open(path_file,"r") 
  if f==nil then 
    staxrip_path = get_staxrip_path(1)
  else
    p = f:read()
    if p ~=nil then
      if found(p .. [[\StaxRip.exe]]) then
        staxrip_path=p
      else
        staxrip_path = get_staxrip_path(1)
      end
    else
      staxrip_path = get_staxrip_path(1)
    end
  end
  return staxrip_path
end

function get_err_GUI()
  err_gui = 
  {
    {x=0,y=0,height=1,width=1,class="label",label="Your folder path is not correct, please double check and try again:"},
    {x=0,y=1,height=1,width=1,class="edit",text="",name="path", hint="The folder that contains StaxRip.exe, Apps, Settings,..."}
  }
  choice,res = aegisub.dialog.display(err_gui,err_buttons)
  return choice, res
end

--send to Aegisub's automation list
aegisub.register_macro([[@TRAMBO: Aegisub2Staxrip/Open StaxRip]],"Open StaxRip",main)
aegisub.register_macro([[@TRAMBO: Aegisub2Staxrip/Update StaxRip Folder]],"Update StaxRip Folder",update_staxrip_path)