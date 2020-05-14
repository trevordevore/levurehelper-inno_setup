[CustomMessages]
AppExe=[[NAME]]

[Setup]
;SignTool=signtool ; Uncomment this line if you have configured a signtool in Inno Setup
AppName=[[NAME]]
AppVerName=[[NAME]] [[APP_VERSION]]
AppID=[[NAME]][[APP_VERSION]]
PrivilegesRequired=admin
OutputBaseFilename=[[INSTALLER_NAME]] [[VERSION]]-[[BUILD]]
AllowNoIcons=No
AppPublisher=Your Company
AppPublisherURL=http://www.mydomain.com
AppSupportURL=http://help.mydomain.com
AppVersion=[[APP_VERSION]]
DefaultDirName={autopf}\[[NAME]] [[MAJOR_VERSION]]
DefaultGroupName=[[NAME]] [[MAJOR_VERSION]]
UninstallDisplayIcon={app}\[[NAME]].exe
Compression=lzma
SolidCompression=yes
OutputDir=.\

UsePreviousTasks=Yes
VersionInfoCompany=MY COMPANY
VersionInfoCopyright=Copyright (c) 2020 My Company
VersionInfoDescription=
VersionInfoProductVersion=[[VERSION]].[[BUILD]]
VersionInfoProductTextVersion=[[VERSION]].[[BUILD]]
VersionInfoTextVersion=[[VERSION]].[[BUILD]]
VersionInfoVersion=[[VERSION]].[[BUILD]]
ShowLanguageDialog=no
ChangesAssociations=yes

[Languages]
; Uncomment this line if you have an end user license agreement
;Name: "english"; MessagesFile: "compiler:Default.isl"; LicenseFile: "..\..\..\build files\EULA.rtf"

[Files]
;; DLL used to check if the target program is running at install time
;Source: psvince.dll; flags: dontcopy
;; psvince is installed in {app} folder, so it will be loaded at
;; uninstall time to check if the target program is running
;Source: psvince.dll; DestDir: {app}

[[FilesAndFoldersToInstall]]

[InstallDelete]

[UninstallDelete]
; Uncomment this example if your application stores information in the user data folder that should be removed.
;Type: filesandordirs; Name: "{userappdata}\[[NAME]]\[[APP_VERSION]]"

[Dirs]

[[DirectoriesToCreate]]

; Uncomment this example if your application stores information in the user data folder and a folder should be created.
;Name: "{userappdata}\[[NAME]]";

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags:

[Icons]
Name: "{group}\{cm:AppExe}"; Filename: "{app}\{cm:AppExe}.exe"
Name: "{group}\Uninstall {cm:AppExe}"; Filename: "{uninstallexe}"
Name: "{userdesktop}\{cm:AppExe}"; Filename: "{app}\{cm:AppExe}.exe"; IconIndex: 0; Tasks: desktopicon

[Registry]

[Run]
Filename: "{app}\{cm:AppExe}.exe"; Description: "{cm:LaunchProgram,[[NAME]]}"; Flags: nowait postinstall skipifsilent;
