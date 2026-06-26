@echo off
chcp 1252 >nul
setlocal EnableDelayedExpansion
title Timer 0.5ms + NVIDIA

rem ---- Auto-elevation administrateur ----
net session >nul 2>&1
if errorlevel 1 (
powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs" >nul 2>&1
exit /b
)

rem ---- Detection GPU NVIDIA (pour le tweak EnableGR535) ----
set "HASNV=0"
for /f "usebackq delims=" %%g in (`powershell -NoProfile -Command "if((Get-CimInstance Win32_VideoController).Name -match 'NVIDIA'){'1'}else{'0'}"`) do set "HASNV=%%g"

rem ---- Base64 du timerres.ps1 (boucle NtSetTimerResolution 0.5 ms, mutex par session) ----
set "TRPSB64=JEVycm9yQWN0aW9uUHJlZmVyZW5jZT0nU2lsZW50bHlDb250aW51ZScKJG10eD1OZXctT2JqZWN0IFN5c3RlbS5UaHJlYWRpbmcuTXV0ZXgoJGZhbHNlLCdMb3dMYXRUaW1lclJlczA1JykKaWYoLW5vdCAkbXR4LldhaXRPbmUoMCkpeyBleGl0IH0KJGNvZGU9QCcKdXNpbmcgU3lzdGVtOwp1c2luZyBTeXN0ZW0uUnVudGltZS5JbnRlcm9wU2VydmljZXM7CnB1YmxpYyBjbGFzcyBUUiB7CiAgW0RsbEltcG9ydCgibnRkbGwuZGxsIildIHB1YmxpYyBzdGF0aWMgZXh0ZXJuIGludCBOdFNldFRpbWVyUmVzb2x1dGlvbih1aW50IERlc2lyZWRSZXNvbHV0aW9uLCBib29sIFNldFJlc29sdXRpb24sIG91dCB1aW50IEN1cnJlbnRSZXNvbHV0aW9uKTsKfQonQApBZGQtVHlwZSAtVHlwZURlZmluaXRpb24gJGNvZGUKJGN1cj0wCndoaWxlKCR0cnVlKXsgW1RSXTo6TnRTZXRUaW1lclJlc29sdXRpb24oNTAwMCwkdHJ1ZSxbcmVmXSRjdXIpIHwgT3V0LU51bGw7IFN0YXJ0LVNsZWVwIC1TZWNvbmRzIDIgfQo="
set "TASKB64=JEVycm9yQWN0aW9uUHJlZmVyZW5jZT0nU2lsZW50bHlDb250aW51ZScKJHRuPSdUaW1lclJlcyAwLjVtcycKJHBzPSRlbnY6U3lzdGVtUm9vdCsnXHRpbWVycmVzLnBzMScKJGE9TmV3LVNjaGVkdWxlZFRhc2tBY3Rpb24gLUV4ZWN1dGUgJ3Bvd2Vyc2hlbGwuZXhlJyAtQXJndW1lbnQgKCctTm9Qcm9maWxlIC1XaW5kb3dTdHlsZSBIaWRkZW4gLUV4ZWN1dGlvblBvbGljeSBCeXBhc3MgLUZpbGUgIicrJHBzKyciJykKJHQxPU5ldy1TY2hlZHVsZWRUYXNrVHJpZ2dlciAtQXRTdGFydHVwCiR0Mj1OZXctU2NoZWR1bGVkVGFza1RyaWdnZXIgLUF0TG9nT24KJHA9TmV3LVNjaGVkdWxlZFRhc2tQcmluY2lwYWwgLVVzZXJJZCAnTlQgQVVUSE9SSVRZXFNZU1RFTScgLUxvZ29uVHlwZSBTZXJ2aWNlQWNjb3VudCAtUnVuTGV2ZWwgSGlnaGVzdAokcz1OZXctU2NoZWR1bGVkVGFza1NldHRpbmdzU2V0IC1BbGxvd1N0YXJ0SWZPbkJhdHRlcmllcyAtRG9udFN0b3BJZkdvaW5nT25CYXR0ZXJpZXMgLUV4ZWN1dGlvblRpbWVMaW1pdCAoW1RpbWVTcGFuXTo6WmVybykgLVJlc3RhcnRDb3VudCAzIC1SZXN0YXJ0SW50ZXJ2YWwgKE5ldy1UaW1lU3BhbiAtTWludXRlcyAxKSAtTXVsdGlwbGVJbnN0YW5jZXMgSWdub3JlTmV3IC1TdGFydFdoZW5BdmFpbGFibGUKUmVnaXN0ZXItU2NoZWR1bGVkVGFzayAtVGFza05hbWUgJHRuIC1BY3Rpb24gJGEgLVRyaWdnZXIgJHQxLCR0MiAtUHJpbmNpcGFsICRwIC1TZXR0aW5ncyAkcyAtRm9yY2UgfCBPdXQtTnVsbApTdGFydC1TY2hlZHVsZWRUYXNrIC1UYXNrTmFtZSAkdG4K"

