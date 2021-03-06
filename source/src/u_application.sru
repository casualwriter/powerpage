$PBExportHeader$u_application.sru
$PBExportComments$application manager
forward
global type u_application from nonvisualobject
end type
end forward

global type u_application from nonvisualobject autoinstantiate
event ue_open ( string commandline )
event ue_close ( )
event ue_idle ( )
event ue_error ( )
event ue_home ( )
end type

type prototypes
FUNCTION boolean ShowWindow( ulong winhandle, int wincommand ) Library "user32"
FUNCTION boolean BringWindowToTop(  ulong  HWND  )  Library "user32"
FUNCTION long FindWindowA( ulong  Winhandle, string wintitle ) Library "user32"
FUNCTION boolean SetForegroundWindow( long hWnd ) LIBRARY "USER32"

FUNCTION long ShellExecute (long hwnd, string lpOperation, string lpFile, &
											string lpParameters,  string lpDirectory, integer nShowCmd ) &
					LIBRARY "shell32" ALIAS FOR ShellExecuteW
					
/*
SE_ERR_FNF              2       // file not found
SE_ERR_PNF              3       // path not found
SE_ERR_ACCESSDENIED     5       // access denied
SE_ERR_OOM              8       // out of memory
SE_ERR_DLLNOTFOUND      32
SE_ERR_SHARE            26
SE_ERR_ASSOCINCOMPLETE  27
SE_ERR_DDETIMEOUT       28
SE_ERR_DDEFAIL          29
SE_ERR_DDEBUSY          30
SE_ERR_NOASSOC          31
*/



end prototypes

type variables
string is_name = 'powerpage'
string is_ini 	 = 'powerpage.ini'

string is_temp_file = '__temp__file'

string is_version, is_credit, is_github, is_home, is_about, is_title

string is_currentPath, is_hostname, is_showerror, is_null, is_watch
string is_login_user, is_login_psw

string is_commandline, is_app_cmdline=''
string is_app_mode, is_app_parm, is_app_start, is_app_script, is_app_select
string is_start_url, is_page_script, is_page_ieMode='IE'
int     ii_app_delay=1000

string is_var_name[], is_var_value[]
long ii_var_count = 0

string is_microhelp[]
long ii_microcount=0

boolean ib_fullscreen = false
boolean ib_silent = false



end variables

forward prototypes
public function string of_replaceall (string csource, string cold, string cnew)
public function long of_findwindowbytitle (string as_title)
public function boolean of_showwindow (long al_handle)
public function boolean of_bringtotop (long al_handle)
public function string of_gettoken (ref string as_parm, string as_token)
public function any of_default (any aa_var, any aa_default)
public function integer of_microhelp (string as_text)
public function string of_get_keyword (string as_text, string as_key, string as_delim, string as_default)
public function string of_url_format (string as_url)
public function string of_encryption (string as_psw)
public function string of_decryption (string as_psw)
public function long of_shellprint (string as_file)
public function integer of_sendkeys (string as_keys)
public function long of_shellopen (string as_folder, string as_file, string as_parm)
public function long of_shellexecute (string as_type, string as_cmd, string as_parm, string as_folder, integer ai_show)
public function long of_shellrun (string as_cmd, string as_folder)
public function long of_shellexecute (string as_cmd, string as_parm, string as_folder)
public function long of_shellrun (string as_cmd)
public function string of_get_cmdline (ref string as_cmdline, boolean ab_quote)
end prototypes

