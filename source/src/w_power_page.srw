$PBExportHeader$w_power_page.srw
$PBExportComments$main window of power page
forward
global type w_power_page from window
end type
type cb_btn5 from commandbutton within w_power_page
end type
type cb_btn4 from commandbutton within w_power_page
end type
type cb_run from commandbutton within w_power_page
end type
type st_input from multilineedit within w_power_page
end type
type st_console from multilineedit within w_power_page
end type
type ole_ie from u_web_browser within w_power_page
end type
type st_status from statictext within w_power_page
end type
type cb_btn2 from commandbutton within w_power_page
end type
type cb_btn1 from commandbutton within w_power_page
end type
type cb_btn3 from commandbutton within w_power_page
end type
type ole_hide from u_ole_browser within w_power_page
end type
end forward

global type w_power_page from window
integer width = 5070
integer height = 2680
boolean titlebar = true
boolean controlmenu = true
boolean minbox = true
boolean maxbox = true
boolean resizable = true
long backcolor = 67108864
boolean toolbarvisible = false
boolean center = true
event ue_button ( string as_text )
event type long ue_mode ( )
cb_btn5 cb_btn5
cb_btn4 cb_btn4
cb_run cb_run
st_input st_input
st_console st_console
ole_ie ole_ie
st_status st_status
cb_btn2 cb_btn2
cb_btn1 cb_btn1
cb_btn3 cb_btn3
ole_hide ole_hide
end type
global w_power_page w_power_page

type prototypes

end prototypes

type variables
string is_status, is_button, is_title, is_temp

time	 idt_now



end variables

event ue_button(string as_text);// special function for mini buttons
if upper(as_text)='MAX' then
	This.WindowState = Maximized!

// [A] about	
elseif upper(as_text)='A' then
	open(w_about)
	
// [B] go back
elseif upper(as_text)='B' then
	
	ole_ie.object.GoBack()

// [F] go forward
elseif upper(as_text)='F' then
	
	ole_ie.object.GoForward()

// [C] hide console if it is open	
elseif upper(as_text)='C' and st_console.visible then
	
	cb_run.visible = false
	st_input.visible = false
	st_console.visible = false
	triggerevent( 'resize' )

// [C] open console	
elseif upper(as_text)='C' then
	
	st_input.visible = true
	st_console.visible = true
	
	long i
	string ls_text = ''
	
	for i = 1 to gnv_app.ii_microcount
		ls_text += gnv_app.is_microhelp[i] + '~r~n'
	next

	st_console.text = ls_text
	triggerevent( 'resize' )
	st_input.setfocus()

// [E] Edit Source
elseif upper(as_text)='E' then
	
	//messagebox( string(ole_ie.object.LocationURL), 'path='+ string(ole_ie.object.path) )
	if left(ole_ie.object.LocationURL,8) = 'file:///' then
		run( profilestring(gnv_app.is_ini, 'browser', 'editor', 'notepad.exe') + ' ' + mid(ole_ie.object.LocationURL,9) )
	end if

// [P] Print preview
elseif upper(as_text)='P' then
	
	ole_ie.object.ExecWB( 7, 0 )
	
// [R] refresh
elseif upper(as_text)='R' then
	
	ole_ie.is_pb_protocol = 'none'
	ole_ie.object.navigate2( ole_ie.object.LocationURL )
	
// [W] Open in IE/Chrome
elseif upper(as_text)='W' then
	
	if keydown(keyControl!) then
		gnv_app.of_shellexecute( 'chrome.exe', ole_ie.object.LocationURL, '' )
	else
		gnv_app.of_shellexecute( 'iexplore.exe', ole_ie.object.LocationURL, '' )
	end if

// [T] testing
elseif upper(as_text)='T' then
	ole_ie.object.ExecWB( 6, 2 )
end if

end event

event type long ue_mode();
if pos(gnv_app.is_watch,'[mode]')>0 then messagebox( 'Process Mode='+gnv_app.is_app_mode, gnv_app.is_app_parm )