set "TIMERSTATE=INCHANGE"
set "NVSTATE=INCHANGE"

cls
echo  ================================================================
echo            TIMER 0.5 ms  +  TWEAK NVIDIA (EnableGR535)
echo  ================================================================
echo.

rem ====================== QUESTION 1 : TIMER ======================
echo   [ ? ]  Timer 0.5 ms  (NtSetTimerResolution, relance au demarrage)
echo          [1] Appliquer       [2] Retirer       [0] Ignorer
echo.
choice /C 120 /N >nul
set "TIMERANS=!errorlevel!"
echo.

rem ================ QUESTION 2 : NVIDIA (si concerne) =============
set "NVANS=3"
if not "!HASNV!"=="1" goto Q2_SKIP
echo   [ ? ]  Tweak NVIDIA  EnableGR535 = 0
echo          [1] Appliquer       [2] Retirer       [0] Ignorer
echo.
choice /C 120 /N >nul
set "NVANS=!errorlevel!"
echo.
goto Q2_DONE
:Q2_SKIP
echo   [ i ]  Pas de GPU NVIDIA detecte : tweak EnableGR535 ignore.
set "NVSTATE=N/A - pas de GPU NVIDIA"
echo.
:Q2_DONE

echo  ----------------------------------------------------------------
echo.

rem ========================= TIMER : action =======================
if "!TIMERANS!"=="1" goto T_APPLY
if "!TIMERANS!"=="2" goto T_REMOVE
echo   [ - ] Timer 0.5 ms : ignore.
goto T_DONE
:T_APPLY
echo   [...] Application du timer 0.5 ms...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v GlobalTimerResolutionRequests /t REG_DWORD /d 1 /f >nul 2>&1
powershell -NoProfile -Command "[IO.File]::WriteAllText('%SystemRoot%\timerres.ps1',[Text.Encoding]::ASCII.GetString([Convert]::FromBase64String('!TRPSB64!')))" >nul 2>&1
powershell -NoProfile -Command "[IO.File]::WriteAllText($env:TEMP+'\tinst.ps1',[Text.Encoding]::ASCII.GetString([Convert]::FromBase64String('!TASKB64!')))" >nul 2>&1
powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP%\tinst.ps1" >nul 2>&1
del /f /q "%TEMP%\tinst.ps1" >nul 2>&1
set "TIMERSTATE=APPLIQUE - tache SYSTEM au boot + a chaque session"
echo   [ OK ] Timer 0.5 ms applique.
goto T_DONE
:T_REMOVE
echo   [...] Retrait du timer 0.5 ms...
schtasks /Delete /F /TN "TimerRes 0.5ms" >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v GlobalTimerResolutionRequests /f >nul 2>&1
powershell -NoProfile -Command "Get-CimInstance Win32_Process | Where-Object {$_.CommandLine -like '*timerres.ps1*'} | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }" >nul 2>&1
del /f /q "%SystemRoot%\timerres.ps1" >nul 2>&1
set "TIMERSTATE=RETIRE"
echo   [ OK ] Timer 0.5 ms retire.
goto T_DONE
:T_DONE

echo.

rem ========================= NVIDIA : action ======================
if "!NVANS!"=="1" goto NV_APPLY
if "!NVANS!"=="2" goto NV_REMOVE
if "!HASNV!"=="1" echo   [ - ] Tweak NVIDIA : ignore.
goto NV_DONE
:NV_APPLY
echo   [...] Application du tweak NVIDIA EnableGR535=0...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS" /v EnableGR535 /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Parameters\FTS" /v EnableGR535 /t REG_DWORD /d 0 /f >nul 2>&1
set "NVSTATE=APPLIQUE - EnableGR535=0"
echo   [ OK ] NVIDIA EnableGR535=0 applique.
goto NV_DONE
:NV_REMOVE
echo   [...] Retrait du tweak NVIDIA EnableGR535...
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS" /v EnableGR535 /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Parameters\FTS" /v EnableGR535 /f >nul 2>&1
set "NVSTATE=RETIRE - retour defaut pilote"
echo   [ OK ] NVIDIA EnableGR535 retire.
goto NV_DONE
:NV_DONE

echo.
echo  ================================================================
echo    RESUME :
echo      Timer 0.5 ms   : !TIMERSTATE!
echo      NVIDIA GR535   : !NVSTATE!
echo  ================================================================
echo.
echo   Un redemarrage est conseille : la demande timer globale et le
echo   tweak NVIDIA prennent pleinement effet apres reboot.
echo.
pause
exit /b
