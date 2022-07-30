CLEAR

**  Agregar CIE  *
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

cMensage = '...BUSCANDO...CIE.....' 
_Screen.Scalemode = 0
Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  

 
TEXT TO lccie_sele noshow
  SELECT COD_CAT, COD_ENF, RTRIM(RTRIM(COD_CAT) + RTRIM(COD_ENF))  AS CODIGO1,   
     RTRIM(SUBSTRING(DESC_ENF, LEN(RTRIM(RTRIM(COD_CAT) + RTRIM(COD_ENF)) + ' - ') + 1, 100)) AS CDESCRIPCION, desc_enf
        FROM [SIGSALUD].[dbo].[CIEX_AGREGAR]
ENDTEXT
lejecutabusca = sqlexec(gconecta,lccie_sele,"tccie")
SELECT tccie
SCAN
  lc_ccie = ALLTRIM(tccie.codigo1)
  lcdes = ALLTRIM(substr(tccie.cdescripcion,1,180))
  lcsexo = ''
  lcmin_edad = 1
  lcmin_tipo = 'D'
  lcmax_edad = '99'
  lcmax_tipo = 'A'
  lcest = 'A'
  lcclase = '4'
  lccat = ALLTRIM(tccie.cod_cat)
  TEXT TO lcbusca_ciex noshow
    SELECT * FROM CIEXHIS WHERE CODIGO = ?lc_ccie
  ENDTEXT
  lejecutabusca = sqlexec(gconecta,lcbusca_ciex,"tbus")
  SELECT tbus
  lnbus = RECCOUNT() 
  IF lnbus > 0
     TEXT TO lc_agregar_marca_existe noshow
          UPDATE [SIGSALUD].[dbo].[CIEX_AGREGAR] SET sagregar = 'E' WHERE RTRIM(RTRIM(COD_CAT) + RTRIM(COD_ENF)) = ?lc_ccie
     ENDTEXT
     lejecutabusca = sqlexec(gconecta,lc_agregar_marca_existe)
     cMensage = '...CIE, YA EXISTE...AGREGANDO MARCA..........' 
     _Screen.Scalemode = 0
     Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  
     
  ELSE
     TEXT TO lcagregar_nuevo noshow
        declare @lidcodord int = (select top 1 CODORD + 1 from CIEXHIS where CODORD <> 90000 order by CODORD desc)
        INSERT INTO [SIGSALUD].[dbo].[CIEXHIS]([CODORD],[CODIGO],[NOMBRE],[SEXO],[MIN_EDAD],[MIN_TIPO],[MAX_EDAD],[MAX_TIPO],[EST],[CLASE],[CODCAT])
             VALUES (@lidcodord, ?lc_ccie, ?lcdes, ?lcsexo, ?lcmin_edad, ?lcmin_tipo, ?lcmax_edad, ?lcmax_tipo, ?lcest, ?lcclase, ?lccat)
     ENDTEXT
     lejecutabusca = sqlexec(gconecta,lcagregar_nuevo)
     IF lejecutabusca > 0
         TEXT TO lc_agregar_marca_nuevo noshow
                       UPDATE [SIGSALUD].[dbo].[CIEX_AGREGAR] SET sagregar = 'A' WHERE RTRIM(RTRIM(COD_CAT) + RTRIM(COD_ENF)) = ?lc_ccie
         ENDTEXT
         lejecutabusca = sqlexec(gconecta,lc_agregar_marca_nuevo)     
         ?lcdes
         cMensage = '...CPT..AGREGADO....'
         _Screen.Scalemode = 0
         Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  
    ELSE
         TEXT TO lc_agregar_marca_nuevo noshow
            UPDATE [SIGSALUD].[dbo].[CIEX_AGREGAR] SET sagregar = 'N' WHERE RTRIM(RTRIM(COD_CAT) + RTRIM(COD_ENF)) = ?lc_ccie
         ENDTEXT
         lejecutabusca = sqlexec(gconecta,lc_agregar_marca_nuevo)     
         cMensage = '...CIE..NOS GRABO CORRECTAMENTE......'
         _Screen.Scalemode = 0
         Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  
    ENDIF
         
  ENDIF
  cMensage = '...ACTUALIZANDO PARA : ' +lcdes
  _Screen.Scalemode = 0
  Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  
  
ENDSCAN
cMensage = '...PROCESO FINALIZADO....'
_Screen.Scalemode = 0
Wait Window cMensage At Int(_Screen.Height/2), Int(_Screen.Width/2 - Len(cMensage)/2) nowait  

