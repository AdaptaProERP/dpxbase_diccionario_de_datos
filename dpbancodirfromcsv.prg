// Programa   : DPBANCODIRFROMCSV          
// Fecha/Hora : 07/04/2024 13:46:20
// Propósito  : Crear directorio bancario desde ejemplo\
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
  LOCAL cMemo,cFile:="ejemplo\banks_venezuela.csv"
  LOCAL aData:={},I,cWhere,cCodBco,oDb:=OpenOdbc(oDp:cDsnData)
  LOCAL cFileDbf:="DATADBF\DPBANCODIR.DBF"

  EJECUTAR("DPCAMPOSADD","DPBANCOS"  ,"BAN_CODDIR","C",05 ,0,"Código Directorio Bancario")
  EJECUTAR("DPCAMPOSADD","DPBANCODIR","BAN_ACTIVO","L",01 ,0,"Activo")

  oDb:EXECUTE("UPDATE DPBANCODIR SET BAN_ACTIVO=1 WHERE BAN_ACTIVO IS NULL")

  EJECUTAR("CREATERECORD","DPBANCODIR",{"BAN_CODIGO","BAN_NOMBRE","BAN_ACTIVO"},;
                                       {"0000"      ,"Indefinido",.T.         },;
            NIL,.T.,"BAN_CODIGO"+GetWhere("=","0000"))

  cWhere:=[WHERE LENGTH(BAN_CODIGO)=5]

  IF COUNT("DPBANCODIR",cWhere)=0
//     RETURN .F.
  ENDIF

  IF !FILE(cFile) 

     IF FILE(cFileDbf)

        CLOSE ALL
        USE (cFileDbf)

        WHILE !EOF()

          IF !Empty(BAN_CODIGO)
             AADD(aData,{BAN_CODIGO,BAN_NOMBRE})
          ENDIF

          DBSKIP()

        ENDDO

        CLOSE ALL

     ENDIF
   
  ELSE
 
    cMemo:=MEMOREAD(cFile)
    cMemo:=STRTRAN(cMemo,CHR(10),"")
    cMemo:=STRTRAN(cMemo,["],[])
    aData:=_VECTOR(cMemo,CHR(13))

  ENDIF

  oTable:=OpenTable("SELECT * FROM DPBANCODIR",.F.)
  oTable:lAuditar:=.F.

  FOR I=1 TO LEN(aData)

     aData[I]:=_VECTOR(aData[I],",")
     cWhere  :="BAN_CODIGO"+GetWhere("=",aData[I,1])

     IF !ISSQLFIND("DPBANCODIR",cWhere)
       oTable:AppendBlank()
       oTable:Replace("BAN_CODIGO",aData[I,1])
       oTable:Replace("BAN_NOMBRE",aData[I,2])
       oTable:Replace("BAN_ACTIVO",.T.)
       oTable:Commit("")
     ENDIF

  NEXT I

  oTable:End()

  // ViewArray(aData)

  aData :={}
  oTable:=OpenTable("SELECT BAN_CODIGO,BAN_NOMBRE FROM DPBANCODIR WHERE LENGTH(BAN_CODIGO)=5",.T.)

  WHILE !oTable:Eof() 

     cWhere:="BAN_NOMBRE"+GetWhere(" LIKE ","%"+ALLTRIM(oTable:BAN_NOMBRE)+"%")+" AND LENGTH(BAN_CODIGO)=4" 

     IF COUNT("dpbancodir",cWhere)=1
       cCodBco:=SQLGET("dpbancodir","BAN_CODIGO",cWhere)
       SQLUPDATE("NMTRABAJADOR","BANCO"     ,cCodBco,"BAN_CODIGO"+GetWhere("=",oTable:BAN_CODIGO))
       SQLUPDATE("DPBANCOS"    ,"BAN_CODDIR",cCodBco,"BAN_BCOTXT"+GetWhere("=",oTable:BAN_NOMBRE))
       SQLUPDATE("DPBANCODIR"  ,"BAN_ACTIVO",.F.    ,"BAN_CODIGO"+GetWhere("=",oTable:BAN_CODIGO))
     ENDIF

     oTable:DbSkip()

  ENDDO

  oTable:End(.T.)

  // Desactiva todos los bancos que no tienen coincidencia
  SQLUPDATE("DPBANCODIR","BAN_CODIGO","0000","(BAN_ACTIVO=0 OR LENGTH(BAN_CODIGO)=5)")
  
  EJECUTAR("UNIQUETABLAS"  ,"DPBANCODIR","BAN_CODIGO")
  EJECUTAR("DPTABLAACENTOS","DPBANCODIR","BAN_NOMBRE") // ,"BAN_CODIGO")

  IF FILE(cFile)
     oTable:=OpenTable("SELECT * FROM DPBANCODIR",.T.)
     oTable:CTODBF("DATADBF\DPBANCODIR.DBF")
     oTable:End(.T.)
  ENDIF

//DPLBX("DPBANCODIR")
//Ã‰//

RETURN .T.
// EOF