event ue_open(string commandline);//# Power Page - Modificaiton History
//#
//#  v0.20. 2015/08/24. initial version
//#  v0.30. 2021/01/21. add new command
//#  v0.31. 2021/01/26. update registry for IE11 feature.
//#  v0.35. 2021/02/04. re-organize
//#  v0.38. 2021/04/29. re-organize, and simplify
//#  v0.39. 2021/05/05. inject js file for pb extention
//#  v0.40. 2021/05/06. session support, console.log 
//#  v0.41. 2021/05/07. eval input expression, more console support
//#  v0.42. 2021/05/11. markdown editor. some misc revision
//#  v0.43. 2021/05/14. some enhance markdown editor
//#  v0.44. 2021/05/17. support using encryption id/psw for db connection.
//#  v0.45. 2021/05/19. minor fix
//#  v0.46. 2021/05/25. add pb://print
//#  v0.47. 2021/05/31. handle more button (E-Edit, P-Print, W-Web)
//#  v0.48. 2021/06/03. pdf printing, refine powerpage.js
//#  v0.49. 2021/06/07. support sendkeys; 06/09. add command pb://runwait/
//#  v0.50. 2021/06/11. rewrite pb://run and pb://shell
//#  v0.51. 2021/06/15. handle commandline options for /url/ini/save/print/pdf/script/watch
//#  v0.52. 2021/06/22. w_power_dialog -> mode=capture
//#  v0.53. 2021/06/29. enhance for web crawler; add "dir" commands
//#  v0.54. 2021/07/03. support fullscreen mode, minor enhance for web crawler
//#  v0.55. 2021/07/07. use db.* command instead of sql.*
//#  v0.56. 2021/07/10. add spider command
//#  v0.57. 2021/10/05. code document framework pp-document.html, update documents
//#  v0.58. 2021/10/12, update documents with markdown parser
//#  v0.60. 2021/10/14. align all (pp-md-editor/oo-web-crawler) to this version
//#  v0.61. 2021/10/15. commandline: html selector support
//#  v0.63. 2021/11/03. minor fix on source code, for release in github.
//#======================================================

// get computer name
string ls_key, ls_cmdline
ulong ul_val

// get computer name, current path, commandline
ls_key = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName'

if RegistryGet (ls_key,'ComputerName', RegString!, is_hostname) > 0 then 
	is_hostname = upper(is_hostname)
else
	messagebox( 'Error', 'Cannot get computer name.' )
end if

// make sure FEATURE_BROWSER_EMULATIO is registered
ls_key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION'
RegistryGet ( ls_key, is_name+'.exe', ReguLong!, ul_val)
if ul_val < 9000 then RegistrySet ( ls_key, is_name+'.exe', ReguLong!, 11000 )

ls_key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION'
RegistryGet ( ls_key, is_name+'.exe', ReguLong!, ul_val)
if ul_val < 9000 then RegistrySet ( ls_key, is_name+'.exe', ReguLong!, 11000 )

is_currentPath   = GetCurrentDirectory ( )
is_commandline = commandline

// handle commandline parameters. syntax:
// /ini=my.ini /url=start.html /print{=printer} /save=output.html /pdf=output.pdf /script=myscript.js /select={selector}
do 
	commandline = trim(commandline)
	
	if left(commandline,5) = '/ini=' then
		commandline = mid( commandline, 6 )
		this.is_ini = of_get_cmdline( commandline, false )
	elseif left( commandline,5) = '/url=' then		
		commandline = mid( commandline, 6 )
		is_app_start = of_get_cmdline( commandline, false )
	elseif left( commandline,5) = '/pdf=' then		
		commandline = mid( commandline, 6 )
		is_app_mode = 'pdf'
		is_app_parm = of_get_cmdline( commandline, false )
	elseif left( commandline,6) = '/save=' then
		commandline = mid( commandline, 7 )
		is_app_mode = 'save'
		is_app_parm = of_get_cmdline( commandline, false )
	elseif left( commandline,7) = '/print=' then		
		commandline = mid( commandline, 8 )
		is_app_mode = 'print'
		is_app_parm = of_get_cmdline( commandline, false )
	elseif left( commandline,8) = '/script=' then		
		commandline = mid( commandline, 9 )
		is_app_script = of_get_cmdline( commandline, false )
	elseif left( commandline,8) = '/select=' then		
		commandline = mid( commandline, 9 )
		is_app_select = of_get_cmdline( commandline, false )
	elseif left( commandline,7) = '/watch=' then		
		commandline = mid( commandline, 8 )
		is_watch = of_get_cmdline( commandline, false )
	elseif left( commandline,7) = '/delay=' then		
		commandline = mid( commandline, 8 )
		ii_app_delay = long( of_get_cmdline( commandline, false ) )
	else
		ls_key = of_get_cmdline( commandline, true )
	    if ls_key = '/print' then		
			is_app_mode = 'print'
			is_app_parm = ''
		elseif ls_key='/fullscreen' or ls_key='/kiosk' then
			ib_fullscreen = true
		elseif ls_key='/silent' then
			ib_silent = true
		elseif ls_key='/console' then
			is_app_mode = 'console'
		else
			is_app_cmdline += ' ' + ls_key 
		end if
	end if
	
