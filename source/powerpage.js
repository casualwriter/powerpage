//========================================================================
// PB interface. 
// 20210301. ck.  pb.callback(), run commands, and all basic features
// 20210505. ck.  pb.session()
// 20210507. ck.  pb.console(), pb.eval() for console support
// 20210529. ck.  pb.print() 
//========================================================================
// pb main function, pb('varname') = js.varname, pb('#div') = getElementById
var pb = function (n) { return n[0]=='#'? document.getElementById(n.substr(2)) : window[n]; }

//=== show message for microhelp, internal error 
pb.microhelp = function (msg) { document.title='pb://microhelp/'+ msg } 
pb.error = function(code,msg) { pb.microhelp( '[error='+ code +'] ' + msg ) }

//=== router function for Powerbuilder, divert to callback 
pb.router = function ( name, result, type, url ) {
  if (typeof window[name] === "function") {
      window[name]( result, type, url );
  } else if (name) {
      alert( 'callback function ' + name + '() not found!\n\n type:' + type + ' from url: ' + url 
             + '\n function: '+name + '\n Result: \n\n' + result )
  } else if (type=='json'||type=='table'||type=='sql'||type=='file') {
      alert( 'callback (default)\n\n type:' + type + ' from url: ' + url 
             + '\n function: '+name + '\n Result: \n\n' + result )
  }  
}

//=== console support 
if (typeof console=="undefined") var console = { }

console.log = pb.console = function () {
  var i, msg = ''
  for (i=0; i < arguments.length; i++) {
    if (typeof arguments[i] === "object") {
      msg += (i==0?'':', ') + JSON.stringify(arguments[i])
    } else {  
      msg += (i==0?'':', ') + arguments[i]
    }
  }
  pb.microhelp( '> ' + msg )   
}

pb.eval = function (exp) {
  try {
    var result = eval(exp)
    pb.microhelp( exp  + (typeof result=="undefined"? '' : '|n= ' + (typeof result=='object'? JSON.stringify(result) : result ) ) )
  } catch (e) {
    pb.microhelp( exp  + '|nError: ' + e.message )      
  }  
}

//=== secure protocol support
pb.cmd = { protocol:'pb://' }
pb.secure = function() { pb.cmd.protocol = 'ps://' ; return pb }

//=== add Prompt or callback to parepare queue
pb.prompt = pb.confirm = function (msg) { pb.cmd.prompt = msg; return pb }
pb.callback = function (funcname) { pb.cmd.callback = funcname; return pb }
 
//=== submit command to Main Program. (support cmd history later)
pb.submit = function ( cmd, parm, callback ) { 
   pb.cmd.command = pb.cmd.prepare(callback) + cmd + '/' + encodeURIComponent(parm);
   window.location = pb.cmd.command
   return pb
}

//=== prepare command prefix with Prompt and callback
pb.cmd.prepare = function(callback) {
   pb.cmd.prefix = pb.cmd.protocol
   pb.cmd.prefix += (pb.cmd.prompt? '?' + pb.cmd.prompt + '?/' : '' )
   pb.cmd.callback = (callback||pb.cmd.callback)
   pb.cmd.prefix += (pb.cmd.callback? 'callback/'+pb.cmd.callback+'/' : '' )
   pb.cmd.prompt = pb.cmd.callback = null  
   return pb.cmd.prefix
}

//=== generate parameter string
pb.cmd.parameters = function(args) {
  if (!args) {
    return ''
  } else if (typeof args === "string" || typeof args === "number") {
    return "/" + args
  } else if (typeof args === "object") {
    var i, key='/';
    for (i=0; i<args.length; i++) { key += args[i]; }
    return key;
  } else {  
    pb.error( '01', "[error] unknow type of arguments! " + args )
  } 
}

//=== call run() commands
pb.run = function ( cmd, callback ) { pb.submit( 'run', cmd, callback ) }
pb.runat = function ( cmd, callback ) { pb.submit( 'run@', cmd, callback ) }   

