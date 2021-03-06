$PBExportHeader$u_web_browser.sru
$PBExportComments$ancestor of web browser control
forward
global type u_web_browser from olecustomcontrol
end type
end forward

global type u_web_browser from olecustomcontrol
integer width = 1719
integer height = 924
borderstyle borderstyle = stylelowered!
boolean focusrectangle = false
string binarykey = "u_web_browser.udo"
integer textsize = -12
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
alignment alignment = center!
event statustextchange ( string text )
event progresschange ( long progress,  long progressmax )
event commandstatechange ( long command,  boolean enable )
event downloadbegin ( )
event downloadcomplete ( )
event titlechange ( string text )
event propertychange ( string szproperty )
event beforenavigate2 ( oleobject pdisp,  any url,  any flags,  any targetframename,  any postdata,  any headers,  ref boolean cancel )
event newwindow2 ( ref oleobject ppdisp,  ref boolean cancel )
event navigatecomplete2 ( oleobject pdisp,  any url )
event documentcomplete ( oleobject pdisp,  any url )
event onquit ( )
event onvisible ( boolean ocx_visible )
event ontoolbar ( boolean toolbar )
event onmenubar ( boolean menubar )
event onstatusbar ( boolean statusbar )
event onfullscreen ( boolean fullscreen )
event ontheatermode ( boolean theatermode )
event windowsetresizable ( boolean resizable )
event windowsetleft ( long left )
event windowsettop ( long top )
event windowsetwidth ( long ocx_width )
event windowsetheight ( long ocx_height )
event windowclosing ( boolean ischildwindow,  ref boolean cancel )
event clienttohostwindow ( ref long cx,  ref long cy )
event setsecurelockicon ( long securelockicon )
event filedownload ( ref boolean cancel )
event navigateerror ( oleobject pdisp,  any url,  any frame,  any statuscode,  ref boolean ole_cancel )
event printtemplateinstantiation ( oleobject pdisp )
event printtemplateteardown ( oleobject pdisp )
event updatepagestatus ( oleobject pdisp,  any npage,  any fdone )
event privacyimpactedstatechange ( boolean bimpacted )
event type string ue_callback ( string as_callback,  string as_result )
event type string ue_pb_protocol ( string as_command,  string as_callback )
event ue_pb_error ( string as_errormsg,  string as_command )
event type string ue_pb_file ( string as_action,  string as_parm )
end type
global u_web_browser u_web_browser

type prototypes
FUNCTION boolean SetForegroundWindow( long hWnd ) LIBRARY "USER32"

FUNCTION long ShellExecute (long hwnd, string lpOperation, string lpFile, string lpParameters,  string lpDirectory, integer nShowCmd ) LIBRARY "shell32" ALIAS FOR ShellExecuteW



end prototypes

type variables
OleObject  iole_wsh

string is_type, is_command, is_callback, is_action
string is_pb_protocol, is_inject_code

long ii_connect, ii_timeout = 15




end variables

forward prototypes
public function string of_default (string as_str, string as_def)
public function string of_sql_to_json (string as_sql)
public function string of_get_string (string as_text)
public function string of_replaceall (string csource, string cold, string cnew)
public function boolean of_connectdb (integer ai_retry)
public function string of_sql_execute (string as_sql)
public function string of_sql_to_table (string as_sql)
public function integer of_new_browser (string as_url, string as_ppty)
public function string of_get_keyword (string as_text, string as_key, string as_delim, string as_default)
public function string of_gettoken (ref string as_parm, string as_token)
public function integer of_sendkeys (string as_keys)
public function integer of_sleepms (integer ai_ms)
public function integer of_wsh_run (string as_run, integer ai_opt, boolean ab_wait)
public function integer of_run_wait (string as_run, integer ai_opt)
public function string of_js_string (string as_str)
public function string of_get_html (string as_selector)
end prototypes

event titlechange(string text);//# handle interface via title change
//#===========================================
if pos( gnv_app.is_watch, '[ole]' )>0 then gnv_app.of_microhelp( 'ole.titlechange(), text='+text )

// return if not pb command
if lower(left(text,5))<>'pb://' and lower(left(text,5))<>'ps://' then return


string ls_callback, ls_command, ls_next

/*
// ps: should be post event, wait till browser document settled. 
time ldt_now
ldt_now = now()
DO WHILE this.object.Busy and secondsafter( ldt_now, now() ) < ii_timeout
      Yield ()
LOOP

//text = this.object.document.script.decodeURI(text)
*/

// handle ps:// security mode
if lower(left(text,5)) = 'ps://' and trim(gnv_app.is_login_user) = '' then
	open(w_login)
	if trim(gnv_app.is_login_user) = '' then 
		return
	end if
	gnv_app.of_microhelp( 'window user login. id=' + gnv_app.is_login_user )
end if

// handle microhelp
if lower(left(text,14)) = 'pb://microhelp' then
	gnv_app.of_microhelp( gnv_app.of_replaceall( mid( text, 16 ), '|n', '~r~n' ) )
	return
end if

if pos(gnv_app.is_watch,'[cmd]')>0 then gnv_app.of_microhelp( 'cmd=' + text )

// handle prompt message
if mid(text,4,4) = '///?' and pos(text,'?/',7) > 0 then	
	if messagebox( 'Confirmation', mid( text, 8, pos(text,'?/',7) - 7 ), Question!, YesNo! ) <> 1 then 
		return
	else
		text = left(text,5) + mid( text, pos(text,'?/',7) + 2 )
	end if
end if

// for pb://protocol, handle callback first
if lower(mid(text,4,11)) = '//callback/' then
	ls_callback   = mid( text, 15, pos(text, '/', 16) - 15 )
	ls_command = mid( text,  pos(text, '/', 16) + 1 )
else
	ls_callback   = ''
	ls_command = mid( text,  6 )
end if

// handle multiple commands
if pos( ls_command, ';pb://' ) > 0 then
	ls_next = mid( ls_command, pos( ls_command, ';pb://' )  +1 )
	ls_command = left( ls_command, pos( ls_command, ';pb://' )  -1 )
	post event titlechange( ls_next )
end if

// call event to handle pb://protocol command
post event ue_pb_protocol( ls_command, ls_callback )




end event

event beforenavigate2(oleobject pdisp, any url, any flags, any targetframename, any postdata, any headers, ref boolean cancel);if pos( gnv_app.is_watch, '[ole]' )>0 then gnv_app.of_microhelp( 'ole.beforenavigate2(), targetframe='+string(targetframename)+', url='+url )
end event

event navigatecomplete2(oleobject pdisp, any url);if pos( gnv_app.is_watch, '[ole]' )>0 then gnv_app.of_microhelp( 'ole.navigatecomplete2(), url='+url )
end event

