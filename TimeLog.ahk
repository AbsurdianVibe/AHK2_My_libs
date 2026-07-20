#Requires AutoHotkey v2.0

/** QPC (QueryPerformanceCounter) Diagnostic
 * @param krok - Step name, "START" to init, or "FLUSH" to dump buffer to disk.
 * @param myRealTime - True to bypass RAM buffer and write directly to disk.
 * @param myLogDir - Optional custom directory path for logs. */
QPC(krok, myRealTime := false, myLogDir?) {
    static freq := 0, last := 0, sciezkaLogu := "", myPersistentDir := "C:\CODE\AHK2\Diag"
    static myLogBuffer := []
    
    if IsSet(myLogDir)
        myPersistentDir := myLogDir

    if (krok == "FLUSH") {
        if (myLogBuffer.Length > 0 && sciezkaLogu != "") {
            myOutput := ""
            for _, myLogLine in myLogBuffer
                myOutput .= myLogLine
            FileAppend(myOutput, sciezkaLogu)
            myLogBuffer := []
        }
        return
    }

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

    myLine := ""
    if (krok == "START") {
        myLine := "`n=== NOWY POMIAR (" FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss") " | Tick: " A_TickCount ") ===`n"
    } else {
        czas := Round((current - last) * 1000 / freq, 2)
        myLine := krok . ": " . czas . " ms`n"
    }
    
    if (myRealTime)
        FileAppend(myLine, sciezkaLogu)
    else
        myLogBuffer.Push(myLine)
        
    last := current
}