
;--------------------------------
;Include Modern UI

  !include "MUI2.nsh"
  !include ..\..\..\target\project.nsh

;--------------------------------
;General

  ;Name and file
  Name "${PROJECT_NAME}"
  
  ;Default installation folder
  InstallDir "$PROGRAMFILES64\${PROJECT_NAME}"
  
  ;Get installation folder from registry if available
  InstallDirRegKey HKCU "Software\${PROJECT_NAME}" ""

  ;Request application privileges for Windows Vista
  RequestExecutionLevel admin


  ;--------------------------------
  ;Interface Settings

  !define MUI_ABORTWARNING
  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_BITMAP "myappbanner.bmp"

  ;--------------------------------
  ;Pages
  !insertmacro MUI_PAGE_WELCOME
  !define MUI_PAGE_CUSTOMFUNCTION_SHOW licpageshow
  !insertmacro MUI_PAGE_LICENSE "License.txt"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY

  !insertmacro MUI_PAGE_INSTFILES
  !define MUI_FINISHPAGE_NOAUTOCLOSE
  !insertmacro MUI_PAGE_FINISH

  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_UNPAGE_FINISH


  ;--------------------------------
  ;Languages
  !insertmacro MUI_LANGUAGE "English"

  ;--------------------------------
  ;Installer Sections
Section "${PROJECT_NAME}" MyApp
  SetOutPath "$INSTDIR"
  File getdown.jar

  Call GetJRE
  Pop $R0
     
  WriteRegStr HKCU "Software\${PROJECT_NAME}" "" $INSTDIR
  WriteRegStr HKCR "getdown" "URL Protocol" ""
  WriteRegStr HKCR "getdown\shell\open\command" "" '"$R0" -jar  "$INSTDIR\getdown.jar" "%1"'

  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\GetDown" "DisplayName" "Get Down"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\GetDown" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""


  ;Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"
SectionEnd

;--------------------------------
;Descriptions

  ;Language strings
  LangString DESC_MyApp ${LANG_ENGLISH} "${PROJECT_NAME}"

  ;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${MyApp} $(DESC_MyApp)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
;Uninstaller Section

Section "Uninstall"
   Delete "$INSTDIR\Uninstall.exe" ; delete self
   Delete "$INSTDIR\*"

   RMDir /REBOOTOK "$INSTDIR"


  DeleteRegKey /ifempty HKCU "Software\${PROJECT_NAME}"
  DeleteRegKey HKCR "getdown"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\GetDown"

SectionEnd

Function licpageshow
    FindWindow $0 "#32770" "" $HWNDPARENT
    CreateFont $1 "Courier New" "$(^FontSize)"
    GetDlgItem $0 $0 1000
    SendMessage $0 ${WM_SETFONT} $1 1
FunctionEnd

Function GetJRE
  Push $R0
  Push $R1
 
  !define JAVAEXE "javaw.exe"
  ;TODO if 32 bit is still a thing maybe we need to look into supporting that?
  SetRegView 64
 
  ClearErrors
  StrCpy $R0 "$EXEDIR\jre\bin\${JAVAEXE}"
  IfFileExists $R0 JreFound  ;; 1) found it locally
  StrCpy $R0 ""
 
  ClearErrors
  ReadEnvStr $R0 "JAVA_HOME"
  StrCpy $R0 "$R0\bin\${JAVAEXE}"
  IfErrors 0 JreFound  ;; 2) found it in JAVA_HOME
 
  ClearErrors
  ReadRegStr $R1 HKLM "SOFTWARE\JavaSoft\Java Runtime Environment" "CurrentVersion"
  ReadRegStr $R0 HKLM "SOFTWARE\JavaSoft\Java Runtime Environment\$R1" "JavaHome"
  StrCpy $R0 "$R0\bin\${JAVAEXE}"
 
  IfErrors 0 JreFound  ;; 3) found it in the registry
  StrCpy $R0 "${JAVAEXE}"  ;; 4) wishing you good luck
 
 JreFound:
  Pop $R1
  Exch $R0
FunctionEnd