event documentcomplete(oleobject pdisp, any url);// watch
if pos( gnv_app.is_watch, '[ole]' )>0 then gnv_app.of_microhelp( 'ole.documentcomplete(), url='+url )

// skip for pdf, or no script, or current URL has been initialized.
if right(lower(url),4) = '.pdf' then return
if isnull(gnv_app.is_page_script) or trim(gnv_app.is_page_script)=''  then return
if this.object.LocationURL = is_pb_protocol then return
	
// inject script for pb protocol 
TRY 
	is_pb_protocol = this.object.LocationURL
	gnv_app.of_microhelp( 'initialize pb protocol for ' + is_pb_protocol )
	this.object.document.script.eval( gnv_app.is_page_script  )	

	// initial pb.session object
	long i
	for i=1 to gnv_app.ii_var_count
		this.object.document.script.pb.session( gnv_app.is_var_name[i], gnv_app.is_var_value[i], 'host' )
	next
	
	this.object.document.script.pb.session( 'gv_hostname', gnv_app.is_hostname, 'host' )
	this.object.document.script.pb.session( 'gv_commandline', gnv_app.is_commandline, 'host' )
	this.object.document.script.pb.session( 'gv_currentpath', gnv_app.is_currentPath, 'host' )
	this.object.document.script.pb.session( 'gv_loginuser', gnv_app.is_login_user, 'host' )
	this.object.document.script.pb.session( 'gv_version', gnv_app.is_version, 'host' )

	// call onPageReady()
	this.object.document.script.onPageReady( trim(gnv_app.is_app_cmdline) )

CATCH (runtimeerror er)
   if pos(gnv_app.is_watch,'[warning]')>0  then 
		MessageBox("Warning@documentcomplete="+string(er.number), er.GetMessage())
	else
		gnv_app.of_microhelp("[warning] documentcomplete="+string(er.number)+': '+er.GetMessage() )
	end if	

END TRY

/*
// handle inject code
if is_inject_code > ' ' then
	gnv_app.of_microhelp( 'inject script for '+url )
	this.object.document.script.eval( '(function() { ' + is_inject_code + ' })()' )
	is_inject_code = ''
else
	gnv_app.of_microhelp( 'documentcomplete: '+url )
end if
*/
end event

event navigateerror(oleobject pdisp, any url, any frame, any statuscode, ref boolean ole_cancel);/*
string ls_callback, ls_command

// return for not pb://protocol
if lower(left(url,5)) <> 'pb://' and lower(left(url,5)) <> 'ps://' then
	ole_cancel = false
	return
end if

// handle ps:// security mode
if lower(left(url,5)) = 'ps://' and trim(gnv_app.is_login_user) = '' then
	open(w_window_login)
	if trim(gnv_app.is_login_user) = '' then 
		ole_cancel = true
		return
	end if
	gnv_app.of_microhelp( 'window user login. id=' + gnv_app.is_login_user )
end if

// handle microhelp
if lower(left(url,14)) = 'pb://microhelp' then
	gnv_app.of_microhelp( mid( url, 16 ) )
	ole_cancel = true
	return
end if

// handle prompt message
if mid(url,4,4) = '///?' and pos(url,'?/',7) > 0 then
	if messagebox( 'Confirmation', mid( url, 8, pos(url,'?/',7) - 7 ), Question!, YesNo! ) <> 1 then 
		ole_cancel = true
		return
	else
		url = left(url,5) + mid( url, pos(url,'?/',7) + 2 )
	end if
end if

// for pb://protocol, handle callback first
if lower(mid(url,4,11)) = '//callback/' then
	ls_callback   = mid( url, 15, pos(url, '/', 16) - 15 )
	ls_command = mid( url,  pos(url, '/', 16) + 1 )
else
	ls_callback   = ''
	ls_command = mid( url,  6 )
end if

// call event to handle pb://protocol command
ole_cancel = true

//of_microhelp( 'calling pb protocal: '+ls_command+' -> ' + ls_callback )
post event ue_pb_protocol( ls_command, ls_callback )
*/
if pos( gnv_app.is_watch, '[ole]' )>0 then gnv_app.of_microhelp( 'ole.navigateerror(), status='+string(statuscode)+', url='+url )

ole_cancel = true

if lower(left(url,5))='pb://' or lower(left(url,5))='ps://' then post event titlechange(url)





end event

event type string ue_callback(string as_callback, string as_result);//if isnull(as_name) or trim(as_name) = '' then return

DO WHILE this.object.Busy
       Yield ()
LOOP
		
this.object.document.script.pb.router( as_callback, as_result, is_type, is_command )
return ''


end event

event type string ue_pb_protocol(string as_command, string as_callback);//# handle PB protocol for extented command. (pb://is_type/ls_name/ls_arg1/ls_arg2/...)
//# ps: this event is a POST event, wait till IE browser completed.
//#
//# Log:  2015/06/15	CK Hung			initial version
//# 		  2015/08/02	CK Hung			js inject, etc..
//# 		  2015/08/24	CK Hung			new command "pb://ie/{options}/{url}; support inject js
//# 		  2021/01/26	CK Hung			revise for PowerPage
//# 		  2021/02/04	CK Hung			by default return json string
//# 		  2021/05/06	CK Hung			handle session/global variables between pages.
//# 		  2021/06/02	CK Hung			print command, and pdf commands
//# 		  2021/06/05	CK Hung			wsh.sendkeys
//# 		  2021/06/29	CK Hung			dir commands
//#=====================================================

string ls_parm, ls_opts, ls_name, ls_path, ls_run, ls_result, ls_null, ls_html, ls_style, ls_mode
long   ll_file, ll_rtn, ll_pos, ll_show, ll_timeout, i
time   ldt_now
window lw_win

SetNull(ls_null)
ldt_now = now()

if pos(gnv_app.is_watch,'[api]')>0 then gnv_app.of_microhelp( 'api=' + as_command + ' callback='+as_callback )

// ps: should be post event, wait till browser document settled. 
DO WHILE this.object.Busy and secondsafter( ldt_now, now() ) < ii_timeout
      Yield ()
LOOP

// interpret command string.  is_command := {is_type}/{is_name}/{ls_parm}
is_command = this.object.document.script.decodeURIComponent(as_command)
is_callback = as_callback

ls_parm  = is_command
is_type = lower( of_gettoken( ls_parm, '/' ) )
ls_name = of_gettoken( ls_parm, '/' )

