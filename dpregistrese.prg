// Programa   : DPREGISTRESE
// Fecha/Hora : 18/06/2023 07:29:42
// Propósito  : Cargar formulario Registrese para licencia Emprendedor
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(nOption,cCodigo)
  LOCAL oBtn,oTable,oGet,oFont,oFontB,oFontG
  LOCAL cSql,cFile,cExcluye:=""
  LOCAL nClrText
  LOCAL cTitle:="Registrese"
  LOCAL lSeniat:=.F.
  LOCAL cMemo:="",aFields:={},I,uValue:=""
  LOCAL aEstados :={"-Seleccionar","Amazonas","Anzoátegui","Apure","Aragua","Barinas","Bolívar","Carabobo","Cojedes","Delta Amacuro","Distrito Federal","Falcón","Guárico",;
                    "Lara","Mérida","Miranda","Monagas","Nueva Esparta","Portuguesa","Sucre","Táchira","Trujillo","Vargas","Yaracuy","Zulia"}

  cExcluye:=""

  DEFAULT cCodigo:="1234",;
          nOption:=1

  DEFINE FONT oFont  NAME "Tahoma" SIZE 0, -10 BOLD
  DEFINE FONT oFontB NAME "Tahoma" SIZE 0, -12 BOLD ITALIC
  DEFINE FONT oFontG NAME "Tahoma" SIZE 0, -11

  nClrText:=10485760 // Color del texto

  oDp:lIsSeniat:=.F.
  lSeniat      :=EJECUTAR("ISSENIAT")
  lSeniat      :=.F.

  cTitle:="Regístrate en AdaptaPro Server, Obten licencia Gratuita para tu Emprendimiento "
  oREGISTRESE:=DPEDIT():New(cTitle,"DPREGISTRESE.edt","oREGISTRESE" , .F. ,.T.)

  oREGISTRESE:nOption  :=nOption
  oREGISTRESE:SetScript()        // Asigna Funciones DpXbase como Metodos de oREGISTRESE
  oREGISTRESE:SetDefault()       // Asume valores standar por Defecto, CANCEL,PRESAVE,POSTSAVE,ORDERBY
  oREGISTRESE:nClrPane  :=oDp:nGris
  oREGISTRESE:lSeniat   :=lSeniat
  oREGISTRESE:lValRif   :=.F.
  oREGISTRESE:REG_IDHD  :=CTOO(NSERIALHD(),"C")
  oREGISTRESE:REG_FCHRUN:=DPFECHA()


  oREGISTRESE:REG_ESTADO  :=aEstados[1]
  oREGISTRESE:REG_ACTIVI  :=SPACE(120)
  oREGISTRESE:REG_REPRES  :=SPACE(120)
  oREGISTRESE:REG_RIF     :=SPACE(12)
  oREGISTRESE:REG_OS      :=SPACE(120)
  oREGISTRESE:REG_TELEFO  :=SPACE(120)
  oREGISTRESE:REG_PC      :=SPACE(120)
  oREGISTRESE:REG_CODPRO  :=oDp:cCodApl
  oREGISTRESE:REG_HORA    :=SPACE(8)
  oREGISTRESE:REG_EMAIL   :=SPACE(120)
  oREGISTRESE:REG_CIUDAD  :=SPACE(120)
  oREGISTRESE:REG_NOMBRE  :=SPACE(120)
  oREGISTRESE:REG_FECHA   :=DPFECHA()
  oREGISTRESE:REG_REQMOV  :=.T.
  oREGISTRESE:REG_DISMAY  :=.T.
  oREGISTRESE:REG_REQPRD  :=.T.
  oREGISTRESE:REG_REQGRP  :=.T.
  oREGISTRESE:REG_REQAA   :=.T.
  oREGISTRESE:REG_REQPFN  :=.T.
  oREGISTRESE:REG_ACTIVO  :=.T.
  oREGISTRESE:REG_AXIFIS  :=.T.
  oREGISTRESE:REG_REQBI   :=.T.
  oREGISTRESE:REG_REQTRA  :=.T.
  oREGISTRESE:REG_REQLCP  :=.T.
  oREGISTRESE:REG_REQNIF  :=.T.
  oREGISTRESE:REG_IMPFIS  :=.T.
  oREGISTRESE:REG_REQPOS  :=.T.
  oREGISTRESE:REG_FABRIC  :=.T.
  oREGISTRESE:REG_IMPORT  :=.T.
  oREGISTRESE:REG_SERCON  :=.T.
  oREGISTRESE:REG_PROYEC  :=.T.
  oREGISTRESE:REG_DETAL   :=.T.
  oREGISTRESE:REG_REQCON  :=.T.
  oREGISTRESE:REG_REQACT  :=.T.
  oREGISTRESE:REG_REQNOM  :=.T.
  oREGISTRESE:REG_REQEPE  :=.F.
  oREGISTRESE:REG_REQGSC  :=.T. // Gestion de Sociedades
  oREGISTRESE:REG_MEMO    :=SPACE(100)
  oREGISTRESE:REG_CANEMP  :=1
  oREGISTRESE:REG_CANSUC  :=1
  oREGISTRESE:REG_CANTRA  :=1
  oREGISTRESE:REG_CAFFAC  :=1
  oREGISTRESE:REG_CANFAV  :=1
  oREGISTRESE:REG_CANPAG  :=1
  oREGISTRESE:REG_CANUSU  :=1

  oREGISTRESE:lRegistrese:=.F. // Solo se coloca verdadero cuando se Registra

