script "Inno Setup Packager"
/*
  - Notified when packaging up an application.
  - Reads in entries from `inno setup` key.
  -
*/
command processCopyFilesFile @pFiledata, pOutputFolder
  local tConfigA, tFolders, tFiles, tFilename, tFlags, tInstallerFiles

  _replaceVariables pFiledata, pOutputFolder

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

  replace "[[FilesAndFoldersToInstall]]" with tInstallerFiles in pFiledata
end processCopyFilesFile


private command _replaceVariables @xFileData, pBuildProfile
  replace textEncode("[[VERSION]]", "utf8") with levureAppGet("version") in xFileData
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