//====== call wsh.sendkeys. pb://sendkeys/{run=cmd/title=activeApp}/s=sleep/keys}
pb.sendkeys = function (cmd) { pb.submit( 'sendkeys', cmd ) }

//=== shell functions
pb.shell = { name: 'shell functions' }
pb.shell.open = function (path, callback) { pb.submit( 'shell/open', path, callback ) };
pb.shell.max  = function (path, callback) { pb.submit( 'shell/max', path, callback ) };
pb.shell.print = function (path, callback) { pb.submit( 'shell/print', path, callback ) }; 
pb.shell.run = function (path, callback) { pb.submit( 'shell/run', path, callback ) };

//=== call Powerbuilder dialog, window, function
pb.dialog = function (win, args, callback) { pb.submit( 'dialog', win + pb.cmd.parameters(args), callback ) }
pb.window = function (win, args, callback) { pb.submit( 'window', win + pb.cmd.parameters(args), callback ) }
pb.function = function (func, args, callback) { pb.submit( 'function', win + pb.cmd.parameters(args), callback ) }
pb.popup = function (url,callback) { pb.submit( 'popup', url, callback ) }

//=== database function
pb.db = { name: 'database functions' }
pb.db.json  = function ( sql, callback ) { pb.submit( 'json', sql, callback ) };
pb.db.table = pb.db.html  = function ( sql, callback ) { pb.submit( 'table', sql, callback ) };
pb.db.query = pb.db.select = function ( sql, callback ) { pb.submit( 'json', sql, callback ) };  
pb.db.execute = pb.db.update = function ( sql, callback ) { pb.submit( 'sql/execute', sql, callback ) };
pb.db.confirm = pb.db.prompt = function ( sql, callback ) { pb.submit( 'sql/prompt', sql, callback ) };

//=== file functions
pb.file = { name: 'file functions' }
pb.file.copy = function (from, to, callback) { pb.submit( 'file/copy', from + '/' + to, callback ) }
pb.file.move = function (from, to, callback) { pb.submit( 'file/move', from + '/' + to, callback ) }
pb.file.read = function (file, callback) { pb.submit( 'file/read', file, callback ) }
pb.file.write = function (file, text, callback) { pb.submit( 'file/write', file + '/' +  text, callback ) }
pb.file.append = function (file, text, callback) { pb.submit( 'file/append', file + '/' +  text, callback ) }
pb.file.delete = function (file, callback) { pb.submit( 'file/delete', file, callback ) }
pb.file.opendialog = function (ext, callback) { pb.submit( 'file/opendialog', ext, callback ) }
pb.file.savedialog = function (ext, callback) { pb.submit( 'file/savedialog', ext, callback ) }

//==== pb session. 
// session(name) -> get value
// session(name,value) -> set value and sync to pb
// session(name,value,'host') -> call from pb(host), init value (no call back)    
pb.session = function ( name, value, from ) {
   if (arguments.length == 1) {
      return pb.session[name]
   } else if (arguments.length == 2) {
      pb.session[name] = (value.substr(0,1)=='{'? JSON.parse(value) : value )
      window.location='pb://session/'+ name + '/' + value;
   } else {
      pb.session[name] = (value.substr(0,1)=='{'? JSON.parse(value) : value )
   }
}

//====== print support. pb://print/[now|preview|setup]
pb.print = function ( opt, callback ) { pb.submit( 'print', opt, callback ) }

//====== PDF report. pb://pdf/[print|open|dialog|div]/{querySelector}
pb.pdf = function ( opt, parm, callback ) { 
  var html=''
  if (opt=='host') { 
     var divs = document.querySelectorAll(parm.replace(/\*/g,'#'))
     for (var i=0; i<divs.length; i++ ) html += divs[i].outerHTML + '\n'
     return html
  }    
  return pb.submit( 'pdf', opt + (parm? '/' + parm : '' ), callback ) 
}

//disable right-click
document.addEventListener("contextmenu", function(e){ e.preventDefault();}, false);