idt_now = now()

DO WHILE ole_ie.object.Busy  and secondsafter( idt_now, now() )<15
      Yield ()
LOOP


//=== [mode=print] print page  (setprinter not work!)
if gnv_app.is_app_mode = 'print' then
	/*
	if gnv_app.is_app_parm>' ' then 
		if PrintSetPrinter ( gnv_app.is_app_parm ) < 0 then
			messagebox( 'Error', 'Cannot set printer to ' + gnv_app.is_app_parm )
		end if
	end if	
	*/
	ole_ie.of_sleepms(gnv_app.ii_app_delay)
	ole_ie.object.ExecWB( 6, 2 )
	ole_ie.of_sleepms(gnv_app.ii_app_delay)
	return close(this)
end if

//=== [mode=save] save page to html file
long ll_file
string ls_html, ls_factory

if gnv_app.is_app_mode = 'save' then
	
	ole_ie.of_sleepms(gnv_app.ii_app_delay)
	
	ll_file = fileopen( gnv_app.is_app_parm, LineMode!, Write!, LockWrite!, Replace!, EncodingUTF8! )
	
	if ll_file<=0 then 
		messagebox( 'Error', 'cannot open temp file '+gnv_app.is_app_parm )
	else
		filewriteex( ll_file, ole_ie.of_get_html(gnv_app.is_app_select) )
		fileclose(ll_file)
	end if	
	
	return close(this)
end if

//=== [mode=pdf] save page as pdf file
if	gnv_app.is_app_mode = 'pdf' then
	ls_factory = profilestring(gnv_app.is_ini, 'system', 'pdf-factory', 'wkhtmltopdf.exe')
	
	if not fileexists(ls_factory) then
		messagebox( 'Error', 'Cannot found PDF factory '+ls_factory )
	else
		ole_ie.of_sleepms(gnv_app.ii_app_delay)
		
		ll_file = fileopen( gnv_app.is_temp_file+'.html', LineMode!, Write!, LockWrite!, Replace!, EncodingUTF8! )
	
		if ll_file<=0 then 
			messagebox( 'Error', 'cannot save to file '+gnv_app.is_temp_file+'.html' )
		else
			filewriteex( ll_file, ole_ie.of_get_html(gnv_app.is_app_select) )
			fileclose(ll_file)
		end if	
	
		ole_ie.of_run_wait( ls_factory +  '  ' + gnv_app.is_temp_file +'.html ' + gnv_app.is_app_parm, 0 )
		filedelete( gnv_app.is_temp_file+ +'.html' )
	end if
	
	return close(this)
end if


end event

on w_power_page.create
this.cb_btn5=create cb_btn5
this.cb_btn4=create cb_btn4
this.cb_run=create cb_run
this.st_input=create st_input
this.st_console=create st_console
this.ole_ie=create ole_ie
this.st_status=create st_status
this.cb_btn2=create cb_btn2
this.cb_btn1=create cb_btn1
this.cb_btn3=create cb_btn3
this.ole_hide=create ole_hide
this.Control[]={this.cb_btn5,&
this.cb_btn4,&
this.cb_run,&
this.st_input,&
this.st_console,&
this.ole_ie,&
this.st_status,&
this.cb_btn2,&
this.cb_btn1,&
this.cb_btn3,&
this.ole_hide}
end on

on w_power_page.destroy
destroy(this.cb_btn5)
destroy(this.cb_btn4)
destroy(this.cb_run)
destroy(this.st_input)
destroy(this.st_console)
destroy(this.ole_ie)
destroy(this.st_status)
destroy(this.cb_btn2)
destroy(this.cb_btn1)
destroy(this.cb_btn3)
destroy(this.ole_hide)
end on

event open;// icon
if profilestring(gnv_app.is_ini, 'browser', 'icon', '' ) > ' ' then
	this.icon = profilestring(gnv_app.is_ini, 'browser', 'icon', '' )
