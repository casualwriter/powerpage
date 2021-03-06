$PBExportHeader$w_about.srw
$PBExportComments$about powerpage
forward
global type w_about from window
end type
type st_about from statictext within w_about
end type
type cb_home from commandbutton within w_about
end type
type st_credit from statictext within w_about
end type
type cb_github from commandbutton within w_about
end type
type cb_1 from commandbutton within w_about
end type
type st_version from statictext within w_about
end type
type st_1 from statictext within w_about
end type
type sle_psw from singlelineedit within w_about
end type
end forward

global type w_about from window
integer width = 2267
integer height = 1228
boolean titlebar = true
string title = "PowerPage"
boolean controlmenu = true
windowtype windowtype = response!
long backcolor = 67108864
string icon = "AppIcon!"
boolean center = true
st_about st_about
cb_home cb_home
st_credit st_credit
cb_github cb_github
cb_1 cb_1
st_version st_version
st_1 st_1
sle_psw sle_psw
end type
global w_about w_about

on w_about.create
this.st_about=create st_about
this.cb_home=create cb_home
this.st_credit=create st_credit
this.cb_github=create cb_github
this.cb_1=create cb_1
this.st_version=create st_version
this.st_1=create st_1
this.sle_psw=create sle_psw
this.Control[]={this.st_about,&
this.cb_home,&
this.st_credit,&
this.cb_github,&
this.cb_1,&
this.st_version,&
this.st_1,&
this.sle_psw}
end on

on w_about.destroy
destroy(this.st_about)
destroy(this.cb_home)
destroy(this.st_credit)
destroy(this.cb_github)
destroy(this.cb_1)
destroy(this.st_version)
destroy(this.st_1)
destroy(this.sle_psw)
end on

event open;this.title = gnv_app.is_title

st_version.text = gnv_app.is_version
st_credit.text = gnv_app.is_credit
st_about.text = gnv_app.is_about

end event

type st_about from statictext within w_about
integer x = 64
integer y = 304
integer width = 2153
integer height = 288
integer textsize = -14
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Calibri"
long textcolor = 8388608
long backcolor = 67108864
boolean focusrectangle = false
end type

event doubleclicked;if keydown( KeyControl! ) then
	sle_psw.visible = true
	this.text = 'Please input your db login id / password (for encryption): '
end if
end event

type cb_home from commandbutton within w_about
integer x = 123
integer y = 940
integer width = 393
integer height = 128
integer taborder = 30
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "HomePage"
end type

event clicked;gnv_app.of_shellrun(gnv_app.is_home)
end event

type st_credit from statictext within w_about
integer x = 151
integer y = 760
integer width = 1915
integer height = 84
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 8388736
long backcolor = 67108864
boolean enabled = false
string text = "Copyright 2021"
alignment alignment = center!
boolean focusrectangle = false
end type

type cb_github from commandbutton within w_about
integer x = 608
integer y = 940
integer width = 393
integer height = 128
integer taborder = 20
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Github"
end type

event clicked;gnv_app.of_shellrun( gnv_app.is_home )

end event

type cb_1 from commandbutton within w_about
integer x = 1691
integer y = 940
integer width = 393
integer height = 128
integer taborder = 10
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "&Close"
end type

event clicked;close(parent)
end event

type st_version from statictext within w_about
integer x = 151
integer y = 640
integer width = 1915
integer height = 84
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 8388736
long backcolor = 67108864
boolean enabled = false
string text = "Version: 0.50, build: 20210428"
alignment alignment = center!
boolean focusrectangle = false
end type

type st_1 from statictext within w_about
integer x = 64
integer y = 16
integer width = 2153
integer height = 300
integer textsize = -14
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Calibri"
long textcolor = 8388736
long backcolor = 67108864
boolean enabled = false
string text = "Powerpage is a lightweight web browser with DB capability and windows accessibility, for rapid development of javascript application."
boolean focusrectangle = false
end type

type sle_psw from singlelineedit within w_about
boolean visible = false
integer x = 64
integer y = 512
integer width = 2158
integer height = 96
integer taborder = 10
boolean bringtotop = true
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
string text = "Log Password / Log ID / DB Parm  "
borderstyle borderstyle = stylelowered!
end type

event modified;clipboard( 'logPass=@' + gnv_app.of_encryption(this.text) )
st_about.text = 'Encryption key [' +this.text + '] has been generated to clipboard.~r~n' + clipboard()

end event

