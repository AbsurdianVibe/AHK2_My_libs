#Requires AutoHotkey v2.0

; Oblicza odległość euklidesową między dwoma punktami (Pitagoras)
ObliczDystans(x1, y1, x2, y2) => Sqrt((x1 - x2)**2 + (y1 - y2)**2)

; Sprawdza dystans myszy od punktu. Opcjonalnie aktualizuje referencję.
SprawdzRuchMyszy(&refX, &refY, tolerancja := 0, aktualizuj := false) {
    MouseGetPos(&currX, &currY)
    dystans := ObliczDystans(refX, refY, currX, currY)
    if (aktualizuj)
        refX := currX, refY := currY
    return (dystans > tolerancja) ? dystans : 0
}

;------------------------------------------------------------------------------------------------------------------------------------------------------------
/**
 * Obsługuje zaawansowaną logikę kliknięć: przytrzymanie, krótkie kliknięcie, podwójne kliknięcie itp.
 * @param {String} klawisz - Nazwa klawisza do nasłuchiwania (np. "LButton", "XButton1").
 * @param {Func} akcjaShort - Funkcja wywoływana przy krótkim kliknięciu.
 * @param {Func} akcjaHold - Funkcja wywoływana przy przytrzymaniu.
 * @param {Func} [akcjaDoubleShort=""] - (Opcjonalne) Funkcja przy zwykłym dwukliku.
 * @param {Func} [akcjaDoubleHold=""] - (Opcjonalne) Funkcja przy dwukliku i przytrzymaniu.
 * @param {Float} [czasPrzytrzymania=0.2] - Czas w sekundach, po którym uznaje się przytrzymanie.
 * @param {Integer} [trybInstant=0] - Jeśli > 0, `akcjaHold` odpala się natychmiast. Wartość określa limit pikseli, w ramach którego ruch myszy jest ignorowany dla akcji `akcjaShort`.
 */
Multiklik(klawisz, akcjaShort, akcjaHold, akcjaDoubleShort := "", akcjaDoubleHold := "", czasPrzytrzymania := 0.2, trybInstant := 0) {
    ; SCENARIUSZ INSTANT
    if (trybInstant > 0) {
        ; 1. Hold startuje natychmiast
        MouseGetPos(&startX, &startY)
        start := A_TickCount
        if (akcjaHold)
            akcjaHold()
        
        KeyWait(klawisz) ; Czekaj na puszczenie
        czasPierwszego := (A_TickCount - start) / 1000
        dystans := SprawdzRuchMyszy(&startX, &startY)

        ; Szybkie puszczenie + brak ruchu -> sprawdzenie dwukliku
        if (czasPierwszego < czasPrzytrzymania && dystans <= trybInstant) {
            
            maDwukliki := (akcjaDoubleShort != "" || akcjaDoubleHold != "")

            ; Brak dwuklików -> Klik natychmiastowy
            if (!maDwukliki) {
                if (akcjaShort)
                    akcjaShort()
                return
            }

            ; warunki spełnione, Oczekiwanie na drugi klik
            if KeyWait(klawisz, "D T" . czasPrzytrzymania) {
                ; 2. Double Hold natychmiast
                    start2 := A_TickCount
                if (akcjaDoubleHold)
                    akcjaDoubleHold()

                KeyWait(klawisz)
                czasDrugiego := (A_TickCount - start2) / 1000

                if (czasDrugiego < czasPrzytrzymania) {
                    if (akcjaDoubleShort)
                        akcjaDoubleShort()
                }
            } else {
                ; Limit czasu -> Pojedyncze kliknięcie
                if (akcjaShort)
                    akcjaShort()
            }
        }
        return
    }

    ; Opóźnienie kliknięcia jeśli zdefiniowano dwuklik
    czyCzekac := (akcjaDoubleHold != "" || akcjaDoubleShort != "")

    ; 1. PRZYTRZYMANIE
    if !KeyWait(klawisz, "T" . czasPrzytrzymania) {
        (akcjaHold) && akcjaHold()
        return
    } 
    
    ; Szybka ścieżka (brak dwukliku)
    if (!czyCzekac) {
        (akcjaShort) && akcjaShort()
        return ; Stop (bez czekania na dwuklik)
    }
        
    ; 2. PODWÓJNE KLIKNIĘCIE
    if KeyWait(klawisz, "D T" . czasPrzytrzymania) {
        if !KeyWait(klawisz, "T" . czasPrzytrzymania) {
            (akcjaDoubleHold) && akcjaDoubleHold()
        } else {
            (akcjaDoubleShort) && akcjaDoubleShort()
        }
    } else {
        ; Wolna ścieżka (limit czasu dwukliku)
        (czyCzekac && akcjaShort) && akcjaShort()
    }
}
