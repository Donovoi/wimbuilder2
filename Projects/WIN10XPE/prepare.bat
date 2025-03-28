rem ===================================
if "x%opt[build.cmd_mode]%"=="xtrue" (
    rem dummy line - DON'T DELETE THIS LINE
    %opt[build.cmd_mode_code]%
)

rem ===================================
rem set Enviroment
rem BUILD_NUMBER
for /f "tokens=1,2,3 delims=." %%a in ("%WB_PE_VER%") do (set VER[1]=%%a) & (set VER[2]=%%b) & (set VER[3]=%%c)
set VER[4]=%WB_PE_BUILD%
set VER[3.4]=%VER[3]%.%VER[4]%
rem ===================================
rem SYSTEM_PATH
rem set X=%WB_X_DRIVE%
set "X_PF=%X%\Program Files"
set X_WIN=%X%\Windows
set X_SYS=%X_WIN%\System32
set X_WOW64=%X_WIN%\SysWOW64
set X_Desktop=%X%\Users\Default\Desktop
set "_CUSTOMFILES_=%WB_PROJECT_PATH%\_CustomFiles_"

set "WB_USER_PROJECT_PATH=%WB_ROOT%\%APPDATA_DIR%\Projects\%WB_PROJECT%"
set "_USER_CUSTOMFILES_=%WB_USER_PROJECT_PATH%\_CustomFiles_"

set CatRoot=\Windows\System32\CatRoot\{F750E6C3-38EE-11D1-85E5-00C04FC295EE}

call "%WB_PROJECT_PATH%\shared\InitLoader.bat"

call V2X -init
call App init _Cache_
set "WINXSHELL=%V_APP%\WinXShell\X_PF\WinXShell\WinXShell_%WB_ARCH%.exe"

echo.
call "%WB_PROJECT_PATH%\shared\CheckUserFiles.bat"

rem ===================================
echo .
echo Update options

call CheckPatch "00-Configures\x-Account"
if "x%HasPatch%"=="xfalse" (
    set opt[account.admin_enabled]=false
)

call CheckPatch "01-Components\02-Network"
set opt[support.network]=%HasPatch%
if "%opt[support.network]%"=="false" (
    set opt[network.function_discovery]=false
)

if "x%opt[account.admin_enabled]%"=="xtrue" (
    set opt[support.admin]=true
)
if "x%opt[component.netfx]%"=="xtrue" (
    set opt[build.registry.software]=full
)


if "x%opt[build.registry.system]%"=="xtrue" (
    set opt[build.registry.system]=merge
)

call CheckPatch "01-Components\Windows Media Player"
if "x%HasPatch%"=="xtrue" (
    echo [INFO] Adapt StartIsBack for Windows Media Player
    set opt[SIB.version]=02.09.00
    set opt[SIB.version]
)

rem ===================================
echo load i18n resources ...
call _Locales_\i18n[en-US].bat
if not "%WB_HOST_LANG%"=="%WB_PE_LANG%" goto :I18N_PRINT
if exist "_Locales_\i18n[%WB_PE_LANG%].bat" call "_Locales_\i18n[%WB_PE_LANG%].bat"
:I18N_PRINT
set i18n.t
rem ===================================
rem reduce the wim file before mounting it
cd /d za-Slim
call SlimWim.bat
rem ===================================