loop while trim(commandline)>''
	
// read application seting from profile ini
is_version = profilestring( gnv_app.is_ini, 'system', 'version', 'v0.63. build on 2021/11/03' )
is_credit   = profilestring( gnv_app.is_ini, 'system', 'credit', 'Copyright (c) 2021, CK Hung' )
is_github  = profilestring( gnv_app.is_ini, 'system', 'github', 'https://github.com/casualwriter/powerpage' )
is_home   = profilestring( gnv_app.is_ini, 'system', 'home', 'https://github.com/casualwriter/powerpage' )
is_about   = profilestring( gnv_app.is_ini, 'system', 'about', '' )
is_title     = profilestring( gnv_app.is_ini, 'system', 'title', 'html' )
is_showerror = profilestring( gnv_app.is_ini, 'system', 'showerror', 'yes' )
is_watch = profilestring( gnv_app.is_ini, 'system', 'watch', of_default(is_watch,'[cmd]') )

// Set PB extent library list
if profilestring( gnv_app.is_ini, 'system', 'extLibrary', '' ) > '' then
	AddToLibraryList( profilestring( gnv_app.is_ini, 'system', 'extLibrary', '' ) )
end if

// Connect to db
sqlca.DBMS		= profilestring( gnv_app.is_ini, 'database', 'DBMS', 'N/A' )
sqlca.ServerName = profilestring( gnv_app.is_ini, 'database', 'ServerName', '' )
sqlca.DBParm 	  	 = profilestring( gnv_app.is_ini, 'database', 'DBParm', '' )
sqlca.LogId 	= profilestring( gnv_app.is_ini, 'database', 'LogId', 'scott' )
sqlca.LogPass = trim(profilestring( gnv_app.is_ini, 'database', 'LogPass', 'tiger' ))

// support encrypted  logid / password / dbparm
if left(sqlca.DBParm,1) = '@' then sqlca.DBParm = of_decryption( mid(sqlca.DBParm,2) )
if left(sqlca.LogId,1) = '@' then sqlca.LogId = of_decryption( mid(sqlca.LogId,2) )
if left(sqlca.LogPass,1) = '@' then sqlca.LogPass = of_decryption( mid(sqlca.LogPass,2) )

if sqlca.DBMS <> 'N/A' then
	
	connect using sqlca;
	
	if sqlca.sqlcode < 0 then
		of_microhelp( 'failed to connect db. ' + sqlca.SQLErrText )
	elseif sqlca.DBhandle() > 0 then
		of_microhelp( 'database connected.' )
	end if	
	
end if

// read for inject js script (for pb interface object)
long ll_file
string ls_name, ls_text

if isnull(is_app_script) or trim(is_app_script)='' then
	is_app_script = profilestring( this.is_ini, 'system', 'script', 'powerpage.js' )
end if

if fileexists(is_app_script) then
	ll_file = fileopen( is_app_script, TextMode!  )
	filereadex( ll_file, is_page_script)
    fileclose(ll_file)
end if

// load session values
ls_text = profilestring( gnv_app.is_ini, 'session', 'var1', '' )

