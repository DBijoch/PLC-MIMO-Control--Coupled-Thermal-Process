// --- 1. ODCZYT I OBLICZENIE UCHYBU ---
licznik := 0;
y1_k := INT_TO_REAL(D100);
y2_k := INT_TO_REAL(D101);

// Przesunięcie historii uchybów
e1_k_2 := e1_k_1;
e1_k_1 := e1_k;
e1_k := y1_zad - y1_k;

e2_k_2 := e2_k_1;
e2_k_1 := e2_k;
e2_k := y2_zad - y2_k;


// --- 2. OBLICZENIE PRZYROSTU STEROWANIA (u_new) ---
IF IF_PID THEN
    // --- Algorytm PID ---
	// --- Nastawy PID 1 ---
	r0_PID1 := 0.90357;
	r1_PID1 := -1.22143;
	r2_PID1 := 0.37500;

	// --- Nastawy PID 2 ---
	r0_PID2 := 0.90357;
	r1_PID2 := -1.22143;
	r2_PID2 := 0.37500;
	
    // Obliczamy TYLKO zmianę (Delta U)
    u1_k_new := r0_PID1*e1_k + r1_PID1*e1_k_1 + r2_PID1*e1_k_2;
    u2_k_new := r0_PID2*e2_k + r1_PID2*e2_k_1 + r2_PID2*e2_k_2;
	
	ELSE
    // --- Algorytm DMC ---
    // Część proporcjonalna
    u1_k_new := Ke11*e1_k + Ke12*e2_k;
    u2_k_new := Ke21*e1_k + Ke22*e2_k;

    // Horyzont dynamiki
    FOR licznik := 0 TO 93 BY 1 DO
        u1_k_new := u1_k_new - Ku11[licznik]*dUp1[licznik] - Ku12[licznik]*dUp2[licznik];
        u2_k_new := u2_k_new - Ku21[licznik]*dUp1[licznik] - Ku22[licznik]*dUp2[licznik];
    END_FOR;
    
    // UWAGA: Usunięto stąd nasycenie i sumowanie. 
    // Robimy to globalnie na dole dla obu algorytmów.
END_IF;


// --- 3. AKTUALIZACJA HISTORII dUp (Przesunięcie) ---
FOR licznik := 93 TO 1 BY -1 DO
    dUp1[licznik] := dUp1[licznik-1];
    dUp2[licznik] := dUp2[licznik-1];
END_FOR;


// --- 4. OBSŁUGA STANU USTALONEGO I NASYCENIA ---
IF Stan_ust THEN
    // Wymuszenie wartości stałych
    u1_k := 280.0;
    u2_k := 330.0;
    
    // Reset przyrostów, żeby nie szarpało
    u1_k_new := 0.0;
    u2_k_new := 0.0;
    
    // Ważne: Aktualizujemy pamięć "poprzedniego kroku" do wartości manualnej,
    // aby po wyłączeniu Stan_ust regulator startował gładko od 280/330.
    u1_k_1 := 280.0;
    u2_k_1 := 330.0;
    
	ELSE
    // --- Algorytm Anti-Windup (Nasycenie przyrostowe) ---
    // Sprawdzamy, czy (Poprzednia + NowaZmiana) mieści się w zakresie 0-1000.
    // Jeśli nie, przycinamy 'u_new' tak, aby wynik wynosił dokładnie limit.

    // Kanał 1
    IF (u1_k_1 + u1_k_new) > 1000.0 THEN 
        u1_k_new := 1000.0 - u1_k_1; 
		ELSIF (u1_k_1 + u1_k_new) < 0.0 THEN 
        u1_k_new := 0.0 - u1_k_1; 
    END_IF;

    // Kanał 2 (Tu był błąd copy-paste: sprawdzałeś u2, a pisałeś do u1!)
    IF (u2_k_1 + u2_k_new) > 1000.0 THEN 
        u2_k_new := 1000.0 - u2_k_1; 
		ELSIF (u2_k_1 + u2_k_new) < 0.0 THEN 
        u2_k_new := 0.0 - u2_k_1; 
    END_IF;

    // --- Sumowanie końcowe (Jedno miejsce w całym kodzie) ---
    u1_k := u1_k_1 + u1_k_new;
    u2_k := u2_k_1 + u2_k_new;
    
    // Zapamiętanie stanu na następny cykl
    u1_k_1 := u1_k;
    u2_k_1 := u2_k;
END_IF;


// --- 5. ZAPIS NAJNOWSZEGO PRZYROSTU DO HISTORII ---
// Robimy to po nasyceniu, aby DMC wiedział, jaki faktycznie ruch wykonano
dUp1[0] := u1_k_new;
dUp2[0] := u2_k_new;


// --- 6. WYJŚCIA FIZYCZNE ---
D114 := REAL_TO_INT(u1_k);
D115 := REAL_TO_INT(u2_k);


// --- 7. ZABEZPIECZENIE AWARYJNE (SAFETY) ---
IF D100 >= 25000 OR D101 >= 25000 THEN
    D114 := 0;
    D115 := 0;
    u1_k := 0.0; 
    u2_k := 0.0;
    // Reset pamięci, aby po ustąpieniu awarii startował od zera
    u1_k_1 := 0.0;
    u2_k_1 := 0.0;
    u1_k_new := 0.0;
    u2_k_new := 0.0;
    dUp1[0] := 0.0;
    dUp2[0] := 0.0;
END_IF;