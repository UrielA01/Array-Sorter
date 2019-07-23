IDEAL
MODEL small
STACK 100h
DATASEG
lenseries1 equ 10
lenseries2 equ 10
series1 db lenseries1 dup(?)
series2 db lenseries2 dup(?)
sorted db lenseries1+lenseries2 dup(?)
insertCon dw 4
endmsg db 'end$'
sortCondition db 0
array1msg db 'Enter array one elements:$'
array2msg db 'Enter array two elements:$'
sortedarrmsg db 'Sorted array:$'
CODESEG	
proc Merge
	push bp
	mov bp,sp
	; stack:
	; bp | ip | sorted | series2 | series1
	;bp+0|bp+2| bp+4   | bp+6    | bp+8
	;
	mov cx,lenseries1
	mov [insertCon],bx ; move bx to insertCon for it's will be able to pass the two arrays and merge them bx=14 (sorted location)
	mov bx,[bp+8] ; move the location of series1 to bx
	mergeloop1:
	mov al,[bx]
	add al,30h ; add ascii value to the array for it will be able to print them
	push bx ; push bx current value to the stack bx=series1 location
	mov bx,[insertCon] ; bx=sorted location
	inc [insertCon]
	mov [bx],al ;al=series1 value in bx
	pop bx
	inc bx
	loop mergeloop1
	
	mov cx,lenseries2
	mov bx,[bp+6]
	mergeloop2: ; same as loop one
	mov al,[bx]
	add al,30h
	push bx
	mov bx,[insertCon]
	inc [insertCon]
	mov [bx],al
	pop bx
	inc bx
	loop mergeloop2
	pop bp
	ret 4
endp Merge
proc sortArr
	push bp
	mov bp,sp
	
	; bp | ip |sorted
	;bp+0|bp+2|bp+4
conditionloop:
	mov bx,[bp+4] ; bx=sorted position 
	mov [sortCondition],1 ; for now, the array is sorted
	mov cx,lenseries1+lenseries2-1
sortloop:
	mov al,[bx]
	mov ah,[bx+1]
	cmp ah,al ; compare array in place bx and bx+1
	jae issort ; if bx<bx+1 this place is sort correct 
	mov [bx+1],al ; if not, swap bx,bx+1
	mov [bx],ah
	mov [sortCondition],0; array not sorted yet
issort:
	inc bx
loop sortloop
	cmp [sortCondition],0
	je conditionloop ; if sortCondition=0 so the array is not sorted and it's to be checked again
ending:
	pop bp
	ret 2
endp sortArr
proc linedrop
	push bp
	mov bp,sp
	mov dl,0dh ;return the pointer to the start of the line
	mov ah,2
	int 21h
	mov dl,0ah ; drop of to the next line
	mov ah,2
	int 21h
	pop bp
	ret 
endp linedrop	
start:
	mov ax, @data
	mov ds, ax
	;code here
	mov ah,9
	mov dx,offset array1msg ; print enter message   
	int 21h
	call linedrop
	mov cx,lenseries1
	mov bx, offset series1
arrayLoop:
	mov ah,1
	int 21h
	sub al,30h ; sub in 30h because the ascii code of number is num+30h and we want to save only the number
	mov [bx],al
	inc bx
loop arrayLoop
	call linedrop
	mov ah,9
	mov dx,offset array2msg
	int 21h
	call linedrop
	mov cx,lenseries2
	mov bx, offset series2
arrayLoop2:
	mov ah,1
	int 21h
	sub al,30h
	mov [bx],al
	inc bx
loop arrayLoop2
	push offset series1 ; push the parameters to the stack for they'll be use in the procedure 
	push offset series2
	push offset sorted
	call Merge 
	push offset sorted
	call sortArr
	call linedrop
	mov ah,9
	mov dx,offset sortedarrmsg
	int 21h
	call linedrop
	mov cx,lenseries1+lenseries2
	mov bx,offset sorted
	printArray:
	mov dl,[bx] ;mov to dl the content of the array for printing
	mov ah,2
	int 21h
	inc bx
	loop printArray
exit: 
	mov ax, 4c00h
	int 21h
END start 