do while ls_text>'' 
	ii_var_count++
	is_var_name[ii_var_count] = trim( of_gettoken( ls_text, ':' ) )
	is_var_value[ii_var_count] = trim(ls_text)
	ls_text = profilestring( gnv_app.is_ini, 'session', 'var'+string(ii_var_count+1), '' )
loop 

// app startup.  cmdline -> ini -> index.html -> pwoerpage.html
if is_app_start>' ' then
	//openwithparm( w_power_page, is_app_start )	
elseif profilestring( this.is_ini, 'system', 'start', '' )>' ' then
	is_app_start = profilestring( this.is_ini, 'system', 'start', '' )
elseif FileExists( 'index.html') then
	is_app_start = 'index.html'
elseif FileExists( gnv_app.is_name + '.html') then
	is_app_start = gnv_app.is_name +'.html' 
end if

// show parameters for debug
if pos( is_watch, '[parm]') > 0 then
	ls_text = ' commandline=' + of_default( is_commandline, '{none}' )
	ls_text += '~r~n page(cmdline)=' + of_default( is_app_cmdline, '{none}' )
    ls_text += '~r~n ini=' + is_ini
	ls_text += '~r~n url=' + of_default( is_app_start, '{none}' )
	if is_app_mode>' ' then ls_text += '~r~n ' + is_app_mode + '=' + of_default( is_app_parm, '{none}' )
	messagebox( 'Program Parameters', ls_text )
end if

// open power page
if is_app_start > ' ' then
	if ib_fullscreen then
		openwithparm( w_power_popup, is_app_start )
	else
		openwithparm( w_power_page, is_app_start )	
	end if
else
	messagebox( 'Error', 'Please specify startup page!' )
end if

end event

event ue_close();if sqlca.DBhandle() > 0 then 
	DISCONNECT using SQLCA;
end if

