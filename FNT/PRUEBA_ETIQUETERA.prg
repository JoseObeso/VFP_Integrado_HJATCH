LCRUTA_IMPRESORA="EPSON_TMU"

SET CONSOLE OFF 
SET PRINTER TO NAME GETPRINTER(LCRUTA_IMPRESORA)


*Se Establece la Configuración de Márgenes y otros valores del Documento 
LNMARGEN_SUP = 5 
LNMARGEN_INF = 5 
LN_NCOL          = 40 


        *Se inicializa el codigo de Impresion 
        ??? CHR(27)+CHR(48)+CHR(27)+CHR(67)+CHR(44) 
        ???  CHR(18)+CHR(27)+CHR(77)+CHR(15) 
        ???  CHR(27)+CHR(77)+CHR(20) 


        *Se imprime el margenSuperior 
        FOR I=1 TO      LNMARGEN_SUP 
                ??? CHR(10)+CHR(13) 
        ENDFOR 


        *--------------------------------- ENCABEZADO DEL TIKET 

        *-123456789-123456789-123456789-123456789-12 
        ??? CHR(10)+CHR(13)+PADC('ESTO ES UNA PRUEBA',LN_NCOL) 
        *------------------------------ FIN DEL ENCABEZADO DEL TIKET 



        *Configuración Terminal de Impresion 
        CLOSE PRINT 
        SET CONSOLE ON 
        SET PRINTER TO 