//oREGISTRESE:CreateWindow()       // Presenta la Ventana
  oREGISTRESE:CreateWindow(NIL,0,0,100,200)

  // Opciones del Formulario
  //
  // Campo : REG_RIF
  // Uso   : RIF
  //
  @ 3.0, 1.0 GET oREGISTRESE:oREG_RIF VAR oREGISTRESE:REG_RIF    ;
                    WHEN (AccessField("DPREGISTRESE","REG_RIF",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                    FONT oFontG;
                    SIZE 48,10

//  oREGISTRESE:oREG_RIF:bKeyDown:={|nKey| IF(nKey=13,REG_VALRIF(), NIL )}

  oREGISTRESE:oREG_RIF   :cMsg    :="Introduzca el RIF sin guiones ni puntos"
  oREGISTRESE:oREG_RIF   :cToolTip:="Introduzca el RIF sin guiones ni puntos"

  @ oREGISTRESE:oREG_RIF   :nTop-08,oREGISTRESE:oREG_RIF   :nLeft SAY "RIF o Cédula" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris

  @ 3,10 BUTTON oBtn PROMPT " > " ACTION REG_VALRIF();
         WHEN .T. 
// oREGISTRESE:lSeniat

  oBtn:cToolTip:="Validar RIF con el Portal del Seniat"

  //
  // Campo : REG_NOMBRE
  // Uso   : Nombre
  //
  @ 4.8, 1.0 GET oREGISTRESE:oREG_NOMBRE  VAR oREGISTRESE:REG_NOMBRE ;
                    FONT oFontG;
                    SIZE 480,10;
                    WHEN !oREGISTRESE:lValRif

    oREGISTRESE:oREG_NOMBRE:cMsg    :="Nombre"
    oREGISTRESE:oREG_NOMBRE:cToolTip:="Nombre"

  @ oREGISTRESE:oREG_NOMBRE:nTop-08,oREGISTRESE:oREG_NOMBRE:nLeft SAY "Nombre" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : REG_REPRES
  // Uso   : Representante
  //
  @ 6.6, 1.0 GET oREGISTRESE:oREG_REPRES  VAR oREGISTRESE:REG_REPRES ;
                    FONT oFontG;
                    SIZE 480,10;
                    WHEN !(LEFT(oREGISTRESE:REG_RIF,1)$"VE")

    oREGISTRESE:oREG_REPRES:cMsg    :="Representante"
    oREGISTRESE:oREG_REPRES:cToolTip:="Representante"

  @ oREGISTRESE:oREG_REPRES:nTop-08,oREGISTRESE:oREG_REPRES:nLeft SAY "Representante" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  @ 6.6, 1.0 COMBOBOX oREGISTRESE:oREG_ESTADO VAR oREGISTRESE:REG_ESTADO ITEMS aEstados;
                      SIZE 100,NIL;
                      COLOR NIL,CLR_WHITE PIXEL FONT oFontB;
                      ON CHANGE 1=1

  // ?  oREGISTRESE:oREG_ESTADO:ClassName(),oREGISTRESE:REG_ESTADO,"oREGISTRESE:REG_ESTADO"

  //
  // Campo : REG_CIUDAD
  // Uso   : Ciudad
  //
  @ 8.4, 1.0 GET oREGISTRESE:oREG_CIUDAD  VAR oREGISTRESE:REG_CIUDAD ;
                    WHEN (AccessField("DPREGISTRESE","REG_CIUDAD",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                    FONT oFontG;
                    SIZE 480,10

    oREGISTRESE:oREG_CIUDAD:cMsg    :="Ciudad"
    oREGISTRESE:oREG_CIUDAD:cToolTip:="Ciudad"

  @ oREGISTRESE:oREG_CIUDAD:nTop-08,oREGISTRESE:oREG_CIUDAD:nLeft SAY "Ciudad" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : REG_TELEFO
  // Uso   : Teléfonos
  //
  @ 10.2, 1.0 GET oREGISTRESE:oREG_TELEFO  VAR oREGISTRESE:REG_TELEFO ;
                    WHEN (AccessField("DPREGISTRESE","REG_TELEFO",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                    FONT oFontG;
                    SIZE 480,10

    oREGISTRESE:oREG_TELEFO:cMsg    :="Teléfonos"
    oREGISTRESE:oREG_TELEFO:cToolTip:="Teléfonos"

  @ oREGISTRESE:oREG_TELEFO:nTop-08,oREGISTRESE:oREG_TELEFO:nLeft SAY "Teléfonos" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : REG_EMAIL
  // Uso   : Correo
  //
  @ 12.0, 1.0 GET oREGISTRESE:oREG_EMAIL   VAR oREGISTRESE:REG_EMAIL  ;
                    WHEN (AccessField("DPREGISTRESE","REG_EMAIL",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                    FONT oFontG;
                    SIZE 480,10

    oREGISTRESE:oREG_EMAIL :cMsg    :="Correo"
    oREGISTRESE:oREG_EMAIL :cToolTip:="Correo"

  @ oREGISTRESE:oREG_EMAIL :nTop-08,oREGISTRESE:oREG_EMAIL :nLeft SAY "Correo" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : REG_ACTIVI
  // Uso   : Actividad Económina
  //
  @ 1.0,15.0 GET oREGISTRESE:oREG_ACTIVI  VAR oREGISTRESE:REG_ACTIVI ;
                    WHEN (AccessField("DPREGISTRESE","REG_ACTIVI",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                    FONT oFontG;
                    SIZE 480,10

    oREGISTRESE:oREG_ACTIVI:cMsg    :="Actividad Económina"
    oREGISTRESE:oREG_ACTIVI:cToolTip:="Actividad Económina"

  @ oREGISTRESE:oREG_ACTIVI:nTop-08,oREGISTRESE:oREG_ACTIVI:nLeft SAY "Actividad Económina" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris



  @ 2.8,15.0 GROUP oREGISTRESE:oGroup TO 7.8,20 PROMPT "Magnitud";
                      FONT oFontG

  //
  // Campo : REG_CANEMP
  // Uso   : Empresas
  //
  @ 2.8,15.0 GET oREGISTRESE:oREG_CANEMP  VAR oREGISTRESE:REG_CANEMP  PICTURE "999";
                    WHEN (AccessField("DPREGISTRESE","REG_CANEMP",oREGISTRESE:nOption);
                        .AND. oREGISTRESE:nOption!=0);
                    FONT oFontG;
                    SIZE 12,10;
                    RIGHT SPINNER;
                    VALID (oREGISTRESE:REG_CANEMP>=1)


    oREGISTRESE:oREG_CANEMP:cMsg    :="Empresas"
    oREGISTRESE:oREG_CANEMP:cToolTip:="Empresas"

  @ oREGISTRESE:oREG_CANEMP:nTop-08,oREGISTRESE:oREG_CANEMP:nLeft SAY "Empresas" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : REG_CANTRA
  // Uso   : Trabajadores
  //
  @ 4.6,15.0 GET oREGISTRESE:oREG_CANTRA  VAR oREGISTRESE:REG_CANTRA  PICTURE "9999";
                    WHEN (AccessField("DPREGISTRESE","REG_CANTRA",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                    FONT oFontG;
                    SIZE 16,10;
                  RIGHT SPINNER


    oREGISTRESE:oREG_CANTRA:cMsg    :="Trabajadores"
    oREGISTRESE:oREG_CANTRA:cToolTip:="Trabajadores"

  @ oREGISTRESE:oREG_CANTRA:nTop-08,oREGISTRESE:oREG_CANTRA:nLeft SAY "Trabajadores" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : REG_CANSUC
  // Uso   : Sucursales
  //
  @ 6.4,15.0 GET oREGISTRESE:oREG_CANSUC  VAR oREGISTRESE:REG_CANSUC  PICTURE "999";
                    WHEN (AccessField("DPREGISTRESE","REG_CANSUC",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                    FONT oFontG;
                    SIZE 12,10;
                  RIGHT SPINNER


    oREGISTRESE:oREG_CANSUC:cMsg    :="Sucursales"
    oREGISTRESE:oREG_CANSUC:cToolTip:="Sucursales"

  @ oREGISTRESE:oREG_CANSUC:nTop-08,oREGISTRESE:oREG_CANSUC:nLeft SAY "Sucursales" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris



  //
  // Campo : REG_CANUSU
  // Uso   : Cant. Usuarios
  //
  @ 11.8,1 GET oREGISTRESE:oREG_CANUSU  VAR oREGISTRESE:REG_CANUSU  PICTURE "9999";
                    WHEN (AccessField("DPREGISTRESE","REG_CANUSU",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                    FONT oFontG;
                    SIZE 16,10;
                  RIGHT SPINNER


    oREGISTRESE:oREG_CANUSU:cMsg    :="Reg. Ventas"
    oREGISTRESE:oREG_CANUSU:cToolTip:="Reg. Ventas"

  @ oREGISTRESE:oREG_CANUSU:nTop-08,oREGISTRESE:oREG_CANUSU:nLeft SAY "Usuarios" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : REG_CAFFAC
  // Uso   : Reg. Compras
  //
  @ 8.2,15.0 GET oREGISTRESE:oREG_CAFFAC  VAR oREGISTRESE:REG_CAFFAC  PICTURE "9999";
                    WHEN (AccessField("DPREGISTRESE","REG_CAFFAC",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                    FONT oFontG;
                    SIZE 16,10;
                  RIGHT SPINNER


    oREGISTRESE:oREG_CAFFAC:cMsg    :="Reg. Compras"
    oREGISTRESE:oREG_CAFFAC:cToolTip:="Reg. Compras"

  @ oREGISTRESE:oREG_CAFFAC:nTop-08,oREGISTRESE:oREG_CAFFAC:nLeft SAY "Reg. Compras" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : REG_CANPAG
  // Uso   : Reg. Pagos
  //
  @ 10.0,15.0 GET oREGISTRESE:oREG_CANPAG  VAR oREGISTRESE:REG_CANPAG  PICTURE "9999";
                    WHEN (AccessField("DPREGISTRESE","REG_CANPAG",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                    FONT oFontG;
                    SIZE 16,10;
                  RIGHT SPINNER


    oREGISTRESE:oREG_CANPAG:cMsg    :="Reg. Pagos"
    oREGISTRESE:oREG_CANPAG:cToolTip:="Reg. Pagos"

  @ oREGISTRESE:oREG_CANPAG:nTop-08,oREGISTRESE:oREG_CANPAG:nLeft SAY "Reg. Pagos" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : REG_CANFAV
  // Uso   : Reg. Ventas
  //
  @ 11.8,15.0 GET oREGISTRESE:oREG_CANFAV  VAR oREGISTRESE:REG_CANFAV  PICTURE "9999";
                    WHEN (AccessField("DPREGISTRESE","REG_CANFAV",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                    FONT oFontG;
                    SIZE 16,10;
                  RIGHT SPINNER


    oREGISTRESE:oREG_CANFAV:cMsg    :="Reg. Ventas"
    oREGISTRESE:oREG_CANFAV:cToolTip:="Reg. Ventas"

  @ oREGISTRESE:oREG_CANFAV:nTop-08,oREGISTRESE:oREG_CANFAV:nLeft SAY "Reg. Ventas" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris




  //
  // Campo : REG_IMPORT
  // Uso   : Importador
  //
  @ 1.0,29.0 CHECKBOX oREGISTRESE:oREG_IMPORT  VAR oREGISTRESE:REG_IMPORT  PROMPT ANSITOOEM("Importador");
                    WHEN (AccessField("DPREGISTRESE","REG_IMPORT",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 100,10;
                    SIZE 4,10

    oREGISTRESE:oREG_IMPORT:cMsg    :="Importador"
    oREGISTRESE:oREG_IMPORT:cToolTip:="Importador"


  //
  // Campo : REG_DISMAY
  // Uso   : Distribuidor Mayorista
  //
  @ 2.8,20.0 CHECKBOX oREGISTRESE:oREG_DISMAY  VAR oREGISTRESE:REG_DISMAY  PROMPT ANSITOOEM("Distribuidor Mayorista");
                    WHEN (AccessField("DPREGISTRESE","REG_DISMAY",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 172,10;
                    SIZE 4,10

    oREGISTRESE:oREG_DISMAY:cMsg    :="Distribuidor Mayorista"
    oREGISTRESE:oREG_DISMAY:cToolTip:="Distribuidor Mayorista"


  //
  // Campo : REG_FABRIC
  // Uso   : Fabricante
  //
  @ 4.6,20.0 CHECKBOX oREGISTRESE:oREG_FABRIC  VAR oREGISTRESE:REG_FABRIC  PROMPT ANSITOOEM("Fabricante");
                    WHEN (AccessField("DPREGISTRESE","REG_FABRIC",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 100,10;
                    SIZE 4,10

    oREGISTRESE:oREG_FABRIC:cMsg    :="Fabricante"
    oREGISTRESE:oREG_FABRIC:cToolTip:="Fabricante"


  //
  // Campo : REG_SERCON
  // Uso   : Presta Servicios Contables y Afines
  //
  @ 6.4,20.0 CHECKBOX oREGISTRESE:oREG_SERCON  VAR oREGISTRESE:REG_SERCON  PROMPT ANSITOOEM("Prestador de Servicios");
                    WHEN (AccessField("DPREGISTRESE","REG_SERCON",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 250,10;
                    SIZE 4,10

    oREGISTRESE:oREG_SERCON:cMsg    :="Presta Servicios Contables y Afines"
    oREGISTRESE:oREG_SERCON:cToolTip:="Presta Servicios Contables y Afines"


  //
  // Campo : REG_PROYEC
  // Uso   : Proyectos
  //
  @ 8.2,20.0 CHECKBOX oREGISTRESE:oREG_PROYEC  VAR oREGISTRESE:REG_PROYEC  PROMPT ANSITOOEM("Proyectos");
                    WHEN (AccessField("DPREGISTRESE","REG_PROYEC",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 94,10;
                    SIZE 4,10

    oREGISTRESE:oREG_PROYEC:cMsg    :="Proyectos"
    oREGISTRESE:oREG_PROYEC:cToolTip:="Proyectos"


  //
  // Campo : REG_DETAL
  // Uso   : Ventas al Detal
  //
  @ 10.0,20.0 CHECKBOX oREGISTRESE:oREG_DETAL   VAR oREGISTRESE:REG_DETAL   PROMPT ANSITOOEM("Ventas al Detal");
                    WHEN (AccessField("DPREGISTRESE","REG_DETAL",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 130,10;
                    SIZE 4,10

    oREGISTRESE:oREG_DETAL :cMsg    :="Ventas al Detal"
    oREGISTRESE:oREG_DETAL :cToolTip:="Ventas al Detal"


  //
  // Campo : REG_IMPFIS
  // Uso   : Impresora Fiscal
  //
  @ 11.8,20.0 CHECKBOX oREGISTRESE:oREG_IMPFIS  VAR oREGISTRESE:REG_IMPFIS  PROMPT ANSITOOEM("Impresora Fiscal");
                    WHEN (AccessField("DPREGISTRESE","REG_IMPFIS",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 136,10;
                    SIZE 4,10

    oREGISTRESE:oREG_IMPFIS:cMsg    :="Impresora Fiscal"
    oREGISTRESE:oREG_IMPFIS:cToolTip:="Impresora Fiscal"



  @ 13.6,20.0 GROUP oREGISTRESE:oGroup TO 18.6,25 PROMPT "Requerimientos";
                      FONT oFontG

  //
  // Campo : REG_REQPOS
  // Uso   : Punto de Venta
  //
  @ 1.0,34.0 CHECKBOX oREGISTRESE:oREG_REQPOS  VAR oREGISTRESE:REG_REQPOS  PROMPT ANSITOOEM("Punto de Venta");
                    WHEN (AccessField("DPREGISTRESE","REG_REQPOS",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 124,10;
                    SIZE 4,10

    oREGISTRESE:oREG_REQPOS:cMsg    :="Punto de Venta"
    oREGISTRESE:oREG_REQPOS:cToolTip:="Punto de Venta"


  //
  // Campo : REG_REQNOM
  // Uso   : Nómina
  //
  @ 2.8,20.0 CHECKBOX oREGISTRESE:oREG_REQNOM  VAR oREGISTRESE:REG_REQNOM  PROMPT ANSITOOEM("Nómina");
                    WHEN (AccessField("DPREGISTRESE","REG_REQNOM",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 76,10;
                    SIZE 4,10

    oREGISTRESE:oREG_REQNOM:cMsg    :="Nómina"
    oREGISTRESE:oREG_REQNOM:cToolTip:="Nómina"


  //
  // Campo : REG_REQMOV
  // Uso   : Consultas Moviles
  //
  @ 4.6,20.0 CHECKBOX oREGISTRESE:oREG_REQMOV  VAR oREGISTRESE:REG_REQMOV  PROMPT ANSITOOEM("Consultas Móviles [eManager]");
                    WHEN (AccessField("DPREGISTRESE","REG_REQMOV",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 142,10;
                    SIZE 4,10

    oREGISTRESE:oREG_REQMOV:cMsg    :="Consultas Moviles"
    oREGISTRESE:oREG_REQMOV:cToolTip:="Consultas Moviles"

  //
  // Campo : REG_REQEPE
  // Uso   : Acceso ePedidos
  //
  @ 4.6,20.0 CHECKBOX oREGISTRESE:oREG_REQEPE  VAR oREGISTRESE:REG_REQEPE  PROMPT ANSITOOEM("ePedidos Móviles");
                    WHEN (AccessField("DPREGISTRESE","REG_REQEPE",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 142,10;
                    SIZE 4,10

    oREGISTRESE:oREG_REQEPE:cMsg    :="Tomar Pedidos desde el Móvil"
    oREGISTRESE:oREG_REQEPE:cToolTip:="Tomar Pedidos desde el Móvil"

  //
  // Campo : REG_REQTRA
  // Uso   : Comunicación y Transferencia de Datos
  //
  @ 6.4,20.0 CHECKBOX oREGISTRESE:oREG_REQTRA  VAR oREGISTRESE:REG_REQTRA  PROMPT ANSITOOEM("Multi-Sucurales conectadas via Internet");
                    WHEN (AccessField("DPREGISTRESE","REG_REQTRA",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 262,10;
                    SIZE 4,10

    oREGISTRESE:oREG_REQTRA:cMsg    :="Comunicación y Transferencia de Datos"
    oREGISTRESE:oREG_REQTRA:cToolTip:="Comunicación y Transferencia de Datos"


  //
  // Campo : REG_REQBI
  // Uso   : Inteligencia de Negocios
  //
  @ 8.2,20.0 CHECKBOX oREGISTRESE:oREG_REQBI   VAR oREGISTRESE:REG_REQBI   PROMPT ANSITOOEM("Inteligencia de Negocios");
                    WHEN (AccessField("DPREGISTRESE","REG_REQBI",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 184,10;
                    SIZE 4,10

    oREGISTRESE:oREG_REQBI :cMsg    :="Inteligencia de Negocios"
    oREGISTRESE:oREG_REQBI :cToolTip:="Inteligencia de Negocios"


  //
  // Campo : REG_REQACT
  // Uso   : Activos
  //
  @ 10.0,20.0 CHECKBOX oREGISTRESE:oREG_REQACT  VAR oREGISTRESE:REG_REQACT  PROMPT ANSITOOEM("Activos");
                    WHEN (AccessField("DPREGISTRESE","REG_REQACT",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 82,10;
                    SIZE 4,10

    oREGISTRESE:oREG_REQACT:cMsg    :="Activos"
    oREGISTRESE:oREG_REQACT:cToolTip:="Activos"


  //
  // Campo : REG_REQCON
  // Uso   : Contabilidad
  //
  @ 11.8,20.0 CHECKBOX oREGISTRESE:oREG_REQCON  VAR oREGISTRESE:REG_REQCON  PROMPT ANSITOOEM("Contabilidad");
                    WHEN (AccessField("DPREGISTRESE","REG_REQCON",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 112,10;
                    SIZE 4,10

    oREGISTRESE:oREG_REQCON:cMsg    :="Contabilidad"
    oREGISTRESE:oREG_REQCON:cToolTip:="Contabilidad"


  //
  // Campo : REG_AXIFIS
  // Uso   : Ajuste Fiscal / DPJ-26
  //
  @ 1.0,34.0 CHECKBOX oREGISTRESE:oREG_AXIFIS  VAR oREGISTRESE:REG_AXIFIS  PROMPT ANSITOOEM("Ajuste Fiscal / DPJ-26");
                    WHEN (AccessField("DPREGISTRESE","REG_AXIFIS",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 172,10;
                    SIZE 4,10

  oREGISTRESE:oREG_AXIFIS:cMsg    :="Ajuste Fiscal / DPJ-26"
  oREGISTRESE:oREG_AXIFIS:cToolTip:="Ajuste Fiscal / DPJ-26"

  //
  // Campo : REG_REQNIF
  // Uso   : NIIF
  //
  @ 2.8,20.0 CHECKBOX oREGISTRESE:oREG_REQNIF  VAR oREGISTRESE:REG_REQNIF  PROMPT ANSITOOEM("Ajuste Financiero");
                    WHEN (AccessField("DPREGISTRESE","REG_REQNIF",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 64,10;
                    SIZE 4,10

    oREGISTRESE:oREG_REQNIF:cMsg    :="Ajuste Financiero"
    oREGISTRESE:oREG_REQNIF:cToolTip:="Ajuste Financiero"


 // Campo : REG_REQLCP
  // Uso   : "Ley de Costos y Precios (FIFO)"
  //
  @ 2.8,20.0 CHECKBOX oREGISTRESE:oREG_REQLCP  VAR oREGISTRESE:REG_REQLCP  PROMPT ANSITOOEM("Estructura de Costos");
                    WHEN (AccessField("DPREGISTRESE","REG_REQLCP",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 64,10;
                    SIZE 4,10

    oREGISTRESE:oREG_REQLCP:cMsg    :="Ley de Costos y Precios (FIFO)"
    oREGISTRESE:oREG_REQLCP:cToolTip:="Ley de Costos y Precios (FIFO)"

  //
  // Campo : REG_REQPRD
  // Uso   : Producción
  //
  @ 4.6,20.0 CHECKBOX oREGISTRESE:oREG_REQPRD  VAR oREGISTRESE:REG_REQPRD  PROMPT ANSITOOEM("Producción");
                    WHEN (AccessField("DPREGISTRESE","REG_REQPRD",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 100,10;
                    SIZE 4,10

    oREGISTRESE:oREG_REQPRD:cMsg    :="Producción"
    oREGISTRESE:oREG_REQPRD:cToolTip:="Producción"


  //
  // Campo : REG_REQGRP
  // Uso   : Generador de Reportes
  //
  @ 6.4,20.0 CHECKBOX oREGISTRESE:oREG_REQGRP  VAR oREGISTRESE:REG_REQGRP  PROMPT ANSITOOEM("Generador de Reportes");
                    WHEN (AccessField("DPREGISTRESE","REG_REQGRP",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 166,10;
                    SIZE 4,10

    oREGISTRESE:oREG_REQGRP:cMsg    :="Generador de Reportes"
    oREGISTRESE:oREG_REQGRP:cToolTip:="Generador de Reportes"


//
  // Campo : REG_REQAA
  // Uso   : Arquitectura Abierta
  //
  @ 8.2,20.0 CHECKBOX oREGISTRESE:oREG_REQAA   VAR oREGISTRESE:REG_REQAA   PROMPT ANSITOOEM("Arquitectura Abierta");
                    WHEN (AccessField("DPREGISTRESE","REG_REQAA",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 160,10;
                    SIZE 4,10

    oREGISTRESE:oREG_REQAA :cMsg    :="Arquitectura Abierta para realizar Personalizaciones"
    oREGISTRESE:oREG_REQAA :cToolTip:="Arquitectura Abierta para realizar Personalizaciones"

  //
  // Campo : REG_REQPFN
  // Uso   : Planificación Financiera
  //
  @ 8.2,20.0 CHECKBOX oREGISTRESE:oREG_REQPFN   VAR oREGISTRESE:REG_REQPFN   PROMPT ANSITOOEM("Planificación Financiera");
                    WHEN (AccessField("DPREGISTRESE","REG_REQPFN",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 160,10;
                    SIZE 4,10

    oREGISTRESE:oREG_REQAA :cMsg    :="Planificación Financiera"
    oREGISTRESE:oREG_REQAA :cToolTip:="Planificación Financiera"

  //
  // Campo : REG_REQGSC
  // Uso   : Gestion de Sociedades
  //
  @ 8.2,20.0 CHECKBOX oREGISTRESE:oREG_REQPFN   VAR oREGISTRESE:REG_REQGSC   PROMPT ANSITOOEM("Gestión de Sociedades");
                    WHEN (AccessField("DPREGISTRESE","REG_REQGSC",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 160,10;
                    SIZE 4,10

    oREGISTRESE:oREG_REQAA :cMsg    :="Gestión de Sociedades"
    oREGISTRESE:oREG_REQAA :cToolTip:="Gestion de Sociedades"


   oREGISTRESE:REG_MEMO:=ALLTRIM(oREGISTRESE:REG_MEMO)


  // Campo : REG_MEMO
  // Uso   : Comentarios
  //
  @ 10.0,20.0 GET oREGISTRESE:oREG_MEMO    VAR oREGISTRESE:REG_MEMO  ;
           MEMO SIZE 80,80;
      ON CHANGE 1=1;
                    WHEN (AccessField("DPREGISTRESE","REG_MEMO",oREGISTRESE:nOption);
                    .AND. oREGISTRESE:nOption!=0);
                    FONT oFontG;
                    SIZE 0,10

    oREGISTRESE:oREG_MEMO  :cMsg    :="Comentarios"
    oREGISTRESE:oREG_MEMO  :cToolTip:="Comentarios"

  @ oREGISTRESE:oREG_MEMO  :nTop-08,oREGISTRESE:oREG_MEMO  :nLeft SAY "Requerimientos que nos permita Asegurarte la Solución Adaptada a tu Actividad Económica y Modelo de Negocio." PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  @ 20,20 SAY "Estado" PIXEL SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris

  oREGISTRESE:Activate({||RViewDatBar()})


RETURN oREGISTRESE:lRegistrese

/*
// Valida que ya este Registrado el RIF
*/
FUNCTION VAL_REG_RIF(cRif,oForm)

   RETURN REG_GRABAR(.T.)

RETURN .T.

//oREGISTRESE
/*
// Barra de Botones
*/
FUNCTION RViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont
   LOCAL oDlg:=oREGISTRESE:oDlg

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   oREGISTRESE:oDlg:Move(85,0)

   IF oREGISTRESE:nOption=2


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XSALIR.BMP";
            ACTION (oREGISTRESE:Close())

     oBtn:cToolTip:="Salir"

   ELSE

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XSAVE.BMP";
            ACTION (REG_PRESAVE())

     oBtn:cToolTip:="Grabar"


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\SENIAT.BMP";
            ACTION oREGISTRESE:REG_VALRIF()

     oBtn:cToolTip:="Grabar"


     DEFINE BUTTON oBtn;
            OF oBar;
            FONT oFont;
            NOBORDER;
            FILENAME "BITMAPS\XCANCEL.BMP";
            ACTION (REG_CANCELAR())

     oBtn:cToolTip:="Cancelar"

   ENDIF

   oBar:SetColor(CLR_BLACK,oDp:nGris)
   AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

RETURN .T.

FUNCTION REG_VALRIF()
  LOCAL lOk:=.T.,cRif:=""

  oDp:aRif:={}

  oREGISTRESE:lValRif:=.F.

  IF ISDIGIT(oREGISTRESE:REG_RIF)
    oREGISTRESE:REG_RIF:=STRZERO(VAL(oREGISTRESE:REG_RIF),8)
    oREGISTRESE:oREG_RIF:VarPut(oREGISTRESE:REG_RIF,.T.)
  ENDIF

  // QUITAR ESPACIOS
  oREGISTRESE:REG_RIF:=PADR(STRTRAN(oREGISTRESE:REG_RIF," ",""),LEN(oREGISTRESE:REG_RIF))

  IF Empty(oREGISTRESE:REG_RIF)
     oREGISTRESE:oREG_RIF:MsgErr("Introduza RIF")
     RETURN .F.
  ENDIF

  oDp:cSeniatErr:=""

  MsgRun("Verificando RIF "+oREGISTRESE:REG_RIF,"Por Favor, Espere",;
         {|| lOk:=.T. })

//  MsgRun("Verificando RIF "+oREGISTRESE:REG_RIF,"Por Favor, Espere",;
//         {|| lOk:=EJECUTAR("VALRIFSENIAT",oREGISTRESE:REG_RIF,!ISDIGIT(cRif),ISDIGIT(cRif)) })

  lOk:=EJECUTAR("VALRIFSENIAT",oREGISTRESE:REG_RIF,!ISDIGIT(cRif),ISDIGIT(cRif))

  IF !lOk .AND. ISDIGIT(oREGISTRESE:REG_RIF)

    MsgRun("Verificando RIF "+oREGISTRESE:REG_RIF,"Por Favor, Espere",;
            {||lOk:=EJECUTAR("RIFVAUTODET",oREGISTRESE:REG_RIF,oREGISTRESE:oREG_RIF)})

  ENDIF

  oDp:lChkIpSeniat:=.F. // No revisar la Web

  IF lOk

     oREGISTRESE:REG_RIFVAL:=.T.
     oREGISTRESE:lValRif   :=.T. // Cuando se Modifica no es necesario Validarlo Nuevamente

     IF !Empty(oDp:aRif) .AND. !Empty(oDp:aRif[1])

       oREGISTRESE:oREG_NOMBRE:VARPUT( oDp:aRif[1] , .T. )

       oREGISTRESE:nRetIva :=oDp:aRif[2]
       oREGISTRESE:cPersona:=oDp:aRif[3]
       oREGISTRESE:cMemoRif:=oDp:aRif[4]

       // Contribuyente

     ENDIF

     IF !VAL_REG_RIF(oREGISTRESE:REG_RIF,oREGISTRESE)
        RETURN .F.
     ENDIF

  ELSE

     oREGISTRESE:REG_RIFVAL:=.F.

     oREGISTRESE:oREG_RIF:MsgErr("RIF "+ALLTRIM(oREGISTRESE:REG_RIF)+" no fué Validado",NIL)

  ENDIF

  oREGISTRESE:oREG_NOMBRE:ForWhen()
  oREGISTRESE:oREG_REPRES:ForWhen()

  IF EVAL(oREGISTRESE:oREG_REPRES:bWhen)
    DPFOCUS(oREGISTRESE:oREG_REPRES)
  ELSE
    DPFOCUS(oREGISTRESE:oREG_CIUDAD)
  ENDIF

RETURN .T.
// EOF