end if

// config browser based on ini.
if profilestring(gnv_app.is_ini, 'browser', 'silent', '' ) = 'yes' then 
	ole_ie.object.Silent = true
elseif profilestring(gnv_app.is_ini, 'browser', 'silent', '' ) = '1' then 
	ole_ie.object.Silent = true
else
	ole_ie.object.Silent = gnv_app.ib_silent
end if	

// title := html | file | {string}
is_title = profilestring(gnv_app.is_ini, 'browser', 'title', gnv_app.is_title )

if is_title<>'html' and is_title<>'file' then this.title = is_title
	
// status bar, button, color
is_status = profilestring(gnv_app.is_ini, 'browser', 'status', 'yes' )
is_button = left( profilestring(gnv_app.is_ini, 'browser', 'button', 'ABC' ), 5 )

if gnv_app.ib_fullscreen or is_status = 'hide' or is_status = 'no' then 
	st_status.visible = false
	cb_btn1.visible = false
	cb_btn2.visible = false
	cb_btn3.visible = false
	cb_btn4.visible = false
	cb_btn5.visible = false
else
	st_status.backcolor = long(profilestring(gnv_app.is_ini, 'browser', 'status.backcolor', '67108864' ))
	st_status.textcolor = long(profilestring(gnv_app.is_ini, 'browser', 'status.textcolor', '0' ))
	cb_btn1.visible = len(is_button)>4
	cb_btn2.visible = len(is_button)>3
	cb_btn3.visible = len(is_button)>2
	cb_btn4.visible = len(is_button)>1
	cb_btn5.visible = len(is_button)>0
	cb_btn1.text = mid( is_button, len(is_button)-4, 1 )
	cb_btn2.text = mid( is_button, len(is_button)-3, 1 )
	cb_btn3.text = mid( is_button, len(is_button)-2, 1 )
	cb_btn4.text = mid( is_button, len(is_button)-1, 1 )
	cb_btn5.text = mid( is_button, len(is_button), 1 )

end if

// position, size
string ls_xpos, ls_ypos, ls_width, ls_height

ls_xpos = profilestring(gnv_app.is_ini, 'browser', 'left', '0' )
ls_ypos = profilestring(gnv_app.is_ini, 'browser', 'top', '0' )
ls_width = profilestring(gnv_app.is_ini, 'browser', 'width', '0' )
ls_height = profilestring(gnv_app.is_ini, 'browser', 'height', '0' )

if ls_xpos>'0' then this.x = PixelsToUnits ( long(ls_xpos), XPixelsToUnits! )
if ls_ypos>'0' then this.y = PixelsToUnits ( long(ls_ypos), YPixelsToUnits! )
if ls_width>'0' then this.width = PixelsToUnits ( long(ls_width), XPixelsToUnits! )
if ls_height>'0' then this.height = PixelsToUnits ( long(ls_height), YPixelsToUnits! )

if ls_xpos>'0' or ls_ypos>'0' then this.center=false
if ls_width='0' and ls_height='0' then post event ue_button('max')

// go to url
ole_ie.object.navigate2( gnv_app.of_url_format(message.stringparm) )

gnv_app.of_microhelp( 'start page is ' + message.stringparm + ' from ' + GetCurrentDirectory ( ) )

end event

event resize;//  status / microhelp bar
st_status.y = this.height - 230
st_status.width = this.width - 60

// web browser
if st_status.visible then
	ole_ie.height = this.height - st_status.height - 130
else
	ole_ie.height = this.height - 100
end if

ole_ie.width = this.width - 60

// handle rgb button
cb_btn1.move( this.width - 480, st_status.y )
cb_btn2.move( this.width - 400, st_status.y )
cb_btn3.move( this.width - 320, st_status.y )
cb_btn4.move( this.width - 240, st_status.y )
cb_btn5.move( this.width - 160, st_status.y )

