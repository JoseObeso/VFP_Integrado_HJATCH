clear
** Revisar las horas del turno ma�ana y tarde ******
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
      lcStringCnxLocal = "Driver={SQL Server Native Client 10.0};" +  "SERVER=" + x_Server + ";" +  "UID=" + x_UID + ";" + "PWD=" + x_PWD + ";" + "DATABASE=" + x_DBaseName + ";"
      Sqlsetprop(0,"DispLogin" , 3 ) 
       * Asignacion de Variables con sus datos 
      gconecta=SQLSTRINGCONNECT(lcStringCnxLocal)
  ENDIF
SET HOURS TO 24
cMensage = '...INICIANDO PROCESO.............' 
_Screen.Scalemode = 0
Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  

lconsultorio = '2021'  && consultorio : CIRUGIA PLASTICA
lcturno = 'T'
lcfecha = '2017-06-23'
lcmedico = 'PLW'
lc_hora_inicio = '14'
lc_minutos_atencion = 17

TEXT TO lqry_ver_turnos_hora noshow
  select CITA_ID, HORA from cita where CONSULTORIO=?lconsultorio AND TURNO_CONSULTA =?lcturno and  FECHA=CONVERT(DATETIME, ?lcfecha, 101) and MEDICO = ?lcmedico ORDER BY CITA_ID ASC
ENDTEXT
lejecutabusca = sqlexec(gconecta,lqry_ver_turnos_hora,"thoras")
SELECT thoras
nr = reccount()
GO top
SCAN
  lid_cita = ALLTRIM(thoras.cita_id)
  lhorainicio = CTOT(lc_hora_inicio)
  lhoragrabar = ALLTRIM(substr(ttoc(lhorainicio), 12, 5))
  TEXT TO lqry_grab noshow
      UPDATE cita SET hora = ?lhoragrabar WHERE cita_id = ?lid_cita
  ENDTEXT
  lejecutabusca = sqlexec(gconecta,lqry_grab)
  lhoracalculo = CTOT(lhoragrabar) + lc_minutos_atencion*60
  lc_hora_inicio = TTOC(lhoracalculo)
  cMensage = '........ASIGNANDO TIEMPO DE : ..' + lc_hora_inicio
  _Screen.Scalemode = 0
  Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  
ENDSCAN


cMensage = '........TODO TERMINADO...'
_Screen.Scalemode = 0
Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  


