## Introduction

[**PowerPage**](https://github.com/casualwriter/powerpage) is a lightweight web browser with DB capability 
and windows accessibility, for rapid development of javascript/html application.

Powerpage will connect to database, load startup page using Microsoft web-browser control (**equivalent to IE11**), 
and communicate with html/js page by ``pb:// or ps://`` protocol to provide below features

* (Run) Call External Program 
* (File) Access file system 
* (DB) Database Accessibility
* (PB) Call Powerbuilder Windows/Functions 
* (Misc) Global variables, sessions information 

### Features

* Portable solution. No need to install
* Single execute file. Quick Deployment.
* Code-and-Play instantly 
* Make use of all javascript library (which support IE11)
* Command Line for multiple purpose (e.g. save url page, generate PDF)
* Work with Powerbuilder (e.g. call powerbuilder window/function/datawindow)

ps: due to the limitation of Microsoft web-browser control, Powerpage web browser is **equivalent to IE11 (not chrome)**!

### Run Powerpage

Powerpage is a single executable program. No installation is needed, just download and run ``powerpage.exe``.

* Simply download from "release" folder, unzip the file, and run ``powerpage.exe``
* Source code and latest version can be downloaded from "source" folder. 

### Files

* ``powerpage.exe`` is the executable file of powerpage. (single executable file)
* ``powerpage.html`` is the startup html file (i.e. javascript/html application)
* ``powerpage.ini`` is the config file for DB connection and misc setup
* ``powerpage.js`` is the initial javascript lib for interface
* ``*.dll`` is Powerbuilder run-time files

* ``pp-markdown.html`` is pp-application of "Powerpage Markdown Editor"
* ``pp-web-crawler.html`` is pp-application of "Powerpage Web Crawler"
* ``pp-db-report.html`` is pp-application of "Powerpage DB Reports"


### How PowerPage work?

Powerpage open a window with MS WebBrowser Control. When HTML page is loaded, Powerpage will import ``powerpage.js`` 
to initialize ``pb`` javascript object to provide Powerpage interface.

HTML page may via the following channel to talk to main program

1. recommented call by javascript: ``pb.apiFunction()``, e.g. pb.run('notepad.exe')
2. by url: ``&lt;a href="pb://command/parameters">Text&lt;/a>`` or ``window.location = "pb://command/parameters"``
3. by change title: ``document.title = "pb://command/parameters"``

Powerpage will interpret and execute the command, and pass the result to HTML page by calling js function ``pb.router(callback, result, type, cmd)``

for example:

* Run notepad.exe to edit powerpage.ini -> ``javascript:pb.run('notepad.exe powerpage.ini')`` or ``pb://run/notepad.exe powerpage.ini``
* Run SQL1 and callback showData() -> ``javascript:pb.callback('showData').db.query(sql1)`` or ``pb://callback/showData/db/query/@sql1``  
* Run update SQL2 -> ``javascript:pb.db.execute(sql3)`` or ``pb://db/execute/@sql3``
* Call About window -> ``javascript:pb.window('w_about')`` or ``pb://window/w_about`` 

For more details, please refer to [API documentation](interface.md)

  
## Command Line

Beside running javascript applications, Powerpage has wide usage by using commandline parameters.

~~~
powerpage.exe /ini={ini-file} /url={start-url} /fullscreen /print /save={save-html} /pdf={output-pdf-file} /delay={1000}
~~~

* ``/ini={ini-file}`` specifies ini setting file. Aplication could be changed by change the ini file.
* ``/url={start-url}`` is used to specify startup link. Aplication could be changed by change startup link. 
* ``/fullscreen`` or ``/kiosk`` will run in fullscreen mode, useful for kiosk, or display board.
* ``/print`` will load startup url, print and close program.
* ``/save={save-html}`` will load startup url, save to html file, and close program. Useful for web-crawler
* ``/pdf={output-pdf-file}`` will load startup url, generate PDF file, and close program. useful for PDF generation.
* ``/delay={1000}`` specifies delay time (by milliseconds) for print/save/pdf options 

### Samples of using command-line

* ``powerpage.exe /url=pp-markdown.html`` run powerpage-markdown-editor
* ``powerpage.exe /url=pp-web-crawler.html`` run powerpage-web-crawler
* ``powerpage.exe /url=http://haodoo.net/`` print the page of haodoo.net
* ``powerpage.exe /url=http://haodoo.net/  /save=haodoo.html`` save the page of haodoo.net
* ``powerpage.exe /url=http://haodoo.net/  /pdf=haodoo.pdf`` save the page of haodoo.net to PDF file
* ``powerpage.exe /url=pp-kanban.html /fullscreen`` run Kanban display board in fullscreen mode
 
 
## Application Samples

Powerpage is released with some sample applications.

* [Screen](powerpage.jpg) -> [Powerpage](https://github.com/casualwriter) with self-demonstration
* [Screen](powerpage-markdown.jpg) -> [Powerpage - Markdown Editor](https://github.com/casualwriter/powerpage-markdown) 
* [Screen](powerpage-web-crawler.jpg) -> [Powerpage - Web Crawler](https://github.com/casualwriter/powerpage-web-crawler) 
 
 
## Modification History

* 2021/05/07, beta version, v0.41 
* 2021/05/14, beta version, v0.43, with markdown editor [powerpage-markdown](https://github.com/casualwriter/powerpage-markdown)
* 2021/05/25, beta version, v0.46, command for html printing
* 2021/06/03, beta version, v0.48, generate PDF report (using wkhtmltopdf.exe)
* 2021/06/16, beta version, v0.50, handle command line
* 2021/07/02, beta version, v0.54, crawl web function, add [powerpage-web-crawler](https://github.com/casualwriter/powerpage-web-crawler)
* 2021/07/08, beta version, v0.55, refine powerpage, update [powerpage-web-crawler](https://github.com/casualwriter/powerpage-web-crawler)
* 2021/07/20, beta version, v0.56, add pb://spider command; update [powerpage-web-crawler](https://github.com/casualwriter/powerpage-web-crawler)
* 2021/10/04, beta version, v0.57, code document frameword, update document