// handle console if visible
if st_console.visible then
	st_input.x = this.width - st_input.width - 80
	st_console.x = st_input.x
	st_console.width = st_input.width
	st_console.height = ole_ie.height - 140
	ole_ie.width = this.width - st_input.width - 80
	cb_run.visible = true
	cb_run.x  = this.width - 280
end if

end event

event key;// [CTRL+LeftArrow] [CTRL+RightArrow] to resize
if st_console.visible and keyflags = 2 then
	if keydown(KeyLeftArrow!) then
		st_input.width += 10
		triggerevent( 'resize' )
	elseif keydown(KeyRightArrow!) then
		st_input.width -= 10
		triggerevent( 'resize' )
	end if
end if

end event

event closequery;// allow close for special app mode
if gnv_app.is_app_mode='print' or gnv_app.is_app_mode='save' or gnv_app.is_app_mode='pdf' then
	return 0
end if

// call html.event onPageClose()
is_temp = string( ole_ie.object.document.script.onPageClose() )

// if return no/false, stop closing window
if is_temp = 'no' or is_temp = 'false' then
	
	return 1
	
// if NOT return 'yes/true', show as message for confirmation
elseif is_temp<> 'yes' and is_temp<>'true' and is_temp>' ' then
	
	if messagebox( gnv_app.is_name, is_temp, question!, yesno! ) = 2 then
		return 1
	end if
	
end if
		
end event

type cb_btn5 from commandbutton within w_power_page
integer x = 1934
integer y = 1216
integer width = 91
integer height = 84
integer taborder = 70
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "W"
end type

event clicked;parent.event ue_button(this.text)
end event

type cb_btn4 from commandbutton within w_power_page
integer x = 1815
integer y = 1212
integer width = 91
integer height = 84
integer taborder = 60
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "P"
end type

event clicked;parent.event ue_button(this.text)
end event

type cb_run from commandbutton within w_power_page
boolean visible = false
integer x = 4658
integer y = 52
integer width = 178
integer height = 96
integer taborder = 60
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Run"
boolean default = true
end type

event clicked;if not st_input.visible then return

if st_input.text = 'clear' or st_input.text = 'cls' then
	st_console.text = ''
	gnv_app.ii_microcount = 1
else
	ole_ie.object.document.script.pb.eval( st_input.text )
end if

st_input.setfocus()
end event

type st_input from multilineedit within w_power_page
boolean visible = false
integer x = 1632
integer y = 12
integer width = 2798
integer height = 100
integer taborder = 10
integer textsize = -11
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 8388736
long backcolor = 134217752
string text = "Expression"
boolean autohscroll = true
end type

event getfocus;this.SelectText ( 1, 999 )  
end event

type st_console from multilineedit within w_power_page
boolean visible = false
integer x = 1632
integer y = 124
integer width = 2999
integer height = 1020
integer taborder = 30
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 134217752
string text = "console"
boolean vscrollbar = true
boolean displayonly = true
borderstyle borderstyle = stylelowered!
end type

type ole_ie from u_web_browser within w_power_page
integer x = 5
integer width = 1614
integer height = 1152
integer taborder = 20
string binarykey = "w_power_page.win"
end type

event windowclosing;call super::windowclosing;cancel = true
close(parent)

end event

event statustextchange;call super::statustextchange;// show html status change
if is_status<>'noweb' then gnv_app.of_microhelp( '>> ' + text )

end event

event titlechange;call super::titlechange;if lower(left(text,5)) = 'pb://' or  lower(left(text,5)) = 'ps://' then return

if is_title='html' then parent.title = text
end event

event documentcomplete;call super::documentcomplete;if is_title='file' then parent.title = url

if pos( '[print][save][pdf][console]', '['+gnv_app.is_app_mode+']') > 0 then
	post event ue_mode()
end if

end event

event ue_pb_error;// spider command
string ls_parm, ls_url, ls_key

