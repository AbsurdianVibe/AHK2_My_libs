#Requires AutoHotkey v2.0
SetTitleMatchMode(2)

; Listen for the system error window (class #32770) for up to 5 seconds
if WinWait("ahk_class #32770",, 5) {
    ; Extract the complete text content directly from the window
    errText := WinGetText("ahk_class #32770")
    
    ; Stream the new crash dump directly to standard output (UTF-8)
    FileAppend(errText, "*", "UTF-8")
    
    ; Kill the hanging modal error window (this will terminate the target script)
    WinClose("ahk_class #32770")
    ; Fallback in case WinClose fails to kill the background process
    ProcessClose("AutoHotkey64.exe")
}
ExitApp
