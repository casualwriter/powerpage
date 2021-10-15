//========================================================================
// PB interface. 
// 20210301. ck.  pb.callback(), run commands, and all basic features
// 20210505. ck.  pb.session()
// 20210507. ck.  pb.console(), pb.eval() for console support
// 20210529. ck.  pb.print(), pd.pdf() 
// 20210615. ck.  add pb.sendkeys(), rewrite pb.run(), pb.shell() 
// 20210701. ck.  add crawl(), spider() for web-crawler
// 20210710. ck.  simple polyfill for crawling IE7 pages
//========================================================================
// pb main function, pb('varname') = js.varname, pb('#div') = getElementById
var pb = function (n) { return n[0]=='#'? document.getElementById(n.substr(1)) : window[n]; }

//=== show message for microhelp, internal error 
pb.microhelp = function (msg) { document.title='pb://microhelp/'+ msg } 
pb.error = function(code,msg) { pb.microhelp( '[error='+ code +'] ' + msg ) }

//=== router function. call from Powerbuilder, divert to callback function
pb.router = function ( name, result, type, url ) {
  try {
    if (typeof window[name] === "function") {
        window[name]( result, type, url );
    } else if (name) {
        alert( 'callback function ' + name + '() not found!\n\n type:' + type + '\n cmd: ' + url 
               + '\n function: '+name + '\n result: \n\n' + result )
    } else if (typeof onCallback === "function") {
        onCallback( result, type, url );
    }
  } catch (e) {
    alert( 'Error in callback! \n\n Name: ' + name + '\nMessage:' + e.message )
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
  document.location='pb://microhelp/> ' + msg   
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
   pb.cmd.command = pb.cmd.prepare(callback) + cmd + '/' + encodeURIComponent(parm||'');
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

//=== call run(), shell(), sendkeys() commands
pb.runat = function ( cmd, callback ) { pb.submit( 'run@', cmd, callback ) }   

pb.run = function ( cmd, path, style, callback ) { 
  if (arguments.length==1) {
    pb.submit( 'run', cmd )   // compatible. pb://run/cmd, or pb.run('cmd=,path=')
  } else {
    var ls_opt = 'cmd=' + cmd + (path? ',path='+path : '' ) + (style? ',style='+style : '' )
    pb.submit( 'run', ls_opt, callback )
  } 
}

pb.shell = function ( action, file, parm, path, show, callback ) { 
  if (arguments.length==1) {
    pb.submit( 'shell', action )
  } else {
    var ls_opt = 'file=' + file + (action? ',action='+action : '' ) + (parm? ',parm='+parm : '' )
    pb.submit( 'shell', ls_opt + (path? ',path='+path : '' ) + (show? ',show='+show : '' ), callback )
  } 
}

pb.sendkeys = function (cmd) { pb.submit( 'sendkeys', cmd ) }

//=== call Powerbuilder window, function; pop url in dialog window
pb.window = function (win, args, callback) { pb.submit( 'window', win + pb.cmd.parameters(args), callback ) }
pb.func = function (name, args, callback) { pb.submit( 'func', name + pb.cmd.parameters(args), callback ) }
pb.popup = function (url,callback) { pb.submit( 'popup', url, callback ) }

//=== database function
pb.db = { name: 'database functions' }
pb.db.json = function ( sql, callback ) { pb.submit( 'db/json', sql, callback ) };
pb.db.html = pb.db.html  = function ( sql, callback ) { pb.submit( 'db/html', sql, callback ) };
pb.db.query = pb.db.select = function ( sql, callback ) { pb.submit( 'db/query', sql, callback ) };  
pb.db.execute = pb.db.update = function ( sql, callback ) { pb.submit( 'db/execute', sql, callback ) };
pb.db.confirm = pb.db.prompt = function ( sql, callback ) { pb.submit( 'db/prompt', sql, callback ) };

//=== file functions
pb.file = { name: 'file functions' }
pb.file.copy = function (from, to, callback) { pb.submit( 'file/copy', from + '/' + to, callback ) }
pb.file.move = function (from, to, callback) { pb.submit( 'file/move', from + '/' + to, callback ) }
pb.file.exists = function (file, callback) { pb.submit( 'file/exists', file, callback ) }
pb.file.read = function (file, callback) { pb.submit( 'file/read', file, callback ) }
pb.file.write = function (file, text, callback) { pb.submit( 'file/write', file + '/' +  text, callback ) }
pb.file.append = function (file, text, callback) { pb.submit( 'file/append', file + '/' +  text, callback ) }
pb.file.delete = function (file, callback) { pb.submit( 'file/delete', file, callback ) }
pb.file.opendialog = function (ext, callback) { pb.submit( 'file/opendialog', ext, callback ) }
pb.file.savedialog = function (ext, callback) { pb.submit( 'file/savedialog', ext, callback ) }
pb.dir = function (action, folder, callback) { pb.submit( 'dir/'+(action||''), folder, callback ) }

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

//====== HTML Selector funciton (selector for outerHTML, @select for innerText, null for header+body)======
pb.html = function (selector) {
  var i, divs, html=''
  if (selector[0]=='@') {
    divs = document.querySelectorAll(selector.substr(1).replace(/\$/g,'#'))
    for (i=0; i<divs.length; i++ ) html += divs[i].innerText + '\n'
  } else if (selector) {
    divs = document.querySelectorAll(selector.replace(/\$/g,'#'))
    for (i=0; i<divs.length; i++ ) html += divs[i].outerHTML + '\n'
  } else {
    html = '<!DOCTYPE html>\n' + document.head.outerHTML + '\n' + document.body.outerHTML + '\n'
  } 
  return html
}
   
//====== print support. pb://print/[now|preview|setup]
pb.print = function ( opt, callback ) { pb.submit( 'print', opt, callback ) }

//====== PDF report. pb://pdf/[print|open|dialog|div]/{querySelector}
pb.pdf = function ( opt, parm, callback ) {  return pb.submit( 'pdf', opt + (parm? '/' + parm : '' ), callback ) }

// spider protocol
pb.spider = function ( url, key, callback ) { pb.submit( 'spider', 'key='+key+'; url='+url, callback ) }

// disable right-click
document.addEventListener("contextmenu", function(e){ e.preventDefault();}, false);

//====== [not-use] grab data for web crawler, key:=name1=select1|name2=select2;
pb.crawlData = function ( key ) {
  var i, item, divs, name, css, text, html='', result={}
  var keys = key.split('|')
  
  for (var k in keys) {
    name = keys[k].split('=')[0].trim()
    css  = (keys[k].split('=')[1]).trim().replace(/\@/g,'#')
    divs = document.querySelectorAll( css )
    for (text='', i=0; i<divs.length; i++) {
      text += (i==0?'':'\n') + divs[i].innerText
      html += divs[i].outerHTML + '\n'
    }   
    result[name] = text
  }
  
  result.html = html
  return JSON.stringify(result)
}

//====== function for web crawler (poup/mode=crawl), key:=body|css-selector 
pb.crawl = function ( key ) {
  var i, text='', html='', links=[], divs=[], url  
  try {
    divs = (key=='a'? document.getElementsByTagName('a') : document.querySelectorAll(key||'body'))
    for (i=0; i<divs.length; i++) { 
      text += divs[i].innerText + '\n'
      html += divs[i].outerHTML + '\n'
      if (typeof divs[i].href=="string") links.push( { url: decodeURI(divs[i].href), text:divs[i].innerText } );
    }
  } catch (e) {
    html = text = 'Error: ' + e.message 
  }   
  return JSON.stringify( { url:location.href, title:document.title, text:text, html:html, links:links } )
}

// simple polyfill for crawling IE7 pages
// querySelectorAll() from https://github.com/inexorabletash/polyfill/blob/master/polyfill.js  (buggy)
if (!document.querySelectorAll) {
    document.querySelectorAll = function (selectors) {
        var style = document.createElement('style'), elements = [], element;
        document.documentElement.firstChild.appendChild(style);
        document._qsa = [];

        style.styleSheet.cssText = selectors + '{x-qsa:expression(document._qsa && document._qsa.push(this))}';
        window.scrollBy(0, 0);
        style.parentNode.removeChild(style);

        while (document._qsa.length) {
            element = document._qsa.shift();
            element.style.removeAttribute('x-qsa');
            elements.push(element);
        }
        document._qsa = null;
        return elements;
    };
}

if (typeof JSON === "undefined" ) {
  JSON = {}
  JSON.stringify = function (value) {
      var tmp = [], res = '[';
      if (value == null) return 'null';
      if (typeof value === 'number') return value.toString();
      if (typeof value === 'boolean') return value.toString();
      if ( (typeof value == "object") && (typeof value.length == "undefined") ) {
        for (var k in value) {
           tmp.push( JSON.stringify(k) + ': ' + JSON.stringify(value[k]));
          }
        return '{' + tmp.join(', ') + '}';
      } else if ( (typeof value == "object") && (value.length>=0) ) {
          for (var i = 0; i < value.length; i++) res += (i ? ', ' : '') + JSON.stringify(value[i]);
          return res + ']';
      } 
      return '"' + value.toString().replace(/\\/g,'\\').replace(/\"/g,'\\"').replace(/(\r\n|\r|\n)/g,'\\n') + '"';
  }
}
