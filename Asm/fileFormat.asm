.model small
.stack 100h
.data
	help_msg	db "Programa suskaido teksta i neilgesnes, nei nurodyta eilutes.", 10, 13,"Iveskite duomenu failo pavadinima, norima eiluciu ilgi ir",10,13,"rezultato failo pavadinima.$"
	error1		db "Nepavyko uzdaryti failo rezultatui.$"
	error2		db "Nepavyko uzdaryti duomenu failo.$"
	error3  	db "Nepavyko nuskaityti duomenu.$"
	error4		db "Nepavyko irasyti duomenu.$"
	duom		db 20 dup(?)		
	rez			db 20 dup(?)   
	endl        db 0Dh,0Ah
	lineNr		dw ?
	skBuf		db 100 dup (?)	
	dFail		dw ?			
	rFail		dw ?			
.code
  pradzia:
	mov	ax, @data		
	mov	ds, ax			

	mov ch,0
	mov cl, es:[0080h]			
	cmp cx,0					;programa paleista be parametru
	je reikiaPagalbos
	mov bx,0081h
find:
	cmp es:[bx],'?/'	;jaunesnysis baitas saugomas pirmiau. bl tada bh.
	je reikiaPagalbos
	inc bx
	loop find
	
;Parametru suvedimas i kintamuosius
	mov bx,0082h	
	mov dx,0
	mov si,0
	mov ch,0
	mov cl, es:[80h]
	dec cl
duomLoop:					
	mov dl,es:[bx]	
	cmp dl,' '
	jz num
	mov duom[si],dl
	inc si
	inc bx
	loop duomLoop
	
num:					
	dec cl
	mov lineNr,0
	mov dl,10
numLoop:
	inc bx
	mov ax,0
	mov al,es:[bx]
	dec cl
	cmp al,' '
	je rezult
	sub al,'0'	
	cmp lineNr,0
	je skip
	mov dh,al
	mov ax,lineNr
	mul dl
	mov lineNr,ax
	mov ah,0
	mov al,dh
	skip: 
	add lineNr,ax
	jmp numLoop 
	
rezult:
	mov si,0
	inc bx			
rezLoop:					
	mov dl,es:[bx]
	mov rez[si],dl
	inc si
	inc bx
	loop rezLoop
	
	jmp nereikiaPagalbos
reikiaPagalbos:					;ne prie klaidu apdorojimo, nes nepasiekia jmp
	mov ah,9
	mov dx,offset help_msg
	int 21h
	jmp pabaiga
nereikiaPagalbos:

;Duomenu failo atidarymas skaitymui
	mov	ah, 3Dh				
	mov	al, 00					;atidaroma skaitymui	
	mov	dx, offset duom			
	int	21h				
	jc	reikiaPagalbos	
	mov	dFail, ax				

;Rezultato failo sukurimas ir atidarymas rasymui
	mov	ah, 3Ch				
	mov	cx, 0					;tik nuskaitymui
	mov	dx, offset rez			
	int	21h				
	jc	klaidaAtidarantRasymui		
	mov	rFail, ax				
    
    jmp pirmasSkaitymas
;Duomenu nuskaitymas ir rasymas i faila
  skaityk:
    cmp ax,lineNr
    jne pirmasSkaitymas 
    mov ah, 40h
    lea dx,endl
    mov cx, 2
    int 21h
    pirmasSkaitymas:
	mov	bx, dFail			
	call SkaitykBuf			
	cmp	ax, 0				;ax - kiek baitu nuskaityta, jeigu 0 - failo pabaiga
	je	uzdarytiRasymui
	
	mov	cx, ax			
	mov	bx, rFail			
	call RasykBuf							
    jmp skaityk
    
;Rezultato failo uzdarymas
  uzdarytiRasymui:
	mov	ah, 3Eh				
	mov	bx, rFail			
	int	21h				
	jc	klaidaUzdarantRasymui		
	
;Duomenu failo uzdarymas
  uzdarytiSkaitymui:
	mov	ah, 3Eh				
	mov	bx, dFail			
	int	21h				
	jc	klaidaUzdarantSkaitymui		

  pabaiga:
	mov	ah,4Ch	
	mov al,00h
	int 21h				

;Klaidu apdorojimas
klaidaAtidarantRasymui:
	mov ah,9
	mov dx,offset help_msg
	int 21h
	jmp	pabaiga
klaidaUzdarantRasymui:
	mov ah,9
	mov dx,offset error1
	int 21h
	jmp	pabaiga
klaidaUzdarantSkaitymui:
	mov ah,9
	mov dx,offset error2
	int 21h
	jmp	pabaiga

;Failo skaitymas
PROC SkaitykBuf
;BX - failo deskriptoriaus numeris
;AX grazins, kiek simboliu nuskaityta
	mov	cx, lineNr
	mov	ah, 3Fh				
	mov	dx, offset skBuf	
	int	21h			
	jc	klaidaSkaitant
	
	mov si,0
arYraNl:
    cmp skBuf[si],0Ah
    je yra
    inc si
    loop arYraNl
    jmp SkaitykBufPabaiga
yra: 
    inc si
    mov al, 01h                 ;current file pos
    mov ah, 42h 
    mov cx,-1 
    mov dx, lineNr
    sub dx, si
    neg dx
    int 21h
    mov ax,si
	jmp SkaitykBufPabaiga
 klaidaSkaitant:
	mov ah,9
	mov dx,offset error3
	int 21h
	mov ax, 0				
SkaitykBufPabaiga:
	RET
SkaitykBuf ENDP

;Rasyti buferi i faila
PROC RasykBuf
;BX - failo deskriptoriaus numeris
;CX - kiek baitu rasyti
;AX - kiek baitų buvo irasyta
	mov	ah, 40h	
	mov	dx, offset skBuf	
	int 21h			
	jc	klaidaRasant 
	jmp RasykBufPabaiga
  klaidaRasant:
	mov ah,9
	mov dx,offset error4
	int 21h
	mov	ax, 0		
RasykBufPabaiga:
	RET
RasykBuf ENDP
END pradzia