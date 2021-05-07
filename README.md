## Introduction

[powerpage](https://github.com/casualwriter/powerpage) is a lightweight web browser with DB capability 
and windows accessibility, for rapid application development by html/css/js. 

Powerpage will connect to database, and load startup page by the setting of powerpage.ini, and open 
OLE web-browser with new protocol pb:// or ps:// to provide below features
 
* (Run) Call External Program 
* (File) Access file system 
* (DB) Database Accessibility
* (PB) Call Powerbuilder Windows/Functions 
* (Misc) Variables, session information 

### Files and Installation

* Simply download from "release" folder, and unzip the file
* Source code, and latest version can be downloaded from "source" folder

### API and Interface

API call provide in pb:// protocol command, or javascript ``pb`` funciton call. 

#### Global Features (Callback, Prompt, @JsVar, Secured protocol)  

Description | pb protocol | javascript
------------|-------------|-----------------
Prompt for confirmation, then run command | pb://?Open notepad?/run/notepad.exe | pb.confirm('Open notepad').run('notepad.exe')  
Callback js function after run command | pb://callback/mycallback/run/calc.exe | pb.run('calc.exe','mycallback')  

#### Run / RunAt / Shell

#### File Accessibility

#### Database Accessibility

#### Work with Powerbuilder

#### Session / Global Variables

#### Url Navigation / Misc

### Modification History

* 2021/05/07, beta version, v0.41 

### Lisense

MIT
