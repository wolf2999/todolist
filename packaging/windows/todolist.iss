; Inno Setup 脚本 —— 把 Flutter Windows Release 文件夹打包成单个安装器 .exe
; 由 GitHub Actions (jrsoftware/isetup-action) 调用：
;   iscc.exe todolist.iss /DAppVersion=1.0.2
; 产物输出到本脚本同级的 Output/todolist-setup-<版本>.exe

#define MyAppName "To-Do List"
#define MyAppVersion "1.0.1"
#define MyAppPublisher "To-Do List"
#define MyAppURL "https://atodolist.pages.dev/"
; AppVersion 由 CI 通过 /DAppVersion= 传入，否则用上面的默认值
#ifndef AppVersion
  #define AppVersion "1.0.1"
#endif

[Setup]
AppId={{A1B2C3D4-E5F6-7890-ABCD-1234567890AB}
AppName={#MyAppName}
AppVersion={#AppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
; 单文件安装包（内嵌压缩，无需外部解压程序）
OutputDir=Output
OutputBaseFilename=todolist-setup-{#AppVersion}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64
UninstallDisplayIcon={app}\todolist.exe

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "chinesesimplified"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"

[Files]
; Flutter 构建产物目录：build\windows\x64\runner\Release
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\todolist.exe"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\todolist.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "创建桌面快捷方式"; GroupDescription: "额外任务:"

[Run]
Filename: "{app}\todolist.exe"; Description: "启动 {#MyAppName}"; Flags: nowait postinstall skipifsilent
