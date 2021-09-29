## Overview (API)

Powerpage open a window with MS WebBrowser Control. When HTML page is loaded, Powerpage will import ``powerpage.js`` 
to initialize ``pb`` javascript object to provide Powerpage interface.

HTML page may via the following channel to talk to main program

1. recommented call by by javascript: ``pb.apiFunction()``, e.g. pb.run('notepad.exe')
2. by url: ``&lt;a href="pb://command/parameters">Text&lt;/a>`` or ``window.location = "pb://command/parameters"``
3. by change title: ``document.title = "pb://command/parameters"``

Powerpage will interpret and execute the command, and pass the result to HTML page by calling js function ``pb.router( result, type, cmd)``

for example:

* Run notepad.exe to edit powerpage.ini -> ``javascript:pb.run('notepad.exe powerpage.ini')`` or ``pb://run/notepad.exe powerpage.ini``
* Run SQL1 and callback showData() -> ``javascript:pb.callback('showData').db.query(sql1)`` or ``pb://callback/showData/db/query/@sql1``  
* Run update SQL2 -> ``javascript:pb.db.execute(sql3)`` or ``pb://db/execute/@sql3``
* Call About window -> ``javascript:pb.window('w_about')`` or ``pb://window/w_about`` 


## Global Features  

``Callback, Prompt/Confirm, @JsVar and Secure Protocol`` are supported in all commands. 

### Callback

* Description: Callback js function after run command 
* ``javascript:pb.callback('mycallback').run('mstsc.exe')`` 
* ``javascript:pb.callback('mycallback').run('cmd=notepad.exe,style=wait')`` 
* pb-protocal: ``pb://callback/mycallback/run/mstsc.exe`` 

### Prompt/Confirm

* Description: Prompt for confirmation, then run command 
* ``javascript:pb.confirm('Open notepad?').run('notepad.exe')``
* pb-protocol: ``pb://?Open notepad?/run/notepad.exe`` 

### @js Variable Replacement

* Description: use @jsVar to pass javascript vaiable as command parameter. very useful for long string.
* javascript: pb.db.query(sql1``) or pb.db.query(``'@sql1'``)
* pb-protocol: pb://sql/query/``@sql1``

### Secured protocol

* Description: ``Secured`` Protocol will prompt user login by windows account.
*  ``javascript:pb.secure().run('resmon.exe')``
* ps-protocol: ``ps://run/resmon.exe`` 


## Run / Shell 

-----------------------------------------------------
### pb.run( command )
### pb.run( cmd, path, style, callback ) 

* Description: Run a program, e.g. resmon.exe
* pb-protocol: `` pb://run/{command}`` or `` pb://run/cmd={command},path={path},style={style}`` 

~~~~
// Source Code (in powerpage.js)
pb.run = function ( cmd, path, style, callback ) { 
  if (arguments.length==1) {
    pb.submit( 'run', cmd ) 
  } else {
    var ls_opt = 'cmd=' + cmd + (path? ',path='+path : '' ) + (style? ',style='+style : '' )
    pb.submit( 'run', ls_opt, callback )
  } 
}
~~~~
 
##### Arguments

* {cmd}  // command 
* {path} // path to run the command
* {style} // style := [ normal | min | max | hide | wait ] 

##### Samples

* ``javascript:pb.run('resmon.exe')`` run resmon.exe
* ``javascript:pb.run('notepad.exe powerpage.html')`` run notepad to edit powerpage.html
* pb-protocol: ``pb://run/notepad.exe powerpage.html`` run notepad to edit powerpage.html
* ``javascript:pb.run('powerpage.exe', 'c:\app')`` run powerpage at c:\app
* ``javascript:pb.run('notepad.exe powerpage.html','.','max+wait','alert')`` edit edit powerpage.html and show status 

-----------------------------------------------------
### pb.shell(command)
### pb.shell(action, file, parm, path, show, callback)

* Description: calling window.shell object to "Open/Run/Print" an file. 
* pb-protocol: `` pb://shell/{command}`` or `` pb://shell/file={file},path={path},show={show},action={action}``

```
pb.shell = function ( action, file, parm, path, show, callback ) { 
  if (arguments.length==1) {
    pb.submit( 'shell', action )
  } else {
    var ls_opt = 'file=' + file + (action? ',action='+action : '' ) + (parm? ',parm='+parm : '' )
    pb.submit( 'shell', ls_opt + (path? ',path='+path : '' ) + (show? ',show='+show : '' ), callback )
  } 
}
```

##### Arguments

* {action}  // aciton := [ open | print | runas ]
* {file}  // file name  
* {path}  // path of the file
* {parm}  // parameters passed to the file
* {show}  // show (or style) := [ normal | min | max | hide | wait ] 


##### Samples 

* ``pb.shell('calc.exe')`` // run calc.exe
* ``pb.shell('open','calc.exe')``  // call calc.exe using shell-open (same as start.exe [file])
* ``pb.shell('run', 'c:\\app\\powerpage.exe')`` // shell-run program (similar to runat())
* ``pb://shell/run/c:\powerpage\powerpage.exe`` // shell-run program (similar to runat())    

-----------------------------------------------------
### pb.sendkeys(keys)

call sendkeys() function of Wscript Shell to send keystrokes.
 
keys := /run={cmd}/title={goto Title}/s={delay}/ms={delay ms}/Keystrokes

##### Samples 

* ``javascript:pb.sendkeys('/run=notepad.exe/title=Untitled - Notepad/s=2/this is a test')``
* ``pb://sendkeys/run=notepad.exe/title=Untitled - Notepad/s=2/this is a test``
* ``javascript:pb.sendkeys(keys)``  
* ``javascript:pb.sendkeys('@keys')`` or ``pb://sendkeys/@keys`` pass keystrokes by variable


