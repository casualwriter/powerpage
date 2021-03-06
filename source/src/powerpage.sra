$PBExportHeader$powerpage.sra
$PBExportComments$Application Object
forward
global type powerpage from application
end type
global transaction sqlca
global dynamicdescriptionarea sqlda
global dynamicstagingarea sqlsa
global error error
global message message
end forward

global variables
u_application	gnv_app
end variables

global type powerpage from application
string appname = "powerpage"
end type
global powerpage powerpage

on powerpage.create
appname="powerpage"
message=create message
sqlca=create transaction
sqlda=create dynamicdescriptionarea
sqlsa=create dynamicstagingarea
error=create error
end on

on powerpage.destroy
destroy(sqlca)
destroy(sqlda)
destroy(sqlsa)
destroy(error)
destroy(message)
end on

event open;gnv_app.event ue_open( commandline )
end event

event close;gnv_app.event ue_close()
end event

event idle;gnv_app.event ue_idle()
end event

event systemerror;gnv_app.event ue_error()
end event

