.MODEL small        
.STACK 100h 

.DATA
hello_message db 'Iveskite simboliu eilute:', 0dh,0ah,'$'
arr db 20 dup(?)    ;ivestu simboliu masyvas
liek db ?           ;saugos liekana
neliek db ?         ;saugos ne liekana
count db 0        ;kiek skaitmenu desimtainiame numeryje, naudojamas paziureti ar skaicius

.CODE
start:
	mov ax,@data    
	mov ds,ax       ;data segmento inicializacija
	mov ah,9	    ;Isvesti stringa
	mov dx, offset hello_message
	int 21h
	
	mov si,0           ;skaiciuos, kiek nuskaityta elementu
	mov ah,01h         ;nuskaito i al
	
input:
	isbad:
    int 21h
	cmp al,'9'		
	ja notNr
	cmp al,'0'
	jae isbad

	notNr:
	cmp al,'A'
	jb isgood
	cmp al,'Z'
	jbe isbad
	
	isgood:
	mov arr[si],al
    inc si
    cmp al,0Dh         ;Iesko new line
    jnz input
	
	
	sub si,1            ;Kad nenaudotu nuskaityto new line
	mov di,0            ;skaiciuos, kiek padare loop						
	
output:
    mov ax,0            ;isvalyti ax
    mov dx,0            ;isvalyti dx 
    mov al,arr[di]      ;ideda pirma simboli i al
    mov dl,10            ;daliklis 10
    
    convert:
    div dl              ;ax\10
    mov neliek,al
    mov liek,ah
    
    mov ax,0            ;isvalom ax
    mov al,liek
    push ax
    inc count           ;padidinam skaitmenu skaiciu
   
    mov al, neliek 
    cmp al,0            ;iesko ar baigti skaiciavimai 0
    jnz convert
    
    print: 
    pop dx
    add dx,'0'          ;konvertuojam i ascii
    mov ah,02h          ;isspausdina
    int 21h
    
    dec count
    cmp count,0
    jnz print
    
    mov dl,32           ;ispausdina tarpa
    mov ah,02h
    int 21h
    
    inc di
    cmp si,di
    jnz output	

	mov ax,4C00h        ;iseiti is programos
	int 21h
end start
	