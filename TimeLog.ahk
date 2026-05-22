#Requires AutoHotkey v2.0

/** QPC (QueryPerformanceCounter) Diagnostic
 * Hardware timer for precise code execution measurement in fractions of milliseconds.
 * 
 * INSTRUCTIONS:
 * 1. Copy QPC() to the bottom of your tested script.
 * 2. Call QPC("START", "optional\path") to reset timer and start a new log.
 * 3. Call QPC("Your Step Name") after each operation.
 * 4. Logs are saved to: [myPersistentDir]\[ScriptName]\QPC_Log...txt
 * 
 * @param krok - Name of the step or "START" to initialize.
 * @param myLogDir - Optional custom directory path for logs.
 * 
 * ⚠️ HEISENBUG I/O WARNING:
 * First FileAppend wakes up antivirus (e.g., Windows Defender) causing huge delays.
 * Ignore the first time anomaly in logs. It is an I/O lag, not your code performance! */
QPC(krok, myLogDir?) {
    static freq := 0, last := 0, sciezkaLogu := "", myPersistentDir := "D:\PRACA\skrypryAHK\Diag"
    
    if IsSet(myLogDir)
        myPersistentDir := myLogDir

    current := 0 ; <--- Inicjalizacja wymuszana przez AHK v2 przy DllCall z wyjściem w parametrze
    if !freq
        DllCall("QueryPerformanceFrequency", "Int64*", &freq)
    DllCall("QueryPerformanceCounter", "Int64*", &current)
    
    if (sciezkaLogu == "" || krok == "START") {
        SplitPath(A_ScriptName, ,,, &myScriptNameNoExt)
        myTargetDir := RTrim(myPersistentDir, "\") "\" myScriptNameNoExt
        if !DirExist(myTargetDir)
            DirCreate(myTargetDir)
        sciezkaLogu := myTargetDir "\QPC_Log_" FormatTime(A_Now, "yyyy_MM_dd__HH_mm_ss") ".txt"
    }

    if (krok == "START") {
        FileAppend("`n=== NOWY POMIAR (" FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss") " | Tick: " A_TickCount ") ===`n", sciezkaLogu)
    } else {
        ; Obliczenie czasu od ostatniego kroku (w milisekundach)
        czas := Round((current - last) * 1000 / freq, 2)
        FileAppend(krok . ": " . czas . " ms`n", sciezkaLogu)
    }
    last := current
}