//## pb://session/{name}/{value}
if is_type = 'session' then
	for i=1 to gnv_app.ii_var_count
		if gnv_app.is_var_name[i]= ls_name then
			gnv_app.is_var_value[i] = ls_parm
			return this.object.document.script.pb.session( ls_name, ls_parm, 'set' )
		end if	
	next
	// add if not found
	gnv_app.ii_var_count++ 
	gnv_app.is_var_name[gnv_app.ii_var_count]= ls_name
	gnv_app.is_var_value[gnv_app.ii_var_count]= ls_parm
	return this.object.document.script.pb.session( ls_name, ls_parm, 'new' )
end if

// ## pb://popup/{opts,url}
if is_type = 'popup' then
	setnull(message.stringparm)
	ll_rtn = openwithparm( w_power_dialog, mid(is_command,7)  )
	return event ue_callback( as_callback, message.stringparm )
end if

//## pb://window/{windowName}[/{parm}] => Call PB dialog window (with parm)
if is_type='window' then
	setnull(message.stringparm)
	if trim(ls_parm)>'' then
		ll_rtn = openwithparm( lw_win, ls_parm, ls_name )	
	else
		ll_rtn = open( lw_win, ls_name )	
	end if
	if message.stringparm > '' then
		return event ue_callback( as_callback, '{ "status":'+string(ll_rtn)+', "return":"' + message.stringparm + '"}' )
	else
		return event ue_callback( as_callback, '{ "status":'+string(ll_rtn)+'}' )
	end if
end if

//## pb://function/{action}/{parameter} => dynamic call f_functions() to handle. it shall be defined in ext pb library
if is_type='func' then
	TRY	
		ls_result = dynamic f_functions(ls_name, ls_parm)
	CATCH (runtimeerror er)
		ls_result = '{ "status":-1, "message":"function not found - ' + ls_name + '()" } ' 
	END TRY	
	return event ue_callback( as_callback, ls_result )
end if

//## pb://file/{action}/{parameter} => extended file function. call event ue_pb_file()
if is_type='file' then
	ls_result = event ue_pb_file( ls_name, ls_parm )
	return event ue_callback( as_callback, ls_result )
end if

//## pb://sendkeys/{keystrokes} => send keys
if is_type = 'sendkeys' then
	ll_rtn = this.of_sendkeys( of_get_string( mid( is_command, 10 ) ) )
	return event ue_callback( as_callback, '{ "status":'+string(ll_rtn)+'}' )	
end if

//## pb://runwait/{command} => run dos/shell command
if is_type = 'runwait' then
	ll_rtn = of_run_wait( mid( is_command, 9 ), 1 )
	return event ue_callback( as_callback, '{ "status":'+string(ll_rtn)+'}' )	
end if

//## pb://dir/list|create|delete|go/{directory}
if is_type = 'dir' then
	if ls_name='' then
		ls_result = '{ "status":1, "directory":"' + GetCurrentDirectory() + '", "current":"' + GetCurrentDirectory() + '" }' 
	elseif ls_name='create' then
		ll_rtn = createDirectory(ls_parm)
		ls_result = '{ "status":' + string(ll_rtn) +', "directory":"' + ls_parm + '", "current":"' + GetCurrentDirectory() + '" }' 
	elseif ls_name='delete' then
		ll_rtn = RemoveDirectory(ls_parm)
		ls_result = '{ "status":' + string(ll_rtn) +', "directory":"' + ls_parm + '", "current":"' + GetCurrentDirectory() + '" }' 
	elseif ls_name='change' then
		ls_parm = gnv_app.of_replaceall(ls_parm,'$parent','..')
		ll_rtn = ChangeDirectory( gnv_app.of_replaceall( ls_parm, '$home', gnv_app.is_currentPath ) )
		ls_result = '{ "status":' + string(ll_rtn) +', "directory":"' + ls_parm + '", "current":"' + GetCurrentDirectory() + '" }' 	
	elseif ls_name='select' then
		ll_rtn = GetFolder ( ls_parm, ls_path )
		ls_result = '{ "status":' + string(ll_rtn) +', "directory":"' + ls_path + '", "current":"' + GetCurrentDirectory() + '" }' 	
	elseif ls_name='exists' then
		if DirectoryExists ( ls_parm ) then
			ls_result = '{ "status": 1, "exists": true  }' 
		else
			ls_result = '{ "status": 0, "exists": false  }' 
		end if
	else
		ls_result = '{ "status": -1, "message": "unknow action - ' + ls_name + '" }' 
	end if
	return event ue_callback( as_callback, ls_result )
	
end if

//## [20210611] pb://shell/path=?,file=?,parm=?,action=open|runas|print|find..,style=[min|max|normal|hide|No.]
if is_type = 'shell' then
	
	ls_opts = mid(is_command,7) 
	ls_path = of_get_keyword( ls_opts, 'path', ',', of_get_keyword( ls_opts, 'folder', ',', ls_null ) )
	ls_name = of_get_keyword( ls_opts, 'file', ',', of_get_keyword( ls_opts, 'cmd', ',', ls_null ) )
	ls_style = of_get_keyword( ls_opts, 'show', ',', of_get_keyword( ls_opts, 'style', ',', 'normal' ) )
	ls_mode = of_get_keyword( ls_opts, 'action', ',', of_get_keyword( ls_opts, 'mode', ',', 'open' ) )
	ls_parm = of_get_keyword( ls_opts, 'parm', ',', ls_null )
	
	if pos(lower(ls_style),'normal')>0 then
		ll_show = 1
	elseif pos(lower(ls_style),'min')>0 then
		ll_show = 2
	elseif pos(lower(ls_style),'max')>0 then
		ll_show = 3
	elseif pos(lower(ls_style),'hide')>0 then
		ll_show = 0
	else
		ll_show = long(ls_style)
	end if
	
	if ls_name>' ' then
		ll_rtn = ShellExecute( handle(this), ls_mode, ls_name, ls_parm, ls_path, ll_show)
	else
		ll_rtn = ShellExecute( handle(this), 'open', ls_opts, ls_null, ls_null, 1)
	end if
	return event ue_callback( as_callback, '{"status":'+string(ll_rtn)+'}' )	
end if

//## [20210611] pb://run/folder=?,cmd=?,style=[min|max|normal|hide]+wait
if is_type = 'run' then
	
	ls_opts = mid(is_command,5) 
	ls_path = of_get_keyword( ls_opts, 'path', ',', of_get_keyword( ls_opts, 'folder', ',', ls_null ) )
	ls_run = of_get_keyword( ls_opts, 'cmd', ',', ls_null )
	ls_style = of_get_keyword( ls_opts, 'style', ',', 'normal' ) 

	if pos(lower(ls_style),'normal')>0 then
		ll_show = 1
	elseif pos(lower(ls_style),'min')>0 then
		ll_show = 2
	elseif pos(lower(ls_style),'max')>0 then
		ll_show = 3
	elseif pos(lower(ls_style),'hide')>0 then
		ll_show = 0
	else
		ll_show = 1
	end if

	if ls_run > ' ' then
		changedirectory( ls_path )
		ll_rtn = of_wsh_run( ls_run, ll_show, pos(ls_style,'wait')>0 )
		changedirectory( gnv_app.is_currentPath )
	else
		ll_rtn = run( mid( is_command, 5 ) )
	end if
	
	return event ue_callback( as_callback, '{ "status":'+string(ll_rtn)+'}' )	
	
