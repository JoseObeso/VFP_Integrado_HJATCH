CLEAR

lnnumeroinicial = 1
lchora_inicio = '18:00'
lchora_intervalo_noche = 40
x = lchora_intervalo_noche*60
 
 

lchora_inicio = substr(TTOC(CTOT(lchora_inicio) + lchora_intervalo_noche*60),12,5)
?lchora_inicio

lchora_inicio = '00:00'
lcfecha = '2021-07-06'

IF lchora_inicio = '00:00'  
   lcfecha = CTOD(DATE())
   
   
   ?lcfecha
ENDIF




   



FOR rt = 1 TO 8

  lnnumeroinicial =   lnnumeroinicial  +1
  lchora_inicio = substr(TTOC(CTOT(lchora_inicio) + lchora_intervalo_noche*60),12,5)
 
      

ENDFOR


