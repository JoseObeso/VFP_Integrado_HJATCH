CLEAR
Archivo_ = FILE(".\bd.ini") 
   IF Archivo_ = .T. 
      N_Cadena = ALLTRIM(FILETOSTR(".\bd.ini")) 
      x_Server = ALLTRIM(SUBSTR(N_Cadena,1,(ATC(CHR(13),N_Cadena,1) - 1))) 
      N_Cadena = ALLTRIM(RIGHT(N_Cadena,LEN(N_Cadena) - ( ATC(CHR(13),N_Cadena,1) + 1 ))) 
      x_UID =    ALLTRIM(SUBSTR(N_Cadena,1,(ATC(CHR(13),N_Cadena,1) - 1))) 
      N_Cadena = ALLTRIM(RIGHT(N_Cadena,LEN(N_Cadena) - ( ATC(CHR(13),N_Cadena,1) + 1 ))) 
      x_PWD =    ALLTRIM(SUBSTR(N_Cadena,1,(ATC(CHR(13),N_Cadena,1) - 1))) 
      N_Cadena = ALLTRIM(RIGHT(N_Cadena,LEN(N_Cadena) - ( ATC(CHR(13),N_Cadena,1) + 1 ))) 
      x_Change = CHRTRAN(N_Cadena,CHR(13),"*") 
      x_DBaseName = Substr(x_Change,1,ATC("*",x_Change,1)-1) 
      lcStringCnxLocal = "Driver={SQL Server Native Client 11.0};" +  "SERVER=" + x_Server + ";" +  "UID=" + x_UID + ";" + "PWD=" + x_PWD + ";" + "DATABASE=" + x_DBaseName + ";"
      ?lcStringCnxLocal
      Sqlsetprop(0,"DispLogin" , 3 ) 
       * Asignacion de Variables con sus datos 
      gconecta=SQLSTRINGCONNECT(lcStringCnxLocal)
  ENDIF

 lc_fecha1 = '2021-06-01'
 lc_fecha2 = '2021-06-30'
 lc_serie = 'B001'
 ln_igv = 18
 
 
 TEXT TO lver_rango NOSHOW
    TRUNCATE TABLE TMP_CAJA_IGV
	declare @lcfecha1 datetime = convert(datetime,  ?lc_fecha1, 101)
	declare @lcfecha2 datetime = convert(datetime, ?lc_fecha2, 101)
	declare @lc_serie varchar(8) = ?lc_serie
	declare @lnigv int = ?ln_igv
	SELECT pagoid, numero, convert(varchar(10), fecha,103) as fecha, subtotal, descuento,   total, modulo 
	FROM V_PAGOC where fecha between @lcfecha1 and @lcfecha2 and SUBSTRING(numero,1,4) =  @lc_serie

ENDTEXT
ejecutabusca = sqlexec(gconecta,lver_rango,"tmp_caja")
SELECT tmp_caja
GO top
SCAN
  ln_pagoid = ALLTRIM(tmp_caja.pagoid)
  lc_numero = ALLTRIM(tmp_caja.numero)
  lc_fecha = ALLTRIM(tmp_caja.fecha)
  ln_total = tmp_caja.total
  lc_modulo = ALLTRIM(tmp_caja.modulo)
  ln_subtotal = tmp_caja.subtotal
  ln_descuento = tmp_caja.descuento
  
  DO CASE   lc_modulo
    CASE lc_modulo = 'LIQUIDACION'
	    TEXT TO lqry_ver noshow
	      SELECT sum(importe) as base FROM PAGOD WHERE PAGOID = ?ln_pagoid AND SUBSTRING(ITEM,1,2) = '17';
	    endtext
	    ejecutabusca = sqlexec(gconecta,lqry_ver,"tmp_ver")
	    SELECT tmp_ver
	    lv = RECCOUNT()
	    IF lv > 0
	      ln_total_nuevo = tmp_ver.base
	      ln_monto_base = ln_total_nuevo - ln_total_nuevo* ln_igv/100
          ln_igv_calculado = ln_total* ln_igv/100
          lc_observacion = 'MEDICINA'
	    ELSE 
   	      ln_total_nuevo = tmp_ver.base
	      ln_monto_base = tmp_ver.base
	      ln_igv_calculado = 0
          lc_observacion = 'SERVICIOS'
	    ENDIF
	    
    CASE lc_modulo = 'FARMACIA'
        ln_total_nuevo = ln_total
        ln_igv_calculado = total* ln_igv/100
        ln_monto_base = total - total* ln_igv/100
        lc_observacion = 'MEDICINA'

        
    OTHERWISE 
        ln_total_nuevo = ln_total
        ln_monto_base = 0
        ln_igv_calculado = 0
        lc_observacion = ''
            
ENDCASE

IF ln_monto_base = 0
   ln_monto_base_final = ln_subtotal
ELSE    
  ln_monto_base_final = ln_monto_base

ENDIF
   

 TEXT TO lqry_final noshow
    INSERT  INTO TMP_CAJA_IGV (pagoid, numero, fecha, subtotal, descuento, monto_base, IGV, total, modulo, observacion)
         VALUES (?ln_pagoid, ?lc_numero, ?lc_fecha, ?ln_subtotal, ?ln_descuento, ?ln_monto_base_final, ?ln_igv_calculado, ?ln_total_nuevo, ?lc_modulo,  ?lc_observacion)
 ENDTEXT
 ejecutabusca = sqlexec(gconecta,lqry_final) 


 TEXT TO lqry_liqui noshow
 	update TMP_CAJA_IGV set monto_base = subtotal, igv = 0, total = subtotal, observacion = 'OTROS SERVICIOS' where modulo = 'LIQUIDACION' and monto_base is null
 ENDTEXT
 ejecutabusca = sqlexec(gconecta,lqry_liqui) 

?lc_modulo
?lc_numero 
?ln_total_nuevo
?ln_monto_base 




ENDSCAN


?'-- fin --'