if left( as_command, 7 ) = 'spider/' then
	 ls_parm = mid( as_command, 8 )
	 ls_url = gnv_app.of_get_keyword( ls_parm, 'url', ';', '' )
	 ls_key = gnv_app.of_get_keyword( ls_parm, 'key', ';', '' )
	 
	 ole_hide.object.Silent = true
	 ole_hide.is_css_select = ls_key
	 ole_hide.is_pb_protocol = ''
	 ole_hide.object.navigate2( ls_url )
	 gnv_app.of_microhelp( 'crawling url:' + ls_url + ' for css:' + ls_key )
	 return
end if
	
//=== exceptional handle of pb:// protocol ===
messagebox( 'Warning', as_errorMsg+'~r~n~r~n'+as_command )

end event

type st_status from statictext within w_power_page
integer x = 9
integer y = 1212
integer width = 1486
integer height = 84
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Calibri"
long textcolor = 33554432
long backcolor = 134217750
string text = "none"
boolean focusrectangle = false
end type

event doubleclicked;/*
if this.height > 200 then
	st_status.y = parent.height - 230
	st_status.height = 80
	return
end if

if not keydown( keyControl! ) then return

// handle ctrl-doubleclick.
st_status.y = 120
st_status.height = parent.height - 250
	
long i
string ls_text = ''

for i = gnv_app.ii_microcount to 1 step -1
	ls_text += gnv_app.is_microhelp[i] + '~r~n'
next

st_status.text = ls_text
*/
end event

type cb_btn2 from commandbutton within w_power_page
integer x = 1600
integer y = 1212
integer width = 91
integer height = 84
integer taborder = 50
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "B"
end type

event clicked;parent.event ue_button(this.text)
end event

type cb_btn1 from commandbutton within w_power_page
integer x = 1509
integer y = 1212
integer width = 91
integer height = 84
integer taborder = 40
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "A"
end type

event clicked;parent.event ue_button(this.text)
end event

type cb_btn3 from commandbutton within w_power_page
integer x = 1687
integer y = 1212
integer width = 91
integer height = 84
integer taborder = 60
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "C"
end type

event clicked;parent.event ue_button(this.text)
end event

type ole_hide from u_ole_browser within w_power_page
integer x = 2149
integer y = 808
integer width = 1682
integer height = 1036
integer taborder = 80
string binarykey = "w_power_page.win"
integer binaryindex = 1
end type

event documentcomplete;call super::documentcomplete;string ls_result, ls_script, ls_ie

// watch
if pos( gnv_app.is_watch, '[ole]' )>0 then gnv_app.of_microhelp( 'hide.documentcomplete(), url='+url )

if this.object.LocationURL = is_pb_protocol then return

/*
//===== ole method, hard-code script + IE7 polyfill ======
ls_script = 'var __pb_spider__ = function(key) { ' + &
  + "  var i, text='aa', html='', links=[]; ~r~n " + &
  + "  var divs = document.querySelectorAll( (key||'body').replace(/\@/g,'#') ); ~r~n  " + &
  + "  for (i=0; i<divs.length; i++) {  text += divs[i].innerText + '\n';  html += divs[i].outerHTML + '\n'; ~r~n" + &
  + "  if (divs[i].nodeName=='A') links.push({ url:decodeURI(divs[i].href), text:divs[i].innerText, id:divs[i].id }); } ~r~n" + &    
  + "  return JSON.stringify( { url:location.href, title:document.title, text:text, html:html, links:links } )    } "

// use special inject js for IE7
long ll_file, ll_ie_ver
ll_ie_ver = long(this.object.document.documentMode)
if long(ll_ie_ver) < 9  then
	ll_file = fileopen( 'powerpage-ie7.js', TextMode!, Read! ) 
	if ll_file>0 then 
		filereadex( ll_file, ls_script )
		fileclose(ll_file)
	end if
	gnv_app.of_microhelp( 'load special script for IE' + string(ll_ie_ver) )
end if
*/

