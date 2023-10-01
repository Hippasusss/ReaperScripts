
--TODO: make this a relative path and stick all the python stuff in the same DIR
DRIVERPATH = ".\\Drive\\driver.py\""

function main()
    setRenderSettings()
    exportPath = getExportPath()
    renameRegions()

    renderProject()
    worked, clientName= reaper.GetUserInputs( "Client Name", 1, "Client Name:", "")

    pythonCommand = string.format("python %s \"%s\" %s", DRIVERPATH, exportPath, clientName)
    print(pythonCommand)
    os.execute(pythonCommand)
end

function getExportPath()
    _, projectPath = reaper.EnumProjects(-1)
    projectPath = splitFileName(projectPath)
    _, exportDirectoryName = reaper.GetSetProjectInfo_String(0, "RENDER_FILE", " ", false)
    fullPath = projectPath .. exportDirectoryName
    return fullPath 
end

function setRenderSettings()
    today = os.date('%d%m%y')

    reaper.GetSetProjectInfo(0, "RENDER_BOUNDSFLAG", 3, true)
    reaper.GetSetProjectInfo(0, "RENDER_SRATE", 48000, true)
    reaper.GetSetProjectInfo(0, "RENDER_TAILFLAG", 8, true)
    reaper.GetSetProjectInfo(0, "RENDER_TAILMS", 1000, true)
    reaper.GetSetProjectInfo(0, "RENDER_ADDTOPROJ", 0, true)
    reaper.GetSetProjectInfo(0, "RENDER_SETTINGS", 16, true)

    reaper.GetSetProjectInfo_String(0, "RENDER_FILE", "Export"..today, true)
    -- left to use file naming that's specified in the render window
end

-- Reanames regions to their id number if they have a default name (from item name or no name) 
function renameRegions()
    numRegMark, numMarkers, numRegions = reaper.CountProjectMarkers(0)
    for id = 1, numRegMark do
        retval, isRegion, startPosition, endPostiion, name, regIndex = reaper.EnumProjectMarkers(id)
        if isRegion and (string.match(name, ".wav") or isEmpty(name)) then
            reaper.SetProjectMarker(regIndex, true, startPosition, endPostiion, regIndex)
        end
    end
end

function print(toPrint)
    reaper.ShowConsoleMsg(toPrint)
end

function isEmpty(s)
  return s == nil or s == ''
end

function renderProject()
    reaper.Main_OnCommand(41824, 0)
end

function splitFileName(path)
	-- Returns the Path, Filename, and Extension as 3 values
	return string.match(path, "(.-)([^\\]-([^\\%.]+))$")
end

main()

-- reaper.GetSetProjectInfo( project, desc, value, is_set )
-- RENDER_SETTINGS : &(1|2)=0:master mix, &1=stems+master mix, &2=stems only, &4=multichannel tracks to multichannel files, &8=use render matrix, &16=tracks with only mono media to mono files, &32=selected media items, &64=selected media items via master
-- RENDER_BOUNDSFLAG : 0=custom time bounds, 1=entire project, 2=time selection, 3=all project regions, 4=selected media items, 5=selected project regions
-- RENDER_CHANNELS : number of channels in rendered file
-- RENDER_SRATE : sample rate of rendered file (or 0 for project sample rate)
-- RENDER_STARTPOS : render start time when RENDER_BOUNDSFLAG=0
-- RENDER_ENDPOS : render end time when RENDER_BOUNDSFLAG=0
-- RENDER_TAILFLAG : apply render tail setting when rendering: &1=custom time bounds, &2=entire project, &4=time selection, &8=all project regions, &16=selected media items, &32=selected project regions
-- RENDER_TAILMS : tail length in ms to render (only used if RENDER_BOUNDSFLAG and RENDER_TAILFLAG are set)
-- RENDER_ADDTOPROJ : 1=add rendered files to project
-- RENDER_DITHER : &1=dither, &2=noise shaping, &4=dither stems, &8=noise shaping on stems
-- PROJECT_SRATE : samplerate (ignored unless PROJECT_SRATE_USE set)
-- PROJECT_SRATE_USE : set to 1 if project samplerate is used
    
-- retval, valuestrNeedBig = reaper.GetSetProjectInfo_String( project, desc, valuestrNeedBig, is_set )
-- MARKER_GUID:X : get the GUID (unique ID) of the marker or region with index X, where X is the index passed to EnumProjectMarkers, not necessarily the displayed number
-- RECORD_PATH : recording directory -- may be blank or a relative path, to get the effective path see GetProjectPathEx()
-- RENDER_FILE : render directory
-- RENDER_PATTERN : render file name (may contain wildcards)
-- RENDER_METADATA : get or set the metadata saved with the project (not metadata embedded in project media). Example, ID3 album name metadata: "ID3:TALB" to get, "ID3:TALB|my album name" to set.
-- RENDER_TARGETS : semicolon separated list of files that would be written if the project is rendered using the most recent render settings
-- RENDER_FORMAT : base64-encoded sink configuration (see project files, etc). Callers can also pass a simple 4-byte string (non-base64-encoded), e.g. "evaw" or "l3pm", to use default settings for that sink type.
-- RENDER_FORMAT2 : base64-encoded secondary sink configuration. Callers can also pass a simple 4-byte string (non-base64-encoded), e.g. "evaw" or "l3pm", to use default settings for that sink type, or "" to disable secondary render.
--     Formats available on this machine:
--     "wave" "aiff" "iso " "ddp " "flac" "mp3l" "oggv" "OggS" "FFMP" "GIF " "LCF " "wvpk"