if fileexists( is_currentPath+'\'+is_temp_file+'.pdf') then 
	filedelete( is_currentPath+'\'+is_temp_file+'.html' )
	filedelete( is_currentPath+'\'+is_temp_file+'.pdf' )
end if

end event

event ue_error();//exclude 19-cannot convert ole object; 32-name not found
if is_showerror='yes' and error.number <> 19 and error.number <> 32 then
	messagebox( 'Error ' + string(error.number), error.object + '.' + error.objectevent + '(' + string(error.line) + ')~r~n' +  error.text )
end if
end event

public function string of_replaceall (string csource, string cold, string cnew);//# Description:
//#
//#	Replace string <cOld> with <cNew> in <cSource>
//# 
//# Example: 
//#
//# 	ls_str = gnv_func.of_ReplaceAll( ls_source, '~t', ';' )
//#
//# Log:
//#	1997/08/05	C.K. Hung	Initial Version
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

public function long of_findwindowbytitle (string as_title);return FindWindowA( 0, as_title )
end function

public function boolean of_showwindow (long al_handle);return ShowWindow( al_handle, 5 )
end function

public function boolean of_bringtotop (long al_handle);return BringWindowToTop( al_handle )
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

public function any of_default (any aa_var, any aa_default);//# Description:
//#
//#	Return a default value for NULL argument
//#
//# Example: 
//#
//# 	ls_username = gnv_func.of_default( ls_username, 'Unknow' )
//# 	li_deptcode = gnv_func.of_default( li_deptcode, 0 )
//#
//# Log
//#	1 Nov 1997	C.K. Hung	Initial version
//#===================================================================

if isnull(aa_var) then
   return aa_default
else
   return aa_var
end if

end function

public function integer of_microhelp (string as_text);if isnull(as_text) or trim(as_text) = '' then return 0

// keep history (skip >> for web status text)
if left(trim(as_text),2) <> '>>' then 
	
	if ii_microcount>=1024 then ii_microcount=1 else ii_microcount++
	
	is_microhelp[ii_microcount] = ' [' + string(ii_microcount)+string(now(),'@hh:mm:ss] ') + as_text
	
end if	

// show text at status bar
if isvalid(w_power_page) then
	
	w_power_page.st_status.text = ' ' + as_text
	
	if w_power_page.st_console.visible and left(trim(as_text),2) <> '>>' then 
		w_power_page.st_console.text += '~r~n[#' + string(now(),'hh:mm:ss] ') + of_replaceall(as_text,'|','~r~n')
		w_power_page.st_console.Scroll(9999)
	end if	
	
	return 1
	
end if

return 0
end function

public function string of_get_keyword (string as_text, string as_key, string as_delim, string as_default);long ll_pos, ll_delim
string ls_value

ll_pos = pos( as_text, as_key+'=' )

if ll_pos > 0 then
	
	ll_delim = pos( as_text, as_delim, ll_pos+1 )
	
	if ll_delim > 0 then
		ls_value = mid( as_text, ll_pos+len(as_key)+1, ll_delim - ll_pos - len(as_key) - 1 )
	else
		ls_value = mid( as_text, ll_pos+len(as_key)+1 )
	end if
	
	return trim(ls_value)
	
end if

return  trim(as_default)

end function

public function string of_url_format (string as_url);// format url
// 1. no change if is web link, e.g. http://mydomain.com
// 2. no change for network file, e.g. d:\path\folder\index.html
// 3. local file, add {currentDirectory} + '/' + filename
//==========================================

// 	for network file, or web link
if pos(as_url,':')>0 or pos(as_url,'\\')>0 then return trim(as_url)

// 	for local file, add current path
return GetCurrentDirectory() + '\' + trim(as_url)

end function

public function string of_encryption (string as_psw);//# Description:
//#
//#	This function is coded for password encryption
//#	user XOR function and decode to Hex(a=0..15), XOR key is project name
//#
//# Log:
//#	1997/08/05		CK. Hung	Initial Version
//#	2021/05/17		CK. Hung	use transform of getapplication().appname
//#============================================================================

int		i, ll_len1, ll_len2, ll_key[], ll_source, ll_keychr
string 	ls_text, ls_key

// for empty password
if isnull(as_psw) or as_psw='' then return ''

// get the ascII array of key
ls_key = 'may' + reverse( getapplication().appname ) + '2021'

ll_len1 = len( ls_key )

for i = ll_len1 to 1 step -1
	ll_key[i] = asc( mid(ls_key,i,1) )
next

// xor operation, f(source,key) = 256 + key - source
ls_text 	= ''
ll_len2	= len(as_psw)

for i = 1 to ll_len2
	ll_source = asc(mid(as_psw,i,1))
	ll_keychr = 256 + ll_key[ 1 + mod( i - 1, ll_len1 ) ] - ll_source
	ls_text 	 = ls_text + char(asc('a')+int(ll_keychr/16)) + char(asc('a')+mod(ll_keychr,16))
next

return reverse(ls_text)

end function

public function string of_decryption (string as_psw);//# Description:
//#
//#	This function is used to decode password for of_encryption()
//#
//# Log:
//#	2005/12/26		CK. Hung	Initial Version
//#	2021/05/17		CK. Hung	use transform of appname as key
//#============================================================================

int		i, ll_len1, ll_len2, ll_key[], ll_source, ll_keychr
string 	ls_text, ls_key

// for empty password
if isnull(as_psw) or as_psw='' then return ''

// get the ascII array of key
as_psw = reverse(as_psw)
ls_key = 'may' + reverse( getapplication().appname ) + '2021'

ll_len1 = len( ls_key )

for i = ll_len1 to 1 step -1
	ll_key[i] = asc( mid(ls_key,i,1) )
next

// xor operation, f(source,key) = 256 + key - source
ls_text 	= ''
ll_len2	= len(as_psw)
for i = 1 to ll_len2 step 2
	ll_source = (asc(mid(as_psw,i,1)) - asc('a'))*16 + (asc(mid(as_psw,i+1,1)) - asc('a'))
	ll_keychr = 256 + ll_key[ 1 + mod( (i -1)/2, ll_len1 ) ] - ll_source
	ls_text 	 = ls_text + char(ll_keychr)
next

return ls_text

end function

public function long of_shellprint (string as_file);return ShellExecute( handle(this), 'print', as_file, is_null, is_null, 0)

end function

public function integer of_sendkeys (string as_keys);//# [20210604] ck, call Wscript to process sendkeys and commands
//# keys := run=command/go=title/s=1000/&#47;&sol;
//#=============================================
OleObject ole_wsh

string ls_cmd
long  ll_conn, ll_ms, ll_cpu

ole_wsh = Create OleObject

ll_conn = ole_wsh.ConnectToNewObject("WScript.Shell")

if ll_conn<0 then return ll_conn

do 
	
	ls_cmd = trim( of_gettoken( as_keys, '/' ) )
	ls_cmd = of_replaceall( of_replaceall( ls_cmd, '&#47;', '/' ), '&sol;', '/' )
	
	if left(ls_cmd,4) = 'run=' then 
		ole_wsh.run( mid( ls_cmd, 5 ) )
	elseif left(ls_cmd,6) = 'title=' then 
		ole_wsh.AppActivate( mid( ls_cmd, 7 ) )
	elseif left(ls_cmd,2) = 's=' then 
		sleep( long( mid( ls_cmd, 3 ) ) )
	elseif left(ls_cmd,3) = 'ms=' then
		ll_cpu = cpu()
		ll_ms = long( mid( ls_cmd, 4 ) )
		do
			yield()
		loop while (cpu() - ll_cpu) < ll_ms
	else
		ole_wsh.SendKeys(ls_cmd)
	end if

loop while trim(as_keys)>''

ole_wsh.DisconnectObject()

return ll_conn
end function

public function long of_shellopen (string as_folder, string as_file, string as_parm);return ShellExecute( handle(this), 'open', as_file, as_parm, as_folder, 1)
end function

public function long of_shellexecute (string as_type, string as_cmd, string as_parm, string as_folder, integer ai_show);//# FUNCTION long ShellExecute (long hwnd, string lpOperation, string lpFile, string lpParameters,  string lpDirectory, integer nShowCmd ) 
//#  LIBRARY "shell32" ALIAS FOR ShellExecuteW
//#
//# ai_show -> nShowCmd := 0-hide, 1-normal, 2-min, 3-max
//# as_type -> lpOperation := open | runas |print | edit | explore | find
//#====================================================================

return ShellExecute( handle(this), as_type, as_cmd, as_parm, as_folder, ai_show)
end function

public function long of_shellrun (string as_cmd, string as_folder);return ShellExecute( handle(this), 'open', as_cmd, as_folder, is_null, 1)
end function

public function long of_shellexecute (string as_cmd, string as_parm, string as_folder);return ShellExecute( handle(this), 'open', as_cmd, as_parm, as_folder, 1)
end function

public function long of_shellrun (string as_cmd);return ShellExecute( handle(this), 'open', as_cmd, is_null, is_null, 1)
end function

public function string of_get_cmdline (ref string as_cmdline, boolean ab_quote);string ls_value
long ll_pos

as_cmdline = trim(as_cmdline)

if left(as_cmdline,1) = '"' then
	
	ll_pos = pos( as_cmdline, '"', 2 )
	if ll_pos > 0 then
		ls_value = left( as_cmdline, ll_pos )
		as_cmdline = trim( mid( as_cmdline, ll_pos + 1 ) )
	else
		ls_value = as_cmdline + '"'
		as_cmdline = ''
	end if
	
	if ab_quote then
		return ls_value
	else
		return mid( ls_value, 2, len(ls_value) -2 )
	end if
end if

return of_gettoken( as_cmdline, ' ' )


end function

on u_application.create
call super::create
TriggerEvent( this, "constructor" )
end on

on u_application.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

