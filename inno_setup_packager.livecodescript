script "Inno Setup Packager"
local sScriptsToCompile

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

  if the platform is not "win32" then return empty

  local tSettingsA, tProfilesA, tName, tMacAppBundleFolder

  if levureAppHasProperty("inno setup") then
    put levureAppGet("inno setup") into tSettingsA
  end if

  if tSettingsA["compiler"] is empty then return empty

  local tCmd, tResult

  repeat for each line tScript in tScriptsToCompile
    # compil32 /cc "c:\isetup\samples\my script.iss"
    put format("\"%s\" /cc \"%s\"", \
        tSettingsA["compiler"], tScript) into tCmd
    put shell(tCmd) into tResult
    if tResult is 1 then
      put "inno setup result:" && the result
      answer error param(0) && "invalid parameters passed to inno setup command line tool"
    else if tResult is 2 then
      put "inno setup result:" && the result
      answer error param(0) && "inno setup compile failed"
    end if
  end repeat
end postPackagForBuildProfile


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
