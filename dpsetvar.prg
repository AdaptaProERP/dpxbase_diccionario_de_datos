// Programa   : DPSETVAR	
// Fecha/Hora : 16/08/2020 09:40:40
// Propósito  : Asignación de Variables oDp:<cName> Desde el Arranque del Sistema
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
   LOCAL cFile:="DP\DPCONFIGSYS.INI"
   LOCAL oIni
   LOCAL aFiles:={}
   LOCAL cFileCli:="CLIENTE\CLIENTE.TXT"

   // 03/10/2023
   // Reemplaza el programa binario c:\dpsgev60\bin\dpsgev60.exe en c:\dpsgev60\dpsgev60.exe
   EJECUTAR("REPLACEBIN") 
   
   oDp:lConfig    :=.F. // no ha sido ejecutado DPLOADCNF
   oDp:cRecTrib   :="Recaudador Tributario"
   oDp:aLogico    :={} // DPLOADCNF debera evaluarlo si esta vacio lo recarga
   oDp:aCamposOpc :={}
   oDp:lAuditar   :=.T. // Desactiva guardar en DPAUDELIMODTAB, Se activa en DPLOADCNF o CONFIGURAR EMPRESA
   oDp:aMyStruct  :={}  // 30/09/2023, optimiza la búsqueda de campos para optimizarlo, evita re-lectura de la tabla
   oDp:lBtnText   :=.T. // Botones en DPLBXRUN, incluye Textos.
   oDp:nBtnHeight :=60
   oDp:nBtnWidth  :=55
   oDp:nBarnHeight:=60 // Tamaño del Ancho de la Barra de Botones Ventana Principal

   oDp:lMYSQLCHKCONN:=.F. // Revisar Conexión Base de datos
   oDp:lDropAllView :=.F. // No debe remover todas las vista, solo en caso de ser solicitada directamente, su valor será redefinido en DPINI
   oDp:lRunPrgView  :=.T. // 04/10/2023, Definición RUNPRGVIEW en DATAPRO.INI genera el valor lógico para la variable
                          // oDp:lRunPrgView quien activa o desactiva la ejecución del programa DPXBASE
                          // asociado con la EJECUCION PREVIA a la creación de la VISTA en el programa SETVISTAS.

   oDp:nGris       :=15724527
   oDp:nGris2      :=16774636  

   oDp:lMsgOff :=.F. // Apaga 
   oDp:cMsgFile:=""  // Archivo LOG contentivo de los mensajes
   oDp:oMemo   :=NIL

   oDp:oDPAUDITOR  :=NIL // Objeto para Optimizar Inserción en programa AUDITORIA BD DPSGEV60
   oDp:oDPAUDITORIA:=NIL // Objeto para Optimizar Inserción en programa AUDITORIA BD ADMCONFIG

   IF FILE(cFile)

     INI oIni File (cFile)

     oDp:nGris :=oIni:Get( "Config", "nGris"  , oDp:nGris )
     oDp:nGris2:=oIni:Get( "Config", "nGris2" , oDp:nGris2)

   ENDIF

   IF FILE(cFileCli) .AND. !FILE("MYSQL.MEM")
      EJECUTAR("DPAPTGETCREDENCIALES") // Solicita Numero de la Licencia para obtener las credenciales desde el Servidor
   ENDIF

   IF FILE("MYSQLPLANB.MEM")
      EJECUTAR("MYSQLPLANB") // Validar las credenciales de MySQL.MEM y MYSQLPLANB.MEM
   ENDIF

   oDp:oSay1      :=NIL
   oDp:oSay2      :=NIL
   oDp:oSay3      :=NIL
   oDp:oSay4      :=NIL
   oDp:oSay5      :=NIL
   oDp:oMeter     :=NIL

RETURN .T.
// EOF
