## Introduction

[**PowerPage**](https://github.com/casualwriter/powerpage) is a lightweight web browser with DB capability 
and windows accessibility, for making Electron-like HTML/JS GUI apps

Powerpage will connect to database, and load startup page by the setting of powerpage.ini, and open 
OLE web-browser with new protocol pb:// or ps:// to provide below features
 
* (Run) Call External Program 
* (File) Access file system 
* (DB) Database Accessibility
* (PB) Call Powerbuilder Windows/Functions 
* (Misc) Variables, session information 

### Files and Installation

* Simply download from "release" folder, and unzip the file, and run ``powerpage.exe``
* Source code, and latest version can be downloaded from "source" folder

### API and Interface

API call provide in pb:// protocol command, or javascript ``pb`` funciton call. 


#### Global Features (Callback, Prompt, @JsVar, Secured protocol)  

"Callback, Prompt/Confirm, @JsVar, Secured protocol" are supported in all commands. 

Description | pb protocol | javascript
------------|-------------|-----------------
Prompt for confirmation, then run command | pb://?Open notepad?/run/notepad.exe | pb.confirm('Open notepad').run('notepad.exe')  
Callback js function after run command | pb://callback/mycallback/run/calc.exe | pb.run('calc.exe','mycallback')  
use @jsVar as command parameter for long string | pb://sql/query/@sql1 | javascript:pb.db.query(sql1)  
``Secured``` Protocol to ask user login windows account first | ps://run/resmon.exe | pb.secure().run('resmon.exe')  


#### Run / RunAt / Shell

Run will call powerbuilder.run(), and RunAt will run program at its existing folder.
Shell command will be diverted to shell32.dll -> ShellExecuteW() 

Description | pb protocol | javascript
------------|-------------|-----------------
Run a program, e.g. resmon.exe | pb://run/mspaint.exe | javascript:pb.run('resmon.exe')  
Run command with parameter | pb://run/notepad.exe powerpage.html | pb.run('notepad.exe powerpage.html')  
Run program in its directory | pb://runat/c:\powerpage\powerpage.exe | pb.runat('c:\\powerpage\\powerpage.exe')  
Shell: Open File (same as start.exe [file]) | pb://shell/open/calc.exe | pb.shell.open('calc.exe')  
Shell: Open folder (e.g. c:\temp) | pb://shell/open/c:\temp | pb.shell.open('c:\\temp')  
Shell: Run program (similar to runat()) | pb://shell/run/c:\powerpage\powerpage.exe | pb.shell.run('c:\\powerpage\\powerpage.exe')  
Shell: Print File | pb://?Print PDF?/shell/print/powerpage.pdf | pb.confirm('Print PDF?').shell.print('powerpage.pdf')  

                                                               
#### File Accessibility

Description | pb protocol | javascript
------------|-------------|-----------------
Copy powerpage.ppg to newfile.html | pb://file/copy/powerpage.html/newfile.html | pb.file.copy( 'powerpage.html', 'newfile.html' )  
Move/Rename newfile.html to another.html | pb://file/move/newfile.html/another.html | pb.file.move( 'newfile.html', 'another.html' )  
Read another.html | pb://file/read/another.html | pb.file.read( 'another.html', callback )  
Write to another.html | pb://file/write/another.html/@sql1 | pb.file.write( 'another.html', sql1, callback )  
Append to another.html | pb://file/append/another.html/@sql2 | pb.file.append( 'another.html', sql2, callback )  
Delete another.html | pb://?sure to delete?/file/delete/another.html | pb.confirm('sure to delete?').file.delete( 'another.html', callback )  


#### Database Accessibility

Query from database, execute sql or stored procedure.

Description | pb protocol | javascript
------------|-------------|-----------------
run ah-hoc SQL, return string in json format | pb://json/select CategoryID, CategoryName from Categories | pb.db.json('select date(), now() ')  
query db by the sql stored in @sql1, return string in json format | pb://json/@sql1 | pb.db.json(sql1)  
alt query command: pb://sql/query = pb://json | pb://sql/query/@sql1 | pb.db.query(sql1) or pb.db.select(sql1)  
run SQL and return string in html table format | pb://table/@sql2 or pb://sql/html/@sql2 | pb.db.table(sql2) or pb.db.html(sql2)  
Execute update statement |pb://sql/execute/@sql3 | pb.db.execute(sql3) or javascript:pb.db.update(sql3)  
Prompt SQL for confirmation, then Execute update statement | pb://sql/prompt/@sql3 | pb.db.prompt(sql3) or pb.db.confirm(sql3)  
execute SQL by id, return json result | . | pb.db.executeById( sqlid, args[], callback )  
run SQL Query by id, return json result | . | pb.db.queryById( sqlid, args[], callback ) 
  

#### Work with Powerbuilder

This program is developed using Powerbuilder 10.5. It is supported to call powerbuilder customized window/function from html. 

Description | pb protocol | javascript
------------|-------------|-----------------
Open PB window object | pb://window/w_about | javascript:pb.window('w_about')  
Open PB window with parameters | pb://window/w_web_dialog/top=20,width=800,url=https://google.com | pb.window('w_web_dialog','left=50,height=500,url=https://google.com')  
Call PB Global Function | pb://function/f_get_product   | pb.function('f_get_product')  

#### Session / Global Variables / Pop HTML Dialog

Session is important for applicaiton development. After page loaded, 
``pb.session``` serves as session object sharing information between different pages.
 
Description | ini / url | javascript
------------|-------------|-----------------
initialized by powerpage.ini | [session] <br>var1 = name: PowerPage |  javascript:alert(pb.session.name) 
support json value. e.g. {"key":"value"} | [session]<br>var2 = user: { "id":"admin", "role":"admin" } | alert(JSON.stringify(pb.session.user))   
update session variables | pb://session/remarks/try update session remarks | pb.session('remarks','session remarks has been updated')  
open url in popup dialog (share session info) | pb://popup/height=400,url=dialog.html | pb.popup('width=800,url=dialog.html')
popup dialog with callback | pb://callback/mycallback/popup/height=400,url=dialog.html | pb.popup('width=500,url=dialog.html','mycallback')  



### Modification History

* 2021/05/07, beta version, v0.41 

### License

MIT