end if

/*
//## pb://run/{command} => run dos/shell command
if is_type = 'run' then
	ll_rtn = run( mid( is_command, 5 ) )
	return event ue_callback( as_callback, '{ "status":'+string(ll_rtn)+'}' )	
end if
*/

//## pb://shell/[open|print|explorer]/{file+parm} => open file/folder using shell action
//## pb://shell/[max|min]/{file+parm} => open file/folder in max/min window 
//## pb://shell/run/{file+parm} => open file at its folder
if is_type = 'shell' then
	if ls_name='max' then
		ll_rtn = ShellExecute( handle(this), 'open', ls_parm, ls_null, ls_null, 3)
	elseif ls_name='min' then
		ll_rtn = ShellExecute( handle(this), 'open', ls_parm, ls_null, ls_null, 2)
	elseif ls_name='open' or ls_name='print' or ls_name='explorer' then
		ll_rtn = ShellExecute( handle(this), ls_name, ls_parm, ls_null, ls_null, 1)
	elseif ls_name='run'  then
		if pos(ls_parm,'\') <=0 then
			ll_rtn = run( ls_parm )
			return event ue_callback( as_callback, '{"status":'+string(ll_rtn)+'}' )		
		end if
	
		ls_name = of_gettoken( ls_parm, ' ' )
		ll_pos = len(ls_name) - pos( reverse(ls_name), '\' ) + 1
		ls_path  = left( ls_name, ll_pos - 1 )
		ls_run    = mid( ls_name, ll_pos + 1 ) + ' ' + ls_parm
		ll_rtn = ShellExecute( handle(this), 'open', mid( ls_name, ll_pos + 1 ), ls_parm, ls_path, 1)
	end if
	return event ue_callback( as_callback, '{"status":'+string(ll_rtn)+'}' )
end if

//## pb://inject/{@command}/{url} => load url and inject js
if is_type = 'inject' then
	is_inject_code = of_get_string( ls_name )
	gnv_app.of_microhelp( 'go to url ' + ls_parm )
	ll_rtn = this.object.navigate2( ls_parm )
	return event ue_callback( as_callback, '{"status":'+string(ll_rtn)+'}'  )	
end if

//## pb://db/query/{@SQL} => pb://db/json/{@SQL} => run query SQL, return json
//## pb://db/html/{@SQL}   =>  run query SQL, return html table
//## pb://db/execute/{@SQL} => execute SQL
//## pb://db/prompt/{@SQL} => prompt msg to confirm, then execute SQL
if is_type='db' then
	ls_parm = of_get_string(ls_parm)
	if ls_name='prompt' then
		if messagebox( 'Execute SQL?',  ls_parm, Question!, YesNo! ) = 1 then
			ls_result = of_sql_execute( ls_parm )
			return event ue_callback( as_callback, ls_result )
		else
			return event ue_callback( as_callback, '{"status": 0, "message":"SQL execution cancelled" }' )			
		end if
	elseif ls_name='execute' then
		ls_result = of_sql_execute( ls_parm )
		return event ue_callback( as_callback, ls_result )
	elseif ls_name='query' or ls_name='json' then
		ls_result = of_sql_to_json( ls_parm )
		return event ue_callback( as_callback, ls_result )
	elseif ls_name='html' then
		ls_result = of_sql_to_table( ls_parm )
		return event ue_callback( as_callback, ls_result )
	end if
end if

//## pb://print/[now|preview|setup]
// 6/7/8= print/printPreview/Pagesetup, 0/1/2=default/PromptUser/NotPrompt
if is_type = 'print' then
	if ls_name = 'now' then
		this.object.ExecWB( 6, 2 )
	elseif ls_name = 'preview' then	
		this.object.ExecWB( 7, 0 )
	elseif ls_name = 'setup' then	
		this.object.ExecWB( 8, 0 )
	else
		this.object.ExecWB( 6, 1 )
	end if
	return event ue_callback( as_callback, '' )
end if

//## pb://pdf, pb://pdf/print|open|dialog|divs/querySelector
if is_type = 'pdf' then
	
	ls_opts = profilestring(gnv_app.is_ini, 'system', 'pdf-preview', 'width=1024,height=768')
    ls_run = profilestring(gnv_app.is_ini, 'system', 'pdf-factory', 'wkhtmltopdf.exe')
    ll_timeout = long( profilestring(gnv_app.is_ini, 'system', 'pdf-timeout', '10') )
	 
	if not fileexists(ls_run) then
		event ue_pb_error( 'PDF factory not found.', is_command )
		return '{"status":-1, "message":"PDF factory not found." } '
	end if
		
	ll_file = fileopen( gnv_app.is_temp_file+'.html', LineMode!, Write!, LockWrite!, Replace!, EncodingUTF8! )
	
	if ll_file<=0 then 
		event ue_pb_error( 'Canot open temp file for PDF generation.', is_command )
		return '{"status":-2, "message":"Canot open temp file for PDF generation" } '
	end if
	
	filewriteex( ll_file, of_get_html(ls_parm) )
	fileclose(ll_file)

	of_run_wait( ls_run +  '  ' + gnv_app.is_temp_file +'.html ' + gnv_app.is_temp_file + '.pdf', 0 )

	filedelete( gnv_app.is_temp_file+ +'.html' )
	
	// open pdf file. 
	if ls_name = 'print' then
		ll_rtn = ShellExecute( handle(this), 'print',  gnv_app.is_temp_file+'.pdf', gnv_app.is_currentPath, ls_null, 1)
	elseif ls_name = 'open' then
		ll_rtn = ShellExecute( handle(this), 'open',  gnv_app.is_temp_file+'.pdf', gnv_app.is_currentPath, ls_null, 1)
	elseif ls_name = 'dialog' then
		ll_rtn = openwithparm( w_power_dialog, ls_opts + ',mode=print,url='+gnv_app.is_temp_file+'.pdf' )
		filedelete( gnv_app.is_temp_file+ +'.pdf' )
	else
		ll_rtn = openwithparm( w_power_dialog, ls_opts + ',url='+gnv_app.is_temp_file+'.pdf' )
		filedelete( gnv_app.is_temp_file+ +'.pdf' )
	end if
	
	return '{"status":' + string(ll_rtn) + ' } '
	
end if
	

// unknown comand
event ue_pb_error( 'Unknown command.', is_command )
return '{"status":-1, "message":"Unknow command" } '

/* 
================ to be outdate===========
//## pb://dbms/odbc/dbmarm  => setup ODBC connection
//## pb://dbms/o90/user/psw/sererName/parm => setup oracle/dbms connection
if is_type = 'dbms' then
	if lower(ls_name) = 'odbc' then
		sqlca.DBMS 	= ls_name
		sqlca.DBParm = ls_parm
	else
		sqlca.DBMS		= ls_name
		sqlca.LogId 	= of_gettoken( ls_parm, '/' )
		sqlca.LogPass = of_gettoken( ls_parm, '/' )
		sqlca.ServerName = of_gettoken( ls_parm, '/' )
		sqlca.DBParm = ls_parm
	end if
    disconnect using sqlca;
	return event ue_callback( as_callback, '{"status": ' + string(sqlca.sqlcode) + ', "handle":'+string(sqlca.DBHandle())+'}' )
end if

//## pb://json/{@sqlSelect} => run sqlSelect and return data in JSON format
if is_type = 'json' then
	ls_result = of_sql_to_json( of_get_string( mid( is_command, 6 ) ) )
	return event ue_callback( as_callback, ls_result )
end if

//## pb://table/{@sqlSelect} => run sqlSelect and return data in HTML table format
if is_type='table' then
	ls_result = of_sql_to_table( of_get_string( mid( is_command, 7 ) ) )
	return event ue_callback( as_callback, ls_result )
end if
*/

//##tbc## pb://sql/select/{table}/{columns}/{where}
//##tbc## pb://sql/update/{table}/{columns}/{values}/{where}
//##tbc## pb://sql/insert/{table}/{columns}/{values}
//##tbc## pb://sql/procedure/{procName}/{parameters}
//##tbc## pb://sql/functon/{funcName}/{parameters}


/*
//## pb://IE/{options,parent=0,script=@inject}/{url}, ps: inject script shall run in compatibility view of IE9
if is_type = 'ie' then
	of_new_browser( ls_parm, ls_name )
	return 
end if
*/

end event

event ue_pb_error(string as_errormsg, string as_command);// === exceptional handle of pb:// protocol ===
messagebox( 'Warning', as_errorMsg+'~r~n~r~n'+as_command )

end event

event type string ue_pb_file(string as_action, string as_parm);// file function support
long ll_file, ll_rtn
string ls_result, ls_name, ls_text, ls_path, ls_file

// pb://file/exists/{FileName}
if as_action = 'exists' then
	if fileexists( as_parm ) then
		return 'true'
	else
		return 'false'
	end if
end if

// pb://file/read/{FileName}
if as_action = 'read' then
	
	ll_file = fileopen( as_parm, TextMode!, Read! )
	if ll_file<=0 then return ''
	/*
	if ll_file<=0 then 
		event ue_pb_error( '[File Error] canot open.', as_action+'/' +as_parm )
		return '{ "status": '+string(ll_file)+' , "message":"Canot open ' + as_action+'/' +as_parm + '" } '
	end if
	
	if filereadex( ll_file, ls_result )<0 then
		fileclose(ll_file)
		event ue_pb_error( '[File Error] canot read.', as_action+'/' +as_parm )
		return '{ "status": -9, "message":"Canot read ' + as_action+'/' +as_parm + '" } '
	end if
	*/
	filereadex( ll_file, ls_result )
	fileclose(ll_file)
	return ls_result
	
end if

// pb://file/append/{FileName}/{Content|@var}
if as_action='append' or as_action='write' then
	
	ls_text = as_parm
	ls_name = of_gettoken( ls_text, '/' )
	ls_text  = of_get_string( ls_text )
	
	if as_action='write' then
		filedelete(ls_name)
		ll_file = fileopen( ls_name, TextMode!, Write!, LockReadWrite!, Replace!, EncodingUTF8! )
	else
		ll_file = fileopen( ls_name, TextMode!, Write!, LockReadWrite!, Append! )
	end if
	
	if ll_file<=0 then 
		event ue_pb_error( '[File Error] canot open file.', as_action+'/' +as_parm )
		return  '{ "status": '+string(ll_file)+' , "message":"failed to open file ' + gnv_app.of_replaceall(ls_name,'\','\\') + '" } '
	end if
	
	if filewriteex( ll_file, ls_text )<0 then
		fileclose(ll_file)
		event ue_pb_error( '[File Error] canot write file.', as_action+'/' +as_parm )
		return '{ "status": -9, "message":"failed to write file ' + gnv_app.of_replaceall(ls_name,'\','\\') + '" } '
	end if
	
	fileclose(ll_file)
	return '{ "status":' + string(len(ls_text)) + ', "message":"write to ' + gnv_app.of_replaceall(ls_name,'\','\\') + ' successfully." } '

end if

// pb://file/delete/{FileName}
if as_action='delete' then
	if filedelete( as_parm  ) then
		return  '{ "status": 1, "message":"file ' + gnv_app.of_replaceall(as_parm,'\','\\') + ' deleted" } '
	else
		return '{ "status": -1, "message":"failed to delete file ' + gnv_app.of_replaceall(as_parm,'\','\\') + '!" } '
	end if
end if

// pb://file/move/{SourceFile}/{targetFile}
if as_action='move' then
	
	ls_text = as_parm
	ls_name = of_gettoken(ls_text,'/')
	ll_rtn = FileMove ( ls_name, ls_text )
	
	if ll_rtn > 0 then
		return  gnv_app.of_replaceall( '{ "status": 1, "message":"move file ' + ls_name + ' to ' + ls_text + '" } ', '\', '\\' )
	else
		return gnv_app.of_replaceall( '{ "status": '+string(ll_rtn)+', "message":"failed to move file ' + ls_name + '" } ', '\', '\\' )
	end if
	
end if

// pb://file/copy/{SourceFile}/{targetFile}
if as_action='copy' then
	
	ls_text = as_parm
	ls_name = of_gettoken(ls_text,'/')
	ll_rtn = FileCopy ( ls_name, ls_text, true )
	
	if ll_rtn > 0 then
		return gnv_app.of_replaceall( '{ "status": 1, "message":"copy file ' + ls_name + ' to ' + ls_text + '" } ', '\', '\\' )
	else
		return gnv_app.of_replaceall( '{ "status": '+string(ll_rtn)+', "message":"failed to copy file ' + ls_name + '" } ', '\', '\\' )
	end if
	
end if


// pb://file/select/extension
if as_action='select' or as_action='savedialog' then
	ll_rtn = GetFileSaveName ( 'Select File', ls_path, ls_file, '', as_parm )
	if ll_rtn >0 then 
		return gnv_app.of_replaceall( '{ "status": 1, "path":"' + ls_path + '", "file":"' + ls_file + '" } ', '\', '\\' )
	else
		return '{ "status": '+string(ll_rtn)+' } '
	end if
end if		

if as_action='opendialog' then
	ll_rtn = GetFileOpenName ( '', ls_path, ls_file, '', as_parm )
	if ll_rtn >0 then 
		return gnv_app.of_replaceall( '{ "status": 1, "path":"' + ls_path + '", "file":"' + ls_file + '" } ', '\', '\\' )
	else
		return '{ "status": '+string(ll_rtn)+' } '
	end if
end if	

event ue_pb_error( 'Unknow file function.', as_action+'/' +as_parm )

return gnv_app.of_replaceall( '{ "status":-1, "message":"unknow file function '+as_action+'/' +as_parm + '" }', '\', '\\' )


end event

public function string of_default (string as_str, string as_def);if isnull(as_str) then return as_def
if trim(as_str)='' then return as_def
return as_str

end function

public function string of_sql_to_json (string as_sql);datastore lds
long i, j, ll_colCount, ll_rowCount
string ls_syntax, ls_error, ls_json, ls_colName, ls_colType[], ls_row

// conenct db
if not of_connectdb(3) then return '{ "error": "database not connected" }'

// dw syntax
sqlca.autocommit=TRUE
ls_syntax = sqlca.syntaxfromsql( as_sql, 'Style(Type=grid)', ls_error )
sqlca.autocommit=FALSE
if ls_error > '' then
	messagebox( 'Invlaid SQL Syntax', ls_error )
	return '{ "error": "' + ls_error + '" }'
end if

lds = create datastore
lds.create(ls_syntax)

lds.settransobject(sqlca)
lds.retrieve()

ll_colCount = integer( lds.Object.DataWindow.Column.Count )
ll_rowCount = lds.rowcount()
ls_json   = '{  "colCount":' + string(ll_colCount) + ' ~r~n '
ls_json += ' , "rowCount":' + string(ll_rowCount) + ' ~r~n '
ls_json += ' , "columns": [ ~r~n ' 

for i = 1 to ll_colCount
	ls_colName = lds.Describe( '#'+String(i)+'.name')
	ls_colName = lds.Describe( ls_colname+'_t.text' )
	ls_colType[i] = lds.Describe( '#'+String(i)+'.coltype')
	if i>1 then ls_json += ', '
	ls_json += '"' + of_replaceall( of_replaceall(ls_colName,'"','' ), '~r~n', ' ' ) + '"' 
next

ls_json += '] ~r~n, "data": [ ~r~n ' 

for i = 1 to ll_rowcount
	ls_row = ' [ '
	for j=1 to ll_colCount
		if j>1 then ls_row += ' , '
		if left( ls_colType[j], 5 ) = 'char('  then
			ls_row += of_default( '"' +  of_js_string( lds.getitemstring( i, j ) ) + '"', 'null' )
		elseif  ls_colType[j] = 'date' then
			ls_row += of_default( '"' + string( lds.getitemdate( i, j ), 'yyyy/mm/dd' ) + '"', 'null' )
		elseif  ls_colType[j] = 'datetime' or  ls_colType[j] = 'timestamp' then
			ls_row += of_default( '"' + string( lds.getitemdatetime( i, j ), 'yyyy/mm/dd hh:mm:ss' ) + '"', 'null' )
		elseif ls_colType[j] = 'time' then
			ls_row += of_default( '"' + string( lds.getitemtime( i, j ), 'hh:mm:ss' ) + '"', 'null' )
		else
			ls_row += of_default( string( lds.GetItemDecimal( i, j ) ), 'null' )
		end if
	next
	//ls_row = of_replaceall( ls_row, '\"','&quot;' )
	//ls_row = of_replaceall( ls_row, '~r~n','\n' )
	ls_json += of_replaceall( ls_row, '~r~n','\n' ) + ' ]  ,~r~n'
next

return left( ls_json, len(ls_json) - 4 ) + ' ~r~n ] } '



end function

public function string of_get_string (string as_text);// load string from js variable
if left(as_text,1)='@' then 
	as_text = this.object.document.script.pb( mid(as_text,2) )	
end if

// handle some special characters
as_text = of_replaceall( as_text, '&gt;', '>' )
as_text = of_replaceall( as_text, '&lt;', '<' )

return as_text

end function

public function string of_replaceall (string csource, string cold, string cnew);//# Description:
//#
//#	Replace string <cOld> with <cNew> in <cSource>
//# 
//# Example: 
//#
//# 	ls_str = of_ReplaceAll( ls_source, '~t', ';' )
//#
//# Log:
//#	1997/08/05		C.K. Hung	Initial Version
//#============================================================================

Long	nLenOld, nLenNew, nScan, nPos

nScan 	= 1
nLenOld 	= len(cOld)
nLenNew	= len(cNew)

nPos = pos(  cSource, cOld, nScan )
DO while nPos > 0
	cSource 	= replace ( cSource, nPos, nLenOld, cNew )
	nPos	 	= pos( cSource, cOld, nPos + nLenNew )
LOOP

RETURN cSource

end function

public function boolean of_connectdb (integer ai_retry);long ll_cnt = 0

// connect to database, retry n time if failed.
do while ( sqlca.DBhandle() <= 0 and ll_cnt < ai_retry )

	connect using sqlca;
	
	if sqlca.DBhandle() <= 0 then
		yield()
		ll_cnt++
		gnv_app.of_microhelp( '[Error@' + string(now(),'hh:mm:ss') + '] Failed to connect database:'+sqlca.ServerName+'. Retry=' + string(ll_cnt) )
	end if

loop

return ( sqlca.DBhandle() > 0 )

end function

public function string of_sql_execute (string as_sql);string ls_msg

// run sql
of_connectdb(3)
EXECUTE IMMEDIATE :as_sql using sqlca; 

// return
if sqlca.sqlcode<>0 then 
	gnv_app.of_microhelp( '[Error] code:'+string(sqlca.sqlcode)+', message:' + of_default(sqlca.sqlerrtext,'null')  )
	ROLLBACK using sqlca;
	return '{ "status": -1, "error":' + string(sqlca.sqlcode)+ ', "message": "' + of_default(sqlca.sqlerrtext,'null') + '" }' 
end if

COMMIT USING sqlca;

gnv_app.of_microhelp( '>> SQL Executed Sucessfully!' )
RETURN '{ "status": 1, "message": "SQL Executed Sucessfully!" }' 

end function

public function string of_sql_to_table (string as_sql);datastore lds
long i, j, ll_colCount, ll_rowCount
string ls_syntax, ls_error, ls_table, ls_colName, ls_colType[], ls_row

// conenct db
if not of_connectdb(3) then return '{ "error": "database not connected" }'

// dw syntax
sqlca.autocommit=TRUE
ls_syntax = sqlca.syntaxfromsql( as_sql, 'Style(Type=grid)', ls_error )
sqlca.autocommit=FALSE
if ls_error > '' then
	messagebox( 'Invlaid SQL Syntax', ls_error )
	return '{ "error": "' + ls_error + '" }'
end if

lds = create datastore
lds.create(ls_syntax)

lds.settransobject(sqlca)
lds.retrieve()

ll_colCount = integer( lds.Object.DataWindow.Column.Count )
ll_rowCount = lds.rowcount()


ls_table   = '<table class="pb-table">~r~n<tr>'

for i = 1 to ll_colCount
	ls_colName = lds.Describe( '#'+String(i)+'.name')
	ls_colName = lds.Describe( ls_colname+'_t.text' )
	ls_colType[i] = lds.Describe( '#'+String(i)+'.coltype')
	ls_table += '   <th>' + ls_colName + '</th>'
next

ls_table += '</tr>~r~n' 

for i = 1 to ll_rowcount
	ls_row = '<tr>'
	for j=1 to ll_colCount
		if left( ls_colType[j], 5 ) = 'char('  then
			ls_row += '<td>' + of_default( lds.getitemstring( i, j ), '&nbsp;' ) + '</td>'
		elseif  ls_colType[j] = 'date' then
			ls_row += '<td>' + of_default( string( lds.getitemdate( i, j ), 'yyyy/mm/dd' ), '' ) + '</td>'
		elseif  ls_colType[j] = 'datetime' or  ls_colType[j] = 'timestamp' then
			ls_row += '<td>' + of_default( string( lds.getitemdatetime( i, j ), 'yyyy/mm/dd hh:mm:ss' ), '&nbsp;' ) + '</td>'
		elseif ls_colType[j] = 'time' then
			ls_row += '<td>' + of_default( string( lds.getitemtime( i, j ), 'hh:mm:ss' ), '&nbsp;' ) + '</td>'
		else
			ls_row += '<td>' + of_default( string( lds.GetItemDecimal( i, j ) ), '&nbsp;' ) + '</td>'
		end if
	next
	ls_row = of_replaceall( ls_row, '\"','&quot;' )
	ls_row = of_replaceall( ls_row, '~r~n','<br>' )
	ls_table += of_replaceall( ls_row, '\','\\' ) + '</tr>~r~n'
next

return ls_table + '<table>'



end function

public function integer of_new_browser (string as_url, string as_ppty);OLEobject IE
string ls_value, ls_script, ls_rtn
string ls_text, ls_key

IE = CREATE OLEObject
IE.ConnectToNewObject("InternetExplorer.Application")
//iole_current = IE

as_ppty = of_replaceall( as_ppty, '|', ',' )

if pos( as_ppty, 'fullscreen')>0 then
	IE.fullscreen = TRUE
else
	IE.left = long( of_get_keyword( as_ppty, 'left', ',', string(IE.left) ) )
	IE.top = long( of_get_keyword( as_ppty, 'top', ',', string(IE.top) ) )
	IE.height = long( of_get_keyword( as_ppty, 'height', ',', string(IE.height) ) )
	IE.width  = long( of_get_keyword( as_ppty, 'width', ',', string(IE.width) ) )
end if

IE.menubar = long( of_get_keyword( as_ppty, 'menu', ',', '0' ) )
IE.toolbar = long( of_get_keyword( as_ppty, 'toolbar', ',', '0' ) )
IE.AddressBar = long( of_get_keyword( as_ppty, 'address', ',', '0' ) )
IE.statusbar = long( of_get_keyword( as_ppty, 'status', ',', '1' ) )

IE.Silent = long( of_get_keyword( as_ppty, 'silent', ',', '1' ) )
IE.Resizable = long( of_get_keyword( as_ppty, 'resize', ',', '1' ) )
IE.visible = long( of_get_keyword( as_ppty, 'visible', ',', '1' ) )

IE.StatusText = 'loading '+as_url
IE.navigate( as_url  )

// handle import (inject)  script
ls_script = of_get_keyword( as_ppty, 'script', ',', '' )

if ls_script > '' then

	do while IE.busy
		yield()
	loop

	gnv_app.of_microhelp( '- run javascript script '+ls_script+' for '+as_url )
	IE.document.script.eval( '(function() { ' +  of_get_string( ls_script ) +' })()' )
	
end if

// handle macro
ls_script = of_get_keyword( as_ppty, 'macro', ',', '' )

if ls_script > '' then 
	
	gnv_app.of_microhelp(ls_script)
	do while IE.busy
		yield()
	loop	
	
	do while ls_script>''
		ls_text = of_gettoken( ls_script, ';' )
		ls_key = trim( of_gettoken( ls_text, '=' ) )
		if ls_key='submit' then
			IE.document.getElementById( trim(ls_text) ).submit()
		else
			IE.document.getElementById( ls_key ).value = trim(ls_text)
		end if
	loop
	
end if	

return 1
end function

public function string of_get_keyword (string as_text, string as_key, string as_delim, string as_default);long ll_pos, ll_delim
string ls_value

ll_pos = pos( as_text, as_key+'=' )

if ll_pos > 0 then
	
	ll_delim = pos( as_text, as_delim, ll_pos )
	
	if ll_delim > 0 then
		ls_value = mid( as_text, ll_pos+len(as_key)+1, ll_delim - ll_pos - len(as_key) - 1 )
	else
		ls_value = mid( as_text, ll_pos+len(as_key)+1 )
	end if
	
	return ls_value
	
end if

return  as_default

end function

public function string of_gettoken (ref string as_parm, string as_token);//# Description
//#	Cut the string into two section in delimeter, return the first section and also 
//#	cut the parameter as second section.
//#
//#
//#
//# Parameter
//#	as_parm				Passed in String
//#	as_token				Delimiter
//#
//# Example
//#	ls_parm1 = gnv_func.of_gettoken( message.stringparm, '~t' )
//#	ls_parm2 = gnv_func.of_gettoken( message.stringparm, '~t' )
//#	ls_parm3 = gnv_func.of_gettoken( message.stringparm, '~t' )
//#
//# Log
//#	1998/01/20	C.K. Hung
//#=====================================================================================

long 		ll_pos
string	ls_ret

ll_pos = Pos(as_parm, as_token)

if ll_pos > 0 then
	ls_ret 	= left( as_parm, ll_pos - 1)
	as_parm 	= mid( as_parm, ll_pos + Len(as_token) )
else
	ls_ret = as_parm
	as_parm = ""
end if

return ls_ret

end function

public function integer of_sendkeys (string as_keys);//# [20210604] ck, call Wscript to process sendkeys and commands
//# keys := run=command/go=title/js=jsFunciton/s=1000/&#47;&sol;
//#=============================================
string ls_cmd
long  ll_ms, ll_cpu

if not iole_wsh.IsAlive() then
	ii_connect = iole_wsh.ConnectToNewObject("WScript.Shell")
	if ii_connect<0 then return ii_connect
end if  

do 
	ls_cmd = trim( of_gettoken( as_keys, '/' ) )
	ls_cmd = of_replaceall( of_replaceall( ls_cmd, '&#47;', '/' ), '&sol;', '/' )
	
	// run shell command
	if left(ls_cmd,4) = 'run=' then 
		iole_wsh.run( mid( ls_cmd, 5 ) )
		
	// goto window by title	
	elseif left(ls_cmd,6) = 'title=' then 
		iole_wsh.AppActivate( mid( ls_cmd, 7 ) )
		
	// call js function	 (call pb.router to activate js command)
	elseif left(ls_cmd,3) = 'js=' then
		this.object.document.script.pb.router( mid( ls_cmd, 4 ), as_keys, 'sendkeys', 'call' )

	// wait for seconds	
	elseif left(ls_cmd,2) = 's=' then 
		sleep( long( mid( ls_cmd, 3 ) ) )
		
	// wait for milliseconds	
	elseif left(ls_cmd,3) = 'ms=' then
		ll_cpu = cpu()
		ll_ms = long( mid( ls_cmd, 4 ) )
		do
			yield()
		loop while (cpu() - ll_cpu) < ll_ms
		
	// send keystrokes.	
	else
		iole_wsh.SendKeys(ls_cmd)
		
	end if

loop while trim(as_keys)>''

return 1
end function

public function integer of_sleepms (integer ai_ms);// sleep in milliseconds
long ll_cpu

ll_cpu = cpu()

do
	yield()
loop while (cpu() - ll_cpu) < ai_ms

return ai_ms
		
end function

public function integer of_wsh_run (string as_run, integer ai_opt, boolean ab_wait);//CONSTANT integer MAXIMIZED = 3
//CONSTANT integer MINIMIZED = 2
//CONSTANT integer NORMAL = 1
//CONSTANT integer HIDE = 0
//CONSTANT boolean WAIT = TRUE
//CONSTANT boolean NOWAIT = FALSE
if not iole_wsh.IsAlive() then
	ii_connect = iole_wsh.ConnectToNewObject("WScript.Shell")	
end if

return iole_wsh.run( as_run, ai_opt, ab_wait )


end function

public function integer of_run_wait (string as_run, integer ai_opt);return iole_wsh.Run( as_run, ai_opt, true )


end function

public function string of_js_string (string as_str);as_str =  of_replaceall( as_str, '\', '\\' )
as_str = of_replaceall( as_str, '"','\"')
as_str = of_replaceall( as_str, '~r~n', '\n')
as_str = of_replaceall( as_str, '~r', '\n')
as_str = of_replaceall( as_str, '~n', '\n')
return as_str
end function

public function string of_get_html (string as_selector);// basically, js.pb.htm() can do all, but below script get less depandence.
// this function will be called for CLI.save|pdf mode, or pb://pdf
//=======================================================

 if trim(as_selector)>' ' then
	return (this.object.document.script.pb.html(as_selector))
end if

// compose and reutrn html header + body
return '<!DOCTYPE html>~r~n' + this.object.document.head.outerHTML + '~r~n' + this.object.document.body.outerHTML + '~r~n'

end function

on u_web_browser.create
end on

on u_web_browser.destroy
end on

event constructor;//#  IE Web Browser with Web Interface support
//#
//#  Log: 
//#		2015/08/01	  Rewrite from campo old browser OLE
//#		2021/01/21  Revise/Merge code for power page
//#		2021/04/29  some revision on pb protocol
//#		2021/10/20  more pb protocol support
//#================================================

//this.object.navigate2('about:blank')

iole_wsh = Create OleObject

ii_connect = iole_wsh.ConnectToNewObject("WScript.Shell")
end event

event destructor;iole_wsh.DisconnectObject()
end event

event error;if pos( gnv_app.is_watch, '[ole]' )>0 then gnv_app.of_microhelp( 'ole.error(), obj='+errorobject+', line='+string(errorline)+', text='+errortext )
end event

event externalexception;if pos( gnv_app.is_watch, '[ole]' )>0 then gnv_app.of_microhelp( 'ole.externalexception(), code='+string(resultcode)+', source='+source+', desc='+description )
end event

event rbuttondown;if pos( gnv_app.is_watch, '[ole]' )>0 then gnv_app.of_microhelp( 'ole.rbuttondown(), flags='+string(flags)+', x='+string(xpos)+', y='+string(ypos) )
end event


Start of PowerBuilder Binary Data Section : Do NOT Edit
0Cu_web_browser.bin 
2200000a00e011cfd0e11ab1a1000000000000000000000000000000000003003e0009fffe000000060000000000000000000000010000000100000000000010000000000200000001fffffffe0000000000000000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdfffffffefffffffefffffffeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff006f00520074006f004500200074006e00790072000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050016ffffffffffffffff00000001000000000000000000000000000000000000000000000000000000001251726001d7d08e00000003000001800000000000500003004f0042005800430054005300450052004d0041000000000000000000000000000000000000000000000000000000000000000000000000000000000102001affffffff00000002ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000009c00000000004200500043004f00530058004f00540041005200450047000000000000000000000000000000000000000000000000000000000000000000000000000000000001001affffffffffffffff000000038856f96111d0340ac0006ba9a205d74f000000001251726001d7d08e1251726001d7d08e000000000000000000000000004f00430054004e004e00450053005400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001020012ffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000030000009c000000000000000100000002fffffffe0000000400000005fffffffeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
20ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000004c000026dc000017e00000000000000000000000000000000000000000000000000000004c0000000000000000000000010057d0e011cf3573000869ae62122e2b00000008000000000000004c0002140100000000000000c0460000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004c000026dc000017e00000000000000000000000000000000000000000000000000000004c0000000000000000000000010057d0e011cf3573000869ae62122e2b00000008000000000000004c0002140100000000000000c0460000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1Cu_web_browser.bin 
End of PowerBuilder Binary Data Section : No Source Expected After This Point
