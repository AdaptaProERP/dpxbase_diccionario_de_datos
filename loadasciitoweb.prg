// Programa   : LOADASCIITOWEB
// Fecha/Hora : 15/12/2024 06:25:20
// Propósito  : Carga Conversión de Acentos hacia WEB
// https://thebigwebdeveloper.blogspot.com/2015/10/html5-usar-acentos-y-caracteres-especiales-en-una-pagina-web.html
// Creado Por : Juan Navas 
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
  LOCAL aLine:={}

//  AADD(aLine,{192,"&Agrave"}) //?,letra may?scula latina A con acento grave
  // á
  AADD(aLine,{224,"&agrave"}) //?,letra min?scula latina a con acento grave
  AADD(aLine,{224,"&agrave"}) //?,letra min?scula latina a con acento grave
  AADD(aLine,{225,"&aacute"}) //?,letra min?scula latina a con acento agudo
  AADD(aLine,{226,"&acirc"}) //?,letra min?scula latina a con acento circunflejo
  AADD(aLine,{227,"&atilde"}) //?,letra min?scula latina a con tilde

  AADD(aLine,{193,"&Aacute"}) //?,letra may?scula latina A con acento agudo
  AADD(aLine,{194,"&Acirc"}) //?,letra may?scula latina A con acento circunflejo
  AADD(aLine,{195,"&Atilde"}) //?,letra may?scula latina A con tilde
  AADD(aLine,{196,"&Auml"}) //?,letra may?scula latina A con di?resis


  // é
  AADD(aLine,{232,"&egrave"}) //?,letra min?scula latina e con acento grave
  AADD(aLine,{233,"&eacute"}) //?,letra min?scula latina e con acento agudo
  AADD(aLine,{234,"&ecirc"}) //?,letra min?scula latina e con acento circunflejo
  AADD(aLine,{235,"&euml"}) //?,letra min?scula latina e con di?resis
  AADD(aLine,{200,"&Egrave"}) //?,letra may?scula latina E con acento grave
  AADD(aLine,{201,"&Eacute"}) //?,letra may?scula latina E con acento agudo
  AADD(aLine,{202,"&Ecirc"}) //?,letra may?scula latina E con acento circunflejo
  AADD(aLine,{203,"&Euml"}) //?,letra may?scula latina E con di?resis


  // í
  AADD(aLine,{236,"&igrave"}) //?,letra min?scula latina i con acento grave
  AADD(aLine,{237,"&iacute"}) //?,letra min?scula latina i con acento agudo
  AADD(aLine,{238,"&icirc"}) //?,letra min?scula latina i con acento circunflejo
  AADD(aLine,{239,"&iuml"}) //?,letra min?scula latina i con di?resis

  // ó
  AADD(aLine,{242,"&ograve"}) //?,letra min?scula latina o con acento grave
  AADD(aLine,{243,"&oacute"}) //?,letra min?scula latina o con acento agudo
  AADD(aLine,{244,"&ocirc"}) //?,letra min?scula latina o con acento circunflejo
  AADD(aLine,{245,"&otilde"}) //?,letra min?scula latina o con tilde
  AADD(aLine,{246,"&ouml"}) //?,letra min?scula latina o con di?resis

  AADD(aLine,{210,"&Ograve"}) //?,letra may?scula latina O con acento grave
  AADD(aLine,{211,"&Oacute"}) //?,letra may?scula latina O con acento agudo
  AADD(aLine,{212,"&Ocirc"}) //?,letra may?scula latina O con acento circunflejo
  AADD(aLine,{213,"&Otilde"}) //?,letra may?scula latina O con tilde
  AADD(aLine,{214,"&Ouml"}) //?,letra may?scula latina O con di?resis


  // ú
  AADD(aLine,{249,"&ugrave"}) //?,letra min?scula latina u con acento grave
  AADD(aLine,{250,"&uacute"}) //?,letra min?scula latina u con acento agudo
  AADD(aLine,{251,"&ucirc"}) //?,letra min?scula latina u con acento circunflejo
  AADD(aLine,{252,"&uuml"}) //?,letra min?scula latina u con di?resis

  // Ñ
  AADD(aLine,{ASC("Ñ"),"&#209"}) 
  AADD(aLine,{ASC("ñ"),"&#241"})

  AADD(aLine,{186,"&ordm"})
  AADD(aLine,{35 ,"&#35"})
  AADD(aLine,{176,"&deg"})






