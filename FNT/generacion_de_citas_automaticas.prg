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
      ?lcStringCnxLocal
      Sqlsetprop(0,"DispLogin" , 3 ) 
       * Asignacion de Variables con sus datos 
      gconecta=SQLSTRINGCONNECT(lcStringCnxLocal)
  ENDIF
  
cMensage = '...INICIANDO PROCESO.............' 
_Screen.Scalemode = 0
Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  
SET HOURS TO 24
lcconsultorio = '5050'
lcmedico = 'LNH'
lnnumeroinicial=1
lnnumerofinal=8
lnbucle = lnnumerofinal - lnnumeroinicial + 1
lchora_intervalo = 10
lcfechadia = '2018-01-31'
?lcfechadia
lcturno1 = 'MT'
lcturno = UPPER(lcturno1)


?lcturno

IF LEN(lcturno) = 1
   DO CASE lcturno
      CASE ALLTRIM(lcturno) = 'M'
        lcturno = 'M'
        lchora_inicio = '08:00'
        lchora_fina = '12:30'
        agregar_citas_con_horas() 
      CASE ALLTRIM(lcturno) = 'T' 
        lcturno = 'T'        
        lchora_inicio = '14:00'
        lchora_fina = '18:30'
        agregar_citas_con_horas() 
        
      CASE ALLTRIM(lcturno) = 'I' 
        lcturno = 'I'        
        lchora_inicio = '12:00'
        lchora_fina = '16:00'
        agregar_citas_con_horas() 
        
      CASE ALLTRIM(lcturno) = 'N' 
        lcturno = 'N'        
        lchora_inicio = '18:00'
        lchora_fina = '20:00'
        agregar_citas_con_horas() 

      OTHERWISE 
        cMensage = '...TURNO NO DEFINIDO.............' 
        _Screen.Scalemode = 0
        Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  
        
        
   ENDCASE
ELSE
        ** INICIA MA�ANA
      *  IF AT('M', lcturno) = 1
           lcturno = 'M'
           lnnumeroinicial=1
           lchora_inicio = '08:00'
           lchora_fina = '12:30'
           agregar_citas_con_horas() 
       * ENDIF
        
        ** INICIA TARDE
        *IF AT('T', lcturno) = 1
           lcturno = 'T'
           lnnumeroinicial=1
           lchora_inicio = '14:00'
           lchora_fina = '18:30'
           agregar_citas_con_horas() 
        *ENDIF
           
        
        ** INICIA INTERMEDIO
        IF AT('I', lcturno) = 1
           lcturno = 'I'
           lnnumeroinicial=1
           lchora_inicio = '12:00'
           lchora_fina = '16:00'
           agregar_citas_con_horas() 
        ENDIF
        
        ** INICIA NOCHE
        IF AT('N', lcturno) = 1
           lcturno = 'N'
           lnnumeroinicial=1
           lchora_inicio = '18:00'
           lchora_fina = '20:00'
           agregar_citas_con_horas() 
       ENDIF
        
ENDIF


