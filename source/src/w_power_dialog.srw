$PBExportHeader$w_power_dialog.srw
$PBExportComments$open web page in dialog (response window)
forward
global type w_power_dialog from window
end type
type ole_ie from u_web_browser within w_power_dialog
end type
end forward

global type w_power_dialog from window
integer x = 800
integer y = 600
integer width = 3881
integer height = 2364
boolean titlebar = true
string title = "PowerPage"
boolean controlmenu = true
windowtype windowtype = response!
long backcolor = 67108864
boolean toolbarvisible = false
boolean center = true
event ue_mode ( )
ole_ie ole_ie
end type
global w_power_dialog w_power_dialog

type prototypes

end prototypes

type variables
string is_delim, is_mode, is_key, is_return
long ii_delay = 1
end variables

event ue_mode();// print now
if is_mode='print' then
	sleep(ii_delay)			
	ole_ie.object.ExecWB( 6, 2 )
	return	
end if

// print preview
if is_mode='preview' then
	sleep(ii_delay)			
	ole_ie.object.ExecWB( 7, 0 )
	return
end if

// mode=crawl, capture html and return
if is_mode='crawl' then
	sleep(ii_delay)			
	closewithreturn( this, string( ole_ie.object.document.script.pb.crawl(is_key) ) )
	return
end if

// mode=crawl2pdf, capture html, save to pdf-file and return
if is_mode='crawl2pdf' then
	messagebox( 'crawl2pdf - not ready', string( ole_ie.object.document.script.pb.crawl(is_key) ) )	
end if

// mode=crawl2pdf, capture html, save to pdf-file and return
if is_mode='crawl2html' then
	messagebox( 'crawl2html - not ready', string( ole_ie.object.document.script.pb.crawl(is_key) ) )	
end if


end event

on w_power_dialog.create
this.ole_ie=create ole_ie
this.Control[]={this.ole_ie}
end on

on w_power_dialog.destroy
destroy(this.ole_ie)
end on

event open;//# Open web page in dialog, for multiple purpose
//#
//#  1. Preview PDF if parameter = gnv_app.is_temp_file+'.pdf'
//#  2. Open url by parameter "delim=,mode=?,top=?,left=?,wisth=?,height=?,url=?,div=?,delay=?,slient=?"
//#
//#  3. mode=print     => load html page, delay and print
//#  4. mode=preview => load html page, delay and preview
//#  5. mode=spider   => load html page, delay and capture html, close+return JSON
//#=========================================================

string ls_silent, ls_xpos, ls_ypos, ls_width, ls_height, ls_url, ls_text
long ll_file

if pos(gnv_app.is_watch,'[cmd]')>0 then gnv_app.of_microhelp( 'w_power_dialog: ' + message.stringparm)

// get delimeter (default=,)
if left(message.stringparm,6)='delim=' then
	is_delim = mid(message.stringparm,7,1)
else
	is_delim = ','
end if

// get some options
is_mode = gnv_app.of_get_keyword( message.stringparm, 'mode', is_delim, is_mode )
is_key = gnv_app.of_get_keyword( message.stringparm, 'key', is_delim, '' )
ii_delay = long(gnv_app.of_get_keyword( message.stringparm, 'delay', is_delim, '1') )

// position, size
ls_xpos = gnv_app.of_get_keyword( message.stringparm, 'left', is_delim, '' )
ls_ypos = gnv_app.of_get_keyword( message.stringparm, 'top', is_delim, '' ) 
ls_width = gnv_app.of_get_keyword( message.stringparm, 'width', is_delim, '' )
ls_height = gnv_app.of_get_keyword( message.stringparm, 'height', is_delim, '' )

if ls_xpos>' ' or ls_ypos>' ' then this.center=false

if ls_xpos>' ' then this.x = PixelsToUnits ( long(ls_xpos), XPixelsToUnits! )
if ls_ypos>' ' then this.y = PixelsToUnits ( long(ls_ypos), YPixelsToUnits! )
if ls_width>' ' then this.width = PixelsToUnits ( long(ls_width), XPixelsToUnits! )
if ls_height>' ' then this.height = PixelsToUnits ( long(ls_height), YPixelsToUnits! )

// silent
ls_silent = profilestring(gnv_app.is_ini, 'browser', 'silent', '' ) 
ls_silent = gnv_app.of_get_keyword( message.stringparm, 'silent', is_delim, ls_silent )
ole_ie.object.Silent = (ls_silent = 'yes' or ls_silent='1')

// go to url
if pos( message.stringparm, 'url=' ) > 0 then
	ls_url = gnv_app.of_get_keyword( message.stringparm, 'url', is_delim, '' )
else
	ls_url = trim(message.stringparm)
end if

ls_url = gnv_app.of_url_format( ls_url )

if pos(gnv_app.is_watch,'[cmd]')>0 then gnv_app.of_microhelp( 'mode='+is_mode+', url=' + ls_url)

ole_ie.object.navigate2( ls_url )



end event

event resize;ole_ie.height = this.height - 100
ole_ie.width = this.width - 60


end event

event close;if fileexists(gnv_app.is_temp_file+'.pdf') then 
	filedelete( gnv_app.is_temp_file+'.html' )
	filedelete( gnv_app.is_temp_file+'.pdf' )
end if

end event

type ole_ie from u_web_browser within w_power_dialog
integer x = 9
integer y = 8
integer width = 1614
integer height = 1152
integer taborder = 10
string binarykey = "w_power_dialog.win"
end type

event windowclosing;call super::windowclosing;cancel = true
close(parent)

end event

event titlechange;call super::titlechange;if message.stringparm = gnv_app.is_temp_file+'.pdf' then
	parent.title = 'Preview PDF'
else
	parent.title = text
end if
end event

event documentcomplete;call super::documentcomplete;gnv_app.of_microhelp( 'documentcompleted')
parent.post event ue_mode()


end event


Start of PowerBuilder Binary Data Section : Do NOT Edit
09w_power_dialog.bin 
2D00000a00e011cfd0e11ab1a1000000000000000000000000000000000003003e0009fffe000000060000000000000000000000010000000100000000000010000000000200000001fffffffe0000000000000000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdfffffffefffffffefffffffeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff006f00520074006f004500200074006e00790072000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050016ffffffffffffffff00000001000000000000000000000000000000000000000000000000000000002bde80c001d7732700000003000001800000000000500003004f0042005800430054005300450052004d0041000000000000000000000000000000000000000000000000000000000000000000000000000000000102001affffffff00000002ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000009c00000000004200500043004f00530058004f00540041005200450047000000000000000000000000000000000000000000000000000000000000000000000000000000000001001affffffffffffffff000000038856f96111d0340ac0006ba9a205d74f000000002bde80c001d773272bde80c001d77327000000000000000000000000004f00430054004e004e00450053005400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001020012ffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000030000009c000000000000000100000002fffffffe0000000400000005fffffffeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
28ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000004c0000247c00001dc40000000000000000000000000000000000000000000000000000004c0000000000000000000000010057d0e011cf3573000869ae62122e2b00000008000000000000004c0002140100000000000000c0460000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004c0000247c00001dc40000000000000000000000000000000000000000000000000000004c0000000000000000000000010057d0e011cf3573000869ae62122e2b00000008000000000000004c0002140100000000000000c0460000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
19w_power_dialog.bin 
End of PowerBuilder Binary Data Section : No Source Expected After This Point