//=== cut crawler script from main script ===
ls_script = '__pb_spider__' + mid( gnv_app.is_page_script, pos( gnv_app.is_page_script, 'pb.crawl = function ' ) + 8 )
sleep(1)

// inject script for pb protocol 
TRY 
	
	is_pb_protocol = this.object.LocationURL
	gnv_app.of_microhelp( 'inject spider script for ' + this.object.LocationURL )
	this.object.document.script.eval( ls_script  )
	
	ls_result = this.object.document.script.__pb_spider__( is_css_select )
	//messagebox( 'return', ls_result)
	ole_ie.event ue_callback( ole_ie.is_callback, ls_result )
	gnv_app.of_microhelp( 'url: ' + is_pb_protocol + ' crawled.' )
	
CATCH (runtimeerror er)
	
   if pos(gnv_app.is_watch,'[warning]')>0  then 
		MessageBox("Warning@spider.documentcomplete="+string(er.number), er.GetMessage())
	else
		gnv_app.of_microhelp("[warning@spider] documentcomplete="+string(er.number)+': '+er.GetMessage() )
	end if	

END TRY

end event


Start of PowerBuilder Binary Data Section : Do NOT Edit
06w_power_page.bin 
2B00000a00e011cfd0e11ab1a1000000000000000000000000000000000003003e0009fffe000000060000000000000000000000010000000100000000000010000000000200000001fffffffe0000000000000000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdfffffffefffffffefffffffeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff006f00520074006f004500200074006e00790072000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050016ffffffffffffffff00000001000000000000000000000000000000000000000000000000000000002b02a48001d7cf9100000003000001800000000000500003004f0042005800430054005300450052004d0041000000000000000000000000000000000000000000000000000000000000000000000000000000000102001affffffff00000002ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000009c00000000004200500043004f00530058004f00540041005200450047000000000000000000000000000000000000000000000000000000000000000000000000000000000001001affffffffffffffff000000038856f96111d0340ac0006ba9a205d74f000000002b02a48001d7cf912b02a48001d7cf91000000000000000000000000004f00430054004e004e00450053005400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001020012ffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000030000009c000000000000000100000002fffffffe0000000400000005fffffffeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
29ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000004c0000247c00001dc40000000000000000000000000000000000000000000000000000004c0000000000000000000000010057d0e011cf3573000869ae62122e2b00000008000000000000004c0002140100000000000000c0460000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004c0000247c00001dc40000000000000000000000000000000000000000000000000000004c0000000000000000000000010057d0e011cf3573000869ae62122e2b00000008000000000000004c0002140100000000000000c046000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a00e011cfd0e11ab1a1000000000000000000000000000000000003003e0009fffe000000060000000000000000000000010000000100000000000010000000000200000001fffffffe0000000000000000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdfffffffefffffffefffffffeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff006f00520074006f004500200074006e00790072000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050016ffffffffffffffff00000001000000000000000000000000000000000000000000000000000000002b02a48001d7cf9100000003000001800000000000500003004f0042005800430054005300450052004d0041000000000000000000000000000000000000000000000000000000000000000000000000000000000102001affffffff00000002ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000009c00000000004200500043004f00530058004f00540041005200450047000000000000000000000000000000000000000000000000000000000000000000000000000000000001001affffffffffffffff000000038856f96111d0340ac0006ba9a205d74f000000002b02a48001d7cf912b02a48001d7cf91000000000000000000000000004f00430054004e004e004500530054
2E00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001020012ffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000030000009c000000000000000100000002fffffffe0000000400000005fffffffeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000004c0000260900001ac50000000000000000000000000000000000000000000000000000004c0000000000000000000000010057d0e011cf3573000869ae62122e2b00000008000000000000004c0002140100000000000000c0460000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004c0000260900001ac50000000000000000000000000000000000000000000000000000004c0000000000000000000000010057d0e011cf3573000869ae62122e2b00000008000000000000004c0002140100000000000000c04600000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
16w_power_page.bin 
End of PowerBuilder Binary Data Section : No Source Expected After This Point
