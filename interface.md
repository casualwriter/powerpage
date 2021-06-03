## API documentation

Interface is provided by ``pb://`` protocol command, or javascript ``pb.`` API function call.  HTML Page may use 

``<a href="pb://protocol/command"> pb://protocol/command</a> `` or javascript:pb.apiFunction()`` to make powerpage API call.

for example:

* Run notepad.exe to edit powerpage.ini -> ``pb://run/notepad.exe powerpage.ini`` or ``javascript: pb.run('notepad.exe powerpage.ini')``
* Run SQL1 and callback showData() -> ``pb://callback/showData/sql/query/@sql1`` or ``javascript: pb.callback('showData').db.query(sql1)`` 
* Run update SQL2 -> ``pb://sql/execute/@sql2`` or  ``javascript: pb.db.execute(sql2)`` 

### How PowerPage work?

Powerpage main program is window with MS OLE Web brwoser. HTML page may via the following channel to talk to main program

1. window.location = "pb://protocol/command"
2. doument.title = "pb://protocol/command"

Powerpage will interpret and execute command, and pass the result to HTML page by calling js function ``pb.router( result, type, cmd)``

When HTML page load, powerpage will import ``powerpage.js`` to initalize ``pb`` javascript object to provide powerpage interface.


### Global Features (Callback, Prompt, @JsVar, Secured protocol)  

"Callback, Prompt/Confirm, @JsVar, Secured protocol" are supported in all commands. 

Description | Protocol / javascript
------------|------------------------
Prompt for confirmation, then run command | pb://?Open notepad?/run/notepad.exe <br> javascript: pb.confirm('OpenNotepad').run('notepad.exe')  
Callback js function after run command | pb://callback/mycallback/run/calc.exe <br> javascript: pb.callback('mycallback').run('calc.exe')  
use @jsVar as command parameter for long string | pb://sql/query/@sql1 <br> javascript:pb.db.query('@sql1') <<br> or javascript: pb.db.query(sql1) 
``Secured`` Protocol (Prompt user login by windows account) | ps://run/resmon.exe <br> javascript: pb.secure().run('resmon.exe')  


#### Run Program

Description | Protocol / javascript
------------|---------------------------
Run a program, e.g. resmon.exe | pb://run/mspaint.exe <br> javascript: pb.run('resmon.exe')  
Run command with parameter | pb://run/notepad.exe powerpage.html <br> javascript: pb.run('notepad.exe powerpage.html')  
Run program in its directory | pb://runat/c:\powerpage\powerpage.exe <br> javascript: pb.runat('c:\\powerpage\\powerpage.exe')  
Shell: Open File (same as start.exe [file]) | pb://shell/open/calc.exe <br> javascript: pb.shell.open('calc.exe')  
Shell: Run program (similar to runat()) | pb://shell/run/c:\powerpage\powerpage.exe <br> javascript: pb.shell.run('c:\\powerpage\\powerpage.exe')  

                                                               
#### File Accessibility

Description | Protocol / javascript
------------|------------------------
Copy powerpage.ppg to newfile.html | pb://file/copy/powerpage.html/newfile.html <br> javascript:pb.file.copy( 'powerpage.html', 'newfile.html' )  
Move/Rename newfile.html to another.html | pb://file/move/newfile.html/another.html <br> javascript:pb.file.move( 'newfile.html', 'another.html' )  
Read another.html | pb://file/read/another.html <br> javascript:pb.file.read( 'another.html', callback )  
Write to another.html | pb://file/write/another.html/@sql1 <br> javascript:pb.file.write( 'another.html', sql1, callback )  
Append to another.html | pb://file/append/another.html/@sql2 <br> javascript: pb.file.append( 'another.html', sql2, callback )  
Delete another.html | pb://?sure to delete?/file/delete/another.html <br> javascript: pb.confirm('sure to delete?').file.delete( 'another.html', callback )  


#### Database Accessibility

Query from database, execute sql or stored procedure.

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
  

#### Work with Powerbuilder

This program is developed using Powerbuilder 10.5. It is supported to call powerbuilder customized window/function from html. 

Description | Protocol / javascript
------------|---------------------------
Open PB window object | pb://window/w_about <br> javascript:pb.window('w_about')  
Open PB window with parameters | pb://window/w_web_dialog/top=20,width=800,url=https://google.com <br> javascript: pb.window('w_web_dialog','left=50,height=500,url=https://google.com')  
Call PB Global Function | pb://function/f_get_product   <br> javascript: pb.function('f_get_product')  

#### Session / Global Variables

``pb.session`` serves as session object sharing information between different pages. initialized by ``powerpage.ini``, e.g.

          [session]
          var1 = name: PowerPage 
          var2 = version: version 0.38, updated on 2021/05/05 
          var3 = remarks: this is a test message
          var4 = user: { "id":"admin", "role":"admin", "group":"IT" } 

to update session variables, may use protocol ``pb://session/remarks/new content`` or by javascript ``pb.session('remarks','new content')``   

#### Pop HTML Dialog

To open url in popup dialog (share session info), use protocol ``pb://popup/height=400,url=dialog.html`` or javascript ``pb.popup('width=800,url=dialog.html')`` 

To popup dialog with callback, by protocol ``pb://callback/mycallback/popup/height=400,url=dialog.html`` or 
by javascript ``pb.popup('width=500,url=dialog.html','mycallback') or pb.callback('mycallback').popup('width=500,url=dialog.html')``

#### Print / Print Preview

* Print (default, with prompt) => ``pb://print`` or js ``pb.print()``
* Print without prompt => ``pb://print.now`` or js ``pb.print('now')``
* Print Preview => ``pb://print/preview`` or js ``pb.print('preview')`` 
* Print Setup => ``pb://print/setup`` or js ``pb.print('setup')``

#### PDF Report

Powerpage using ``wkhtmltopdf.exe`` to generate PDF report. please setup the path in INI file. You may also setup "pdf-preview" for preview window, and "pdf-timeout" if need.

~~~
[system]
pdf-factory=C:\PortableWork\wkhtmltox\wkhtmltopdf.exe
pdf-preview=width=1024,height=768
pdf-timeout=10
~~~

* Generate PDF report, (by default, preview PDF in browser) => ``pb://pdf`` or js ``pb.pdf()``
* Generate PDF, and open (=shell.open, open by installed PDF reader) => ``pb://pdf/open`` or js ``pb.pdf('open')``
* Generate PDF, and print (=shell.print, print by installed PDF reader) => ``pb://pdf/print`` or js ``pb.pdf('print')``
* Generate PDF, open in browser, and call print dialog => ``pb://pdf/dialog`` or js ``pb.pdf('dialog')``
* Generate PDF with selected elements => ``pb://div/*elm-id1,*elm-id2,.class,p`` or js ``pb.pdf( 'div', '#elm-id1,#elm-id2,.class,p' )``


### Modification History

* 2021/05/11  initial
* 2021/05/31  add print commands  
* 2021/06/03  add PDF report generation, and pdf print support 




