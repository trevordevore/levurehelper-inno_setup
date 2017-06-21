script "Inno Setup Packager"
local sScriptsToCompile
local sWineCmd, sWinePathCmd

command processCopyFilesFile pBuildProfile, @xFiledata, pOutputFolder, pOutputFilename, pFileSettingsA
  local tConfigA, tFolders, tFiles, tFilename, tFlags, tInstallerFiles

  _replaceVariables xFiledata, pOutputFolder

  if levureAppHasProperty("inno setup") then
    put levureAppGet("inno setup") into tConfigA
  end if

  put folders(pOutputFolder & "/windows") into tFolders
  put files(pOutputFolder & "/windows") into tFiles

  filter tFolders without ".*"
  filter tFolders without "..*"
  filter tFiles without ".*"

  /*
  Examples:
  Source: ".\windows\MyApp.exe"; DestDir: "{app}"; Flags: ignoreversion sign
  Source: ".\windows\levure.livecodescript"; DestDir: "{app}"; Flags: ignoreversion
  Source: ".\windows\helpers\*"; DestDir: "{app}\helpers"; Flags: ignoreversion recursesubdirs createallsubdirs
  */
  repeat for each line tFilename in tFolders
    put _q("Source: `.\windows\" & tFilename & "\*`; DestDir: `{app}" & "\" & tFilename & "`;") after tInstallerFiles

    put _flagsForFilename(tConfigA, tFilename, true) into tFlags
    if tFlags is not empty then
      put space & tFlags after tInstallerFiles
    end if
    put cr after tInstallerFiles
  end repeat

  repeat for each line tFilename in tFiles
    put _q("Source: `.\windows\" & tFilename & "`; DestDir: `{app}`;") after tInstallerFiles

    put _flagsForFilename(tConfigA, tFilename, false) into tFlags
    if tFlags is not empty then
      put space & tFlags after tInstallerFiles
    end if
    put cr after tInstallerFiles
  end repeat

  delete the last char of tInstallerFiles

  replace "[[FilesAndFoldersToInstall]]" with tInstallerFiles in xFiledata

  if pFileSettingsA["compile"] is not false then
    put pOutputFolder & "/" & pOutputFilename into line (the number of lines of sScriptsToCompile + 1) of sScriptsToCompile
  end if
end processCopyFilesFile


command postPackagForBuildProfile pBuildProfile, pOutputFolder
  local tScriptsToCompile

  put sScriptsToCompile into tScriptsToCompile
  put empty into sScriptsToCompile

  if the platform is "win32" or _isWineInstalled() then
    local tSettingsA, tCompilerPath

    if levureAppHasProperty("inno setup") then
      put levureAppGet("inno setup") into tSettingsA
    end if

    if the platform is "win32" then
      put tSettingsA["windows compiler"] into tCompilerPath
    else
      put tSettingsA["wine compiler"] into tCompilerPath
    end if

    if tCompilerPath is empty then return empty

    local tCmd, tResult, tReturnVal

    repeat for each line tScript in tScriptsToCompile
      # compil32 /cc "c:\isetup\samples\my script.iss"
      if the platform is "win32" then
        replace "/" with "\" in tScript
        put format("\"%s\" /cc \"%s\"", tCompilerPath, tScript) into tCmd
        put shell(tCmd) into tResult
        put the result into tReturnVal
      else
        local tWineFilepath

        put format("\"%s\" -w \"%s\"", sWinePathCmd, tScript) into tCmd
        put line 1 of shell(tCmd) into tWineFilepath
        put the result into tReturnVal

        if tReturnVal is empty then
          put format("\"%s\" \"%s\" /cc \"%s\"", sWineCmd, tCompilerPath, tWineFilepath) into tCmd
          put shell(tCmd) into tResult
          put the result into tReturnVal
        end if
      end if

      if tReturnVal is 1 then
        put "inno setup result:" && tResult & cr & "for command:" && tCmd
        answer error param(0) && "invalid parameters passed to inno setup command line tool"
        exit repeat
      else if tReturnVal is not empty then
        put "inno setup result:" && tResult & cr & "for command:" && tCmd
        answer error param(0) && "inno setup compile failed" && tReturnVal
        exit repeat
      end if
    end repeat
  end if
end postPackagForBuildProfile


private function _isWineInstalled
  if the platform is not "macos" then return false

  local tResult, tReturnVal

  put "wine" into sWineCmd
  put shell(sWineCmd && "--version") into tResult
  put the result into tReturnVal

  if tReturnVal is not empty then
    put "/usr/local/bin/wine" into sWineCmd
    put shell(sWineCmd && "--version") into tResult
    put the result into tReturnVal
  end if

  if tReturnVal is not empty then
    put empty into sWineCmd
    return false
  else
    set the itemDelimiter to "/"
    put sWineCmd into sWinePathCmd
    put "winepath" into the last item of sWinePathCmd
    return true
  end if
end _isWineInstalled


private command _replaceVariables @xFileData, pBuildProfile
  local tVersion

  put levureAppGet("version") into tVersion
  set the itemDelimiter to "."

  replace textEncode("[[NAME]]", "utf8") with levureAppGet("name") in xFileData
  replace textEncode("[[VERSION]]", "utf8") with tVersion in xFileData
  replace textEncode("[[MAJOR_VERSION]]", "utf8") with item 1 of tVersion in xFileData
  replace textEncode("[[APP_VERSION]]", "utf8") with item 1 to 2 of tVersion in xFileData
  replace textEncode("[[BUILD]]", "utf8") with levureAppGet("build") in xFileData
  replace textEncode("[[BUILD_PROFILE]]", "utf8") with tolower(pBuildProfile) in xFileData
end _replaceVariables


private function _flagsForFilename pConfigA, pFilename, pIsFolder
  local tFlags

  if pIsFolder then
    if pConfigA["folder flags"] is not empty then
      put "Flags: " & pConfigA["folder flags"] into tFlags
    end if
  else
    if pFilename ends with ".exe" and pConfigA["executable flags"] is not empty then
      put "Flags: " & pConfigA["executable flags"] into tFlags
    else if pConfigA["file flags"] is not empty then
      put "Flags: " & pConfigA["file flags"] into tFlags
    end if
  end if

  return tFlags
end _flagsForFilename


private function _q pStr
  replace "`" with quote in pStr
  return pStr
end _q