## Database Accessibility

Query from database, execute sql or stored procedure.

-----------------------------------------------------
### pb.db.json( sql, callback )

-----------------------------------------------------
### pb.db.html( sql, callback )

-----------------------------------------------------
### pb.db.query( sql, callback )
### pb.db.select( sql, callback )

-----------------------------------------------------
### pb.db.update( sql, callback )
### pb.db.execute( sql, callback )

-----------------------------------------------------
### pb.db.prompt( sql, callback )
### pb.db.confirm( sql, callback )


Description | Protocol / javascript
------------|------------------------
run ah-hoc SQL, return string in json format | pb://json/select CategoryID, CategoryName from Categories <br> javascript: pb.db.json('select date(), now() ')  
query db by the sql stored in @sql1, return string in json format | pb://json/@sql1 <br> javascript: pb.db.json(sql1)  
alt query command: pb://sql/query = pb://json | pb://sql/query/@sql1 <br> javascript: pb.db.query(sql1) or pb.db.select(sql1)  
run SQL and return string in html table format | pb://table/@sql2 or pb://sql/html/@sql2 <br> javascript: pb.db.table(sql2) or pb.db.html(sql2)  
Execute update statement |pb://sql/execute/@sql3 <br> javascript: pb.db.execute(sql3) 
Prompt SQL for confirmation, then Execute update statement | pb://sql/prompt/@sql3 <br> javascript: pb.db.prompt(sql3) or pb.db.confirm(sql3)  
execute SQL by id, return json result | javascript: pb.db.executeById( sqlid, args[], callback )  
run SQL Query by id, return json result | javascript: pb.db.queryById( sqlid, args[], callback ) 
  

                                                             
## File Accessibility

-----------------------------------------------------
### pb.file.copy(from, to, callback)

-----------------------------------------------------
### pb.file.move(from, to, callback)

-----------------------------------------------------
### pb.file.exists(file, callback)

-----------------------------------------------------
### pb.file.read(file, callback)

-----------------------------------------------------
### pb.file.write(file, text, callback)

-----------------------------------------------------
### pb.file.append(file, text, callback)

-----------------------------------------------------
### pb.file.delete(file, callback)

-----------------------------------------------------
### pb.file.opendialog(ext, callback)

-----------------------------------------------------
### pb.file.savedialog(ext, callback)

-----------------------------------------------------
### pb.dir(action, folder, callback)

Description | Protocol / javascript
------------|------------------------
Copy powerpage.ppg to newfile.html | pb://file/copy/powerpage.html/newfile.html <br> javascript:pb.file.copy( 'powerpage.html', 'newfile.html' )  
Move/Rename newfile.html to another.html | pb://file/move/newfile.html/another.html <br> javascript:pb.file.move( 'newfile.html', 'another.html' )  
Read another.html | pb://file/read/another.html <br> javascript:pb.file.read( 'another.html', callback )  
Write to another.html | pb://file/write/another.html/@sql1 <br> javascript:pb.file.write( 'another.html', sql1, callback )  
Append to another.html | pb://file/append/another.html/@sql2 <br> javascript: pb.file.append( 'another.html', sql2, callback )  
Delete another.html | pb://?sure to delete?/file/delete/another.html <br> javascript: pb.confirm('sure to delete?').file.delete( 'another.html', callback )  


## Work with Powerbuilder

This program is developed using Powerbuilder 10.5. 
It is supported to call powerbuilder customized window/function from html. 

-----------------------------------------------------
### pb.window(win, args, callback)

* Open PB window with parameters
* pb://window/w_web_dialog/top=20,width=800,url=https://google.com 
* javascript: pb.window('w_web_dialog','left=50,height=500,url=https://google.com')  
* Open PB window object 
* pb://window/w_about 
* <br> javascript:pb.window('w_about')  

-----------------------------------------------------
### pb.func(name, args, callback)

* Not ready yet!!



## Misc Features

-----------------------------------------------------
### Session / Global Variables

``pb.session`` serves as session object sharing information between different pages. initialized by ``powerpage.ini``, e.g.

          [session]
          var1 = name: PowerPage 
          var2 = version: version 0.38, updated on 2021/05/05 
          var3 = remarks: this is a test message
          var4 = user: { "id":"admin", "role":"admin", "group":"IT" } 

to update session variables, may use protocol ``pb://session/remarks/new content`` or by javascript ``pb.session('remarks','new content')``   


-----------------------------------------------------
### pb.popup(url,callback) 

Pop HTML Dialog within pwoerpage

To open url in popup dialog (share session info), use protocol ``pb://popup/height=400,url=dialog.html`` or javascript ``pb.popup('width=800,url=dialog.html')`` 

To popup dialog with callback, by protocol ``pb://callback/mycallback/popup/height=400,url=dialog.html`` or 
by javascript ``pb.popup('width=500,url=dialog.html','mycallback') or pb.callback('mycallback').popup('width=500,url=dialog.html')``

-----------------------------------------------------
### pb.print(( opt, callback )

* Print (default, with prompt) => ``pb://print`` or js ``pb.print()``
* Print without prompt => ``pb://print.now`` or js ``pb.print('now')``
* Print Preview => ``pb://print/preview`` or js ``pb.print('preview')`` 
* Print Setup => ``pb://print/setup`` or js ``pb.print('setup')``

-----------------------------------------------------
### pb.pdf( opt, parm, callback )  

-----------------------------------------------------
### pb.pdf( opt, parm, callback )  


-----------------------------------------------------
### pb.spider


-----------------------------------------------------
## Modification History

* 2021/05/11  initial
* 2021/05/31  add print commands
* 2021/09/28  rewrite document


