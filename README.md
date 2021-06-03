## Introduction

[**PowerPage**](https://github.com/casualwriter/powerpage) is a lightweight web browser with DB capability 
and windows accessibility, for making Electron-like HTML/JS GUI apps

Powerpage will connect to database, and load startup page using MS web-browser control with new protocol pb:// or ps:// to provide below features
 
* (Run) Call External Program 
* (File) Access file system 
* (DB) Database Accessibility
* (PB) Call Powerbuilder Windows/Functions 
* (Misc) Variables, session information 

## Installation & Run

Powerpage is a single executable program. No installation is needed, Just download and run ``powerpage.exe``.

* Simply download from "release" folder, unzip the file, and run ``powerpage.exe``
* Source code and latest version can be downloaded from "source" folder. 


## Files

  * powerpage.exe  // powerpage executable file. (single file)
  * Powerpage.htlm // Startup html file
  * Powerpage.ini  // Ini file of powerpage
  * Powerpage.js   // Javascript lib of powerpage
  * *.dll          // Powerbuilder run-time files


## How PowerPage work?

Powerpage open a window with MS WebBrowser Control. When HTML page is loaded, Powerpage will import ``powerpage.js`` to initialize ``pb`` javascript object to provide Powerpage interface.

HTML page may via the following channel to talk to main program

1. by url: window.location = "pb://protocol/command"
2. by title: document.title = "pb://protocol/command"
3. by javascript pb.apiFunction()

Powerpage will interpret and execute the command, and pass the result to HTML page by calling js function ``pb.router( result, type, cmd)``

## Protocol Commands

Interface is provided by ``pb://`` protocol command, or javascript ``pb.`` API function call.  HTML Page may use 

``<a href="pb://protocol/command"> pb://protocol/command</a> `` or javascript:pb.apiFunction()`` to make powerpage API call.

for example:

* Run notepad.exe to edit powerpage.ini -> ``pb://run/notepad.exe powerpage.ini`` or ``javascript: pb.run('notepad.exe powerpage.ini')``
* Run SQL1 and callback showData() -> ``pb://callback/showData/sql/query/@sql1`` or ``javascript: pb.callback('showData').db.query(sql1)`` 
* Run update SQL2 -> ``pb://sql/execute/@sql2`` or  ``javascript: pb.db.execute(sql2)`` 

For more details, please refer to [API documentation](interface.md)


## Sample

* [Screen Layout](powerpage.jpg)
* [Powerpage - Markdown Editor](https://github.com/casualwriter/powerpage-md)


## Modification History

* 2021/05/07, beta version, v0.41 
* 2021/05/14, beta version, v0.43, with markdown editor [powerpage-md](https://github.com/casualwriter/powerpage-md)
* 2021/05/19, beta version, v0.45, minor fix.
* 2021/05/25, beta version, v0.46, command for html printing
* 2021/06/03, beta version, v0.48, generate PDF report (using wkhtmltopdf.exe)