** Funciones definidas
FUNCTION agregar_citas_horas_en_blanco()
  FOR RT = 1 TO lnbucle
    lcnumerocita = ALLTRIM(STR(lnnumeroinicial))
    cMensage = '........AGREGANDO CITA NRO. :  ' +lcnumerocita
    _Screen.Scalemode = 0
    Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  
      TEXT TO lqry_agregar_citas noshow
         declare @lid_cita int = (select convert(int, MAX(CITA_ID)) + 1  as id_cita from CITA)
         DECLARE @ldfecha datetime = convert(datetime, ?lcfechadia, 101)
         declare @lchora char(6) = ?lchora
         declare @lcnumero varchar(3) = ?lcnumerocita
         declare @lcturno char(2) = ?lcturno
         declare @lcnombre varchar(60) = '                                                              '
         DECLARE @lcconsultorio varchar(8) = ?lcconsultorio
         declare @lcmedico varchar(4) = ?lcmedico
         INSERT INTO [SIGSALUD].[dbo].[CITA]([CITA_ID],[CONSULTORIO],[MEDICO],[FECHA_PROGRAMACION],[FECHA_OTORGA],[FECHA_PAGO],[FECHA_LIBRE],[FECHA],[HORA],[TURNO_CONSULTA],[TIPO_PACIENTE],[TIPO_CITA],[PACIENTE],[NOMBRE],[OBSERVACION],
           [PAGOID],[SEGURO],[ESTADO],[NUMERO],[HORA_OTORGA],[TIPO_SOLICITUD],[SITUACION],[USUARIO],[NUMATENCION],[USER_ELIMINACION],[FECHA_HORA_ELIMINACION])
                 VALUES (convert(char(9), @lid_cita), @lcconsultorio, @lcmedico, GETDATE() - 0.15, NULL, NULL, NULL, @ldfecha, @lchora, @lcturno, 'N', 'C', ' ', ' ', ' ', ' ','0','1', @lcnumero, @lcnombre, 'P', null, null, '0', null, null)
      ENDTEXT
      lejecutabusca = sqlexec(gconecta,lqry_agregar_citas)
      lnnumeroinicial =   lnnumeroinicial  +1
  ENDFOR
  cMensage = '........TODO TERMINADO...'
  _Screen.Scalemode = 0
  Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  
ENDFUNC


FUNCTION agregar_citas_con_horas() 
  FOR RT = 1 TO lnbucle
    lcnumerocita = PADL(ALLTRIM(STR(lnnumeroinicial)), 2, '0')
    lhoragrabar =  lchora_inicio
    cMensage = '........AGREGANDO CITA NRO. :  ' +lcnumerocita
    _Screen.Scalemode = 0
    Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  
      TEXT TO lqry_agregar_citas_horas noshow
         declare @lid_cita int = (select convert(int, MAX(CITA_ID)) + 1  as id_cita from CITA)
         DECLARE @ldfecha datetime = convert(datetime, ?lcfechadia, 101)
         declare @lchora char(6) = ?lhoragrabar
         declare @lcnumero varchar(3) = ?lcnumerocita
         declare @lcturno char(2) = ?lcturno
         declare @lcnombre varchar(60) = '                                                              '
         DECLARE @lcconsultorio varchar(8) = ?lcconsultorio
         declare @lcmedico varchar(4) = ?lcmedico
         INSERT INTO [SIGSALUD].[dbo].[CITA]([CITA_ID],[CONSULTORIO],[MEDICO],[FECHA_PROGRAMACION],[FECHA_OTORGA],[FECHA_PAGO],[FECHA_LIBRE],[FECHA],[HORA],[TURNO_CONSULTA],[TIPO_PACIENTE],[TIPO_CITA],[PACIENTE],[NOMBRE],[OBSERVACION],
           [PAGOID],[SEGURO],[ESTADO],[NUMERO],[HORA_OTORGA],[TIPO_SOLICITUD],[SITUACION],[USUARIO],[NUMATENCION],[USER_ELIMINACION],[FECHA_HORA_ELIMINACION])
                 VALUES (convert(char(9), @lid_cita), @lcconsultorio, @lcmedico, GETDATE() - 0.15, NULL, NULL, NULL, @ldfecha, @lchora, @lcturno, 'N', 'C', ' ', ' ', ' ', ' ','0','1', @lcnumero, @lcnombre, 'P', null, null, '0', null, null)
      ENDTEXT
      lejecutabusca = sqlexec(gconecta,lqry_agregar_citas_horas)
      lnnumeroinicial =   lnnumeroinicial  +1
      lchora_inicio = substr(TTOC(CTOT(lchora_inicio) + lchora_intervalo*60),12,5)
  ENDFOR
  cMensage = '........TODO TERMINADO...'
  _Screen.Scalemode = 0
  Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  
ENDFUNC