/*
  AADD(aLine,{193,"&Aacute"}) //?,letra may?scula latina A con acento agudo
  AADD(aLine,{194,"&Acirc"}) //?,letra may?scula latina A con acento circunflejo
  AADD(aLine,{195,"&Atilde"}) //?,letra may?scula latina A con tilde
  AADD(aLine,{196,"&Auml"}) //?,letra may?scula latina A con di?resis
  AADD(aLine,{200,"&Egrave"}) //?,letra may?scula latina E con acento grave
  AADD(aLine,{201,"&Eacute"}) //?,letra may?scula latina E con acento agudo
  AADD(aLine,{202,"&Ecirc"}) //?,letra may?scula latina E con acento circunflejo
  AADD(aLine,{203,"&Euml"}) //?,letra may?scula latina E con di?resis
  AADD(aLine,{204,"&Igrave"}) //?,letra may?scula latina I con acento grave
  AADD(aLine,{205,"&Iacute"}) //?,letra may?scula latina I con acento agudo
  AADD(aLine,{206,"&Icirc"}) //?,letra may?scula latina I con acento circunflejo
  AADD(aLine,{207,"&Iuml"}) //?,letra may?scula latina I con di?resis
  AADD(aLine,{210,"&Ograve"}) //?,letra may?scula latina O con acento grave
  AADD(aLine,{211,"&Oacute"}) //?,letra may?scula latina O con acento agudo
  AADD(aLine,{212,"&Ocirc"}) //?,letra may?scula latina O con acento circunflejo
  AADD(aLine,{213,"&Otilde"}) //?,letra may?scula latina O con tilde
  AADD(aLine,{214,"&Ouml"}) //?,letra may?scula latina O con di?resis
  AADD(aLine,{217,"&Ugrave"}) //?,letra may?scula latina U con acento grave
  AADD(aLine,{218,"&Uacute"}) //?,letra may?scula latina U con acento agudo
  AADD(aLine,{219,"&Ucirc"}) //?,letra may?scula latina U con acento circunflejo
  AADD(aLine,{220,"&Uuml"}) //?,letra may?scula latina U con di?resis
  AADD(aLine,{352,"&Scaron"}) //?,letra may?scula latina S con anti circunflejo
  AADD(aLine,{221,"&Yacute"}) //?,letra may?scula latina Y con acento agudo
  AADD(aLine,{376,"&Yuml"}) //?,letra may?scula latina Y con di?resis
  AADD(aLine,{224,"&agrave"}) //?,letra min?scula latina a con acento grave
  AADD(aLine,{225,"&aacute"}) //?,letra min?scula latina a con acento agudo
  AADD(aLine,{226,"&acirc"}) //?,letra min?scula latina a con acento circunflejo
  AADD(aLine,{227,"&atilde"}) //?,letra min?scula latina a con tilde
  AADD(aLine,{228,"&auml"}) //?,letra min?scula latina a con di?resis
  AADD(aLine,{232,"&egrave"}) //?,letra min?scula latina e con acento grave
  AADD(aLine,{233,"&eacute"}) //?,letra min?scula latina e con acento agudo
  AADD(aLine,{234,"&ecirc"}) //?,letra min?scula latina e con acento circunflejo
  AADD(aLine,{235,"&euml"}) //?,letra min?scula latina e con di?resis
  AADD(aLine,{236,"&igrave"}) //?,letra min?scula latina i con acento grave
  AADD(aLine,{237,"&iacute"}) //?,letra min?scula latina i con acento agudo
  AADD(aLine,{238,"&icirc"}) //?,letra min?scula latina i con acento circunflejo
  AADD(aLine,{239,"&iuml"}) //?,letra min?scula latina i con di?resis
  AADD(aLine,{242,"&ograve"}) //?,letra min?scula latina o con acento grave
  AADD(aLine,{243,"&oacute"}) //?,letra min?scula latina o con acento agudo
  AADD(aLine,{244,"&ocirc"}) //?,letra min?scula latina o con acento circunflejo
  AADD(aLine,{245,"&otilde"}) //?,letra min?scula latina o con tilde
  AADD(aLine,{246,"&ouml"}) //?,letra min?scula latina o con di?resis
  AADD(aLine,{249,"&ugrave"}) //?,letra min?scula latina u con acento grave
  AADD(aLine,{250,"&uacute"}) //?,letra min?scula latina u con acento agudo
  AADD(aLine,{251,"&ucirc"}) //?,letra min?scula latina u con acento circunflejo
  AADD(aLine,{252,"&uuml"}) //?,letra min?scula latina u con di?resis
  AADD(aLine,{353,"&scaron"}) //?,letra min?scula latina S con anti circunflejo
  AADD(aLine,{253,"&yacute"}) //?,letra min?scula latina y con acento agudo
  AADD(aLine,{255,"&yuml"}) //?,letra min?scula latina y con di?resis
*/
RETURN aLine
// EOF
