/*
	Copyright (c) 2004-2006, The Dojo Foundation
	All Rights Reserved.

	Licensed under the Academic Free License version 2.1 or above OR the
	modified BSD license. For more information on Dojo licensing, see:

		http://dojotoolkit.org/community/licensing.shtml
*/

/*
	This is a compiled version of Dojo, built for deployment and not for
	development. To get an editable version, please visit:

		http://dojotoolkit.org

	for documentation and information on getting the source.
*/

if(typeof dojo=="undefined"){
var dj_global=this;
var dj_currentContext=this;
function dj_undef(_1,_2){
return (typeof (_2||dj_currentContext)[_1]=="undefined");
}
if(dj_undef("djConfig",this)){
var djConfig={};
}
if(dj_undef("dojo",this)){
var dojo={};
}
dojo.global=function(){
return dj_currentContext;
};
dojo.locale=djConfig.locale;
dojo.version={major:0,minor:0,patch:0,flag:"dev",revision:Number("$Rev: 7460 $".match(/[0-9]+/)[0]),toString:function(){
with(dojo.version){
return major+"."+minor+"."+patch+flag+" ("+revision+")";
}
}};
dojo.getObject=function(_3,_4,_5,_6){
var _7,_8;
if(typeof _3!="string"){
return undefined;
}
_7=_5;
if(!_7){
_7=dojo.global();
}
var _9=_3.split("."),i=0,_b,_c,_d;
do{
_b=_7;
_d=_9[i];
_c=_7[_9[i]];
if((_4)&&(!_c)){
_c=_7[_9[i]]={};
}
_7=_c;
i++;
}while(i<_9.length&&_7);
_8=_7;
_7=_b;
return (_6)?{obj:_7,prop:_d}:_8;
};
dojo.exists=function(_e,_f){
if(typeof _f=="string"){
dojo.deprecated("dojo.exists(obj, name)","use dojo.exists(name, obj, /*optional*/create)","0.6");
var tmp=_e;
_e=_f;
_f=tmp;
}
return (!!dojo.getObject(_e,false,_f));
};
dojo.evalProp=function(_11,_12,_13){
dojo.deprecated("dojo.evalProp","just use hash syntax. Sheesh.","0.6");
return _12[_11]||(_13?(_12[_11]={}):undefined);
};
dojo.parseObjPath=function(_14,_15,_16){
dojo.deprecated("dojo.parseObjPath","use dojo.getObject(path, create, context, true)","0.6");
return dojo.getObject(_14,_16,_15,true);
};
dojo.evalObjPath=function(_17,_18){
dojo.deprecated("dojo.evalObjPath","use dojo.getObject(path, create)","0.6");
return dojo.getObject(_17,_18);
};
dojo.errorToString=function(_19){
return (_19["message"]||_19["description"]||_19);
};
dojo.raise=function(_1a,_1b){
if(_1b){
_1a=_1a+": "+dojo.errorToString(_1b);
}else{
_1a=dojo.errorToString(_1a);
}
try{
if(djConfig.isDebug){
dojo.hostenv.println("FATAL exception raised: "+_1a);
}
}
catch(e){
}
throw _1b||Error(_1a);
};
dojo.debug=function(){
};
dojo.debugShallow=function(obj){
};
dojo.profile={start:function(){
},end:function(){
},stop:function(){
},dump:function(){
}};
function dj_eval(_1d){
return dj_global.eval?dj_global.eval(_1d):eval(_1d);
}
dojo.unimplemented=function(_1e,_1f){
var _20="'"+_1e+"' not implemented";
if(_1f!=null){
_20+=" "+_1f;
}
dojo.raise(_20);
};
dojo.deprecated=function(_21,_22,_23){
var _24="DEPRECATED: "+_21;
if(_22){
_24+=" "+_22;
}
if(_23){
_24+=" -- will be removed in version: "+_23;
}
dojo.debug(_24);
};
dojo.render=(function(){
function vscaffold(_25,_26){
var tmp={capable:false,support:{builtin:false,plugin:false},prefixes:_25};
for(var i=0;i<_26.length;i++){
tmp[_26[i]]=false;
}
return tmp;
}
return {name:"",ver:dojo.version,os:{win:false,linux:false,osx:false},html:vscaffold(["html"],["ie","opera","khtml","safari","moz"]),svg:vscaffold(["svg"],["corel","adobe","batik"]),vml:vscaffold(["vml"],["ie"]),swf:vscaffold(["Swf","Flash","Mm"],["mm"]),swt:vscaffold(["Swt"],["ibm"])};
})();
dojo.hostenv=(function(){
var _29={isDebug:false,allowQueryConfig:false,baseScriptUri:"",baseRelativePath:"",libraryScriptUri:"",iePreventClobber:false,ieClobberMinimal:true,preventBackButtonFix:true,delayMozLoadingFix:false,searchIds:[],parseWidgets:true};
if(typeof djConfig=="undefined"){
djConfig=_29;
}else{
for(var _2a in _29){
if(typeof djConfig[_2a]=="undefined"){
djConfig[_2a]=_29[_2a];
}
}
}
return {name_:"(unset)",version_:"(unset)",getName:function(){
return this.name_;
},getVersion:function(){
return this.version_;
},getText:function(uri){
dojo.unimplemented("getText","uri="+uri);
}};
})();
dojo.hostenv.getBaseScriptUri=function(){
if(djConfig.baseScriptUri.length){
return djConfig.baseScriptUri;
}
var uri=new String(djConfig.libraryScriptUri||djConfig.baseRelativePath);
if(!uri){
dojo.raise("Nothing returned by getLibraryScriptUri(): "+uri);
}
djConfig.baseScriptUri=djConfig.baseRelativePath;
return djConfig.baseScriptUri;
};
(function(){
var _2d={pkgFileName:"__package__",loading_modules_:{},loaded_modules_:{},addedToLoadingCount:[],removedFromLoadingCount:[],inFlightCount:0,modulePrefixes_:{dojo:{name:"dojo",value:"src"}},registerModulePath:function(_2e,_2f){
this.modulePrefixes_[_2e]={name:_2e,value:_2f};
},moduleHasPrefix:function(_30){
var mp=this.modulePrefixes_;
return Boolean(mp[_30]&&mp[_30].value);
},getModulePrefix:function(_32){
if(this.moduleHasPrefix(_32)){
return this.modulePrefixes_[_32].value;
}
return _32;
},getTextStack:[],loadUriStack:[],loadedUris:[],post_load_:false,modulesLoadedListeners:[],unloadListeners:[],loadNotifying:false};
for(var _33 in _2d){
dojo.hostenv[_33]=_2d[_33];
}
})();
dojo.hostenv.loadPath=function(_34,_35,cb){
var uri;
if(_34.charAt(0)=="/"||_34.match(/^\w+:/)){
uri=_34;
}else{
uri=this.getBaseScriptUri()+_34;
}
if(djConfig.cacheBust&&dojo.render.html.capable){
uri+="?"+String(djConfig.cacheBust).replace(/\W+/g,"");
}
try{
return !_35?this.loadUri(uri,cb):this.loadUriAndCheck(uri,_35,cb);
}
catch(e){
dojo.debug(e);
return false;
}
};
dojo.hostenv.loadUri=function(uri,cb){
if(this.loadedUris[uri]){
return true;
}
var _3a=this.getText(uri,null,true);
if(!_3a){
return false;
}
this.loadedUris[uri]=true;
if(cb){
_3a="("+_3a+")";
}
var _3b=dj_eval(_3a);
if(cb){
cb(_3b);
}
return true;
};
dojo.hostenv.loadUriAndCheck=function(uri,_3d,cb){
var ok=true;
try{
ok=this.loadUri(uri,cb);
}
catch(e){
dojo.debug("failed loading ",uri," with error: ",e);
}
return Boolean(ok&&this.findModule(_3d,false));
};
dojo.loaded=function(){
};
dojo.unloaded=function(){
};
dojo.hostenv.loaded=function(){
this.loadNotifying=true;
this.post_load_=true;
var mll=this.modulesLoadedListeners;
for(var x=0;x<mll.length;x++){
mll[x]();
}
this.modulesLoadedListeners=[];
this.loadNotifying=false;
dojo.loaded();
};
dojo.hostenv.unloaded=function(){
var mll=this.unloadListeners;
while(mll.length){
(mll.pop())();
}
dojo.unloaded();
};
dojo.addOnLoad=function(obj,_44){
var dh=dojo.hostenv;
if(arguments.length==1){
dh.modulesLoadedListeners.push(obj);
}else{
if(arguments.length>1){
dh.modulesLoadedListeners.push(function(){
obj[_44]();
});
}
}
if(dh.post_load_&&dh.inFlightCount==0&&!dh.loadNotifying){
dh.callLoaded();
}
};
dojo.addOnUnload=function(obj,_47){
var dh=dojo.hostenv;
if(arguments.length==1){
dh.unloadListeners.push(obj);
}else{
if(arguments.length>1){
dh.unloadListeners.push(function(){
obj[_47]();
});
}
}
};
dojo.hostenv.modulesLoaded=function(){
if(this.post_load_){
return;
}
if(this.loadUriStack.length==0&&this.getTextStack.length==0){
if(this.inFlightCount>0){
dojo.debug("files still in flight!");
return;
}
dojo.hostenv.callLoaded();
}
};
dojo.hostenv.callLoaded=function(){
if(typeof setTimeout=="object"||(djConfig["useXDomain"]&&dojo.render.html.opera)){
setTimeout("dojo.hostenv.loaded();",0);
}else{
dojo.hostenv.loaded();
}
};
dojo.hostenv.getModuleSymbols=function(_49){
var _4a=_49.split(".");
for(var i=_4a.length;i>0;i--){
var _4c=_4a.slice(0,i).join(".");
if((i==1)&&!this.moduleHasPrefix(_4c)){
_4a[0]="../"+_4a[0];
}else{
var _4d=this.getModulePrefix(_4c);
if(_4d!=_4c){
_4a.splice(0,i,_4d);
break;
}
}
}
return _4a;
};
dojo.hostenv._global_omit_module_check=false;
dojo.hostenv.loadModule=function(_4e,_4f,_50){
if(!_4e){
return;
}
_50=this._global_omit_module_check||_50;
var _51=this.findModule(_4e,false);
if(_51){
return _51;
}
if(dj_undef(_4e,this.loading_modules_)){
this.addedToLoadingCount.push(_4e);
}
this.loading_modules_[_4e]=1;
var _52=_4e.replace(/\./g,"/")+".js";
var _53=_4e.split(".");
var _54=this.getModuleSymbols(_4e);
var _55=((_54[0].charAt(0)!="/")&&!_54[0].match(/^\w+:/));
var _56=_54[_54.length-1];
var ok;
if(_56=="*"){
_4e=_53.slice(0,-1).join(".");
while(_54.length){
_54.pop();
_54.push(this.pkgFileName);
_52=_54.join("/")+".js";
if(_55&&_52.charAt(0)=="/"){
_52=_52.slice(1);
}
ok=this.loadPath(_52,!_50?_4e:null);
if(ok){
break;
}
_54.pop();
}
}else{
_52=_54.join("/")+".js";
_4e=_53.join(".");
var _58=!_50?_4e:null;
ok=this.loadPath(_52,_58);
if(!ok&&!_4f){
_54.pop();
while(_54.length){
_52=_54.join("/")+".js";
ok=this.loadPath(_52,_58);
if(ok){
break;
}
_54.pop();
_52=_54.join("/")+"/"+this.pkgFileName+".js";
if(_55&&_52.charAt(0)=="/"){
_52=_52.slice(1);
}
ok=this.loadPath(_52,_58);
if(ok){
break;
}
}
}
if(!ok&&!_50){
dojo.raise("Could not load '"+_4e+"'; last tried '"+_52+"'");
}
}
if(!_50&&!this["isXDomain"]){
_51=this.findModule(_4e,false);
if(!_51){
dojo.raise("symbol '"+_4e+"' is not defined after loading '"+_52+"'");
}
}
return _51;
};
dojo.hostenv.startPackage=function(_59){
var _5a=String(_59);
var _5b=_5a;
var _5c=_59.split(/\./);
if(_5c[_5c.length-1]=="*"){
_5c.pop();
_5b=_5c.join(".");
}
var _5d=dojo.getObject(_5b,true);
this.loaded_modules_[_5a]=_5d;
this.loaded_modules_[_5b]=_5d;
return _5d;
};
dojo.hostenv.findModule=function(_5e,_5f){
var lmn=String(_5e);
if(this.loaded_modules_[lmn]){
return this.loaded_modules_[lmn];
}
if(_5f){
dojo.raise("no loaded module named '"+_5e+"'");
}
return null;
};
dojo.kwCompoundRequire=function(_61){
var _62=_61["common"]||[];
var _63=_62.concat(_61[dojo.hostenv.name_]||_61["default"]||[]);
for(var x=0;x<_63.length;x++){
var _65=_63[x];
if(_65.constructor==Array){
dojo.hostenv.loadModule.apply(dojo.hostenv,_65);
}else{
dojo.hostenv.loadModule(_65);
}
}
};
dojo.require=function(_66){
dojo.hostenv.loadModule.apply(dojo.hostenv,arguments);
};
dojo.requireIf=function(_67,_68){
var _69=arguments[0];
if((_69===true)||(_69=="common")||(_69&&dojo.render[_69].capable)){
var _6a=[];
for(var i=1;i<arguments.length;i++){
_6a.push(arguments[i]);
}
dojo.require.apply(dojo,_6a);
}
};
dojo.requireAfterIf=dojo.requireIf;
dojo.provide=function(_6c){
return dojo.hostenv.startPackage.apply(dojo.hostenv,arguments);
};
dojo.registerModulePath=function(_6d,_6e){
return dojo.hostenv.registerModulePath(_6d,_6e);
};
if(djConfig["modulePaths"]){
for(var param in djConfig["modulePaths"]){
dojo.registerModulePath(param,djConfig["modulePaths"][param]);
}
}
dojo.requireLocalization=function(_6f,_70,_71,_72){
dojo.require("dojo.i18n.loader");
dojo.i18n._requireLocalization.apply(dojo.hostenv,arguments);
};
}
if(typeof window!="undefined"){
(function(){
if(djConfig.allowQueryConfig){
var _73=document.location.toString();
var _74=_73.split("?",2);
if(_74.length>1){
var _75=_74[1];
var _76=_75.split("&");
for(var x in _76){
var sp=_76[x].split("=");
if((sp[0].length>9)&&(sp[0].substr(0,9)=="djConfig.")){
var opt=sp[0].substr(9);
try{
djConfig[opt]=eval(sp[1]);
}
catch(e){
djConfig[opt]=sp[1];
}
}
}
}
}
if(((djConfig["baseScriptUri"]=="")||(djConfig["baseRelativePath"]==""))&&(document&&document.getElementsByTagName)){
var _7a=document.getElementsByTagName("script");
var _7b=/(__package__|dojo|bootstrap1)\.js([\?\.]|$)/i;
for(var i=0;i<_7a.length;i++){
var src=_7a[i].getAttribute("src");
if(!src){
continue;
}
var m=src.match(_7b);
if(m){
var _7f=src.substring(0,m.index);
if(src.indexOf("bootstrap1")>-1){
_7f+="../";
}
if(!this["djConfig"]){
djConfig={};
}
if(djConfig["baseScriptUri"]==""){
djConfig["baseScriptUri"]=_7f;
}
if(djConfig["baseRelativePath"]==""){
djConfig["baseRelativePath"]=_7f;
}
break;
}
}
}
var dr=dojo.render;
var drh=dojo.render.html;
var drs=dojo.render.svg;
var dua=(drh.UA=navigator.userAgent);
var dav=(drh.AV=navigator.appVersion);
var t=true;
var f=false;
drh.capable=t;
drh.support.builtin=t;
dr.ver=parseFloat(drh.AV);
dr.os.mac=dav.indexOf("Macintosh")>=0;
dr.os.win=dav.indexOf("Windows")>=0;
dr.os.linux=dav.indexOf("X11")>=0;
drh.opera=dua.indexOf("Opera")>=0;
drh.khtml=(dav.indexOf("Konqueror")>=0)||(dav.indexOf("Safari")>=0);
drh.safari=dav.indexOf("Safari")>=0;
var _87=dua.indexOf("Gecko");
drh.mozilla=drh.moz=(_87>=0)&&(!drh.khtml);
if(drh.mozilla){
drh.geckoVersion=dua.substring(_87+6,_87+14);
}
drh.ie=(document.all)&&(!drh.opera);
drh.ie50=drh.ie&&dav.indexOf("MSIE 5.0")>=0;
drh.ie55=drh.ie&&dav.indexOf("MSIE 5.5")>=0;
drh.ie60=drh.ie&&dav.indexOf("MSIE 6.0")>=0;
drh.ie70=drh.ie&&dav.indexOf("MSIE 7.0")>=0;
var cm=document["compatMode"];
drh.quirks=(cm=="BackCompat")||(cm=="QuirksMode")||drh.ie55||drh.ie50;
dojo.locale=dojo.locale||(drh.ie?navigator.userLanguage:navigator.language).toLowerCase();
dr.vml.capable=drh.ie;
drs.capable=f;
drs.support.plugin=f;
drs.support.builtin=f;
var _89=window["document"];
var tdi=_89["implementation"];
if((tdi)&&(tdi["hasFeature"])&&(tdi.hasFeature("org.w3c.dom.svg","1.0"))){
drs.capable=t;
drs.support.builtin=t;
drs.support.plugin=f;
}
if(drh.safari){
var tmp=dua.split("AppleWebKit/")[1];
var ver=parseFloat(tmp.split(" ")[0]);
if(ver>=420){
drs.capable=t;
drs.support.builtin=t;
drs.support.plugin=f;
}
}else{
}
})();
dojo.hostenv.startPackage("dojo.hostenv");
dojo.render.name=dojo.hostenv.name_="browser";
dojo.hostenv.searchIds=[];
dojo.hostenv._XMLHTTP_PROGIDS=["Msxml2.XMLHTTP","Microsoft.XMLHTTP","Msxml2.XMLHTTP.4.0"];
dojo.hostenv.getXmlhttpObject=function(){
var _8d=null;
var _8e=null;
try{
_8d=new XMLHttpRequest();
}
catch(e){
}
if(!_8d){
for(var i=0;i<3;++i){
var _90=dojo.hostenv._XMLHTTP_PROGIDS[i];
try{
_8d=new ActiveXObject(_90);
}
catch(e){
_8e=e;
}
if(_8d){
dojo.hostenv._XMLHTTP_PROGIDS=[_90];
break;
}
}
}
if(!_8d){
return dojo.raise("XMLHTTP not available",_8e);
}
return _8d;
};
dojo.hostenv._blockAsync=false;
dojo.hostenv.getText=function(uri,_92,_93){
if(!_92){
this._blockAsync=true;
}
var _94=this.getXmlhttpObject();
function isDocumentOk(_95){
var _96=_95["status"];
return Boolean((!_96)||((200<=_96)&&(300>_96))||(_96==304));
}
if(_92){
var _97=this,_98=null,gbl=dojo.global();
var xhr=dojo.getObject("dojo.io.XMLHTTPTransport");
_94.onreadystatechange=function(){
if(_98){
gbl.clearTimeout(_98);
_98=null;
}
if(_97._blockAsync||(xhr&&xhr._blockAsync)){
_98=gbl.setTimeout(function(){
_94.onreadystatechange.apply(this);
},10);
}else{
if(4==_94.readyState){
if(isDocumentOk(_94)){
_92(_94.responseText);
}
}
}
};
}
_94.open("GET",uri,_92?true:false);
try{
_94.send(null);
if(_92){
return null;
}
if(!isDocumentOk(_94)){
var err=Error("Unable to load "+uri+" status:"+_94.status);
err.status=_94.status;
err.responseText=_94.responseText;
throw err;
}
}
catch(e){
this._blockAsync=false;
if((_93)&&(!_92)){
return null;
}else{
throw e;
}
}
this._blockAsync=false;
return _94.responseText;
};
dojo.hostenv.defaultDebugContainerId="dojoDebug";
dojo.hostenv._println_buffer=[];
dojo.hostenv._println_safe=false;
dojo.hostenv.println=function(_9c){
if(!dojo.hostenv._println_safe){
dojo.hostenv._println_buffer.push(_9c);
}else{
try{
var _9d=document.getElementById(djConfig.debugContainerId?djConfig.debugContainerId:dojo.hostenv.defaultDebugContainerId);
if(!_9d){
_9d=dojo.body();
}
var div=document.createElement("div");
div.appendChild(document.createTextNode(_9c));
_9d.appendChild(div);
}
catch(e){
try{
document.write("<div>"+_9c+"</div>");
}
catch(e2){
window.status=_9c;
}
}
}
};
dojo.addOnLoad(function(){
dojo.hostenv._println_safe=true;
while(dojo.hostenv._println_buffer.length>0){
dojo.hostenv.println(dojo.hostenv._println_buffer.shift());
}
});
function dj_addNodeEvtHdlr(_9f,_a0,fp){
var _a2=_9f["on"+_a0]||function(){
};
_9f["on"+_a0]=function(){
fp.apply(_9f,arguments);
_a2.apply(_9f,arguments);
};
return true;
}
dojo.hostenv._djInitFired=false;
function dj_load_init(e){
dojo.hostenv._djInitFired=true;
var _a4=(e&&e.type)?e.type.toLowerCase():"load";
if(arguments.callee.initialized||(_a4!="domcontentloaded"&&_a4!="load")){
return;
}
arguments.callee.initialized=true;
if(typeof (_timer)!="undefined"){
clearInterval(_timer);
delete _timer;
}
var _a5=function(){
if(dojo.render.html.ie){
dojo.hostenv.makeWidgets();
}
};
if(dojo.hostenv.inFlightCount==0){
_a5();
dojo.hostenv.modulesLoaded();
}else{
dojo.hostenv.modulesLoadedListeners.unshift(_a5);
}
}
if(document.addEventListener){
if(dojo.render.html.opera||(dojo.render.html.moz&&(djConfig["enableMozDomContentLoaded"]===true))){
document.addEventListener("DOMContentLoaded",dj_load_init,null);
}
window.addEventListener("load",dj_load_init,null);
}
if(dojo.render.html.ie&&dojo.render.os.win){
document.write("<scr"+"ipt defer src=\"//:\" "+"onreadystatechange=\"if(this.readyState=='complete'){dj_load_init();}\">"+"</scr"+"ipt>");
}
if(/(WebKit|khtml)/i.test(navigator.userAgent)){
var _timer=setInterval(function(){
if(/loaded|complete/.test(document.readyState)){
dj_load_init();
}
},10);
}
if(dojo.render.html.ie){
dj_addNodeEvtHdlr(window,"beforeunload",function(){
dojo.hostenv._unloading=true;
window.setTimeout(function(){
dojo.hostenv._unloading=false;
},0);
});
}
dj_addNodeEvtHdlr(window,"unload",function(){
if((!dojo.render.html.ie)||(dojo.render.html.ie&&dojo.hostenv._unloading)){
dojo.hostenv.unloaded();
}
});
dojo.hostenv.makeWidgets=function(){
var _a6=[];
if(djConfig.searchIds&&djConfig.searchIds.length>0){
_a6=_a6.concat(djConfig.searchIds);
}
if(dojo.hostenv.searchIds&&dojo.hostenv.searchIds.length>0){
_a6=_a6.concat(dojo.hostenv.searchIds);
}
if((djConfig.parseWidgets)||(_a6.length>0)){
if(dojo.getObject("dojo.widget.Parse")){
var _a7=new dojo.xml.Parse();
if(_a6.length>0){
for(var x=0;x<_a6.length;x++){
var _a9=document.getElementById(_a6[x]);
if(!_a9){
continue;
}
var _aa=_a7.parseElement(_a9,null,true);
dojo.widget.getParser().createComponents(_aa);
}
}else{
if(djConfig.parseWidgets){
var _aa=_a7.parseElement(dojo.body(),null,true);
dojo.widget.getParser().createComponents(_aa);
}
}
}
}
};
dojo.addOnLoad(function(){
if(!dojo.render.html.ie){
dojo.hostenv.makeWidgets();
}
});
try{
if(dojo.render.html.ie){
document.namespaces.add("v","urn:schemas-microsoft-com:vml");
document.createStyleSheet().addRule("v\\:*","behavior:url(#default#VML)");
}
}
catch(e){
}
dojo.hostenv.writeIncludes=function(){
};
if(!dj_undef("document",this)){
dj_currentDocument=this.document;
}
dojo.doc=function(){
return dj_currentDocument;
};
dojo.body=function(){
return dojo.doc().body||dojo.doc().getElementsByTagName("body")[0];
};
dojo.byId=function(id,doc){
if((id)&&((typeof id=="string")||(id instanceof String))){
if(!doc){
doc=dj_currentDocument;
}
var ele=doc.getElementById(id);
if(ele&&(ele.id!=id)&&doc.all){
ele=null;
eles=doc.all[id];
if(eles){
if(eles.length){
for(var i=0;i<eles.length;i++){
if(eles[i].id==id){
ele=eles[i];
break;
}
}
}else{
ele=eles;
}
}
}
return ele;
}
return id;
};
dojo.setContext=function(_af,_b0){
dj_currentContext=_af;
dj_currentDocument=_b0;
};
dojo._fireCallback=function(_b1,_b2,_b3){
if((_b2)&&((typeof _b1=="string")||(_b1 instanceof String))){
_b1=_b2[_b1];
}
return (_b2?_b1.apply(_b2,_b3||[]):_b1());
};
dojo.withGlobal=function(_b4,_b5,_b6,_b7){
var _b8;
var _b9=dj_currentContext;
var _ba=dj_currentDocument;
try{
dojo.setContext(_b4,_b4.document);
_b8=dojo._fireCallback(_b5,_b6,_b7);
}
finally{
dojo.setContext(_b9,_ba);
}
return _b8;
};
dojo.withDoc=function(_bb,_bc,_bd,_be){
var _bf;
var _c0=dj_currentDocument;
try{
dj_currentDocument=_bb;
_bf=dojo._fireCallback(_bc,_bd,_be);
}
finally{
dj_currentDocument=_c0;
}
return _bf;
};
}
dojo.requireIf((djConfig["isDebug"]||djConfig["debugAtAllCosts"]),"dojo.debug");
dojo.requireIf(djConfig["debugAtAllCosts"]&&!window.widget&&!djConfig["useXDomain"],"dojo.browser_debug");
dojo.requireIf(djConfig["debugAtAllCosts"]&&!window.widget&&djConfig["useXDomain"],"dojo.browser_debug_xd");
dojo.provide("dojo.string.common");
dojo.string.trim=function(str,wh){
if(!str.replace){
return str;
}
if(!str.length){
return str;
}
var re=(wh>0)?(/^\s+/):(wh<0)?(/\s+$/):(/^\s+|\s+$/g);
return str.replace(re,"");
};
dojo.string.trimStart=function(str){
return dojo.string.trim(str,1);
};
dojo.string.trimEnd=function(str){
return dojo.string.trim(str,-1);
};
dojo.string.repeat=function(str,_c7,_c8){
var out="";
for(var i=0;i<_c7;i++){
out+=str;
if(_c8&&i<_c7-1){
out+=_c8;
}
}
return out;
};
dojo.string.pad=function(str,len,c,dir){
var out=String(str);
if(!c){
c="0";
}
if(!dir){
dir=1;
}
while(out.length<len){
if(dir>0){
out=c+out;
}else{
out+=c;
}
}
return out;
};
dojo.string.padLeft=function(str,len,c){
return dojo.string.pad(str,len,c,1);
};
dojo.string.padRight=function(str,len,c){
return dojo.string.pad(str,len,c,-1);
};
dojo.provide("dojo.string");
dojo.provide("dojo.lang.common");
dojo.lang.inherits=function(_d6,_d7){
if(!dojo.lang.isFunction(_d7)){
dojo.raise("dojo.inherits: superclass argument ["+_d7+"] must be a function (subclass: ["+_d6+"']");
}
_d6.prototype=new _d7();
_d6.prototype.constructor=_d6;
_d6.superclass=_d7.prototype;
_d6["super"]=_d7.prototype;
};
dojo.lang._mixin=function(obj,_d9){
var _da={};
for(var x in _d9){
if((typeof _da[x]=="undefined")||(_da[x]!=_d9[x])){
obj[x]=_d9[x];
}
}
if(dojo.render.html.ie&&(typeof (_d9["toString"])=="function")&&(_d9["toString"]!=obj["toString"])&&(_d9["toString"]!=_da["toString"])){
obj.toString=_d9.toString;
}
return obj;
};
dojo.lang.mixin=function(obj,_dd){
for(var i=1,l=arguments.length;i<l;i++){
dojo.lang._mixin(obj,arguments[i]);
}
return obj;
};
dojo.lang.extend=function(_e0,_e1){
for(var i=1,l=arguments.length;i<l;i++){
dojo.lang._mixin(_e0.prototype,arguments[i]);
}
return _e0;
};
dojo.lang._delegate=function(obj,_e5){
function TMP(){
}
TMP.prototype=obj;
var tmp=new TMP();
if(_e5){
dojo.lang.mixin(tmp,_e5);
}
return tmp;
};
dojo.inherits=dojo.lang.inherits;
dojo.mixin=dojo.lang.mixin;
dojo.extend=dojo.lang.extend;
dojo.lang.find=function(_e7,_e8,_e9,_ea){
var _eb=dojo.lang.isString(_e7);
if(_eb){
_e7=_e7.split("");
}
if(_ea){
var _ec=-1;
var i=_e7.length-1;
var end=-1;
}else{
var _ec=1;
var i=0;
var end=_e7.length;
}
if(_e9){
while(i!=end){
if(_e7[i]===_e8){
return i;
}
i+=_ec;
}
}else{
while(i!=end){
if(_e7[i]==_e8){
return i;
}
i+=_ec;
}
}
return -1;
};
dojo.lang.indexOf=dojo.lang.find;
dojo.lang.findLast=function(_ef,_f0,_f1){
return dojo.lang.find(_ef,_f0,_f1,true);
};
dojo.lang.lastIndexOf=dojo.lang.findLast;
dojo.lang.inArray=function(_f2,_f3){
return dojo.lang.find(_f2,_f3)>-1;
};
dojo.lang.isObject=function(it){
if(typeof it=="undefined"){
return false;
}
return (typeof it=="object"||it===null||dojo.lang.isArray(it)||dojo.lang.isFunction(it));
};
dojo.lang.isArray=function(it){
return (it&&it instanceof Array||typeof it=="array");
};
dojo.lang.isArrayLike=function(it){
if((!it)||(dojo.lang.isUndefined(it))){
return false;
}
if(dojo.lang.isString(it)){
return false;
}
if(dojo.lang.isFunction(it)){
return false;
}
if(dojo.lang.isArray(it)){
return true;
}
if((it.tagName)&&(it.tagName.toLowerCase()=="form")){
return false;
}
if(dojo.lang.isNumber(it.length)&&isFinite(it.length)){
return true;
}
return false;
};
dojo.lang.isFunction=function(it){
return (it instanceof Function||typeof it=="function");
};
(function(){
if((dojo.render.html.capable)&&(dojo.render.html["safari"])){
dojo.lang.isFunction=function(it){
if((typeof (it)=="function")&&(it=="[object NodeList]")){
return false;
}
return (it instanceof Function||typeof it=="function");
};
}
})();
dojo.lang.isString=function(it){
return (typeof it=="string"||it instanceof String);
};
dojo.lang.isAlien=function(it){
if(!it){
return false;
}
return !dojo.lang.isFunction(it)&&/\{\s*\[native code\]\s*\}/.test(String(it));
};
dojo.lang.isBoolean=function(it){
return (it instanceof Boolean||typeof it=="boolean");
};
dojo.lang.isNumber=function(it){
return (it instanceof Number||typeof it=="number");
};
dojo.lang.isUndefined=function(it){
return ((typeof (it)=="undefined")&&(it==undefined));
};
dojo.provide("dojo.lang.extras");
dojo.lang.setTimeout=function(_fe,_ff){
var _100=window,_101=2;
if(!dojo.lang.isFunction(_fe)){
_100=_fe;
_fe=_ff;
_ff=arguments[2];
_101++;
}
if(dojo.lang.isString(_fe)){
_fe=_100[_fe];
}
var args=[];
for(var i=_101;i<arguments.length;i++){
args.push(arguments[i]);
}
return dojo.global().setTimeout(function(){
_fe.apply(_100,args);
},_ff);
};
dojo.lang.clearTimeout=function(_104){
dojo.global().clearTimeout(_104);
};
dojo.lang.getNameInObj=function(ns,item){
if(!ns){
ns=dj_global;
}
for(var x in ns){
if(ns[x]===item){
return new String(x);
}
}
return null;
};
dojo.lang.shallowCopy=function(obj,deep){
var i,ret;
if(obj===null){
return null;
}
if(dojo.lang.isObject(obj)){
ret=new obj.constructor();
for(i in obj){
if(dojo.lang.isUndefined(ret[i])){
ret[i]=deep?dojo.lang.shallowCopy(obj[i],deep):obj[i];
}
}
}else{
if(dojo.lang.isArray(obj)){
ret=[];
for(i=0;i<obj.length;i++){
ret[i]=deep?dojo.lang.shallowCopy(obj[i],deep):obj[i];
}
}else{
ret=obj;
}
}
return ret;
};
dojo.lang.firstValued=function(){
for(var i=0;i<arguments.length;i++){
if(typeof arguments[i]!="undefined"){
return arguments[i];
}
}
return undefined;
};
dojo.lang.getObjPathValue=function(_10d,_10e,_10f){
dojo.deprecated("dojo.lang.getObjPathValue","use dojo.getObject","0.6");
with(dojo.parseObjPath(_10d,_10e,_10f)){
return dojo.evalProp(prop,obj,_10f);
}
};
dojo.lang.setObjPathValue=function(_110,_111,_112,_113){
dojo.deprecated("dojo.lang.setObjPathValue","use dojo.parseObjPath and the '=' operator","0.6");
if(arguments.length<4){
_113=true;
}
with(dojo.parseObjPath(_110,_112,_113)){
if(obj&&(_113||(prop in obj))){
obj[prop]=_111;
}
}
};
dojo.provide("dojo.io.common");
dojo.io.transports=[];
dojo.io.hdlrFuncNames=["load","error","timeout"];
dojo.io.Request=function(url,_115,_116,_117){
if((arguments.length==1)&&(arguments[0].constructor==Object)){
this.fromKwArgs(arguments[0]);
}else{
this.url=url;
if(_115){
this.mimetype=_115;
}
if(_116){
this.transport=_116;
}
if(arguments.length>=4){
this.changeUrl=_117;
}
}
};
dojo.lang.extend(dojo.io.Request,{url:"",mimetype:"text/plain",method:"GET",content:undefined,transport:undefined,changeUrl:undefined,formNode:undefined,sync:false,bindSuccess:false,useCache:false,preventCache:false,jsonFilter:function(_118){
if((this.mimetype=="text/json-comment-filtered")||(this.mimetype=="application/json-comment-filtered")){
var _119=_118.indexOf("/*");
var _11a=_118.lastIndexOf("*/");
if((_119==-1)||(_11a==-1)){
dojo.debug("your JSON wasn't comment filtered!");
return "";
}
return _118.substring(_119+2,_11a);
}
dojo.debug("please consider using a mimetype of text/json-comment-filtered to avoid potential security issues with JSON endpoints");
return _118;
},load:function(type,data,_11d,_11e){
},error:function(type,_120,_121,_122){
},timeout:function(type,_124,_125,_126){
},handle:function(type,data,_129,_12a){
},timeoutSeconds:0,abort:function(){
},fromKwArgs:function(_12b){
if(_12b["url"]){
_12b.url=_12b.url.toString();
}
if(_12b["formNode"]){
_12b.formNode=dojo.byId(_12b.formNode);
}
if(!_12b["method"]&&_12b["formNode"]&&_12b["formNode"].method){
_12b.method=_12b["formNode"].method;
}
if(!_12b["handle"]&&_12b["handler"]){
_12b.handle=_12b.handler;
}
if(!_12b["load"]&&_12b["loaded"]){
_12b.load=_12b.loaded;
}
if(!_12b["changeUrl"]&&_12b["changeURL"]){
_12b.changeUrl=_12b.changeURL;
}
_12b.encoding=dojo.lang.firstValued(_12b["encoding"],djConfig["bindEncoding"],"");
_12b.sendTransport=dojo.lang.firstValued(_12b["sendTransport"],djConfig["ioSendTransport"],false);
var _12c=dojo.lang.isFunction;
for(var x=0;x<dojo.io.hdlrFuncNames.length;x++){
var fn=dojo.io.hdlrFuncNames[x];
if(_12b[fn]&&_12c(_12b[fn])){
continue;
}
if(_12b["handle"]&&_12c(_12b["handle"])){
_12b[fn]=_12b.handle;
}
}
dojo.lang.mixin(this,_12b);
}});
dojo.io.Error=function(msg,type,num){
this.message=msg;
this.type=type||"unknown";
this.number=num||0;
};
dojo.io.transports.addTransport=function(name){
this.push(name);
this[name]=dojo.io[name];
};
dojo.io.bind=function(_133){
if(!(_133 instanceof dojo.io.Request)){
try{
_133=new dojo.io.Request(_133);
}
catch(e){
dojo.debug(e);
}
}
var _134="";
if(_133["transport"]){
_134=_133["transport"];
if(!this[_134]){
dojo.io.sendBindError(_133,"No dojo.io.bind() transport with name '"+_133["transport"]+"'.");
return _133;
}
if(!this[_134].canHandle(_133)){
dojo.io.sendBindError(_133,"dojo.io.bind() transport with name '"+_133["transport"]+"' cannot handle this type of request.");
return _133;
}
}else{
for(var x=0;x<dojo.io.transports.length;x++){
var tmp=dojo.io.transports[x];
if((this[tmp])&&(this[tmp].canHandle(_133))){
_134=tmp;
break;
}
}
if(_134==""){
dojo.io.sendBindError(_133,"None of the loaded transports for dojo.io.bind()"+" can handle the request.");
return _133;
}
}
this[_134].bind(_133);
_133.bindSuccess=true;
return _133;
};
dojo.io.sendBindError=function(_137,_138){
if((typeof _137.error=="function"||typeof _137.handle=="function")&&(typeof setTimeout=="function"||typeof setTimeout=="object")){
var _139=new dojo.io.Error(_138);
setTimeout(function(){
_137[(typeof _137.error=="function")?"error":"handle"]("error",_139,null,_137);
},50);
}else{
dojo.raise(_138);
}
};
dojo.io.queueBind=function(_13a){
if(!(_13a instanceof dojo.io.Request)){
try{
_13a=new dojo.io.Request(_13a);
}
catch(e){
dojo.debug(e);
}
}
var _13b=_13a.load;
_13a.load=function(){
dojo.io._queueBindInFlight=false;
var ret=_13b.apply(this,arguments);
dojo.io._dispatchNextQueueBind();
return ret;
};
var _13d=_13a.error;
_13a.error=function(){
dojo.io._queueBindInFlight=false;
var ret=_13d.apply(this,arguments);
dojo.io._dispatchNextQueueBind();
return ret;
};
dojo.io._bindQueue.push(_13a);
dojo.io._dispatchNextQueueBind();
return _13a;
};
dojo.io._dispatchNextQueueBind=function(){
if(!dojo.io._queueBindInFlight){
dojo.io._queueBindInFlight=true;
if(dojo.io._bindQueue.length>0){
dojo.io.bind(dojo.io._bindQueue.shift());
}else{
dojo.io._queueBindInFlight=false;
}
}
};
dojo.io._bindQueue=[];
dojo.io._queueBindInFlight=false;
dojo.io.argsFromMap=function(map,_140,last){
var enc=/utf/i.test(_140||"")?encodeURIComponent:dojo.string.encodeAscii;
var _143=[];
var _144=new Object();
for(var name in map){
var _146=function(elt){
var val=enc(name)+"="+enc(elt);
_143[(last==name)?"push":"unshift"](val);
};
if(!_144[name]){
var _149=map[name];
if(dojo.lang.isArray(_149)){
dojo.lang.forEach(_149,_146);
}else{
_146(_149);
}
}
}
return _143.join("&");
};
dojo.io.setIFrameSrc=function(_14a,src,_14c){
try{
var r=dojo.render.html;
if(!_14c){
if(r.safari){
_14a.location=src;
}else{
frames[_14a.name].location=src;
}
}else{
var idoc;
if(r.ie){
idoc=_14a.contentWindow.document;
}else{
if(r.safari){
idoc=_14a.document;
}else{
idoc=_14a.contentWindow;
}
}
if(!idoc){
_14a.location=src;
return;
}else{
idoc.location.replace(src);
}
}
}
catch(e){
dojo.debug(e);
dojo.debug("setIFrameSrc: "+e);
}
};
dojo.provide("dojo.lang.array");
dojo.lang.mixin(dojo.lang,{has:function(obj,name){
try{
return typeof obj[name]!="undefined";
}
catch(e){
return false;
}
},isEmpty:function(obj){
if(dojo.lang.isArrayLike(obj)||dojo.lang.isString(obj)){
return obj.length===0;
}else{
if(dojo.lang.isObject(obj)){
var tmp={};
for(var x in obj){
if(obj[x]&&(!tmp[x])){
return false;
}
}
return true;
}
}
},map:function(arr,obj,_156){
var _157=dojo.lang.isString(arr);
if(_157){
arr=arr.split("");
}
if(dojo.lang.isFunction(obj)&&(!_156)){
_156=obj;
obj=dj_global;
}else{
if(dojo.lang.isFunction(obj)&&_156){
var _158=obj;
obj=_156;
_156=_158;
}
}
if(Array.map){
var _159=Array.map(arr,_156,obj);
}else{
var _159=[];
for(var i=0;i<arr.length;++i){
_159.push(_156.call(obj,arr[i]));
}
}
if(_157){
return _159.join("");
}else{
return _159;
}
},reduce:function(arr,_15c,_15d,_15e){
var _15f=_15d;
if(arguments.length==2){
_15f=arr[0];
arr=arr.slice(1);
}
var ob=_15e||dj_global;
dojo.lang.map(arr,function(val){
_15f=_15c.call(ob,_15f,val);
});
return _15f;
},forEach:function(_162,_163,_164){
if(dojo.lang.isString(_162)){
_162=_162.split("");
}
if(Array.forEach){
Array.forEach(_162,_163,_164);
}else{
if(!_164){
_164=dj_global;
}
for(var i=0,l=_162.length;i<l;i++){
_163.call(_164,_162[i],i,_162);
}
}
},_everyOrSome:function(_167,arr,_169,_16a){
if(dojo.lang.isString(arr)){
arr=arr.split("");
}
if(Array.every){
return Array[_167?"every":"some"](arr,_169,_16a);
}else{
if(!_16a){
_16a=dj_global;
}
for(var i=0,l=arr.length;i<l;i++){
var _16d=_169.call(_16a,arr[i],i,arr);
if(_167&&!_16d){
return false;
}else{
if((!_167)&&(_16d)){
return true;
}
}
}
return Boolean(_167);
}
},every:function(arr,_16f,_170){
return this._everyOrSome(true,arr,_16f,_170);
},some:function(arr,_172,_173){
return this._everyOrSome(false,arr,_172,_173);
},filter:function(arr,_175,_176){
var _177=dojo.lang.isString(arr);
if(_177){
arr=arr.split("");
}
var _178;
if(Array.filter){
_178=Array.filter(arr,_175,_176);
}else{
if(!_176){
if(arguments.length>=3){
dojo.raise("thisObject doesn't exist!");
}
_176=dj_global;
}
_178=[];
for(var i=0;i<arr.length;i++){
if(_175.call(_176,arr[i],i,arr)){
_178.push(arr[i]);
}
}
}
if(_177){
return _178.join("");
}else{
return _178;
}
},unnest:function(){
var out=[];
for(var i=0;i<arguments.length;i++){
if(dojo.lang.isArrayLike(arguments[i])){
var add=dojo.lang.unnest.apply(this,arguments[i]);
out=out.concat(add);
}else{
out.push(arguments[i]);
}
}
return out;
},toArray:function(_17d,_17e){
var _17f=[];
for(var i=_17e||0;i<_17d.length;i++){
_17f.push(_17d[i]);
}
return _17f;
}});
dojo.provide("dojo.lang.func");
dojo.lang.hitch=function(_181,_182){
var args=[];
for(var x=2;x<arguments.length;x++){
args.push(arguments[x]);
}
var fcn=(dojo.lang.isString(_182)?_181[_182]:_182)||function(){
};
return function(){
var ta=args.concat([]);
for(var x=0;x<arguments.length;x++){
ta.push(arguments[x]);
}
return fcn.apply(_181,ta);
};
};
dojo.lang.anonCtr=0;
dojo.lang.anon={};
dojo.lang.nameAnonFunc=function(_188,_189,_18a){
var isIE=(dojo.render.html.capable&&dojo.render.html["ie"]);
var jpn="$joinpoint";
var nso=(_189||dojo.lang.anon);
if(isIE){
var cn=_188["__dojoNameCache"];
if(cn&&nso[cn]===_188){
return _188["__dojoNameCache"];
}else{
if(cn){
var _18f=cn.indexOf(jpn);
if(_18f!=-1){
return cn.substring(0,_18f);
}
}
}
}
if((_18a)||((dj_global["djConfig"])&&(djConfig["slowAnonFuncLookups"]==true))){
for(var x in nso){
try{
if(nso[x]===_188){
if(isIE){
_188["__dojoNameCache"]=x;
var _18f=x.indexOf(jpn);
if(_18f!=-1){
x=x.substring(0,_18f);
}
}
return x;
}
}
catch(e){
}
}
}
var ret="__"+dojo.lang.anonCtr++;
while(typeof nso[ret]!="undefined"){
ret="__"+dojo.lang.anonCtr++;
}
nso[ret]=_188;
return ret;
};
dojo.lang.forward=function(_192){
return function(){
return this[_192].apply(this,arguments);
};
};
dojo.lang.curry=function(_193,func){
var _195=[];
_193=_193||dj_global;
if(dojo.lang.isString(func)){
func=_193[func];
}
for(var x=2;x<arguments.length;x++){
_195.push(arguments[x]);
}
var _197=(func["__preJoinArity"]||func.length)-_195.length;
function gather(_198,_199,_19a){
var _19b=_19a;
var _19c=_199.slice(0);
for(var x=0;x<_198.length;x++){
_19c.push(_198[x]);
}
_19a=_19a-_198.length;
if(_19a<=0){
var res=func.apply(_193,_19c);
_19a=_19b;
return res;
}else{
return function(){
return gather(arguments,_19c,_19a);
};
}
}
return gather([],_195,_197);
};
dojo.lang.curryArguments=function(_19f,func,args,_1a2){
var _1a3=[];
var x=_1a2||0;
for(x=_1a2;x<args.length;x++){
_1a3.push(args[x]);
}
return dojo.lang.curry.apply(dojo.lang,[_19f,func].concat(_1a3));
};
dojo.lang.tryThese=function(){
for(var x=0;x<arguments.length;x++){
try{
if(typeof arguments[x]=="function"){
var ret=(arguments[x]());
if(ret){
return ret;
}
}
}
catch(e){
dojo.debug(e);
}
}
};
dojo.lang.delayThese=function(farr,cb,_1a9,_1aa){
if(!farr.length){
if(typeof _1aa=="function"){
_1aa();
}
return;
}
if((typeof _1a9=="undefined")&&(typeof cb=="number")){
_1a9=cb;
cb=function(){
};
}else{
if(!cb){
cb=function(){
};
if(!_1a9){
_1a9=0;
}
}
}
setTimeout(function(){
(farr.shift())();
cb();
dojo.lang.delayThese(farr,cb,_1a9,_1aa);
},_1a9);
};
dojo.provide("dojo.string.extras");
dojo.string.substitute=function(_1ab,map,_1ad,_1ae){
return _1ab.replace(/\$\{([^\s\:\}]+)(?:\:(\S+))?\}/g,function(_1af,key,_1b1){
var _1b2=dojo.getObject(key,false,map).toString();
if(_1b1){
_1b2=dojo.getObject(_1b1,false,_1ae)(_1b2);
}
if(_1ad){
_1b2=_1ad(_1b2);
}
return _1b2;
});
};
dojo.string.capitalize=function(str){
if(!dojo.lang.isString(str)){
return "";
}
return str.replace(/[^\s]+/g,function(word){
return word.substring(0,1).toUpperCase()+word.substring(1);
});
};
dojo.string.isBlank=function(str){
if(!dojo.lang.isString(str)){
return true;
}
return (dojo.string.trim(str).length==0);
};
dojo.string.encodeAscii=function(str){
if(!dojo.lang.isString(str)){
return str;
}
var ret="";
var _1b8=escape(str);
var _1b9,re=/%u([0-9A-F]{4})/i;
while((_1b9=_1b8.match(re))){
var num=Number("0x"+_1b9[1]);
var _1bc=escape("&#"+num+";");
ret+=_1b8.substring(0,_1b9.index)+_1bc;
_1b8=_1b8.substring(_1b9.index+_1b9[0].length);
}
ret+=_1b8.replace(/\+/g,"%2B");
return ret;
};
dojo.string.escape=function(type,str){
var args=dojo.lang.toArray(arguments,1);
switch(type.toLowerCase()){
case "xml":
case "html":
case "xhtml":
return dojo.string.escapeXml.apply(this,args);
case "sql":
return dojo.string.escapeSql.apply(this,args);
case "regexp":
case "regex":
return dojo.string.escapeRegExp.apply(this,args);
case "javascript":
case "jscript":
case "js":
return dojo.string.escapeJavaScript.apply(this,args);
case "ascii":
return dojo.string.encodeAscii.apply(this,args);
default:
return str;
}
};
dojo.string.escapeXml=function(str,_1c1){
str=str.replace(/&/gm,"&amp;").replace(/</gm,"&lt;").replace(/>/gm,"&gt;").replace(/"/gm,"&quot;");
if(!_1c1){
str=str.replace(/'/gm,"&#39;");
}
return str;
};
dojo.string.escapeSql=function(str){
return str.replace(/'/gm,"''");
};
dojo.string.escapeRegExp=function(str,_1c4){
return str.replace(/([\.$?*!=:|{}\(\)\[\]\\\/^])/g,function(ch){
if(_1c4&&_1c4.indexOf(ch)!=-1){
return ch;
}
return "\\"+ch;
});
};
dojo.string.escapeJavaScript=function(str){
return str.replace(/(["'\f\b\n\t\r])/gm,"\\$1");
};
dojo.string.escapeString=function(str){
return ("\""+str.replace(/(["\\])/g,"\\$1")+"\"").replace(/[\f]/g,"\\f").replace(/[\b]/g,"\\b").replace(/[\n]/g,"\\n").replace(/[\t]/g,"\\t").replace(/[\r]/g,"\\r");
};
dojo.string.summary=function(str,len){
if(!len||str.length<=len){
return str;
}
return str.substring(0,len).replace(/\.+$/,"")+"...";
};
dojo.string.endsWith=function(str,end,_1cc){
if(_1cc){
str=str.toLowerCase();
end=end.toLowerCase();
}
if((str.length-end.length)<0){
return false;
}
return str.lastIndexOf(end)==str.length-end.length;
};
dojo.string.endsWithAny=function(str){
for(var i=1;i<arguments.length;i++){
if(dojo.string.endsWith(str,arguments[i])){
return true;
}
}
return false;
};
dojo.string.startsWith=function(str,_1d0,_1d1){
if(_1d1){
str=str.toLowerCase();
_1d0=_1d0.toLowerCase();
}
return str.indexOf(_1d0)==0;
};
dojo.string.startsWithAny=function(str){
for(var i=1;i<arguments.length;i++){
if(dojo.string.startsWith(str,arguments[i])){
return true;
}
}
return false;
};
dojo.string.has=function(str){
for(var i=1;i<arguments.length;i++){
if(str.indexOf(arguments[i])>-1){
return true;
}
}
return false;
};
dojo.string.normalizeNewlines=function(text,_1d7){
if(_1d7=="\n"){
text=text.replace(/\r\n/g,"\n");
text=text.replace(/\r/g,"\n");
}else{
if(_1d7=="\r"){
text=text.replace(/\r\n/g,"\r");
text=text.replace(/\n/g,"\r");
}else{
text=text.replace(/([^\r])\n/g,"$1\r\n").replace(/\r([^\n])/g,"\r\n$1");
}
}
return text;
};
dojo.string.splitEscaped=function(str,_1d9){
var _1da=[];
for(var i=0,_1dc=0;i<str.length;i++){
if(str.charAt(i)=="\\"){
i++;
continue;
}
if(str.charAt(i)==_1d9){
_1da.push(str.substring(_1dc,i));
_1dc=i+1;
}
}
_1da.push(str.substr(_1dc));
return _1da;
};
dojo.provide("dojo.dom");
dojo.dom.ELEMENT_NODE=1;
dojo.dom.ATTRIBUTE_NODE=2;
dojo.dom.TEXT_NODE=3;
dojo.dom.CDATA_SECTION_NODE=4;
dojo.dom.ENTITY_REFERENCE_NODE=5;
dojo.dom.ENTITY_NODE=6;
dojo.dom.PROCESSING_INSTRUCTION_NODE=7;
dojo.dom.COMMENT_NODE=8;
dojo.dom.DOCUMENT_NODE=9;
dojo.dom.DOCUMENT_TYPE_NODE=10;
dojo.dom.DOCUMENT_FRAGMENT_NODE=11;
dojo.dom.NOTATION_NODE=12;
dojo.dom.dojoml="http://www.dojotoolkit.org/2004/dojoml";
dojo.dom.xmlns={svg:"http://www.w3.org/2000/svg",smil:"http://www.w3.org/2001/SMIL20/",mml:"http://www.w3.org/1998/Math/MathML",cml:"http://www.xml-cml.org",xlink:"http://www.w3.org/1999/xlink",xhtml:"http://www.w3.org/1999/xhtml",xul:"http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul",xbl:"http://www.mozilla.org/xbl",fo:"http://www.w3.org/1999/XSL/Format",xsl:"http://www.w3.org/1999/XSL/Transform",xslt:"http://www.w3.org/1999/XSL/Transform",xi:"http://www.w3.org/2001/XInclude",xforms:"http://www.w3.org/2002/01/xforms",saxon:"http://icl.com/saxon",xalan:"http://xml.apache.org/xslt",xsd:"http://www.w3.org/2001/XMLSchema",dt:"http://www.w3.org/2001/XMLSchema-datatypes",xsi:"http://www.w3.org/2001/XMLSchema-instance",rdf:"http://www.w3.org/1999/02/22-rdf-syntax-ns#",rdfs:"http://www.w3.org/2000/01/rdf-schema#",dc:"http://purl.org/dc/elements/1.1/",dcq:"http://purl.org/dc/qualifiers/1.0","soap-env":"http://schemas.xmlsoap.org/soap/envelope/",wsdl:"http://schemas.xmlsoap.org/wsdl/",AdobeExtensions:"http://ns.adobe.com/AdobeSVGViewerExtensions/3.0/"};
dojo.dom.isNode=function(wh){
if(typeof Element=="function"){
try{
return wh instanceof Element;
}
catch(e){
}
}else{
return wh&&!isNaN(wh.nodeType);
}
};
dojo.dom.getUniqueId=function(){
var _1de=dojo.doc();
do{
var id="dj_unique_"+(++arguments.callee._idIncrement);
}while(_1de.getElementById(id));
return id;
};
dojo.dom.getUniqueId._idIncrement=0;
dojo.dom.firstElement=dojo.dom.getFirstChildElement=function(_1e0,_1e1){
var node=_1e0.firstChild;
while(node&&node.nodeType!=dojo.dom.ELEMENT_NODE){
node=node.nextSibling;
}
if(_1e1&&node&&node.tagName&&node.tagName.toLowerCase()!=_1e1.toLowerCase()){
node=dojo.dom.nextElement(node,_1e1);
}
return node;
};
dojo.dom.lastElement=dojo.dom.getLastChildElement=function(_1e3,_1e4){
var node=_1e3.lastChild;
while(node&&node.nodeType!=dojo.dom.ELEMENT_NODE){
node=node.previousSibling;
}
if(_1e4&&node&&node.tagName&&node.tagName.toLowerCase()!=_1e4.toLowerCase()){
node=dojo.dom.prevElement(node,_1e4);
}
return node;
};
dojo.dom.nextElement=dojo.dom.getNextSiblingElement=function(node,_1e7){
if(!node){
return null;
}
do{
node=node.nextSibling;
}while(node&&node.nodeType!=dojo.dom.ELEMENT_NODE);
if(node&&_1e7&&_1e7.toLowerCase()!=node.tagName.toLowerCase()){
return dojo.dom.nextElement(node,_1e7);
}
return node;
};
dojo.dom.prevElement=dojo.dom.getPreviousSiblingElement=function(node,_1e9){
if(!node){
return null;
}
if(_1e9){
_1e9=_1e9.toLowerCase();
}
do{
node=node.previousSibling;
}while(node&&node.nodeType!=dojo.dom.ELEMENT_NODE);
if(node&&_1e9&&_1e9.toLowerCase()!=node.tagName.toLowerCase()){
return dojo.dom.prevElement(node,_1e9);
}
return node;
};
dojo.dom.moveChildren=function(_1ea,_1eb,trim){
var _1ed=0;
if(trim){
while(_1ea.hasChildNodes()&&_1ea.firstChild.nodeType==dojo.dom.TEXT_NODE){
_1ea.removeChild(_1ea.firstChild);
}
while(_1ea.hasChildNodes()&&_1ea.lastChild.nodeType==dojo.dom.TEXT_NODE){
_1ea.removeChild(_1ea.lastChild);
}
}
while(_1ea.hasChildNodes()){
_1eb.appendChild(_1ea.firstChild);
_1ed++;
}
return _1ed;
};
dojo.dom.copyChildren=function(_1ee,_1ef,trim){
var _1f1=_1ee.cloneNode(true);
return this.moveChildren(_1f1,_1ef,trim);
};
dojo.dom.replaceChildren=function(node,_1f3){
var _1f4=[];
if(dojo.render.html.ie){
for(var i=0;i<node.childNodes.length;i++){
_1f4.push(node.childNodes[i]);
}
}
dojo.dom.removeChildren(node);
node.appendChild(_1f3);
for(var i=0;i<_1f4.length;i++){
dojo.dom.destroyNode(_1f4[i]);
}
};
dojo.dom.removeChildren=function(node){
var _1f7=node.childNodes.length;
while(node.hasChildNodes()){
dojo.dom.removeNode(node.firstChild);
}
return _1f7;
};
dojo.dom.replaceNode=function(node,_1f9){
return node.parentNode.replaceChild(_1f9,node);
};
dojo.dom.destroyNode=function(node){
if(node.parentNode){
node=dojo.dom.removeNode(node);
}
if(node.nodeType!=3){
if(dojo.exists("dojo.event.browser.clean")){
dojo.event.browser.clean(node);
}
if(dojo.render.html.ie){
node.outerHTML="";
}
}
};
dojo.dom.removeNode=function(node){
if(node&&node.parentNode){
return node.parentNode.removeChild(node);
}
};
dojo.dom.getAncestors=function(node,_1fd,_1fe){
var _1ff=[];
var _200=(_1fd&&(_1fd instanceof Function||typeof _1fd=="function"));
while(node){
if(!_200||_1fd(node)){
_1ff.push(node);
}
if(_1fe&&_1ff.length>0){
return _1ff[0];
}
node=node.parentNode;
}
if(_1fe){
return null;
}
return _1ff;
};
dojo.dom.getAncestorsByTag=function(node,tag,_203){
tag=tag.toLowerCase();
return dojo.dom.getAncestors(node,function(el){
return ((el.tagName)&&(el.tagName.toLowerCase()==tag));
},_203);
};
dojo.dom.getFirstAncestorByTag=function(node,tag){
return dojo.dom.getAncestorsByTag(node,tag,true);
};
dojo.dom.isDescendantOf=function(node,_208,_209){
if(_209&&node){
node=node.parentNode;
}
while(node){
if(node==_208){
return true;
}
node=node.parentNode;
}
return false;
};
dojo.dom.innerXML=function(node){
if(node.innerXML){
return node.innerXML;
}else{
if(node.xml){
return node.xml;
}else{
if(typeof XMLSerializer!="undefined"){
return (new XMLSerializer()).serializeToString(node);
}
}
}
};
dojo.dom.createDocument=function(){
var doc=null;
var _20c=dojo.doc();
if(!dj_undef("ActiveXObject")){
var _20d=["MSXML2","Microsoft","MSXML","MSXML3"];
for(var i=0;i<_20d.length;i++){
try{
doc=new ActiveXObject(_20d[i]+".XMLDOM");
}
catch(e){
}
if(doc){
break;
}
}
}else{
if((_20c.implementation)&&(_20c.implementation.createDocument)){
doc=_20c.implementation.createDocument("","",null);
}
}
return doc;
};
dojo.dom.createDocumentFromText=function(str,_210){
if(!_210){
_210="text/xml";
}
if(!dj_undef("DOMParser")){
var _211=new DOMParser();
return _211.parseFromString(str,_210);
}else{
if(!dj_undef("ActiveXObject")){
var _212=dojo.dom.createDocument();
if(_212){
_212.async=false;
_212.loadXML(str);
return _212;
}else{
dojo.debug("toXml didn't work?");
}
}else{
var _213=dojo.doc();
if(_213.createElement){
var tmp=_213.createElement("xml");
tmp.innerHTML=str;
if(_213.implementation&&_213.implementation.createDocument){
var _215=_213.implementation.createDocument("foo","",null);
for(var i=0;i<tmp.childNodes.length;i++){
_215.importNode(tmp.childNodes.item(i),true);
}
return _215;
}
return ((tmp.document)&&(tmp.document.firstChild?tmp.document.firstChild:tmp));
}
}
}
return null;
};
dojo.dom.prependChild=function(node,_218){
if(_218.firstChild){
_218.insertBefore(node,_218.firstChild);
}else{
_218.appendChild(node);
}
return true;
};
dojo.dom.insertBefore=function(node,ref,_21b){
if((_21b!=true)&&(node===ref||node.nextSibling===ref)){
return false;
}
var _21c=ref.parentNode;
_21c.insertBefore(node,ref);
return true;
};
dojo.dom.insertAfter=function(node,ref,_21f){
var pn=ref.parentNode;
if(ref==pn.lastChild){
if((_21f!=true)&&(node===ref)){
return false;
}
pn.appendChild(node);
}else{
return this.insertBefore(node,ref.nextSibling,_21f);
}
return true;
};
dojo.dom.insertAtPosition=function(node,ref,_223){
if((!node)||(!ref)||(!_223)){
return false;
}
switch(_223.toLowerCase()){
case "before":
return dojo.dom.insertBefore(node,ref);
case "after":
return dojo.dom.insertAfter(node,ref);
case "first":
if(ref.firstChild){
return dojo.dom.insertBefore(node,ref.firstChild);
}else{
ref.appendChild(node);
return true;
}
break;
default:
ref.appendChild(node);
return true;
}
};
dojo.dom.insertAtIndex=function(node,_225,_226){
var _227=_225.childNodes;
if(!_227.length||_227.length==_226){
_225.appendChild(node);
return true;
}
if(_226==0){
return dojo.dom.prependChild(node,_225);
}
return dojo.dom.insertAfter(node,_227[_226-1]);
};
dojo.dom.textContent=function(node,text){
if(arguments.length>1){
var _22a=dojo.doc();
dojo.dom.replaceChildren(node,_22a.createTextNode(text));
return text;
}else{
if(node["textContent"]!=undefined){
return node.textContent;
}
var _22b="";
if(node==null){
return _22b;
}
var i=0,n;
while(n=node.childNodes[i++]){
switch(n.nodeType){
case 1:
case 5:
_22b+=dojo.dom.textContent(n);
break;
case 3:
case 2:
case 4:
_22b+=n.nodeValue;
break;
default:
break;
}
}
return _22b;
}
};
dojo.dom.hasParent=function(node){
return Boolean(node&&node.parentNode&&dojo.dom.isNode(node.parentNode));
};
dojo.dom.isTag=function(node){
if(node&&node.tagName){
for(var i=1;i<arguments.length;i++){
if(node.tagName==String(arguments[i])){
return String(arguments[i]);
}
}
}
return "";
};
dojo.dom.setAttributeNS=function(elem,_232,_233,_234){
if(elem==null||((elem==undefined)&&(typeof elem=="undefined"))){
dojo.raise("No element given to dojo.dom.setAttributeNS");
}
if(!((elem.setAttributeNS==undefined)&&(typeof elem.setAttributeNS=="undefined"))){
elem.setAttributeNS(_232,_233,_234);
}else{
var _235=elem.ownerDocument;
var _236=_235.createNode(2,_233,_232);
_236.nodeValue=_234;
elem.setAttributeNode(_236);
}
};
dojo.provide("dojo.undo.browser");
try{
if((!djConfig["preventBackButtonFix"])&&(!dojo.hostenv.post_load_)){
document.write("<iframe style='border: 0px; width: 1px; height: 1px; position: absolute; bottom: 0px; right: 0px; visibility: visible;' name='djhistory' id='djhistory' src='"+(djConfig["dojoIframeHistoryUrl"]||dojo.hostenv.getBaseScriptUri()+"iframe_history.html")+"'></iframe>");
}
}
catch(e){
}
if(dojo.render.html.opera){
dojo.debug("Opera is not supported with dojo.undo.browser, so back/forward detection will not work.");
}
dojo.undo.browser={initialHref:(!dj_undef("window"))?window.location.href:"",initialHash:(!dj_undef("window"))?window.location.hash:"",moveForward:false,historyStack:[],forwardStack:[],historyIframe:null,bookmarkAnchor:null,locationTimer:null,setInitialState:function(args){
this.initialState=this._createState(this.initialHref,args,this.initialHash);
},addToHistory:function(args){
this.forwardStack=[];
var hash=null;
var url=null;
if(!this.historyIframe){
if(djConfig["useXDomain"]&&!djConfig["dojoIframeHistoryUrl"]){
dojo.debug("dojo.undo.browser: When using cross-domain Dojo builds,"+" please save iframe_history.html to your domain and set djConfig.dojoIframeHistoryUrl"+" to the path on your domain to iframe_history.html");
}
this.historyIframe=window.frames["djhistory"];
}
if(!this.bookmarkAnchor){
this.bookmarkAnchor=document.createElement("a");
dojo.body().appendChild(this.bookmarkAnchor);
this.bookmarkAnchor.style.display="none";
}
if(args["changeUrl"]){
hash="#"+((args["changeUrl"]!==true)?args["changeUrl"]:(new Date()).getTime());
if(this.historyStack.length==0&&this.initialState.urlHash==hash){
this.initialState=this._createState(url,args,hash);
return;
}else{
if(this.historyStack.length>0&&this.historyStack[this.historyStack.length-1].urlHash==hash){
this.historyStack[this.historyStack.length-1]=this._createState(url,args,hash);
return;
}
}
this.changingUrl=true;
setTimeout("window.location.href = '"+hash+"'; dojo.undo.browser.changingUrl = false;",1);
this.bookmarkAnchor.href=hash;
if(dojo.render.html.ie){
url=this._loadIframeHistory();
var _23b=args["back"]||args["backButton"]||args["handle"];
var tcb=function(_23d){
if(window.location.hash!=""){
setTimeout("window.location.href = '"+hash+"';",1);
}
_23b.apply(this,[_23d]);
};
if(args["back"]){
args.back=tcb;
}else{
if(args["backButton"]){
args.backButton=tcb;
}else{
if(args["handle"]){
args.handle=tcb;
}
}
}
var _23e=args["forward"]||args["forwardButton"]||args["handle"];
var tfw=function(_240){
if(window.location.hash!=""){
window.location.href=hash;
}
if(_23e){
_23e.apply(this,[_240]);
}
};
if(args["forward"]){
args.forward=tfw;
}else{
if(args["forwardButton"]){
args.forwardButton=tfw;
}else{
if(args["handle"]){
args.handle=tfw;
}
}
}
}else{
if(dojo.render.html.moz){
if(!this.locationTimer){
this.locationTimer=setInterval("dojo.undo.browser.checkLocation();",200);
}
}
}
}else{
url=this._loadIframeHistory();
}
this.historyStack.push(this._createState(url,args,hash));
},checkLocation:function(){
if(!this.changingUrl){
var hsl=this.historyStack.length;
if((window.location.hash==this.initialHash||window.location.href==this.initialHref)&&(hsl==1)){
this.handleBackButton();
return;
}
if(this.forwardStack.length>0){
if(this.forwardStack[this.forwardStack.length-1].urlHash==window.location.hash){
this.handleForwardButton();
return;
}
}
if((hsl>=2)&&(this.historyStack[hsl-2])){
if(this.historyStack[hsl-2].urlHash==window.location.hash){
this.handleBackButton();
return;
}
}
}
},iframeLoaded:function(evt,_243){
if(!dojo.render.html.opera){
var _244=this._getUrlQuery(_243.href);
if(_244==null){
if(this.historyStack.length==1){
this.handleBackButton();
}
return;
}
if(this.moveForward){
this.moveForward=false;
return;
}
if(this.historyStack.length>=2&&_244==this._getUrlQuery(this.historyStack[this.historyStack.length-2].url)){
this.handleBackButton();
}else{
if(this.forwardStack.length>0&&_244==this._getUrlQuery(this.forwardStack[this.forwardStack.length-1].url)){
this.handleForwardButton();
}
}
}
},handleBackButton:function(){
var _245=this.historyStack.pop();
if(!_245){
return;
}
var last=this.historyStack[this.historyStack.length-1];
if(!last&&this.historyStack.length==0){
last=this.initialState;
}
if(last){
if(last.kwArgs["back"]){
last.kwArgs["back"]();
}else{
if(last.kwArgs["backButton"]){
last.kwArgs["backButton"]();
}else{
if(last.kwArgs["handle"]){
last.kwArgs.handle("back");
}
}
}
}
this.forwardStack.push(_245);
},handleForwardButton:function(){
var last=this.forwardStack.pop();
if(!last){
return;
}
if(last.kwArgs["forward"]){
last.kwArgs.forward();
}else{
if(last.kwArgs["forwardButton"]){
last.kwArgs.forwardButton();
}else{
if(last.kwArgs["handle"]){
last.kwArgs.handle("forward");
}
}
}
this.historyStack.push(last);
},_createState:function(url,args,hash){
return {"url":url,"kwArgs":args,"urlHash":hash};
},_getUrlQuery:function(url){
var _24c=url.split("?");
if(_24c.length<2){
return null;
}else{
return _24c[1];
}
},_loadIframeHistory:function(){
var url=(djConfig["dojoIframeHistoryUrl"]||dojo.hostenv.getBaseScriptUri()+"iframe_history.html")+"?"+(new Date()).getTime();
this.moveForward=true;
dojo.io.setIFrameSrc(this.historyIframe,url,false);
return url;
}};
dojo.provide("dojo.io.BrowserIO");
if(!dj_undef("window")){
dojo.io.checkChildrenForFile=function(node){
var _24f=false;
var _250=node.getElementsByTagName("input");
dojo.lang.forEach(_250,function(_251){
if(_24f){
return;
}
if(_251.getAttribute("type")=="file"){
_24f=true;
}
});
return _24f;
};
dojo.io.formHasFile=function(_252){
return dojo.io.checkChildrenForFile(_252);
};
dojo.io.updateNode=function(node,_254){
node=dojo.byId(node);
var args=_254;
if(dojo.lang.isString(_254)){
args={url:_254};
}
args.mimetype="text/html";
args.load=function(t,d,e){
while(node.firstChild){
dojo.dom.destroyNode(node.firstChild);
}
node.innerHTML=d;
};
dojo.io.bind(args);
};
dojo.io.formFilter=function(node){
var type=(node.type||"").toLowerCase();
return !node.disabled&&node.name&&!dojo.lang.inArray(["file","submit","image","reset","button"],type);
};
dojo.io.encodeForm=function(_25b,_25c,_25d){
if((!_25b)||(!_25b.tagName)||(!_25b.tagName.toLowerCase()=="form")){
dojo.raise("Attempted to encode a non-form element.");
}
if(!_25d){
_25d=dojo.io.formFilter;
}
var enc=/utf/i.test(_25c||"")?encodeURIComponent:dojo.string.encodeAscii;
var _25f=[];
for(var i=0;i<_25b.elements.length;i++){
var elm=_25b.elements[i];
if(!elm||elm.tagName.toLowerCase()=="fieldset"||!_25d(elm)){
continue;
}
var name=enc(elm.name);
var type=elm.type.toLowerCase();
if(type=="select-multiple"){
for(var j=0;j<elm.options.length;j++){
if(elm.options[j].selected){
_25f.push(name+"="+enc(elm.options[j].value));
}
}
}else{
if(dojo.lang.inArray(["radio","checkbox"],type)){
if(elm.checked){
_25f.push(name+"="+enc(elm.value));
}
}else{
_25f.push(name+"="+enc(elm.value));
}
}
}
var _265=_25b.getElementsByTagName("input");
for(var i=0;i<_265.length;i++){
var _266=_265[i];
if(_266.type.toLowerCase()=="image"&&_266.form==_25b&&_25d(_266)){
var name=enc(_266.name);
_25f.push(name+"="+enc(_266.value));
_25f.push(name+".x=0");
_25f.push(name+".y=0");
}
}
return _25f.join("&")+"&";
};
dojo.io.FormBind=function(args){
this.bindArgs={};
if(args&&args.formNode){
this.init(args);
}else{
if(args){
this.init({formNode:args});
}
}
};
dojo.lang.extend(dojo.io.FormBind,{form:null,bindArgs:null,clickedButton:null,init:function(args){
var form=dojo.byId(args.formNode);
if(!form||!form.tagName||form.tagName.toLowerCase()!="form"){
throw new Error("FormBind: Couldn't apply, invalid form");
}else{
if(this.form==form){
return;
}else{
if(this.form){
throw new Error("FormBind: Already applied to a form");
}
}
}
dojo.lang.mixin(this.bindArgs,args);
this.form=form;
this.connect(form,"onsubmit","submit");
for(var i=0;i<form.elements.length;i++){
var node=form.elements[i];
if(node&&node.type&&dojo.lang.inArray(["submit","button"],node.type.toLowerCase())){
this.connect(node,"onclick","click");
}
}
var _26c=form.getElementsByTagName("input");
for(var i=0;i<_26c.length;i++){
var _26d=_26c[i];
if(_26d.type.toLowerCase()=="image"&&_26d.form==form){
this.connect(_26d,"onclick","click");
}
}
},onSubmit:function(form){
return true;
},submit:function(e){
e.preventDefault();
if(this.onSubmit(this.form)){
dojo.io.bind(dojo.lang.mixin(this.bindArgs,{formFilter:dojo.lang.hitch(this,"formFilter")}));
}
},click:function(e){
var node=e.currentTarget;
if(node.disabled){
return;
}
this.clickedButton=node;
},formFilter:function(node){
var type=(node.type||"").toLowerCase();
var _274=false;
if(node.disabled||!node.name){
_274=false;
}else{
if(dojo.lang.inArray(["submit","button","image"],type)){
if(!this.clickedButton){
this.clickedButton=node;
}
_274=node==this.clickedButton;
}else{
_274=!dojo.lang.inArray(["file","submit","reset","button"],type);
}
}
return _274;
},connect:function(_275,_276,_277){
if(dojo.getObject("dojo.event.connect")){
dojo.event.connect(_275,_276,this,_277);
}else{
var fcn=dojo.lang.hitch(this,_277);
_275[_276]=function(e){
if(!e){
e=window.event;
}
if(!e.currentTarget){
e.currentTarget=e.srcElement;
}
if(!e.preventDefault){
e.preventDefault=function(){
window.event.returnValue=false;
};
}
fcn(e);
};
}
}});
dojo.io.XMLHTTPTransport=new function(){
var _27a=this;
var _27b={};
this.useCache=false;
this.preventCache=false;
function getCacheKey(url,_27d,_27e){
return url+"|"+_27d+"|"+_27e.toLowerCase();
}
function addToCache(url,_280,_281,http){
_27b[getCacheKey(url,_280,_281)]=http;
}
function getFromCache(url,_284,_285){
return _27b[getCacheKey(url,_284,_285)];
}
this.clearCache=function(){
_27b={};
};
function doLoad(_286,http,url,_289,_28a){
if(((http.status>=200)&&(http.status<300))||(http.status==304)||(http.status==1223)||(location.protocol=="file:"&&(http.status==0||http.status==undefined))||(location.protocol=="chrome:"&&(http.status==0||http.status==undefined))){
var ret;
if(_286.method.toLowerCase()=="head"){
var _28c=http.getAllResponseHeaders();
ret={};
ret.toString=function(){
return _28c;
};
var _28d=_28c.split(/[\r\n]+/g);
for(var i=0;i<_28d.length;i++){
var pair=_28d[i].match(/^([^:]+)\s*:\s*(.+)$/i);
if(pair){
ret[pair[1]]=pair[2];
}
}
}else{
if(_286.mimetype=="text/javascript"){
try{
ret=dj_eval(http.responseText);
}
catch(e){
dojo.debug(e);
dojo.debug(http.responseText);
ret=null;
}
}else{
if(_286.mimetype.substr(0,9)=="text/json"||_286.mimetype.substr(0,16)=="application/json"){
try{
ret=dj_eval("("+_286.jsonFilter(http.responseText)+")");
}
catch(e){
dojo.debug(e);
dojo.debug(http.responseText);
ret=false;
}
}else{
if((_286.mimetype=="application/xml")||(_286.mimetype=="text/xml")){
ret=http.responseXML;
if(!ret||typeof ret=="string"||!http.getResponseHeader("Content-Type")){
ret=dojo.dom.createDocumentFromText(http.responseText);
}
}else{
ret=http.responseText;
}
}
}
}
if(_28a){
addToCache(url,_289,_286.method,http);
}
_286[(typeof _286.load=="function")?"load":"handle"]("load",ret,http,_286);
}else{
var _290=new dojo.io.Error("XMLHttpTransport Error: "+http.status+" "+http.statusText);
_286[(typeof _286.error=="function")?"error":"handle"]("error",_290,http,_286);
}
}
function setHeaders(http,_292){
if(_292["headers"]){
for(var _293 in _292["headers"]){
if(_293.toLowerCase()=="content-type"&&!_292["contentType"]){
_292["contentType"]=_292["headers"][_293];
}else{
http.setRequestHeader(_293,_292["headers"][_293]);
}
}
}
}
this.inFlight=[];
this.inFlightTimer=null;
this.startWatchingInFlight=function(){
if(!this.inFlightTimer){
this.inFlightTimer=setTimeout("dojo.io.XMLHTTPTransport.watchInFlight();",10);
}
};
this.watchInFlight=function(){
var now=null;
if(!dojo.hostenv._blockAsync&&!_27a._blockAsync){
for(var x=this.inFlight.length-1;x>=0;x--){
try{
var tif=this.inFlight[x];
if(!tif||tif.http._aborted||!tif.http.readyState){
this.inFlight.splice(x,1);
continue;
}
if(4==tif.http.readyState){
this.inFlight.splice(x,1);
doLoad(tif.req,tif.http,tif.url,tif.query,tif.useCache);
}else{
if(tif.startTime){
if(!now){
now=(new Date()).getTime();
}
if(tif.startTime+(tif.req.timeoutSeconds*1000)<now){
if(typeof tif.http.abort=="function"){
tif.http.abort();
}
this.inFlight.splice(x,1);
tif.req[(typeof tif.req.timeout=="function")?"timeout":"handle"]("timeout",null,tif.http,tif.req);
}
}
}
}
catch(e){
try{
var _297=new dojo.io.Error("XMLHttpTransport.watchInFlight Error: "+e);
tif.req[(typeof tif.req.error=="function")?"error":"handle"]("error",_297,tif.http,tif.req);
}
catch(e2){
dojo.debug("XMLHttpTransport error callback failed: "+e2);
}
}
}
}
clearTimeout(this.inFlightTimer);
if(this.inFlight.length==0){
this.inFlightTimer=null;
return;
}
this.inFlightTimer=setTimeout("dojo.io.XMLHTTPTransport.watchInFlight();",10);
};
var _298=dojo.hostenv.getXmlhttpObject()?true:false;
this.canHandle=function(_299){
var mlc=_299["mimetype"].toLowerCase()||"";
return _298&&((dojo.lang.inArray(["text/plain","text/html","application/xml","text/xml","text/javascript"],mlc))||(mlc.substr(0,9)=="text/json"||mlc.substr(0,16)=="application/json"))&&!(_299["formNode"]&&dojo.io.formHasFile(_299["formNode"]));
};
this.multipartBoundary="45309FFF-BD65-4d50-99C9-36986896A96F";
this.bind=function(_29b){
var url=_29b.url;
var _29d="";
if(_29b["formNode"]){
var ta=_29b.formNode.getAttribute("action");
if(typeof (ta)!="string"){
ta=_29b.formNode.attributes.action.value;
}
if((ta)&&(!_29b["url"])){
url=ta;
}
var tp=_29b.formNode.getAttribute("method");
if((tp)&&(!_29b["method"])){
_29b.method=tp;
}
_29d+=dojo.io.encodeForm(_29b.formNode,_29b.encoding,_29b["formFilter"]);
}
if(url.indexOf("#")>-1){
dojo.debug("Warning: dojo.io.bind: stripping hash values from url:",url);
url=url.split("#")[0];
}
if(_29b["file"]){
_29b.method="post";
}
if(!_29b["method"]){
_29b.method="get";
}
if(_29b.method.toLowerCase()=="get"){
_29b.multipart=false;
}else{
if(_29b["file"]){
_29b.multipart=true;
}else{
if(!_29b["multipart"]){
_29b.multipart=false;
}
}
}
if(_29b["backButton"]||_29b["back"]||_29b["changeUrl"]){
dojo.undo.browser.addToHistory(_29b);
}
var _2a0=_29b["content"]||{};
if(_29b.sendTransport){
_2a0["dojo.transport"]="xmlhttp";
}
do{
if(_29b.postContent){
_29d=_29b.postContent;
break;
}
if(_2a0){
_29d+=dojo.io.argsFromMap(_2a0,_29b.encoding);
}
if(_29b.method.toLowerCase()=="get"||!_29b.multipart){
break;
}
var t=[];
if(_29d.length){
var q=_29d.split("&");
for(var i=0;i<q.length;++i){
if(q[i].length){
var p=q[i].split("=");
t.push("--"+this.multipartBoundary,"Content-Disposition: form-data; name=\""+p[0]+"\"","",p[1]);
}
}
}
if(_29b.file){
if(dojo.lang.isArray(_29b.file)){
for(var i=0;i<_29b.file.length;++i){
var o=_29b.file[i];
t.push("--"+this.multipartBoundary,"Content-Disposition: form-data; name=\""+o.name+"\"; filename=\""+("fileName" in o?o.fileName:o.name)+"\"","Content-Type: "+("contentType" in o?o.contentType:"application/octet-stream"),"",o.content);
}
}else{
var o=_29b.file;
t.push("--"+this.multipartBoundary,"Content-Disposition: form-data; name=\""+o.name+"\"; filename=\""+("fileName" in o?o.fileName:o.name)+"\"","Content-Type: "+("contentType" in o?o.contentType:"application/octet-stream"),"",o.content);
}
}
if(t.length){
t.push("--"+this.multipartBoundary+"--","");
_29d=t.join("\r\n");
}
}while(false);
var _2a6=_29b["sync"]?false:true;
var _2a7=_29b["preventCache"]||(this.preventCache==true&&_29b["preventCache"]!=false);
var _2a8=_29b["useCache"]==true||(this.useCache==true&&_29b["useCache"]!=false);
if(!_2a7&&_2a8){
var _2a9=getFromCache(url,_29d,_29b.method);
if(_2a9){
doLoad(_29b,_2a9,url,_29d,false);
return;
}
}
var http=dojo.hostenv.getXmlhttpObject(_29b);
var _2ab=false;
if(_2a6){
var _2ac=this.inFlight.push({"req":_29b,"http":http,"url":url,"query":_29d,"useCache":_2a8,"startTime":_29b.timeoutSeconds?(new Date()).getTime():0});
this.startWatchingInFlight();
}else{
_27a._blockAsync=true;
}
if(_29b.method.toLowerCase()=="post"){
if(!_29b.user){
http.open("POST",url,_2a6);
}else{
http.open("POST",url,_2a6,_29b.user,_29b.password);
}
setHeaders(http,_29b);
http.setRequestHeader("Content-Type",_29b.multipart?("multipart/form-data; boundary="+this.multipartBoundary):(_29b.contentType||"application/x-www-form-urlencoded"));
try{
http.send(_29d);
}
catch(e){
if(typeof http.abort=="function"){
http.abort();
}
doLoad(_29b,{status:404},url,_29d,_2a8);
}
}else{
var _2ad=url;
if(_29d!=""){
_2ad+=(_2ad.indexOf("?")>-1?"&":"?")+_29d;
}
if(_2a7){
_2ad+=(dojo.string.endsWithAny(_2ad,"?","&")?"":(_2ad.indexOf("?")>-1?"&":"?"))+"dojo.preventCache="+new Date().valueOf();
}
if(!_29b.user){
http.open(_29b.method.toUpperCase(),_2ad,_2a6);
}else{
http.open(_29b.method.toUpperCase(),_2ad,_2a6,_29b.user,_29b.password);
}
setHeaders(http,_29b);
try{
http.send(null);
}
catch(e){
if(typeof http.abort=="function"){
http.abort();
}
doLoad(_29b,{status:404},url,_29d,_2a8);
}
}
if(!_2a6){
doLoad(_29b,http,url,_29d,_2a8);
_27a._blockAsync=false;
}
_29b.abort=function(){
try{
http._aborted=true;
}
catch(e){
}
return http.abort();
};
return;
};
dojo.io.transports.addTransport("XMLHTTPTransport");
};
}
dojo.provide("dojo.io.cookie");
dojo.io.cookie.setCookie=function(name,_2af,days,path,_2b2,_2b3){
var _2b4=-1;
if((typeof days=="number")&&(days>=0)){
var d=new Date();
d.setTime(d.getTime()+(days*24*60*60*1000));
_2b4=d.toGMTString();
}
_2af=escape(_2af);
document.cookie=name+"="+_2af+";"+(_2b4!=-1?" expires="+_2b4+";":"")+(path?"path="+path:"")+(_2b2?"; domain="+_2b2:"")+(_2b3?"; secure":"");
};
dojo.io.cookie.set=dojo.io.cookie.setCookie;
dojo.io.cookie.getCookie=function(name){
var idx=document.cookie.lastIndexOf(name+"=");
if(idx==-1){
return null;
}
var _2b8=document.cookie.substring(idx+name.length+1);
var end=_2b8.indexOf(";");
if(end==-1){
end=_2b8.length;
}
_2b8=_2b8.substring(0,end);
_2b8=unescape(_2b8);
return _2b8;
};
dojo.io.cookie.get=dojo.io.cookie.getCookie;
dojo.io.cookie.deleteCookie=function(name){
dojo.io.cookie.setCookie(name,"-",0);
};
dojo.io.cookie.setObjectCookie=function(name,obj,days,path,_2bf,_2c0,_2c1){
if(arguments.length==5){
_2c1=_2bf;
_2bf=null;
_2c0=null;
}
var _2c2=[],_2c3,_2c4="";
if(!_2c1){
_2c3=dojo.io.cookie.getObjectCookie(name);
}
if(days>=0){
if(!_2c3){
_2c3={};
}
for(var prop in obj){
if(obj[prop]==null){
delete _2c3[prop];
}else{
if((typeof obj[prop]=="string")||(typeof obj[prop]=="number")){
_2c3[prop]=obj[prop];
}
}
}
prop=null;
for(var prop in _2c3){
_2c2.push(escape(prop)+"="+escape(_2c3[prop]));
}
_2c4=_2c2.join("&");
}
dojo.io.cookie.setCookie(name,_2c4,days,path,_2bf,_2c0);
};
dojo.io.cookie.getObjectCookie=function(name){
var _2c7=null,_2c8=dojo.io.cookie.getCookie(name);
if(_2c8){
_2c7={};
var _2c9=_2c8.split("&");
for(var i=0;i<_2c9.length;i++){
var pair=_2c9[i].split("=");
var _2cc=pair[1];
if(isNaN(_2cc)){
_2cc=unescape(pair[1]);
}
_2c7[unescape(pair[0])]=_2cc;
}
}
return _2c7;
};
dojo.io.cookie.isSupported=function(){
if(typeof navigator.cookieEnabled!="boolean"){
dojo.io.cookie.setCookie("__TestingYourBrowserForCookieSupport__","CookiesAllowed",90,null);
var _2cd=dojo.io.cookie.getCookie("__TestingYourBrowserForCookieSupport__");
navigator.cookieEnabled=(_2cd=="CookiesAllowed");
if(navigator.cookieEnabled){
this.deleteCookie("__TestingYourBrowserForCookieSupport__");
}
}
return navigator.cookieEnabled;
};
if(!dojo.io.cookies){
dojo.io.cookies=dojo.io.cookie;
}
dojo.kwCompoundRequire({common:["dojo.io.common"],rhino:["dojo.io.RhinoIO"],browser:["dojo.io.BrowserIO","dojo.io.cookie"],dashboard:["dojo.io.BrowserIO","dojo.io.cookie"]});
dojo.provide("dojo.io.*");
dojo.provide("dojo.io.ScriptSrcIO");
dojo.io.ScriptSrcTransport=new function(){
this.preventCache=false;
this.maxUrlLength=1000;
this.inFlightTimer=null;
this.DsrStatusCodes={Continue:100,Ok:200,Error:500};
this.startWatchingInFlight=function(){
if(!this.inFlightTimer){
this.inFlightTimer=setInterval("dojo.io.ScriptSrcTransport.watchInFlight();",100);
}
};
this.watchInFlight=function(){
var _2ce=0;
var _2cf=0;
for(var _2d0 in this._state){
_2ce++;
var _2d1=this._state[_2d0];
if(_2d1.isDone){
_2cf++;
delete this._state[_2d0];
}else{
if(!_2d1.isFinishing){
var _2d2=_2d1.kwArgs;
try{
if(_2d1.checkString&&eval("typeof("+_2d1.checkString+") != 'undefined'")){
_2d1.isFinishing=true;
this._finish(_2d1,"load");
_2cf++;
delete this._state[_2d0];
}else{
if(_2d2.timeoutSeconds&&_2d2.timeout){
if(_2d1.startTime+(_2d2.timeoutSeconds*1000)<(new Date()).getTime()){
_2d1.isFinishing=true;
this._finish(_2d1,"timeout");
_2cf++;
delete this._state[_2d0];
}
}else{
if(!_2d2.timeoutSeconds){
_2cf++;
}
}
}
}
catch(e){
_2d1.isFinishing=true;
this._finish(_2d1,"error",{status:this.DsrStatusCodes.Error,response:e});
}
}
}
}
if(_2cf>=_2ce){
clearInterval(this.inFlightTimer);
this.inFlightTimer=null;
}
};
this.canHandle=function(_2d3){
return dojo.lang.inArray(["text/javascript","text/json","application/json"],(_2d3["mimetype"].toLowerCase()))&&(_2d3["method"].toLowerCase()=="get")&&!(_2d3["formNode"]&&dojo.io.formHasFile(_2d3["formNode"]))&&(!_2d3["sync"]||_2d3["sync"]==false)&&!_2d3["file"]&&!_2d3["multipart"];
};
this.removeScripts=function(){
var _2d4=document.getElementsByTagName("script");
for(var i=0;_2d4&&i<_2d4.length;i++){
var _2d6=_2d4[i];
if(_2d6.className=="ScriptSrcTransport"){
var _2d7=_2d6.parentNode;
_2d7.removeChild(_2d6);
i--;
}
}
};
this.bind=function(_2d8){
var url=_2d8.url;
var _2da="";
if(_2d8["formNode"]){
var ta=_2d8.formNode.getAttribute("action");
if((ta)&&(!_2d8["url"])){
url=ta;
}
var tp=_2d8.formNode.getAttribute("method");
if((tp)&&(!_2d8["method"])){
_2d8.method=tp;
}
_2da+=dojo.io.encodeForm(_2d8.formNode,_2d8.encoding,_2d8["formFilter"]);
}
if(url.indexOf("#")>-1){
dojo.debug("Warning: dojo.io.bind: stripping hash values from url:",url);
url=url.split("#")[0];
}
var _2dd=url.split("?");
if(_2dd&&_2dd.length==2){
url=_2dd[0];
_2da+=(_2da?"&":"")+_2dd[1];
}
if(_2d8["backButton"]||_2d8["back"]||_2d8["changeUrl"]){
dojo.undo.browser.addToHistory(_2d8);
}
var id=_2d8["apiId"]?_2d8["apiId"]:"id"+this._counter++;
var _2df=_2d8["content"];
var _2e0=_2d8.jsonParamName;
if(_2d8.sendTransport||_2e0){
if(!_2df){
_2df={};
}
if(_2d8.sendTransport){
_2df["dojo.transport"]="scriptsrc";
}
if(_2e0){
_2df[_2e0]="dojo.io.ScriptSrcTransport._state."+id+".jsonpCall";
}
}
if(_2d8.postContent){
_2da=_2d8.postContent;
}else{
if(_2df){
_2da+=((_2da)?"&":"")+dojo.io.argsFromMap(_2df,_2d8.encoding,_2e0);
}
}
if(_2d8["apiId"]){
_2d8["useRequestId"]=true;
}
var _2e1={"id":id,"idParam":"_dsrid="+id,"url":url,"query":_2da,"kwArgs":_2d8,"startTime":(new Date()).getTime(),"isFinishing":false};
if(!url){
this._finish(_2e1,"error",{status:this.DsrStatusCodes.Error,statusText:"url.none"});
return;
}
if(_2df&&_2df[_2e0]){
_2e1.jsonp=_2df[_2e0];
_2e1.jsonpCall=function(data){
if(data["Error"]||data["error"]){
if(dojo["json"]&&dojo["json"]["serialize"]){
dojo.debug(dojo.json.serialize(data));
}
dojo.io.ScriptSrcTransport._finish(this,"error",data);
}else{
dojo.io.ScriptSrcTransport._finish(this,"load",data);
}
};
}
if(_2d8["useRequestId"]||_2d8["checkString"]||_2e1["jsonp"]){
this._state[id]=_2e1;
}
if(_2d8["checkString"]){
_2e1.checkString=_2d8["checkString"];
}
_2e1.constantParams=(_2d8["constantParams"]==null?"":_2d8["constantParams"]);
if(_2d8["preventCache"]||(this.preventCache==true&&_2d8["preventCache"]!=false)){
_2e1.nocacheParam="dojo.preventCache="+new Date().valueOf();
}else{
_2e1.nocacheParam="";
}
var _2e3=_2e1.url.length+_2e1.query.length+_2e1.constantParams.length+_2e1.nocacheParam.length+this._extraPaddingLength;
if(_2d8["useRequestId"]){
_2e3+=_2e1.idParam.length;
}
if(!_2d8["checkString"]&&_2d8["useRequestId"]&&!_2e1["jsonp"]&&!_2d8["forceSingleRequest"]&&_2e3>this.maxUrlLength){
if(url>this.maxUrlLength){
this._finish(_2e1,"error",{status:this.DsrStatusCodes.Error,statusText:"url.tooBig"});
return;
}else{
this._multiAttach(_2e1,1);
}
}else{
var _2e4=[_2e1.constantParams,_2e1.nocacheParam,_2e1.query];
if(_2d8["useRequestId"]&&!_2e1["jsonp"]){
_2e4.unshift(_2e1.idParam);
}
var _2e5=this._buildUrl(_2e1.url,_2e4);
_2e1.finalUrl=_2e5;
this._attach(_2e1.id,_2e5);
}
this.startWatchingInFlight();
};
this._counter=1;
this._state={};
this._extraPaddingLength=16;
this._buildUrl=function(url,_2e7){
var _2e8=url;
var _2e9="?";
for(var i=0;i<_2e7.length;i++){
if(_2e7[i]){
_2e8+=_2e9+_2e7[i];
_2e9="&";
}
}
return _2e8;
};
this._attach=function(id,url){
var _2ed=document.createElement("script");
_2ed.type="text/javascript";
_2ed.src=url;
_2ed.id=id;
_2ed.className="ScriptSrcTransport";
document.getElementsByTagName("head")[0].appendChild(_2ed);
};
this._multiAttach=function(_2ee,part){
if(_2ee.query==null){
this._finish(_2ee,"error",{status:this.DsrStatusCodes.Error,statusText:"query.null"});
return;
}
if(!_2ee.constantParams){
_2ee.constantParams="";
}
var _2f0=this.maxUrlLength-_2ee.idParam.length-_2ee.constantParams.length-_2ee.url.length-_2ee.nocacheParam.length-this._extraPaddingLength;
var _2f1=_2ee.query.length<_2f0;
var _2f2;
if(_2f1){
_2f2=_2ee.query;
_2ee.query=null;
}else{
var _2f3=_2ee.query.lastIndexOf("&",_2f0-1);
var _2f4=_2ee.query.lastIndexOf("=",_2f0-1);
if(_2f3>_2f4||_2f4==_2f0-1){
_2f2=_2ee.query.substring(0,_2f3);
_2ee.query=_2ee.query.substring(_2f3+1,_2ee.query.length);
}else{
_2f2=_2ee.query.substring(0,_2f0);
var _2f5=_2f2.substring((_2f3==-1?0:_2f3+1),_2f4);
_2ee.query=_2f5+"="+_2ee.query.substring(_2f0,_2ee.query.length);
}
}
var _2f6=[_2f2,_2ee.idParam,_2ee.constantParams,_2ee.nocacheParam];
if(!_2f1){
_2f6.push("_part="+part);
}
var url=this._buildUrl(_2ee.url,_2f6);
this._attach(_2ee.id+"_"+part,url);
};
this._finish=function(_2f8,_2f9,_2fa){
if(_2f9!="partOk"&&!_2f8.kwArgs[_2f9]&&!_2f8.kwArgs["handle"]){
if(_2f9=="error"){
_2f8.isDone=true;
throw _2fa;
}
}else{
switch(_2f9){
case "load":
var _2fb=_2fa?_2fa.response:null;
if(!_2fb){
_2fb=_2fa;
}
_2f8.kwArgs[(typeof _2f8.kwArgs.load=="function")?"load":"handle"]("load",_2fb,_2fa,_2f8.kwArgs);
_2f8.isDone=true;
break;
case "partOk":
var part=parseInt(_2fa.response.part,10)+1;
if(_2fa.response.constantParams){
_2f8.constantParams=_2fa.response.constantParams;
}
this._multiAttach(_2f8,part);
_2f8.isDone=false;
break;
case "error":
_2f8.kwArgs[(typeof _2f8.kwArgs.error=="function")?"error":"handle"]("error",_2fa.response,_2fa,_2f8.kwArgs);
_2f8.isDone=true;
break;
default:
_2f8.kwArgs[(typeof _2f8.kwArgs[_2f9]=="function")?_2f9:"handle"](_2f9,_2fa,_2fa,_2f8.kwArgs);
_2f8.isDone=true;
}
}
};
dojo.io.transports.addTransport("ScriptSrcTransport");
};
if(typeof window!="undefined"){
window.onscriptload=function(_2fd){
var _2fe=null;
var _2ff=dojo.io.ScriptSrcTransport;
if(_2ff._state[_2fd.id]){
_2fe=_2ff._state[_2fd.id];
}else{
var _300;
for(var _301 in _2ff._state){
_300=_2ff._state[_301];
if(_300.finalUrl&&_300.finalUrl==_2fd.id){
_2fe=_300;
break;
}
}
if(_2fe==null){
var _302=document.getElementsByTagName("script");
for(var i=0;_302&&i<_302.length;i++){
var _304=_302[i];
if(_304.getAttribute("class")=="ScriptSrcTransport"&&_304.src==_2fd.id){
_2fe=_2ff._state[_304.id];
break;
}
}
}
if(_2fe==null){
throw "No matching state for onscriptload event.id: "+_2fd.id;
}
}
var _305="error";
switch(_2fd.status){
case dojo.io.ScriptSrcTransport.DsrStatusCodes.Continue:
_305="partOk";
break;
case dojo.io.ScriptSrcTransport.DsrStatusCodes.Ok:
_305="load";
break;
}
_2ff._finish(_2fe,_305,_2fd);
};
}
var Prototype={Version:"1.5.1.1",Browser:{IE:!!(window.attachEvent&&!window.opera),Opera:!!window.opera,WebKit:navigator.userAgent.indexOf("AppleWebKit/")>-1,Gecko:navigator.userAgent.indexOf("Gecko")>-1&&navigator.userAgent.indexOf("KHTML")==-1},BrowserFeatures:{XPath:!!document.evaluate,ElementExtensions:!!window.HTMLElement,SpecificElementExtensions:(document.createElement("div").__proto__!==document.createElement("form").__proto__)},ScriptFragment:"<script[^>]*>([\\S\\s]*?)</script>",JSONFilter:/^\/\*-secure-([\s\S]*)\*\/\s*$/,emptyFunction:function(){
},K:function(x){
return x;
}};
var Class={create:function(){
return function(){
this.initialize.apply(this,arguments);
};
}};
var Abstract=new Object();
Object.extend=function(_307,_308){
for(var _309 in _308){
_307[_309]=_308[_309];
}
return _307;
};
Object.extend(Object,{inspect:function(_30a){
try{
if(_30a===undefined){
return "undefined";
}
if(_30a===null){
return "null";
}
return _30a.inspect?_30a.inspect():_30a.toString();
}
catch(e){
if(e instanceof RangeError){
return "...";
}
throw e;
}
},toJSON:function(_30b){
var type=typeof _30b;
switch(type){
case "undefined":
case "function":
case "unknown":
return;
case "boolean":
return _30b.toString();
}
if(_30b===null){
return "null";
}
if(_30b.toJSON){
return _30b.toJSON();
}
if(_30b.ownerDocument===document){
return;
}
var _30d=[];
for(var _30e in _30b){
var _30f=Object.toJSON(_30b[_30e]);
if(_30f!==undefined){
_30d.push(_30e.toJSON()+": "+_30f);
}
}
return "{"+_30d.join(", ")+"}";
},keys:function(_310){
var keys=[];
for(var _312 in _310){
keys.push(_312);
}
return keys;
},values:function(_313){
var _314=[];
for(var _315 in _313){
_314.push(_313[_315]);
}
return _314;
},clone:function(_316){
return Object.extend({},_316);
}});
Function.prototype.bind=function(){
var _317=this,args=$A(arguments),_319=args.shift();
return function(){
return _317.apply(_319,args.concat($A(arguments)));
};
};
Function.prototype.bindAsEventListener=function(_31a){
var _31b=this,args=$A(arguments),_31a=args.shift();
return function(_31d){
return _31b.apply(_31a,[_31d||window.event].concat(args));
};
};
Object.extend(Number.prototype,{toColorPart:function(){
return this.toPaddedString(2,16);
},succ:function(){
return this+1;
},times:function(_31e){
$R(0,this,true).each(_31e);
return this;
},toPaddedString:function(_31f,_320){
var _321=this.toString(_320||10);
return "0".times(_31f-_321.length)+_321;
},toJSON:function(){
return isFinite(this)?this.toString():"null";
}});
Date.prototype.toJSON=function(){
return "\""+this.getFullYear()+"-"+(this.getMonth()+1).toPaddedString(2)+"-"+this.getDate().toPaddedString(2)+"T"+this.getHours().toPaddedString(2)+":"+this.getMinutes().toPaddedString(2)+":"+this.getSeconds().toPaddedString(2)+"\"";
};
var Try={these:function(){
var _322;
for(var i=0,_324=arguments.length;i<_324;i++){
var _325=arguments[i];
try{
_322=_325();
break;
}
catch(e){
}
}
return _322;
}};
var PeriodicalExecuter=Class.create();
PeriodicalExecuter.prototype={initialize:function(_326,_327){
this.callback=_326;
this.frequency=_327;
this.currentlyExecuting=false;
this.registerCallback();
},registerCallback:function(){
this.timer=setInterval(this.onTimerEvent.bind(this),this.frequency*1000);
},stop:function(){
if(!this.timer){
return;
}
clearInterval(this.timer);
this.timer=null;
},onTimerEvent:function(){
if(!this.currentlyExecuting){
try{
this.currentlyExecuting=true;
this.callback(this);
}
finally{
this.currentlyExecuting=false;
}
}
}};
Object.extend(String,{interpret:function(_328){
return _328==null?"":String(_328);
},specialChar:{"\b":"\\b","\t":"\\t","\n":"\\n","\f":"\\f","\r":"\\r","\\":"\\\\"}});
Object.extend(String.prototype,{gsub:function(_329,_32a){
var _32b="",_32c=this,_32d;
_32a=arguments.callee.prepareReplacement(_32a);
while(_32c.length>0){
if(_32d=_32c.match(_329)){
_32b+=_32c.slice(0,_32d.index);
_32b+=String.interpret(_32a(_32d));
_32c=_32c.slice(_32d.index+_32d[0].length);
}else{
_32b+=_32c,_32c="";
}
}
return _32b;
},sub:function(_32e,_32f,_330){
_32f=this.gsub.prepareReplacement(_32f);
_330=_330===undefined?1:_330;
return this.gsub(_32e,function(_331){
if(--_330<0){
return _331[0];
}
return _32f(_331);
});
},scan:function(_332,_333){
this.gsub(_332,_333);
return this;
},truncate:function(_334,_335){
_334=_334||30;
_335=_335===undefined?"...":_335;
return this.length>_334?this.slice(0,_334-_335.length)+_335:this;
},strip:function(){
return this.replace(/^\s+/,"").replace(/\s+$/,"");
},stripTags:function(){
return this.replace(/<\/?[^>]+>/gi,"");
},stripScripts:function(){
return this.replace(new RegExp(Prototype.ScriptFragment,"img"),"");
},extractScripts:function(){
var _336=new RegExp(Prototype.ScriptFragment,"img");
var _337=new RegExp(Prototype.ScriptFragment,"im");
return (this.match(_336)||[]).map(function(_338){
return (_338.match(_337)||["",""])[1];
});
},evalScripts:function(){
return this.extractScripts().map(function(_339){
return eval(_339);
});
},escapeHTML:function(){
var self=arguments.callee;
self.text.data=this;
return self.div.innerHTML;
},unescapeHTML:function(){
var div=document.createElement("div");
div.innerHTML=this.stripTags();
return div.childNodes[0]?(div.childNodes.length>1?$A(div.childNodes).inject("",function(memo,node){
return memo+node.nodeValue;
}):div.childNodes[0].nodeValue):"";
},toQueryParams:function(_33e){
var _33f=this.strip().match(/([^?#]*)(#.*)?$/);
if(!_33f){
return {};
}
return _33f[1].split(_33e||"&").inject({},function(hash,pair){
if((pair=pair.split("="))[0]){
var key=decodeURIComponent(pair.shift());
var _343=pair.length>1?pair.join("="):pair[0];
if(_343!=undefined){
_343=decodeURIComponent(_343);
}
if(key in hash){
if(hash[key].constructor!=Array){
hash[key]=[hash[key]];
}
hash[key].push(_343);
}else{
hash[key]=_343;
}
}
return hash;
});
},toArray:function(){
return this.split("");
},succ:function(){
return this.slice(0,this.length-1)+String.fromCharCode(this.charCodeAt(this.length-1)+1);
},times:function(_344){
var _345="";
for(var i=0;i<_344;i++){
_345+=this;
}
return _345;
},camelize:function(){
var _347=this.split("-"),len=_347.length;
if(len==1){
return _347[0];
}
var _349=this.charAt(0)=="-"?_347[0].charAt(0).toUpperCase()+_347[0].substring(1):_347[0];
for(var i=1;i<len;i++){
_349+=_347[i].charAt(0).toUpperCase()+_347[i].substring(1);
}
return _349;
},capitalize:function(){
return this.charAt(0).toUpperCase()+this.substring(1).toLowerCase();
},underscore:function(){
return this.gsub(/::/,"/").gsub(/([A-Z]+)([A-Z][a-z])/,"#{1}_#{2}").gsub(/([a-z\d])([A-Z])/,"#{1}_#{2}").gsub(/-/,"_").toLowerCase();
},dasherize:function(){
return this.gsub(/_/,"-");
},inspect:function(_34b){
var _34c=this.gsub(/[\x00-\x1f\\]/,function(_34d){
var _34e=String.specialChar[_34d[0]];
return _34e?_34e:"\\u00"+_34d[0].charCodeAt().toPaddedString(2,16);
});
if(_34b){
return "\""+_34c.replace(/"/g,"\\\"")+"\"";
}
return "'"+_34c.replace(/'/g,"\\'")+"'";
},toJSON:function(){
return this.inspect(true);
},unfilterJSON:function(_34f){
return this.sub(_34f||Prototype.JSONFilter,"#{1}");
},isJSON:function(){
var str=this.replace(/\\./g,"@").replace(/"[^"\\\n\r]*"/g,"");
return (/^[,:{}\[\]0-9.\-+Eaeflnr-u \n\r\t]*$/).test(str);
},evalJSON:function(_351){
var json=this.unfilterJSON();
try{
if(!_351||json.isJSON()){
return eval("("+json+")");
}
}
catch(e){
}
throw new SyntaxError("Badly formed JSON string: "+this.inspect());
},include:function(_353){
return this.indexOf(_353)>-1;
},startsWith:function(_354){
return this.indexOf(_354)===0;
},endsWith:function(_355){
var d=this.length-_355.length;
return d>=0&&this.lastIndexOf(_355)===d;
},empty:function(){
return this=="";
},blank:function(){
return /^\s*$/.test(this);
}});
if(Prototype.Browser.WebKit||Prototype.Browser.IE){
Object.extend(String.prototype,{escapeHTML:function(){
return this.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;");
},unescapeHTML:function(){
return this.replace(/&amp;/g,"&").replace(/&lt;/g,"<").replace(/&gt;/g,">");
}});
}
String.prototype.gsub.prepareReplacement=function(_357){
if(typeof _357=="function"){
return _357;
}
var _358=new Template(_357);
return function(_359){
return _358.evaluate(_359);
};
};
String.prototype.parseQuery=String.prototype.toQueryParams;
Object.extend(String.prototype.escapeHTML,{div:document.createElement("div"),text:document.createTextNode("")});
with(String.prototype.escapeHTML){
div.appendChild(text);
}
var Template=Class.create();
Template.Pattern=/(^|.|\r|\n)(#\{(.*?)\})/;
Template.prototype={initialize:function(_35a,_35b){
this.template=_35a.toString();
this.pattern=_35b||Template.Pattern;
},evaluate:function(_35c){
return this.template.gsub(this.pattern,function(_35d){
var _35e=_35d[1];
if(_35e=="\\"){
return _35d[2];
}
return _35e+String.interpret(_35c[_35d[3]]);
});
}};
var $break={},$continue=new Error("\"throw $continue\" is deprecated, use \"return\" instead");
var Enumerable={each:function(_35f){
var _360=0;
try{
this._each(function(_361){
_35f(_361,_360++);
});
}
catch(e){
if(e!=$break){
throw e;
}
}
return this;
},eachSlice:function(_362,_363){
var _364=-_362,_365=[],_366=this.toArray();
while((_364+=_362)<_366.length){
_365.push(_366.slice(_364,_364+_362));
}
return _365.map(_363);
},all:function(_367){
var _368=true;
this.each(function(_369,_36a){
_368=_368&&!!(_367||Prototype.K)(_369,_36a);
if(!_368){
throw $break;
}
});
return _368;
},any:function(_36b){
var _36c=false;
this.each(function(_36d,_36e){
if(_36c=!!(_36b||Prototype.K)(_36d,_36e)){
throw $break;
}
});
return _36c;
},collect:function(_36f){
var _370=[];
this.each(function(_371,_372){
_370.push((_36f||Prototype.K)(_371,_372));
});
return _370;
},detect:function(_373){
var _374;
this.each(function(_375,_376){
if(_373(_375,_376)){
_374=_375;
throw $break;
}
});
return _374;
},findAll:function(_377){
var _378=[];
this.each(function(_379,_37a){
if(_377(_379,_37a)){
_378.push(_379);
}
});
return _378;
},grep:function(_37b,_37c){
var _37d=[];
this.each(function(_37e,_37f){
var _380=_37e.toString();
if(_380.match(_37b)){
_37d.push((_37c||Prototype.K)(_37e,_37f));
}
});
return _37d;
},include:function(_381){
var _382=false;
this.each(function(_383){
if(_383==_381){
_382=true;
throw $break;
}
});
return _382;
},inGroupsOf:function(_384,_385){
_385=_385===undefined?null:_385;
return this.eachSlice(_384,function(_386){
while(_386.length<_384){
_386.push(_385);
}
return _386;
});
},inject:function(memo,_388){
this.each(function(_389,_38a){
memo=_388(memo,_389,_38a);
});
return memo;
},invoke:function(_38b){
var args=$A(arguments).slice(1);
return this.map(function(_38d){
return _38d[_38b].apply(_38d,args);
});
},max:function(_38e){
var _38f;
this.each(function(_390,_391){
_390=(_38e||Prototype.K)(_390,_391);
if(_38f==undefined||_390>=_38f){
_38f=_390;
}
});
return _38f;
},min:function(_392){
var _393;
this.each(function(_394,_395){
_394=(_392||Prototype.K)(_394,_395);
if(_393==undefined||_394<_393){
_393=_394;
}
});
return _393;
},partition:function(_396){
var _397=[],_398=[];
this.each(function(_399,_39a){
((_396||Prototype.K)(_399,_39a)?_397:_398).push(_399);
});
return [_397,_398];
},pluck:function(_39b){
var _39c=[];
this.each(function(_39d,_39e){
_39c.push(_39d[_39b]);
});
return _39c;
},reject:function(_39f){
var _3a0=[];
this.each(function(_3a1,_3a2){
if(!_39f(_3a1,_3a2)){
_3a0.push(_3a1);
}
});
return _3a0;
},sortBy:function(_3a3){
return this.map(function(_3a4,_3a5){
return {value:_3a4,criteria:_3a3(_3a4,_3a5)};
}).sort(function(left,_3a7){
var a=left.criteria,b=_3a7.criteria;
return a<b?-1:a>b?1:0;
}).pluck("value");
},toArray:function(){
return this.map();
},zip:function(){
var _3aa=Prototype.K,args=$A(arguments);
if(typeof args.last()=="function"){
_3aa=args.pop();
}
var _3ac=[this].concat(args).map($A);
return this.map(function(_3ad,_3ae){
return _3aa(_3ac.pluck(_3ae));
});
},size:function(){
return this.toArray().length;
},inspect:function(){
return "#<Enumerable:"+this.toArray().inspect()+">";
}};
Object.extend(Enumerable,{map:Enumerable.collect,find:Enumerable.detect,select:Enumerable.findAll,member:Enumerable.include,entries:Enumerable.toArray});
var $A=Array.from=function(_3af){
if(!_3af){
return [];
}
if(_3af.toArray){
return _3af.toArray();
}else{
var _3b0=[];
for(var i=0,_3b2=_3af.length;i<_3b2;i++){
_3b0.push(_3af[i]);
}
return _3b0;
}
};
if(Prototype.Browser.WebKit){
$A=Array.from=function(_3b3){
if(!_3b3){
return [];
}
if(!(typeof _3b3=="function"&&_3b3=="[object NodeList]")&&_3b3.toArray){
return _3b3.toArray();
}else{
var _3b4=[];
for(var i=0,_3b6=_3b3.length;i<_3b6;i++){
_3b4.push(_3b3[i]);
}
return _3b4;
}
};
}
Object.extend(Array.prototype,Enumerable);
if(!Array.prototype._reverse){
Array.prototype._reverse=Array.prototype.reverse;
}
Object.extend(Array.prototype,{_each:function(_3b7){
for(var i=0,_3b9=this.length;i<_3b9;i++){
_3b7(this[i]);
}
},clear:function(){
this.length=0;
return this;
},first:function(){
return this[0];
},last:function(){
return this[this.length-1];
},compact:function(){
return this.select(function(_3ba){
return _3ba!=null;
});
},flatten:function(){
return this.inject([],function(_3bb,_3bc){
return _3bb.concat(_3bc&&_3bc.constructor==Array?_3bc.flatten():[_3bc]);
});
},without:function(){
var _3bd=$A(arguments);
return this.select(function(_3be){
return !_3bd.include(_3be);
});
},indexOf:function(_3bf){
for(var i=0,_3c1=this.length;i<_3c1;i++){
if(this[i]==_3bf){
return i;
}
}
return -1;
},reverse:function(_3c2){
return (_3c2!==false?this:this.toArray())._reverse();
},reduce:function(){
return this.length>1?this:this[0];
},uniq:function(_3c3){
return this.inject([],function(_3c4,_3c5,_3c6){
if(0==_3c6||(_3c3?_3c4.last()!=_3c5:!_3c4.include(_3c5))){
_3c4.push(_3c5);
}
return _3c4;
});
},clone:function(){
return [].concat(this);
},size:function(){
return this.length;
},inspect:function(){
return "["+this.map(Object.inspect).join(", ")+"]";
},toJSON:function(){
var _3c7=[];
this.each(function(_3c8){
var _3c9=Object.toJSON(_3c8);
if(_3c9!==undefined){
_3c7.push(_3c9);
}
});
return "["+_3c7.join(", ")+"]";
}});
Array.prototype.toArray=Array.prototype.clone;
function $w(_3ca){
_3ca=_3ca.strip();
return _3ca?_3ca.split(/\s+/):[];
}
if(Prototype.Browser.Opera){
Array.prototype.concat=function(){
var _3cb=[];
for(var i=0,_3cd=this.length;i<_3cd;i++){
_3cb.push(this[i]);
}
for(var i=0,_3cd=arguments.length;i<_3cd;i++){
if(arguments[i].constructor==Array){
for(var j=0,_3cf=arguments[i].length;j<_3cf;j++){
_3cb.push(arguments[i][j]);
}
}else{
_3cb.push(arguments[i]);
}
}
return _3cb;
};
}
var Hash=function(_3d0){
if(_3d0 instanceof Hash){
this.merge(_3d0);
}else{
Object.extend(this,_3d0||{});
}
};
Object.extend(Hash,{toQueryString:function(obj){
var _3d2=[];
_3d2.add=arguments.callee.addPair;
this.prototype._each.call(obj,function(pair){
if(!pair.key){
return;
}
var _3d4=pair.value;
if(_3d4&&typeof _3d4=="object"){
if(_3d4.constructor==Array){
_3d4.each(function(_3d5){
_3d2.add(pair.key,_3d5);
});
}
return;
}
_3d2.add(pair.key,_3d4);
});
return _3d2.join("&");
},toJSON:function(_3d6){
var _3d7=[];
this.prototype._each.call(_3d6,function(pair){
var _3d9=Object.toJSON(pair.value);
if(_3d9!==undefined){
_3d7.push(pair.key.toJSON()+": "+_3d9);
}
});
return "{"+_3d7.join(", ")+"}";
}});
Hash.toQueryString.addPair=function(key,_3db,_3dc){
key=encodeURIComponent(key);
if(_3db===undefined){
this.push(key);
}else{
this.push(key+"="+(_3db==null?"":encodeURIComponent(_3db)));
}
};
Object.extend(Hash.prototype,Enumerable);
Object.extend(Hash.prototype,{_each:function(_3dd){
for(var key in this){
var _3df=this[key];
if(_3df&&_3df==Hash.prototype[key]){
continue;
}
var pair=[key,_3df];
pair.key=key;
pair.value=_3df;
_3dd(pair);
}
},keys:function(){
return this.pluck("key");
},values:function(){
return this.pluck("value");
},merge:function(hash){
return $H(hash).inject(this,function(_3e2,pair){
_3e2[pair.key]=pair.value;
return _3e2;
});
},remove:function(){
var _3e4;
for(var i=0,_3e6=arguments.length;i<_3e6;i++){
var _3e7=this[arguments[i]];
if(_3e7!==undefined){
if(_3e4===undefined){
_3e4=_3e7;
}else{
if(_3e4.constructor!=Array){
_3e4=[_3e4];
}
_3e4.push(_3e7);
}
}
delete this[arguments[i]];
}
return _3e4;
},toQueryString:function(){
return Hash.toQueryString(this);
},inspect:function(){
return "#<Hash:{"+this.map(function(pair){
return pair.map(Object.inspect).join(": ");
}).join(", ")+"}>";
},toJSON:function(){
return Hash.toJSON(this);
}});
function $H(_3e9){
if(_3e9 instanceof Hash){
return _3e9;
}
return new Hash(_3e9);
}
if(function(){
var i=0,Test=function(_3ec){
this.key=_3ec;
};
Test.prototype.key="foo";
for(var _3ed in new Test("bar")){
i++;
}
return i>1;
}()){
Hash.prototype._each=function(_3ee){
var _3ef=[];
for(var key in this){
var _3f1=this[key];
if((_3f1&&_3f1==Hash.prototype[key])||_3ef.include(key)){
continue;
}
_3ef.push(key);
var pair=[key,_3f1];
pair.key=key;
pair.value=_3f1;
_3ee(pair);
}
};
}
ObjectRange=Class.create();
Object.extend(ObjectRange.prototype,Enumerable);
Object.extend(ObjectRange.prototype,{initialize:function(_3f3,end,_3f5){
this.start=_3f3;
this.end=end;
this.exclusive=_3f5;
},_each:function(_3f6){
var _3f7=this.start;
while(this.include(_3f7)){
_3f6(_3f7);
_3f7=_3f7.succ();
}
},include:function(_3f8){
if(_3f8<this.start){
return false;
}
if(this.exclusive){
return _3f8<this.end;
}
return _3f8<=this.end;
}});
var $R=function(_3f9,end,_3fb){
return new ObjectRange(_3f9,end,_3fb);
};
var Ajax={getTransport:function(){
return Try.these(function(){
return new XMLHttpRequest();
},function(){
return new ActiveXObject("Msxml2.XMLHTTP");
},function(){
return new ActiveXObject("Microsoft.XMLHTTP");
})||false;
},activeRequestCount:0};
Ajax.Responders={responders:[],_each:function(_3fc){
this.responders._each(_3fc);
},register:function(_3fd){
if(!this.include(_3fd)){
this.responders.push(_3fd);
}
},unregister:function(_3fe){
this.responders=this.responders.without(_3fe);
},dispatch:function(_3ff,_400,_401,json){
this.each(function(_403){
if(typeof _403[_3ff]=="function"){
try{
_403[_3ff].apply(_403,[_400,_401,json]);
}
catch(e){
}
}
});
}};
Object.extend(Ajax.Responders,Enumerable);
Ajax.Responders.register({onCreate:function(){
Ajax.activeRequestCount++;
},onComplete:function(){
Ajax.activeRequestCount--;
}});
Ajax.Base=function(){
};
Ajax.Base.prototype={setOptions:function(_404){
this.options={method:"post",asynchronous:true,contentType:"application/x-www-form-urlencoded",encoding:"UTF-8",parameters:""};
Object.extend(this.options,_404||{});
this.options.method=this.options.method.toLowerCase();
if(typeof this.options.parameters=="string"){
this.options.parameters=this.options.parameters.toQueryParams();
}
}};
Ajax.Request=Class.create();
Ajax.Request.Events=["Uninitialized","Loading","Loaded","Interactive","Complete"];
Ajax.Request.prototype=Object.extend(new Ajax.Base(),{_complete:false,initialize:function(url,_406){
this.transport=Ajax.getTransport();
this.setOptions(_406);
this.request(url);
},request:function(url){
this.url=url;
this.method=this.options.method;
var _408=Object.clone(this.options.parameters);
if(!["get","post"].include(this.method)){
_408["_method"]=this.method;
this.method="post";
}
this.parameters=_408;
if(_408=Hash.toQueryString(_408)){
if(this.method=="get"){
this.url+=(this.url.include("?")?"&":"?")+_408;
}else{
if(/Konqueror|Safari|KHTML/.test(navigator.userAgent)){
_408+="&_=";
}
}
}
try{
if(this.options.onCreate){
this.options.onCreate(this.transport);
}
Ajax.Responders.dispatch("onCreate",this,this.transport);
this.transport.open(this.method.toUpperCase(),this.url,this.options.asynchronous);
if(this.options.asynchronous){
setTimeout(function(){
this.respondToReadyState(1);
}.bind(this),10);
}
this.transport.onreadystatechange=this.onStateChange.bind(this);
this.setRequestHeaders();
this.body=this.method=="post"?(this.options.postBody||_408):null;
this.transport.send(this.body);
if(!this.options.asynchronous&&this.transport.overrideMimeType){
this.onStateChange();
}
}
catch(e){
this.dispatchException(e);
}
},onStateChange:function(){
var _409=this.transport.readyState;
if(_409>1&&!((_409==4)&&this._complete)){
this.respondToReadyState(this.transport.readyState);
}
},setRequestHeaders:function(){
var _40a={"X-Requested-With":"XMLHttpRequest","X-Prototype-Version":Prototype.Version,"Accept":"text/javascript, text/html, application/xml, text/xml, */*"};
if(this.method=="post"){
_40a["Content-type"]=this.options.contentType+(this.options.encoding?"; charset="+this.options.encoding:"");
if(this.transport.overrideMimeType&&(navigator.userAgent.match(/Gecko\/(\d{4})/)||[0,2005])[1]<2005){
_40a["Connection"]="close";
}
}
if(typeof this.options.requestHeaders=="object"){
var _40b=this.options.requestHeaders;
if(typeof _40b.push=="function"){
for(var i=0,_40d=_40b.length;i<_40d;i+=2){
_40a[_40b[i]]=_40b[i+1];
}
}else{
$H(_40b).each(function(pair){
_40a[pair.key]=pair.value;
});
}
}
for(var name in _40a){
this.transport.setRequestHeader(name,_40a[name]);
}
},success:function(){
return !this.transport.status||(this.transport.status>=200&&this.transport.status<300);
},respondToReadyState:function(_410){
var _411=Ajax.Request.Events[_410];
var _412=this.transport,json=this.evalJSON();
if(_411=="Complete"){
try{
this._complete=true;
(this.options["on"+this.transport.status]||this.options["on"+(this.success()?"Success":"Failure")]||Prototype.emptyFunction)(_412,json);
}
catch(e){
this.dispatchException(e);
}
var _414=this.getHeader("Content-type");
if(_414&&_414.strip().match(/^(text|application)\/(x-)?(java|ecma)script(;.*)?$/i)){
this.evalResponse();
}
}
try{
(this.options["on"+_411]||Prototype.emptyFunction)(_412,json);
Ajax.Responders.dispatch("on"+_411,this,_412,json);
}
catch(e){
this.dispatchException(e);
}
if(_411=="Complete"){
this.transport.onreadystatechange=Prototype.emptyFunction;
}
},getHeader:function(name){
try{
return this.transport.getResponseHeader(name);
}
catch(e){
return null;
}
},evalJSON:function(){
try{
var json=this.getHeader("X-JSON");
return json?json.evalJSON():null;
}
catch(e){
return null;
}
},evalResponse:function(){
try{
return eval((this.transport.responseText||"").unfilterJSON());
}
catch(e){
this.dispatchException(e);
}
},dispatchException:function(_417){
(this.options.onException||Prototype.emptyFunction)(this,_417);
Ajax.Responders.dispatch("onException",this,_417);
}});
Ajax.Updater=Class.create();
Object.extend(Object.extend(Ajax.Updater.prototype,Ajax.Request.prototype),{initialize:function(_418,url,_41a){
this.container={success:(_418.success||_418),failure:(_418.failure||(_418.success?null:_418))};
this.transport=Ajax.getTransport();
this.setOptions(_41a);
var _41b=this.options.onComplete||Prototype.emptyFunction;
this.options.onComplete=(function(_41c,_41d){
this.updateContent();
_41b(_41c,_41d);
}).bind(this);
this.request(url);
},updateContent:function(){
var _41e=this.container[this.success()?"success":"failure"];
var _41f=this.transport.responseText;
if(!this.options.evalScripts){
_41f=_41f.stripScripts();
}
if(_41e=$(_41e)){
if(this.options.insertion){
new this.options.insertion(_41e,_41f);
}else{
_41e.update(_41f);
}
}
if(this.success()){
if(this.onComplete){
setTimeout(this.onComplete.bind(this),10);
}
}
}});
Ajax.PeriodicalUpdater=Class.create();
Ajax.PeriodicalUpdater.prototype=Object.extend(new Ajax.Base(),{initialize:function(_420,url,_422){
this.setOptions(_422);
this.onComplete=this.options.onComplete;
this.frequency=(this.options.frequency||2);
this.decay=(this.options.decay||1);
this.updater={};
this.container=_420;
this.url=url;
this.start();
},start:function(){
this.options.onComplete=this.updateComplete.bind(this);
this.onTimerEvent();
},stop:function(){
this.updater.options.onComplete=undefined;
clearTimeout(this.timer);
(this.onComplete||Prototype.emptyFunction).apply(this,arguments);
},updateComplete:function(_423){
if(this.options.decay){
this.decay=(_423.responseText==this.lastText?this.decay*this.options.decay:1);
this.lastText=_423.responseText;
}
this.timer=setTimeout(this.onTimerEvent.bind(this),this.decay*this.frequency*1000);
},onTimerEvent:function(){
this.updater=new Ajax.Updater(this.container,this.url,this.options);
}});
function $(_424){
if(arguments.length>1){
for(var i=0,_426=[],_427=arguments.length;i<_427;i++){
_426.push($(arguments[i]));
}
return _426;
}
if(typeof _424=="string"){
_424=document.getElementById(_424);
}
return Element.extend(_424);
}
if(Prototype.BrowserFeatures.XPath){
document._getElementsByXPath=function(_428,_429){
var _42a=[];
var _42b=document.evaluate(_428,$(_429)||document,null,XPathResult.ORDERED_NODE_SNAPSHOT_TYPE,null);
for(var i=0,_42d=_42b.snapshotLength;i<_42d;i++){
_42a.push(_42b.snapshotItem(i));
}
return _42a;
};
document.getElementsByClassName=function(_42e,_42f){
var q=".//*[contains(concat(' ', @class, ' '), ' "+_42e+" ')]";
return document._getElementsByXPath(q,_42f);
};
}else{
document.getElementsByClassName=function(_431,_432){
var _433=($(_432)||document.body).getElementsByTagName("*");
var _434=[],_435,_436=new RegExp("(^|\\s)"+_431+"(\\s|$)");
for(var i=0,_438=_433.length;i<_438;i++){
_435=_433[i];
var _439=_435.className;
if(_439.length==0){
continue;
}
if(_439==_431||_439.match(_436)){
_434.push(Element.extend(_435));
}
}
return _434;
};
}
if(!window.Element){
var Element={};
}
Element.extend=function(_43a){
var F=Prototype.BrowserFeatures;
if(!_43a||!_43a.tagName||_43a.nodeType==3||_43a._extended||F.SpecificElementExtensions||_43a==window){
return _43a;
}
var _43c={},_43d=_43a.tagName,_43e=Element.extend.cache,T=Element.Methods.ByTag;
if(!F.ElementExtensions){
Object.extend(_43c,Element.Methods),Object.extend(_43c,Element.Methods.Simulated);
}
if(T[_43d]){
Object.extend(_43c,T[_43d]);
}
for(var _440 in _43c){
var _441=_43c[_440];
if(typeof _441=="function"&&!(_440 in _43a)){
_43a[_440]=_43e.findOrStore(_441);
}
}
_43a._extended=Prototype.emptyFunction;
return _43a;
};
Element.extend.cache={findOrStore:function(_442){
return this[_442]=this[_442]||function(){
return _442.apply(null,[this].concat($A(arguments)));
};
}};
Element.Methods={visible:function(_443){
return $(_443).style.display!="none";
},toggle:function(_444){
_444=$(_444);
Element[Element.visible(_444)?"hide":"show"](_444);
return _444;
},hide:function(_445){
$(_445).style.display="none";
return _445;
},show:function(_446){
$(_446).style.display="";
return _446;
},remove:function(_447){
_447=$(_447);
_447.parentNode.removeChild(_447);
return _447;
},update:function(_448,html){
html=typeof html=="undefined"?"":html.toString();
$(_448).innerHTML=html.stripScripts();
setTimeout(function(){
html.evalScripts();
},10);
return _448;
},replace:function(_44a,html){
_44a=$(_44a);
html=typeof html=="undefined"?"":html.toString();
if(_44a.outerHTML){
_44a.outerHTML=html.stripScripts();
}else{
var _44c=_44a.ownerDocument.createRange();
_44c.selectNodeContents(_44a);
_44a.parentNode.replaceChild(_44c.createContextualFragment(html.stripScripts()),_44a);
}
setTimeout(function(){
html.evalScripts();
},10);
return _44a;
},inspect:function(_44d){
_44d=$(_44d);
var _44e="<"+_44d.tagName.toLowerCase();
$H({"id":"id","className":"class"}).each(function(pair){
var _450=pair.first(),_451=pair.last();
var _452=(_44d[_450]||"").toString();
if(_452){
_44e+=" "+_451+"="+_452.inspect(true);
}
});
return _44e+">";
},recursivelyCollect:function(_453,_454){
_453=$(_453);
var _455=[];
while(_453=_453[_454]){
if(_453.nodeType==1){
_455.push(Element.extend(_453));
}
}
return _455;
},ancestors:function(_456){
return $(_456).recursivelyCollect("parentNode");
},descendants:function(_457){
return $A($(_457).getElementsByTagName("*")).each(Element.extend);
},firstDescendant:function(_458){
_458=$(_458).firstChild;
while(_458&&_458.nodeType!=1){
_458=_458.nextSibling;
}
return $(_458);
},immediateDescendants:function(_459){
if(!(_459=$(_459).firstChild)){
return [];
}
while(_459&&_459.nodeType!=1){
_459=_459.nextSibling;
}
if(_459){
return [_459].concat($(_459).nextSiblings());
}
return [];
},previousSiblings:function(_45a){
return $(_45a).recursivelyCollect("previousSibling");
},nextSiblings:function(_45b){
return $(_45b).recursivelyCollect("nextSibling");
},siblings:function(_45c){
_45c=$(_45c);
return _45c.previousSiblings().reverse().concat(_45c.nextSiblings());
},match:function(_45d,_45e){
if(typeof _45e=="string"){
_45e=new Selector(_45e);
}
return _45e.match($(_45d));
},up:function(_45f,_460,_461){
_45f=$(_45f);
if(arguments.length==1){
return $(_45f.parentNode);
}
var _462=_45f.ancestors();
return _460?Selector.findElement(_462,_460,_461):_462[_461||0];
},down:function(_463,_464,_465){
_463=$(_463);
if(arguments.length==1){
return _463.firstDescendant();
}
var _466=_463.descendants();
return _464?Selector.findElement(_466,_464,_465):_466[_465||0];
},previous:function(_467,_468,_469){
_467=$(_467);
if(arguments.length==1){
return $(Selector.handlers.previousElementSibling(_467));
}
var _46a=_467.previousSiblings();
return _468?Selector.findElement(_46a,_468,_469):_46a[_469||0];
},next:function(_46b,_46c,_46d){
_46b=$(_46b);
if(arguments.length==1){
return $(Selector.handlers.nextElementSibling(_46b));
}
var _46e=_46b.nextSiblings();
return _46c?Selector.findElement(_46e,_46c,_46d):_46e[_46d||0];
},getElementsBySelector:function(){
var args=$A(arguments),_470=$(args.shift());
return Selector.findChildElements(_470,args);
},getElementsByClassName:function(_471,_472){
return document.getElementsByClassName(_472,_471);
},readAttribute:function(_473,name){
_473=$(_473);
if(Prototype.Browser.IE){
if(!_473.attributes){
return null;
}
var t=Element._attributeTranslations;
if(t.values[name]){
return t.values[name](_473,name);
}
if(t.names[name]){
name=t.names[name];
}
var _476=_473.attributes[name];
return _476?_476.nodeValue:null;
}
return _473.getAttribute(name);
},getHeight:function(_477){
return $(_477).getDimensions().height;
},getWidth:function(_478){
return $(_478).getDimensions().width;
},classNames:function(_479){
return new Element.ClassNames(_479);
},hasClassName:function(_47a,_47b){
if(!(_47a=$(_47a))){
return;
}
var _47c=_47a.className;
if(_47c.length==0){
return false;
}
if(_47c==_47b||_47c.match(new RegExp("(^|\\s)"+_47b+"(\\s|$)"))){
return true;
}
return false;
},addClassName:function(_47d,_47e){
if(!(_47d=$(_47d))){
return;
}
Element.classNames(_47d).add(_47e);
return _47d;
},removeClassName:function(_47f,_480){
if(!(_47f=$(_47f))){
return;
}
Element.classNames(_47f).remove(_480);
return _47f;
},toggleClassName:function(_481,_482){
if(!(_481=$(_481))){
return;
}
Element.classNames(_481)[_481.hasClassName(_482)?"remove":"add"](_482);
return _481;
},observe:function(){
Event.observe.apply(Event,arguments);
return $A(arguments).first();
},stopObserving:function(){
Event.stopObserving.apply(Event,arguments);
return $A(arguments).first();
},cleanWhitespace:function(_483){
_483=$(_483);
var node=_483.firstChild;
while(node){
var _485=node.nextSibling;
if(node.nodeType==3&&!/\S/.test(node.nodeValue)){
_483.removeChild(node);
}
node=_485;
}
return _483;
},empty:function(_486){
return $(_486).innerHTML.blank();
},descendantOf:function(_487,_488){
_487=$(_487),_488=$(_488);
while(_487=_487.parentNode){
if(_487==_488){
return true;
}
}
return false;
},scrollTo:function(_489){
_489=$(_489);
var pos=Position.cumulativeOffset(_489);
window.scrollTo(pos[0],pos[1]);
return _489;
},getStyle:function(_48b,_48c){
_48b=$(_48b);
_48c=_48c=="float"?"cssFloat":_48c.camelize();
var _48d=_48b.style[_48c];
if(!_48d){
var css=document.defaultView.getComputedStyle(_48b,null);
_48d=css?css[_48c]:null;
}
if(_48c=="opacity"){
return _48d?parseFloat(_48d):1;
}
return _48d=="auto"?null:_48d;
},getOpacity:function(_48f){
return $(_48f).getStyle("opacity");
},setStyle:function(_490,_491,_492){
_490=$(_490);
var _493=_490.style;
for(var _494 in _491){
if(_494=="opacity"){
_490.setOpacity(_491[_494]);
}else{
_493[(_494=="float"||_494=="cssFloat")?(_493.styleFloat===undefined?"cssFloat":"styleFloat"):(_492?_494:_494.camelize())]=_491[_494];
}
}
return _490;
},setOpacity:function(_495,_496){
_495=$(_495);
_495.style.opacity=(_496==1||_496==="")?"":(_496<0.00001)?0:_496;
return _495;
},getDimensions:function(_497){
_497=$(_497);
var _498=$(_497).getStyle("display");
if(_498!="none"&&_498!=null){
return {width:_497.offsetWidth,height:_497.offsetHeight};
}
var els=_497.style;
var _49a=els.visibility;
var _49b=els.position;
var _49c=els.display;
els.visibility="hidden";
els.position="absolute";
els.display="block";
var _49d=_497.clientWidth;
var _49e=_497.clientHeight;
els.display=_49c;
els.position=_49b;
els.visibility=_49a;
return {width:_49d,height:_49e};
},makePositioned:function(_49f){
_49f=$(_49f);
var pos=Element.getStyle(_49f,"position");
if(pos=="static"||!pos){
_49f._madePositioned=true;
_49f.style.position="relative";
if(window.opera){
_49f.style.top=0;
_49f.style.left=0;
}
}
return _49f;
},undoPositioned:function(_4a1){
_4a1=$(_4a1);
if(_4a1._madePositioned){
_4a1._madePositioned=undefined;
_4a1.style.position=_4a1.style.top=_4a1.style.left=_4a1.style.bottom=_4a1.style.right="";
}
return _4a1;
},makeClipping:function(_4a2){
_4a2=$(_4a2);
if(_4a2._overflow){
return _4a2;
}
_4a2._overflow=_4a2.style.overflow||"auto";
if((Element.getStyle(_4a2,"overflow")||"visible")!="hidden"){
_4a2.style.overflow="hidden";
}
return _4a2;
},undoClipping:function(_4a3){
_4a3=$(_4a3);
if(!_4a3._overflow){
return _4a3;
}
_4a3.style.overflow=_4a3._overflow=="auto"?"":_4a3._overflow;
_4a3._overflow=null;
return _4a3;
}};
Object.extend(Element.Methods,{childOf:Element.Methods.descendantOf,childElements:Element.Methods.immediateDescendants});
if(Prototype.Browser.Opera){
Element.Methods._getStyle=Element.Methods.getStyle;
Element.Methods.getStyle=function(_4a4,_4a5){
switch(_4a5){
case "left":
case "top":
case "right":
case "bottom":
if(Element._getStyle(_4a4,"position")=="static"){
return null;
}
default:
return Element._getStyle(_4a4,_4a5);
}
};
}else{
if(Prototype.Browser.IE){
Element.Methods.getStyle=function(_4a6,_4a7){
_4a6=$(_4a6);
_4a7=(_4a7=="float"||_4a7=="cssFloat")?"styleFloat":_4a7.camelize();
var _4a8=_4a6.style[_4a7];
if(!_4a8&&_4a6.currentStyle){
_4a8=_4a6.currentStyle[_4a7];
}
if(_4a7=="opacity"){
if(_4a8=(_4a6.getStyle("filter")||"").match(/alpha\(opacity=(.*)\)/)){
if(_4a8[1]){
return parseFloat(_4a8[1])/100;
}
}
return 1;
}
if(_4a8=="auto"){
if((_4a7=="width"||_4a7=="height")&&(_4a6.getStyle("display")!="none")){
return _4a6["offset"+_4a7.capitalize()]+"px";
}
return null;
}
return _4a8;
};
Element.Methods.setOpacity=function(_4a9,_4aa){
_4a9=$(_4a9);
var _4ab=_4a9.getStyle("filter"),_4ac=_4a9.style;
if(_4aa==1||_4aa===""){
_4ac.filter=_4ab.replace(/alpha\([^\)]*\)/gi,"");
return _4a9;
}else{
if(_4aa<0.00001){
_4aa=0;
}
}
_4ac.filter=_4ab.replace(/alpha\([^\)]*\)/gi,"")+"alpha(opacity="+(_4aa*100)+")";
return _4a9;
};
Element.Methods.update=function(_4ad,html){
_4ad=$(_4ad);
html=typeof html=="undefined"?"":html.toString();
var _4af=_4ad.tagName.toUpperCase();
if(["THEAD","TBODY","TR","TD"].include(_4af)){
var div=document.createElement("div");
switch(_4af){
case "THEAD":
case "TBODY":
div.innerHTML="<table><tbody>"+html.stripScripts()+"</tbody></table>";
depth=2;
break;
case "TR":
div.innerHTML="<table><tbody><tr>"+html.stripScripts()+"</tr></tbody></table>";
depth=3;
break;
case "TD":
div.innerHTML="<table><tbody><tr><td>"+html.stripScripts()+"</td></tr></tbody></table>";
depth=4;
}
$A(_4ad.childNodes).each(function(node){
_4ad.removeChild(node);
});
depth.times(function(){
div=div.firstChild;
});
$A(div.childNodes).each(function(node){
_4ad.appendChild(node);
});
}else{
_4ad.innerHTML=html.stripScripts();
}
setTimeout(function(){
html.evalScripts();
},10);
return _4ad;
};
}else{
if(Prototype.Browser.Gecko){
Element.Methods.setOpacity=function(_4b3,_4b4){
_4b3=$(_4b3);
_4b3.style.opacity=(_4b4==1)?0.999999:(_4b4==="")?"":(_4b4<0.00001)?0:_4b4;
return _4b3;
};
}
}
}
Element._attributeTranslations={names:{colspan:"colSpan",rowspan:"rowSpan",valign:"vAlign",datetime:"dateTime",accesskey:"accessKey",tabindex:"tabIndex",enctype:"encType",maxlength:"maxLength",readonly:"readOnly",longdesc:"longDesc"},values:{_getAttr:function(_4b5,_4b6){
return _4b5.getAttribute(_4b6,2);
},_flag:function(_4b7,_4b8){
return $(_4b7).hasAttribute(_4b8)?_4b8:null;
},style:function(_4b9){
return _4b9.style.cssText.toLowerCase();
},title:function(_4ba){
var node=_4ba.getAttributeNode("title");
return node.specified?node.nodeValue:null;
}}};
(function(){
Object.extend(this,{href:this._getAttr,src:this._getAttr,type:this._getAttr,disabled:this._flag,checked:this._flag,readonly:this._flag,multiple:this._flag});
}).call(Element._attributeTranslations.values);
Element.Methods.Simulated={hasAttribute:function(_4bc,_4bd){
var t=Element._attributeTranslations,node;
_4bd=t.names[_4bd]||_4bd;
node=$(_4bc).getAttributeNode(_4bd);
return node&&node.specified;
}};
Element.Methods.ByTag={};
Object.extend(Element,Element.Methods);
if(!Prototype.BrowserFeatures.ElementExtensions&&document.createElement("div").__proto__){
window.HTMLElement={};
window.HTMLElement.prototype=document.createElement("div").__proto__;
Prototype.BrowserFeatures.ElementExtensions=true;
}
Element.hasAttribute=function(_4c0,_4c1){
if(_4c0.hasAttribute){
return _4c0.hasAttribute(_4c1);
}
return Element.Methods.Simulated.hasAttribute(_4c0,_4c1);
};
Element.addMethods=function(_4c2){
var F=Prototype.BrowserFeatures,T=Element.Methods.ByTag;
if(!_4c2){
Object.extend(Form,Form.Methods);
Object.extend(Form.Element,Form.Element.Methods);
Object.extend(Element.Methods.ByTag,{"FORM":Object.clone(Form.Methods),"INPUT":Object.clone(Form.Element.Methods),"SELECT":Object.clone(Form.Element.Methods),"TEXTAREA":Object.clone(Form.Element.Methods)});
}
if(arguments.length==2){
var _4c5=_4c2;
_4c2=arguments[1];
}
if(!_4c5){
Object.extend(Element.Methods,_4c2||{});
}else{
if(_4c5.constructor==Array){
_4c5.each(extend);
}else{
extend(_4c5);
}
}
function extend(_4c6){
_4c6=_4c6.toUpperCase();
if(!Element.Methods.ByTag[_4c6]){
Element.Methods.ByTag[_4c6]={};
}
Object.extend(Element.Methods.ByTag[_4c6],_4c2);
}
function copy(_4c7,_4c8,_4c9){
_4c9=_4c9||false;
var _4ca=Element.extend.cache;
for(var _4cb in _4c7){
var _4cc=_4c7[_4cb];
if(!_4c9||!(_4cb in _4c8)){
_4c8[_4cb]=_4ca.findOrStore(_4cc);
}
}
}
function findDOMClass(_4cd){
var _4ce;
var _4cf={"OPTGROUP":"OptGroup","TEXTAREA":"TextArea","P":"Paragraph","FIELDSET":"FieldSet","UL":"UList","OL":"OList","DL":"DList","DIR":"Directory","H1":"Heading","H2":"Heading","H3":"Heading","H4":"Heading","H5":"Heading","H6":"Heading","Q":"Quote","INS":"Mod","DEL":"Mod","A":"Anchor","IMG":"Image","CAPTION":"TableCaption","COL":"TableCol","COLGROUP":"TableCol","THEAD":"TableSection","TFOOT":"TableSection","TBODY":"TableSection","TR":"TableRow","TH":"TableCell","TD":"TableCell","FRAMESET":"FrameSet","IFRAME":"IFrame"};
if(_4cf[_4cd]){
_4ce="HTML"+_4cf[_4cd]+"Element";
}
if(window[_4ce]){
return window[_4ce];
}
_4ce="HTML"+_4cd+"Element";
if(window[_4ce]){
return window[_4ce];
}
_4ce="HTML"+_4cd.capitalize()+"Element";
if(window[_4ce]){
return window[_4ce];
}
window[_4ce]={};
window[_4ce].prototype=document.createElement(_4cd).__proto__;
return window[_4ce];
}
if(F.ElementExtensions){
copy(Element.Methods,HTMLElement.prototype);
copy(Element.Methods.Simulated,HTMLElement.prototype,true);
}
if(F.SpecificElementExtensions){
for(var tag in Element.Methods.ByTag){
var _4d1=findDOMClass(tag);
if(typeof _4d1=="undefined"){
continue;
}
copy(T[tag],_4d1.prototype);
}
}
Object.extend(Element,Element.Methods);
delete Element.ByTag;
};
var Toggle={display:Element.toggle};
Abstract.Insertion=function(_4d2){
this.adjacency=_4d2;
};
Abstract.Insertion.prototype={initialize:function(_4d3,_4d4){
this.element=$(_4d3);
this.content=_4d4.stripScripts();
if(this.adjacency&&this.element.insertAdjacentHTML){
try{
this.element.insertAdjacentHTML(this.adjacency,this.content);
}
catch(e){
var _4d5=this.element.tagName.toUpperCase();
if(["TBODY","TR"].include(_4d5)){
this.insertContent(this.contentFromAnonymousTable());
}else{
throw e;
}
}
}else{
this.range=this.element.ownerDocument.createRange();
if(this.initializeRange){
this.initializeRange();
}
this.insertContent([this.range.createContextualFragment(this.content)]);
}
setTimeout(function(){
_4d4.evalScripts();
},10);
},contentFromAnonymousTable:function(){
var div=document.createElement("div");
div.innerHTML="<table><tbody>"+this.content+"</tbody></table>";
return $A(div.childNodes[0].childNodes[0].childNodes);
}};
var Insertion=new Object();
Insertion.Before=Class.create();
Insertion.Before.prototype=Object.extend(new Abstract.Insertion("beforeBegin"),{initializeRange:function(){
this.range.setStartBefore(this.element);
},insertContent:function(_4d7){
_4d7.each((function(_4d8){
this.element.parentNode.insertBefore(_4d8,this.element);
}).bind(this));
}});
Insertion.Top=Class.create();
Insertion.Top.prototype=Object.extend(new Abstract.Insertion("afterBegin"),{initializeRange:function(){
this.range.selectNodeContents(this.element);
this.range.collapse(true);
},insertContent:function(_4d9){
_4d9.reverse(false).each((function(_4da){
this.element.insertBefore(_4da,this.element.firstChild);
}).bind(this));
}});
Insertion.Bottom=Class.create();
Insertion.Bottom.prototype=Object.extend(new Abstract.Insertion("beforeEnd"),{initializeRange:function(){
this.range.selectNodeContents(this.element);
this.range.collapse(this.element);
},insertContent:function(_4db){
_4db.each((function(_4dc){
this.element.appendChild(_4dc);
}).bind(this));
}});
Insertion.After=Class.create();
Insertion.After.prototype=Object.extend(new Abstract.Insertion("afterEnd"),{initializeRange:function(){
this.range.setStartAfter(this.element);
},insertContent:function(_4dd){
_4dd.each((function(_4de){
this.element.parentNode.insertBefore(_4de,this.element.nextSibling);
}).bind(this));
}});
Element.ClassNames=Class.create();
Element.ClassNames.prototype={initialize:function(_4df){
this.element=$(_4df);
},_each:function(_4e0){
this.element.className.split(/\s+/).select(function(name){
return name.length>0;
})._each(_4e0);
},set:function(_4e2){
this.element.className=_4e2;
},add:function(_4e3){
if(this.include(_4e3)){
return;
}
this.set($A(this).concat(_4e3).join(" "));
},remove:function(_4e4){
if(!this.include(_4e4)){
return;
}
this.set($A(this).without(_4e4).join(" "));
},toString:function(){
return $A(this).join(" ");
}};
Object.extend(Element.ClassNames.prototype,Enumerable);
var Selector=Class.create();
Selector.prototype={initialize:function(_4e5){
this.expression=_4e5.strip();
this.compileMatcher();
},compileMatcher:function(){
if(Prototype.BrowserFeatures.XPath&&!(/\[[\w-]*?:/).test(this.expression)){
return this.compileXPathMatcher();
}
var e=this.expression,ps=Selector.patterns,h=Selector.handlers,c=Selector.criteria,le,p,m;
if(Selector._cache[e]){
this.matcher=Selector._cache[e];
return;
}
this.matcher=["this.matcher = function(root) {","var r = root, h = Selector.handlers, c = false, n;"];
while(e&&le!=e&&(/\S/).test(e)){
le=e;
for(var i in ps){
p=ps[i];
if(m=e.match(p)){
this.matcher.push(typeof c[i]=="function"?c[i](m):new Template(c[i]).evaluate(m));
e=e.replace(m[0],"");
break;
}
}
}
this.matcher.push("return h.unique(n);\n}");
eval(this.matcher.join("\n"));
Selector._cache[this.expression]=this.matcher;
},compileXPathMatcher:function(){
var e=this.expression,ps=Selector.patterns,x=Selector.xpath,le,m;
if(Selector._cache[e]){
this.xpath=Selector._cache[e];
return;
}
this.matcher=[".//*"];
while(e&&le!=e&&(/\S/).test(e)){
le=e;
for(var i in ps){
if(m=e.match(ps[i])){
this.matcher.push(typeof x[i]=="function"?x[i](m):new Template(x[i]).evaluate(m));
e=e.replace(m[0],"");
break;
}
}
}
this.xpath=this.matcher.join("");
Selector._cache[this.expression]=this.xpath;
},findElements:function(root){
root=root||document;
if(this.xpath){
return document._getElementsByXPath(this.xpath,root);
}
return this.matcher(root);
},match:function(_4f5){
return this.findElements(document).include(_4f5);
},toString:function(){
return this.expression;
},inspect:function(){
return "#<Selector:"+this.expression.inspect()+">";
}};
Object.extend(Selector,{_cache:{},xpath:{descendant:"//*",child:"/*",adjacent:"/following-sibling::*[1]",laterSibling:"/following-sibling::*",tagName:function(m){
if(m[1]=="*"){
return "";
}
return "[local-name()='"+m[1].toLowerCase()+"' or local-name()='"+m[1].toUpperCase()+"']";
},className:"[contains(concat(' ', @class, ' '), ' #{1} ')]",id:"[@id='#{1}']",attrPresence:"[@#{1}]",attr:function(m){
m[3]=m[5]||m[6];
return new Template(Selector.xpath.operators[m[2]]).evaluate(m);
},pseudo:function(m){
var h=Selector.xpath.pseudos[m[1]];
if(!h){
return "";
}
if(typeof h==="function"){
return h(m);
}
return new Template(Selector.xpath.pseudos[m[1]]).evaluate(m);
},operators:{"=":"[@#{1}='#{3}']","!=":"[@#{1}!='#{3}']","^=":"[starts-with(@#{1}, '#{3}')]","$=":"[substring(@#{1}, (string-length(@#{1}) - string-length('#{3}') + 1))='#{3}']","*=":"[contains(@#{1}, '#{3}')]","~=":"[contains(concat(' ', @#{1}, ' '), ' #{3} ')]","|=":"[contains(concat('-', @#{1}, '-'), '-#{3}-')]"},pseudos:{"first-child":"[not(preceding-sibling::*)]","last-child":"[not(following-sibling::*)]","only-child":"[not(preceding-sibling::* or following-sibling::*)]","empty":"[count(*) = 0 and (count(text()) = 0 or translate(text(), ' \t\r\n', '') = '')]","checked":"[@checked]","disabled":"[@disabled]","enabled":"[not(@disabled)]","not":function(m){
var e=m[6],p=Selector.patterns,x=Selector.xpath,le,m,v;
var _500=[];
while(e&&le!=e&&(/\S/).test(e)){
le=e;
for(var i in p){
if(m=e.match(p[i])){
v=typeof x[i]=="function"?x[i](m):new Template(x[i]).evaluate(m);
_500.push("("+v.substring(1,v.length-1)+")");
e=e.replace(m[0],"");
break;
}
}
}
return "[not("+_500.join(" and ")+")]";
},"nth-child":function(m){
return Selector.xpath.pseudos.nth("(count(./preceding-sibling::*) + 1) ",m);
},"nth-last-child":function(m){
return Selector.xpath.pseudos.nth("(count(./following-sibling::*) + 1) ",m);
},"nth-of-type":function(m){
return Selector.xpath.pseudos.nth("position() ",m);
},"nth-last-of-type":function(m){
return Selector.xpath.pseudos.nth("(last() + 1 - position()) ",m);
},"first-of-type":function(m){
m[6]="1";
return Selector.xpath.pseudos["nth-of-type"](m);
},"last-of-type":function(m){
m[6]="1";
return Selector.xpath.pseudos["nth-last-of-type"](m);
},"only-of-type":function(m){
var p=Selector.xpath.pseudos;
return p["first-of-type"](m)+p["last-of-type"](m);
},nth:function(_50a,m){
var mm,_50d=m[6],_50e;
if(_50d=="even"){
_50d="2n+0";
}
if(_50d=="odd"){
_50d="2n+1";
}
if(mm=_50d.match(/^(\d+)$/)){
return "["+_50a+"= "+mm[1]+"]";
}
if(mm=_50d.match(/^(-?\d*)?n(([+-])(\d+))?/)){
if(mm[1]=="-"){
mm[1]=-1;
}
var a=mm[1]?Number(mm[1]):1;
var b=mm[2]?Number(mm[2]):0;
_50e="[((#{fragment} - #{b}) mod #{a} = 0) and "+"((#{fragment} - #{b}) div #{a} >= 0)]";
return new Template(_50e).evaluate({fragment:_50a,a:a,b:b});
}
}}},criteria:{tagName:"n = h.tagName(n, r, \"#{1}\", c);   c = false;",className:"n = h.className(n, r, \"#{1}\", c); c = false;",id:"n = h.id(n, r, \"#{1}\", c);        c = false;",attrPresence:"n = h.attrPresence(n, r, \"#{1}\"); c = false;",attr:function(m){
m[3]=(m[5]||m[6]);
return new Template("n = h.attr(n, r, \"#{1}\", \"#{3}\", \"#{2}\"); c = false;").evaluate(m);
},pseudo:function(m){
if(m[6]){
m[6]=m[6].replace(/"/g,"\\\"");
}
return new Template("n = h.pseudo(n, \"#{1}\", \"#{6}\", r, c); c = false;").evaluate(m);
},descendant:"c = \"descendant\";",child:"c = \"child\";",adjacent:"c = \"adjacent\";",laterSibling:"c = \"laterSibling\";"},patterns:{laterSibling:/^\s*~\s*/,child:/^\s*>\s*/,adjacent:/^\s*\+\s*/,descendant:/^\s/,tagName:/^\s*(\*|[\w\-]+)(\b|$)?/,id:/^#([\w\-\*]+)(\b|$)/,className:/^\.([\w\-\*]+)(\b|$)/,pseudo:/^:((first|last|nth|nth-last|only)(-child|-of-type)|empty|checked|(en|dis)abled|not)(\((.*?)\))?(\b|$|\s|(?=:))/,attrPresence:/^\[([\w]+)\]/,attr:/\[((?:[\w-]*:)?[\w-]+)\s*(?:([!^$*~|]?=)\s*((['"])([^\]]*?)\4|([^'"][^\]]*?)))?\]/},handlers:{concat:function(a,b){
for(var i=0,node;node=b[i];i++){
a.push(node);
}
return a;
},mark:function(_517){
for(var i=0,node;node=_517[i];i++){
node._counted=true;
}
return _517;
},unmark:function(_51a){
for(var i=0,node;node=_51a[i];i++){
node._counted=undefined;
}
return _51a;
},index:function(_51d,_51e,_51f){
_51d._counted=true;
if(_51e){
for(var _520=_51d.childNodes,i=_520.length-1,j=1;i>=0;i--){
node=_520[i];
if(node.nodeType==1&&(!_51f||node._counted)){
node.nodeIndex=j++;
}
}
}else{
for(var i=0,j=1,_520=_51d.childNodes;node=_520[i];i++){
if(node.nodeType==1&&(!_51f||node._counted)){
node.nodeIndex=j++;
}
}
}
},unique:function(_523){
if(_523.length==0){
return _523;
}
var _524=[],n;
for(var i=0,l=_523.length;i<l;i++){
if(!(n=_523[i])._counted){
n._counted=true;
_524.push(Element.extend(n));
}
}
return Selector.handlers.unmark(_524);
},descendant:function(_528){
var h=Selector.handlers;
for(var i=0,_52b=[],node;node=_528[i];i++){
h.concat(_52b,node.getElementsByTagName("*"));
}
return _52b;
},child:function(_52d){
var h=Selector.handlers;
for(var i=0,_530=[],node;node=_52d[i];i++){
for(var j=0,_533=[],_534;_534=node.childNodes[j];j++){
if(_534.nodeType==1&&_534.tagName!="!"){
_530.push(_534);
}
}
}
return _530;
},adjacent:function(_535){
for(var i=0,_537=[],node;node=_535[i];i++){
var next=this.nextElementSibling(node);
if(next){
_537.push(next);
}
}
return _537;
},laterSibling:function(_53a){
var h=Selector.handlers;
for(var i=0,_53d=[],node;node=_53a[i];i++){
h.concat(_53d,Element.nextSiblings(node));
}
return _53d;
},nextElementSibling:function(node){
while(node=node.nextSibling){
if(node.nodeType==1){
return node;
}
}
return null;
},previousElementSibling:function(node){
while(node=node.previousSibling){
if(node.nodeType==1){
return node;
}
}
return null;
},tagName:function(_541,root,_543,_544){
_543=_543.toUpperCase();
var _545=[],h=Selector.handlers;
if(_541){
if(_544){
if(_544=="descendant"){
for(var i=0,node;node=_541[i];i++){
h.concat(_545,node.getElementsByTagName(_543));
}
return _545;
}else{
_541=this[_544](_541);
}
if(_543=="*"){
return _541;
}
}
for(var i=0,node;node=_541[i];i++){
if(node.tagName.toUpperCase()==_543){
_545.push(node);
}
}
return _545;
}else{
return root.getElementsByTagName(_543);
}
},id:function(_549,root,id,_54c){
var _54d=$(id),h=Selector.handlers;
if(!_549&&root==document){
return _54d?[_54d]:[];
}
if(_549){
if(_54c){
if(_54c=="child"){
for(var i=0,node;node=_549[i];i++){
if(_54d.parentNode==node){
return [_54d];
}
}
}else{
if(_54c=="descendant"){
for(var i=0,node;node=_549[i];i++){
if(Element.descendantOf(_54d,node)){
return [_54d];
}
}
}else{
if(_54c=="adjacent"){
for(var i=0,node;node=_549[i];i++){
if(Selector.handlers.previousElementSibling(_54d)==node){
return [_54d];
}
}
}else{
_549=h[_54c](_549);
}
}
}
}
for(var i=0,node;node=_549[i];i++){
if(node==_54d){
return [_54d];
}
}
return [];
}
return (_54d&&Element.descendantOf(_54d,root))?[_54d]:[];
},className:function(_551,root,_553,_554){
if(_551&&_554){
_551=this[_554](_551);
}
return Selector.handlers.byClassName(_551,root,_553);
},byClassName:function(_555,root,_557){
if(!_555){
_555=Selector.handlers.descendant([root]);
}
var _558=" "+_557+" ";
for(var i=0,_55a=[],node,_55c;node=_555[i];i++){
_55c=node.className;
if(_55c.length==0){
continue;
}
if(_55c==_557||(" "+_55c+" ").include(_558)){
_55a.push(node);
}
}
return _55a;
},attrPresence:function(_55d,root,attr){
var _560=[];
for(var i=0,node;node=_55d[i];i++){
if(Element.hasAttribute(node,attr)){
_560.push(node);
}
}
return _560;
},attr:function(_563,root,attr,_566,_567){
if(!_563){
_563=root.getElementsByTagName("*");
}
var _568=Selector.operators[_567],_569=[];
for(var i=0,node;node=_563[i];i++){
var _56c=Element.readAttribute(node,attr);
if(_56c===null){
continue;
}
if(_568(_56c,_566)){
_569.push(node);
}
}
return _569;
},pseudo:function(_56d,name,_56f,root,_571){
if(_56d&&_571){
_56d=this[_571](_56d);
}
if(!_56d){
_56d=root.getElementsByTagName("*");
}
return Selector.pseudos[name](_56d,_56f,root);
}},pseudos:{"first-child":function(_572,_573,root){
for(var i=0,_576=[],node;node=_572[i];i++){
if(Selector.handlers.previousElementSibling(node)){
continue;
}
_576.push(node);
}
return _576;
},"last-child":function(_578,_579,root){
for(var i=0,_57c=[],node;node=_578[i];i++){
if(Selector.handlers.nextElementSibling(node)){
continue;
}
_57c.push(node);
}
return _57c;
},"only-child":function(_57e,_57f,root){
var h=Selector.handlers;
for(var i=0,_583=[],node;node=_57e[i];i++){
if(!h.previousElementSibling(node)&&!h.nextElementSibling(node)){
_583.push(node);
}
}
return _583;
},"nth-child":function(_585,_586,root){
return Selector.pseudos.nth(_585,_586,root);
},"nth-last-child":function(_588,_589,root){
return Selector.pseudos.nth(_588,_589,root,true);
},"nth-of-type":function(_58b,_58c,root){
return Selector.pseudos.nth(_58b,_58c,root,false,true);
},"nth-last-of-type":function(_58e,_58f,root){
return Selector.pseudos.nth(_58e,_58f,root,true,true);
},"first-of-type":function(_591,_592,root){
return Selector.pseudos.nth(_591,"1",root,false,true);
},"last-of-type":function(_594,_595,root){
return Selector.pseudos.nth(_594,"1",root,true,true);
},"only-of-type":function(_597,_598,root){
var p=Selector.pseudos;
return p["last-of-type"](p["first-of-type"](_597,_598,root),_598,root);
},getIndices:function(a,b,_59d){
if(a==0){
return b>0?[b]:[];
}
return $R(1,_59d).inject([],function(memo,i){
if(0==(i-b)%a&&(i-b)/a>=0){
memo.push(i);
}
return memo;
});
},nth:function(_5a0,_5a1,root,_5a3,_5a4){
if(_5a0.length==0){
return [];
}
if(_5a1=="even"){
_5a1="2n+0";
}
if(_5a1=="odd"){
_5a1="2n+1";
}
var h=Selector.handlers,_5a6=[],_5a7=[],m;
h.mark(_5a0);
for(var i=0,node;node=_5a0[i];i++){
if(!node.parentNode._counted){
h.index(node.parentNode,_5a3,_5a4);
_5a7.push(node.parentNode);
}
}
if(_5a1.match(/^\d+$/)){
_5a1=Number(_5a1);
for(var i=0,node;node=_5a0[i];i++){
if(node.nodeIndex==_5a1){
_5a6.push(node);
}
}
}else{
if(m=_5a1.match(/^(-?\d*)?n(([+-])(\d+))?/)){
if(m[1]=="-"){
m[1]=-1;
}
var a=m[1]?Number(m[1]):1;
var b=m[2]?Number(m[2]):0;
var _5ad=Selector.pseudos.getIndices(a,b,_5a0.length);
for(var i=0,node,l=_5ad.length;node=_5a0[i];i++){
for(var j=0;j<l;j++){
if(node.nodeIndex==_5ad[j]){
_5a6.push(node);
}
}
}
}
}
h.unmark(_5a0);
h.unmark(_5a7);
return _5a6;
},"empty":function(_5b0,_5b1,root){
for(var i=0,_5b4=[],node;node=_5b0[i];i++){
if(node.tagName=="!"||(node.firstChild&&!node.innerHTML.match(/^\s*$/))){
continue;
}
_5b4.push(node);
}
return _5b4;
},"not":function(_5b6,_5b7,root){
var h=Selector.handlers,_5ba,m;
var _5bc=new Selector(_5b7).findElements(root);
h.mark(_5bc);
for(var i=0,_5be=[],node;node=_5b6[i];i++){
if(!node._counted){
_5be.push(node);
}
}
h.unmark(_5bc);
return _5be;
},"enabled":function(_5c0,_5c1,root){
for(var i=0,_5c4=[],node;node=_5c0[i];i++){
if(!node.disabled){
_5c4.push(node);
}
}
return _5c4;
},"disabled":function(_5c6,_5c7,root){
for(var i=0,_5ca=[],node;node=_5c6[i];i++){
if(node.disabled){
_5ca.push(node);
}
}
return _5ca;
},"checked":function(_5cc,_5cd,root){
for(var i=0,_5d0=[],node;node=_5cc[i];i++){
if(node.checked){
_5d0.push(node);
}
}
return _5d0;
}},operators:{"=":function(nv,v){
return nv==v;
},"!=":function(nv,v){
return nv!=v;
},"^=":function(nv,v){
return nv.startsWith(v);
},"$=":function(nv,v){
return nv.endsWith(v);
},"*=":function(nv,v){
return nv.include(v);
},"~=":function(nv,v){
return (" "+nv+" ").include(" "+v+" ");
},"|=":function(nv,v){
return ("-"+nv.toUpperCase()+"-").include("-"+v.toUpperCase()+"-");
}},matchElements:function(_5e0,_5e1){
var _5e2=new Selector(_5e1).findElements(),h=Selector.handlers;
h.mark(_5e2);
for(var i=0,_5e5=[],_5e6;_5e6=_5e0[i];i++){
if(_5e6._counted){
_5e5.push(_5e6);
}
}
h.unmark(_5e2);
return _5e5;
},findElement:function(_5e7,_5e8,_5e9){
if(typeof _5e8=="number"){
_5e9=_5e8;
_5e8=false;
}
return Selector.matchElements(_5e7,_5e8||"*")[_5e9||0];
},findChildElements:function(_5ea,_5eb){
var _5ec=_5eb.join(","),_5eb=[];
_5ec.scan(/(([\w#:.~>+()\s-]+|\*|\[.*?\])+)\s*(,|$)/,function(m){
_5eb.push(m[1].strip());
});
var _5ee=[],h=Selector.handlers;
for(var i=0,l=_5eb.length,_5f2;i<l;i++){
_5f2=new Selector(_5eb[i].strip());
h.concat(_5ee,_5f2.findElements(_5ea));
}
return (l>1)?h.unique(_5ee):_5ee;
}});
function $$(){
return Selector.findChildElements(document,$A(arguments));
}
var Form={reset:function(form){
$(form).reset();
return form;
},serializeElements:function(_5f4,_5f5){
var data=_5f4.inject({},function(_5f7,_5f8){
if(!_5f8.disabled&&_5f8.name){
var key=_5f8.name,_5fa=$(_5f8).getValue();
if(_5fa!=null){
if(key in _5f7){
if(_5f7[key].constructor!=Array){
_5f7[key]=[_5f7[key]];
}
_5f7[key].push(_5fa);
}else{
_5f7[key]=_5fa;
}
}
}
return _5f7;
});
return _5f5?data:Hash.toQueryString(data);
}};
Form.Methods={serialize:function(form,_5fc){
return Form.serializeElements(Form.getElements(form),_5fc);
},getElements:function(form){
return $A($(form).getElementsByTagName("*")).inject([],function(_5fe,_5ff){
if(Form.Element.Serializers[_5ff.tagName.toLowerCase()]){
_5fe.push(Element.extend(_5ff));
}
return _5fe;
});
},getInputs:function(form,_601,name){
form=$(form);
var _603=form.getElementsByTagName("input");
if(!_601&&!name){
return $A(_603).map(Element.extend);
}
for(var i=0,_605=[],_606=_603.length;i<_606;i++){
var _607=_603[i];
if((_601&&_607.type!=_601)||(name&&_607.name!=name)){
continue;
}
_605.push(Element.extend(_607));
}
return _605;
},disable:function(form){
form=$(form);
Form.getElements(form).invoke("disable");
return form;
},enable:function(form){
form=$(form);
Form.getElements(form).invoke("enable");
return form;
},findFirstElement:function(form){
return $(form).getElements().find(function(_60b){
return _60b.type!="hidden"&&!_60b.disabled&&["input","select","textarea"].include(_60b.tagName.toLowerCase());
});
},focusFirstElement:function(form){
form=$(form);
form.findFirstElement().activate();
return form;
},request:function(form,_60e){
form=$(form),_60e=Object.clone(_60e||{});
var _60f=_60e.parameters;
_60e.parameters=form.serialize(true);
if(_60f){
if(typeof _60f=="string"){
_60f=_60f.toQueryParams();
}
Object.extend(_60e.parameters,_60f);
}
if(form.hasAttribute("method")&&!_60e.method){
_60e.method=form.method;
}
return new Ajax.Request(form.readAttribute("action"),_60e);
}};
Form.Element={focus:function(_610){
$(_610).focus();
return _610;
},select:function(_611){
$(_611).select();
return _611;
}};
Form.Element.Methods={serialize:function(_612){
_612=$(_612);
if(!_612.disabled&&_612.name){
var _613=_612.getValue();
if(_613!=undefined){
var pair={};
pair[_612.name]=_613;
return Hash.toQueryString(pair);
}
}
return "";
},getValue:function(_615){
_615=$(_615);
var _616=_615.tagName.toLowerCase();
return Form.Element.Serializers[_616](_615);
},clear:function(_617){
$(_617).value="";
return _617;
},present:function(_618){
return $(_618).value!="";
},activate:function(_619){
_619=$(_619);
try{
_619.focus();
if(_619.select&&(_619.tagName.toLowerCase()!="input"||!["button","reset","submit"].include(_619.type))){
_619.select();
}
}
catch(e){
}
return _619;
},disable:function(_61a){
_61a=$(_61a);
_61a.blur();
_61a.disabled=true;
return _61a;
},enable:function(_61b){
_61b=$(_61b);
_61b.disabled=false;
return _61b;
}};
var Field=Form.Element;
var $F=Form.Element.Methods.getValue;
Form.Element.Serializers={input:function(_61c){
switch(_61c.type.toLowerCase()){
case "checkbox":
case "radio":
return Form.Element.Serializers.inputSelector(_61c);
default:
return Form.Element.Serializers.textarea(_61c);
}
},inputSelector:function(_61d){
return _61d.checked?_61d.value:null;
},textarea:function(_61e){
return _61e.value;
},select:function(_61f){
return this[_61f.type=="select-one"?"selectOne":"selectMany"](_61f);
},selectOne:function(_620){
var _621=_620.selectedIndex;
return _621>=0?this.optionValue(_620.options[_621]):null;
},selectMany:function(_622){
var _623,_624=_622.length;
if(!_624){
return null;
}
for(var i=0,_623=[];i<_624;i++){
var opt=_622.options[i];
if(opt.selected){
_623.push(this.optionValue(opt));
}
}
return _623;
},optionValue:function(opt){
return Element.extend(opt).hasAttribute("value")?opt.value:opt.text;
}};
Abstract.TimedObserver=function(){
};
Abstract.TimedObserver.prototype={initialize:function(_628,_629,_62a){
this.frequency=_629;
this.element=$(_628);
this.callback=_62a;
this.lastValue=this.getValue();
this.registerCallback();
},registerCallback:function(){
setInterval(this.onTimerEvent.bind(this),this.frequency*1000);
},onTimerEvent:function(){
var _62b=this.getValue();
var _62c=("string"==typeof this.lastValue&&"string"==typeof _62b?this.lastValue!=_62b:String(this.lastValue)!=String(_62b));
if(_62c){
this.callback(this.element,_62b);
this.lastValue=_62b;
}
}};
Form.Element.Observer=Class.create();
Form.Element.Observer.prototype=Object.extend(new Abstract.TimedObserver(),{getValue:function(){
return Form.Element.getValue(this.element);
}});
Form.Observer=Class.create();
Form.Observer.prototype=Object.extend(new Abstract.TimedObserver(),{getValue:function(){
return Form.serialize(this.element);
}});
Abstract.EventObserver=function(){
};
Abstract.EventObserver.prototype={initialize:function(_62d,_62e){
this.element=$(_62d);
this.callback=_62e;
this.lastValue=this.getValue();
if(this.element.tagName.toLowerCase()=="form"){
this.registerFormCallbacks();
}else{
this.registerCallback(this.element);
}
},onElementEvent:function(){
var _62f=this.getValue();
if(this.lastValue!=_62f){
this.callback(this.element,_62f);
this.lastValue=_62f;
}
},registerFormCallbacks:function(){
Form.getElements(this.element).each(this.registerCallback.bind(this));
},registerCallback:function(_630){
if(_630.type){
switch(_630.type.toLowerCase()){
case "checkbox":
case "radio":
Event.observe(_630,"click",this.onElementEvent.bind(this));
break;
default:
Event.observe(_630,"change",this.onElementEvent.bind(this));
break;
}
}
}};
Form.Element.EventObserver=Class.create();
Form.Element.EventObserver.prototype=Object.extend(new Abstract.EventObserver(),{getValue:function(){
return Form.Element.getValue(this.element);
}});
Form.EventObserver=Class.create();
Form.EventObserver.prototype=Object.extend(new Abstract.EventObserver(),{getValue:function(){
return Form.serialize(this.element);
}});
if(!window.Event){
var Event=new Object();
}
Object.extend(Event,{KEY_BACKSPACE:8,KEY_TAB:9,KEY_RETURN:13,KEY_ESC:27,KEY_LEFT:37,KEY_UP:38,KEY_RIGHT:39,KEY_DOWN:40,KEY_DELETE:46,KEY_HOME:36,KEY_END:35,KEY_PAGEUP:33,KEY_PAGEDOWN:34,element:function(_631){
return $(_631.target||_631.srcElement);
},isLeftClick:function(_632){
return (((_632.which)&&(_632.which==1))||((_632.button)&&(_632.button==1)));
},pointerX:function(_633){
return _633.pageX||(_633.clientX+(document.documentElement.scrollLeft||document.body.scrollLeft));
},pointerY:function(_634){
return _634.pageY||(_634.clientY+(document.documentElement.scrollTop||document.body.scrollTop));
},stop:function(_635){
if(_635.preventDefault){
_635.preventDefault();
_635.stopPropagation();
}else{
_635.returnValue=false;
_635.cancelBubble=true;
}
},findElement:function(_636,_637){
var _638=Event.element(_636);
while(_638.parentNode&&(!_638.tagName||(_638.tagName.toUpperCase()!=_637.toUpperCase()))){
_638=_638.parentNode;
}
return _638;
},observers:false,_observeAndCache:function(_639,name,_63b,_63c){
if(!this.observers){
this.observers=[];
}
if(_639.addEventListener){
this.observers.push([_639,name,_63b,_63c]);
_639.addEventListener(name,_63b,_63c);
}else{
if(_639.attachEvent){
this.observers.push([_639,name,_63b,_63c]);
_639.attachEvent("on"+name,_63b);
}
}
},unloadCache:function(){
if(!Event.observers){
return;
}
for(var i=0,_63e=Event.observers.length;i<_63e;i++){
Event.stopObserving.apply(this,Event.observers[i]);
Event.observers[i][0]=null;
}
Event.observers=false;
},observe:function(_63f,name,_641,_642){
_63f=$(_63f);
_642=_642||false;
if(name=="keypress"&&(Prototype.Browser.WebKit||_63f.attachEvent)){
name="keydown";
}
Event._observeAndCache(_63f,name,_641,_642);
},stopObserving:function(_643,name,_645,_646){
_643=$(_643);
_646=_646||false;
if(name=="keypress"&&(Prototype.Browser.WebKit||_643.attachEvent)){
name="keydown";
}
if(_643.removeEventListener){
_643.removeEventListener(name,_645,_646);
}else{
if(_643.detachEvent){
try{
_643.detachEvent("on"+name,_645);
}
catch(e){
}
}
}
}});
if(Prototype.Browser.IE){
Event.observe(window,"unload",Event.unloadCache,false);
}
var Position={includeScrollOffsets:false,prepare:function(){
this.deltaX=window.pageXOffset||document.documentElement.scrollLeft||document.body.scrollLeft||0;
this.deltaY=window.pageYOffset||document.documentElement.scrollTop||document.body.scrollTop||0;
},realOffset:function(_647){
var _648=0,_649=0;
do{
_648+=_647.scrollTop||0;
_649+=_647.scrollLeft||0;
_647=_647.parentNode;
}while(_647);
return [_649,_648];
},cumulativeOffset:function(_64a){
var _64b=0,_64c=0;
do{
_64b+=_64a.offsetTop||0;
_64c+=_64a.offsetLeft||0;
_64a=_64a.offsetParent;
}while(_64a);
return [_64c,_64b];
},positionedOffset:function(_64d){
var _64e=0,_64f=0;
do{
_64e+=_64d.offsetTop||0;
_64f+=_64d.offsetLeft||0;
_64d=_64d.offsetParent;
if(_64d){
if(_64d.tagName=="BODY"){
break;
}
var p=Element.getStyle(_64d,"position");
if(p=="relative"||p=="absolute"){
break;
}
}
}while(_64d);
return [_64f,_64e];
},offsetParent:function(_651){
if(_651.offsetParent){
return _651.offsetParent;
}
if(_651==document.body){
return _651;
}
while((_651=_651.parentNode)&&_651!=document.body){
if(Element.getStyle(_651,"position")!="static"){
return _651;
}
}
return document.body;
},within:function(_652,x,y){
if(this.includeScrollOffsets){
return this.withinIncludingScrolloffsets(_652,x,y);
}
this.xcomp=x;
this.ycomp=y;
this.offset=this.cumulativeOffset(_652);
return (y>=this.offset[1]&&y<this.offset[1]+_652.offsetHeight&&x>=this.offset[0]&&x<this.offset[0]+_652.offsetWidth);
},withinIncludingScrolloffsets:function(_655,x,y){
var _658=this.realOffset(_655);
this.xcomp=x+_658[0]-this.deltaX;
this.ycomp=y+_658[1]-this.deltaY;
this.offset=this.cumulativeOffset(_655);
return (this.ycomp>=this.offset[1]&&this.ycomp<this.offset[1]+_655.offsetHeight&&this.xcomp>=this.offset[0]&&this.xcomp<this.offset[0]+_655.offsetWidth);
},overlap:function(mode,_65a){
if(!mode){
return 0;
}
if(mode=="vertical"){
return ((this.offset[1]+_65a.offsetHeight)-this.ycomp)/_65a.offsetHeight;
}
if(mode=="horizontal"){
return ((this.offset[0]+_65a.offsetWidth)-this.xcomp)/_65a.offsetWidth;
}
},page:function(_65b){
var _65c=0,_65d=0;
var _65e=_65b;
do{
_65c+=_65e.offsetTop||0;
_65d+=_65e.offsetLeft||0;
if(_65e.offsetParent==document.body){
if(Element.getStyle(_65e,"position")=="absolute"){
break;
}
}
}while(_65e=_65e.offsetParent);
_65e=_65b;
do{
if(!window.opera||_65e.tagName=="BODY"){
_65c-=_65e.scrollTop||0;
_65d-=_65e.scrollLeft||0;
}
}while(_65e=_65e.parentNode);
return [_65d,_65c];
},clone:function(_65f,_660){
var _661=Object.extend({setLeft:true,setTop:true,setWidth:true,setHeight:true,offsetTop:0,offsetLeft:0},arguments[2]||{});
_65f=$(_65f);
var p=Position.page(_65f);
_660=$(_660);
var _663=[0,0];
var _664=null;
if(Element.getStyle(_660,"position")=="absolute"){
_664=Position.offsetParent(_660);
_663=Position.page(_664);
}
if(_664==document.body){
_663[0]-=document.body.offsetLeft;
_663[1]-=document.body.offsetTop;
}
if(_661.setLeft){
_660.style.left=(p[0]-_663[0]+_661.offsetLeft)+"px";
}
if(_661.setTop){
_660.style.top=(p[1]-_663[1]+_661.offsetTop)+"px";
}
if(_661.setWidth){
_660.style.width=_65f.offsetWidth+"px";
}
if(_661.setHeight){
_660.style.height=_65f.offsetHeight+"px";
}
},absolutize:function(_665){
_665=$(_665);
if(_665.style.position=="absolute"){
return;
}
Position.prepare();
var _666=Position.positionedOffset(_665);
var top=_666[1];
var left=_666[0];
var _669=_665.clientWidth;
var _66a=_665.clientHeight;
_665._originalLeft=left-parseFloat(_665.style.left||0);
_665._originalTop=top-parseFloat(_665.style.top||0);
_665._originalWidth=_665.style.width;
_665._originalHeight=_665.style.height;
_665.style.position="absolute";
_665.style.top=top+"px";
_665.style.left=left+"px";
_665.style.width=_669+"px";
_665.style.height=_66a+"px";
},relativize:function(_66b){
_66b=$(_66b);
if(_66b.style.position=="relative"){
return;
}
Position.prepare();
_66b.style.position="relative";
var top=parseFloat(_66b.style.top||0)-(_66b._originalTop||0);
var left=parseFloat(_66b.style.left||0)-(_66b._originalLeft||0);
_66b.style.top=top+"px";
_66b.style.left=left+"px";
_66b.style.height=_66b._originalHeight;
_66b.style.width=_66b._originalWidth;
}};
if(Prototype.Browser.WebKit){
Position.cumulativeOffset=function(_66e){
var _66f=0,_670=0;
do{
_66f+=_66e.offsetTop||0;
_670+=_66e.offsetLeft||0;
if(_66e.offsetParent==document.body){
if(Element.getStyle(_66e,"position")=="absolute"){
break;
}
}
_66e=_66e.offsetParent;
}while(_66e);
return [_670,_66f];
};
}
Element.addMethods();
String.prototype.parseColor=function(){
var _671="#";
if(this.slice(0,4)=="rgb("){
var cols=this.slice(4,this.length-1).split(",");
var i=0;
do{
_671+=parseInt(cols[i]).toColorPart();
}while(++i<3);
}else{
if(this.slice(0,1)=="#"){
if(this.length==4){
for(var i=1;i<4;i++){
_671+=(this.charAt(i)+this.charAt(i)).toLowerCase();
}
}
if(this.length==7){
_671=this.toLowerCase();
}
}
}
return (_671.length==7?_671:(arguments[0]||this));
};
Element.collectTextNodes=function(_674){
return $A($(_674).childNodes).collect(function(node){
return (node.nodeType==3?node.nodeValue:(node.hasChildNodes()?Element.collectTextNodes(node):""));
}).flatten().join("");
};
Element.collectTextNodesIgnoreClass=function(_676,_677){
return $A($(_676).childNodes).collect(function(node){
return (node.nodeType==3?node.nodeValue:((node.hasChildNodes()&&!Element.hasClassName(node,_677))?Element.collectTextNodesIgnoreClass(node,_677):""));
}).flatten().join("");
};
Element.setContentZoom=function(_679,_67a){
_679=$(_679);
_679.setStyle({fontSize:(_67a/100)+"em"});
if(navigator.appVersion.indexOf("AppleWebKit")>0){
window.scrollBy(0,0);
}
return _679;
};
Element.getOpacity=function(_67b){
_67b=$(_67b);
var _67c;
if(_67c=_67b.getStyle("opacity")){
return parseFloat(_67c);
}
if(_67c=(_67b.getStyle("filter")||"").match(/alpha\(opacity=(.*)\)/)){
if(_67c[1]){
return parseFloat(_67c[1])/100;
}
}
return 1;
};
Element.setOpacity=function(_67d,_67e){
_67d=$(_67d);
if(_67e==1){
_67d.setStyle({opacity:(/Gecko/.test(navigator.userAgent)&&!/Konqueror|Safari|KHTML/.test(navigator.userAgent))?0.999999:1});
if(/MSIE/.test(navigator.userAgent)&&!window.opera){
_67d.setStyle({filter:Element.getStyle(_67d,"filter").replace(/alpha\([^\)]*\)/gi,"")});
}
}else{
if(_67e<0.00001){
_67e=0;
}
_67d.setStyle({opacity:_67e});
if(/MSIE/.test(navigator.userAgent)&&!window.opera){
_67d.setStyle({filter:_67d.getStyle("filter").replace(/alpha\([^\)]*\)/gi,"")+"alpha(opacity="+_67e*100+")"});
}
}
return _67d;
};
Element.getInlineOpacity=function(_67f){
return $(_67f).style.opacity||"";
};
Element.forceRerendering=function(_680){
try{
_680=$(_680);
var n=document.createTextNode(" ");
_680.appendChild(n);
_680.removeChild(n);
}
catch(e){
}
};
Array.prototype.call=function(){
var args=arguments;
this.each(function(f){
f.apply(this,args);
});
};
var Effect={_elementDoesNotExistError:{name:"ElementDoesNotExistError",message:"The specified DOM element does not exist, but is required for this effect to operate"},tagifyText:function(_684){
if(typeof Builder=="undefined"){
throw ("Effect.tagifyText requires including script.aculo.us' builder.js library");
}
var _685="position:relative";
if(/MSIE/.test(navigator.userAgent)&&!window.opera){
_685+=";zoom:1";
}
_684=$(_684);
$A(_684.childNodes).each(function(_686){
if(_686.nodeType==3){
_686.nodeValue.toArray().each(function(_687){
_684.insertBefore(Builder.node("span",{style:_685},_687==" "?String.fromCharCode(160):_687),_686);
});
Element.remove(_686);
}
});
},multiple:function(_688,_689){
var _68a;
if(((typeof _688=="object")||(typeof _688=="function"))&&(_688.length)){
_68a=_688;
}else{
_68a=$(_688).childNodes;
}
var _68b=Object.extend({speed:0.1,delay:0},arguments[2]||{});
var _68c=_68b.delay;
$A(_68a).each(function(_68d,_68e){
new _689(_68d,Object.extend(_68b,{delay:_68e*_68b.speed+_68c}));
});
},PAIRS:{"slide":["SlideDown","SlideUp"],"blind":["BlindDown","BlindUp"],"appear":["Appear","Fade"]},toggle:function(_68f,_690){
_68f=$(_68f);
_690=(_690||"appear").toLowerCase();
var _691=Object.extend({queue:{position:"end",scope:(_68f.id||"global"),limit:1}},arguments[2]||{});
Effect[_68f.visible()?Effect.PAIRS[_690][1]:Effect.PAIRS[_690][0]](_68f,_691);
}};
var Effect2=Effect;
Effect.Transitions={linear:Prototype.K,sinoidal:function(pos){
return (-Math.cos(pos*Math.PI)/2)+0.5;
},reverse:function(pos){
return 1-pos;
},flicker:function(pos){
return ((-Math.cos(pos*Math.PI)/4)+0.75)+Math.random()/4;
},wobble:function(pos){
return (-Math.cos(pos*Math.PI*(9*pos))/2)+0.5;
},pulse:function(pos,_697){
_697=_697||5;
return (Math.round((pos%(1/_697))*_697)==0?((pos*_697*2)-Math.floor(pos*_697*2)):1-((pos*_697*2)-Math.floor(pos*_697*2)));
},none:function(pos){
return 0;
},full:function(pos){
return 1;
}};
Effect.ScopedQueue=Class.create();
Object.extend(Object.extend(Effect.ScopedQueue.prototype,Enumerable),{initialize:function(){
this.effects=[];
this.interval=null;
},_each:function(_69a){
this.effects._each(_69a);
},add:function(_69b){
var _69c=new Date().getTime();
var _69d=(typeof _69b.options.queue=="string")?_69b.options.queue:_69b.options.queue.position;
switch(_69d){
case "front":
this.effects.findAll(function(e){
return e.state=="idle";
}).each(function(e){
e.startOn+=_69b.finishOn;
e.finishOn+=_69b.finishOn;
});
break;
case "with-last":
_69c=this.effects.pluck("startOn").max()||_69c;
break;
case "end":
_69c=this.effects.pluck("finishOn").max()||_69c;
break;
}
_69b.startOn+=_69c;
_69b.finishOn+=_69c;
if(!_69b.options.queue.limit||(this.effects.length<_69b.options.queue.limit)){
this.effects.push(_69b);
}
if(!this.interval){
this.interval=setInterval(this.loop.bind(this),40);
}
},remove:function(_6a0){
this.effects=this.effects.reject(function(e){
return e==_6a0;
});
if(this.effects.length==0){
clearInterval(this.interval);
this.interval=null;
}
},loop:function(){
var _6a2=new Date().getTime();
this.effects.invoke("loop",_6a2);
}});
Effect.Queues={instances:$H(),get:function(_6a3){
if(typeof _6a3!="string"){
return _6a3;
}
if(!this.instances[_6a3]){
this.instances[_6a3]=new Effect.ScopedQueue();
}
return this.instances[_6a3];
}};
Effect.Queue=Effect.Queues.get("global");
Effect.DefaultOptions={transition:Effect.Transitions.sinoidal,duration:1,fps:25,sync:false,from:0,to:1,delay:0,queue:"parallel"};
Effect.Base=function(){
};
Effect.Base.prototype={position:null,start:function(_6a4){
this.options=Object.extend(Object.extend({},Effect.DefaultOptions),_6a4||{});
this.currentFrame=0;
this.state="idle";
this.startOn=this.options.delay*1000;
this.finishOn=this.startOn+(this.options.duration*1000);
this.event("beforeStart");
if(!this.options.sync){
Effect.Queues.get(typeof this.options.queue=="string"?"global":this.options.queue.scope).add(this);
}
},loop:function(_6a5){
if(_6a5>=this.startOn){
if(_6a5>=this.finishOn){
this.render(1);
this.cancel();
this.event("beforeFinish");
if(this.finish){
this.finish();
}
this.event("afterFinish");
return;
}
var pos=(_6a5-this.startOn)/(this.finishOn-this.startOn);
var _6a7=Math.round(pos*this.options.fps*this.options.duration);
if(_6a7>this.currentFrame){
this.render(pos);
this.currentFrame=_6a7;
}
}
},render:function(pos){
if(this.state=="idle"){
this.state="running";
this.event("beforeSetup");
if(this.setup){
this.setup();
}
this.event("afterSetup");
}
if(this.state=="running"){
if(this.options.transition){
pos=this.options.transition(pos);
}
pos*=(this.options.to-this.options.from);
pos+=this.options.from;
this.position=pos;
this.event("beforeUpdate");
if(this.update){
this.update(pos);
}
this.event("afterUpdate");
}
},cancel:function(){
if(!this.options.sync){
Effect.Queues.get(typeof this.options.queue=="string"?"global":this.options.queue.scope).remove(this);
}
this.state="finished";
},event:function(_6a9){
if(this.options[_6a9+"Internal"]){
this.options[_6a9+"Internal"](this);
}
if(this.options[_6a9]){
this.options[_6a9](this);
}
},inspect:function(){
return "#<Effect:"+$H(this).inspect()+",options:"+$H(this.options).inspect()+">";
}};
Effect.Parallel=Class.create();
Object.extend(Object.extend(Effect.Parallel.prototype,Effect.Base.prototype),{initialize:function(_6aa){
this.effects=_6aa||[];
this.start(arguments[1]);
},update:function(_6ab){
this.effects.invoke("render",_6ab);
},finish:function(_6ac){
this.effects.each(function(_6ad){
_6ad.render(1);
_6ad.cancel();
_6ad.event("beforeFinish");
if(_6ad.finish){
_6ad.finish(_6ac);
}
_6ad.event("afterFinish");
});
}});
Effect.Event=Class.create();
Object.extend(Object.extend(Effect.Event.prototype,Effect.Base.prototype),{initialize:function(){
var _6ae=Object.extend({duration:0},arguments[0]||{});
this.start(_6ae);
},update:Prototype.emptyFunction});
Effect.Opacity=Class.create();
Object.extend(Object.extend(Effect.Opacity.prototype,Effect.Base.prototype),{initialize:function(_6af){
this.element=$(_6af);
if(!this.element){
throw (Effect._elementDoesNotExistError);
}
if(/MSIE/.test(navigator.userAgent)&&!window.opera&&(!this.element.currentStyle.hasLayout)){
this.element.setStyle({zoom:1});
}
var _6b0=Object.extend({from:this.element.getOpacity()||0,to:1},arguments[1]||{});
this.start(_6b0);
},update:function(_6b1){
this.element.setOpacity(_6b1);
}});
Effect.Move=Class.create();
Object.extend(Object.extend(Effect.Move.prototype,Effect.Base.prototype),{initialize:function(_6b2){
this.element=$(_6b2);
if(!this.element){
throw (Effect._elementDoesNotExistError);
}
var _6b3=Object.extend({x:0,y:0,mode:"relative"},arguments[1]||{});
this.start(_6b3);
},setup:function(){
this.element.makePositioned();
this.originalLeft=parseFloat(this.element.getStyle("left")||"0");
this.originalTop=parseFloat(this.element.getStyle("top")||"0");
if(this.options.mode=="absolute"){
this.options.x=this.options.x-this.originalLeft;
this.options.y=this.options.y-this.originalTop;
}
},update:function(_6b4){
this.element.setStyle({left:Math.round(this.options.x*_6b4+this.originalLeft)+"px",top:Math.round(this.options.y*_6b4+this.originalTop)+"px"});
}});
Effect.MoveBy=function(_6b5,_6b6,_6b7){
return new Effect.Move(_6b5,Object.extend({x:_6b7,y:_6b6},arguments[3]||{}));
};
Effect.Scale=Class.create();
Object.extend(Object.extend(Effect.Scale.prototype,Effect.Base.prototype),{initialize:function(_6b8,_6b9){
this.element=$(_6b8);
if(!this.element){
throw (Effect._elementDoesNotExistError);
}
var _6ba=Object.extend({scaleX:true,scaleY:true,scaleContent:true,scaleFromCenter:false,scaleMode:"box",scaleFrom:100,scaleTo:_6b9},arguments[2]||{});
this.start(_6ba);
},setup:function(){
this.restoreAfterFinish=this.options.restoreAfterFinish||false;
this.elementPositioning=this.element.getStyle("position");
this.originalStyle={};
["top","left","width","height","fontSize"].each(function(k){
this.originalStyle[k]=this.element.style[k];
}.bind(this));
this.originalTop=this.element.offsetTop;
this.originalLeft=this.element.offsetLeft;
var _6bc=this.element.getStyle("font-size")||"100%";
["em","px","%","pt"].each(function(_6bd){
if(_6bc.indexOf(_6bd)>0){
this.fontSize=parseFloat(_6bc);
this.fontSizeType=_6bd;
}
}.bind(this));
this.factor=(this.options.scaleTo-this.options.scaleFrom)/100;
this.dims=null;
if(this.options.scaleMode=="box"){
this.dims=[this.element.offsetHeight,this.element.offsetWidth];
}
if(/^content/.test(this.options.scaleMode)){
this.dims=[this.element.scrollHeight,this.element.scrollWidth];
}
if(!this.dims){
this.dims=[this.options.scaleMode.originalHeight,this.options.scaleMode.originalWidth];
}
},update:function(_6be){
var _6bf=(this.options.scaleFrom/100)+(this.factor*_6be);
if(this.options.scaleContent&&this.fontSize){
this.element.setStyle({fontSize:this.fontSize*_6bf+this.fontSizeType});
}
this.setDimensions(this.dims[0]*_6bf,this.dims[1]*_6bf);
},finish:function(_6c0){
if(this.restoreAfterFinish){
this.element.setStyle(this.originalStyle);
}
},setDimensions:function(_6c1,_6c2){
var d={};
if(this.options.scaleX){
d.width=Math.round(_6c2)+"px";
}
if(this.options.scaleY){
d.height=Math.round(_6c1)+"px";
}
if(this.options.scaleFromCenter){
var topd=(_6c1-this.dims[0])/2;
var _6c5=(_6c2-this.dims[1])/2;
if(this.elementPositioning=="absolute"){
if(this.options.scaleY){
d.top=this.originalTop-topd+"px";
}
if(this.options.scaleX){
d.left=this.originalLeft-_6c5+"px";
}
}else{
if(this.options.scaleY){
d.top=-topd+"px";
}
if(this.options.scaleX){
d.left=-_6c5+"px";
}
}
}
this.element.setStyle(d);
}});
Effect.Highlight=Class.create();
Object.extend(Object.extend(Effect.Highlight.prototype,Effect.Base.prototype),{initialize:function(_6c6){
this.element=$(_6c6);
if(!this.element){
throw (Effect._elementDoesNotExistError);
}
var _6c7=Object.extend({startcolor:"#ffff99"},arguments[1]||{});
this.start(_6c7);
},setup:function(){
if(this.element.getStyle("display")=="none"){
this.cancel();
return;
}
this.oldStyle={backgroundImage:this.element.getStyle("background-image")};
this.element.setStyle({backgroundImage:"none"});
if(!this.options.endcolor){
this.options.endcolor=this.element.getStyle("background-color").parseColor("#ffffff");
}
if(!this.options.restorecolor){
this.options.restorecolor=this.element.getStyle("background-color");
}
this._base=$R(0,2).map(function(i){
return parseInt(this.options.startcolor.slice(i*2+1,i*2+3),16);
}.bind(this));
this._delta=$R(0,2).map(function(i){
return parseInt(this.options.endcolor.slice(i*2+1,i*2+3),16)-this._base[i];
}.bind(this));
},update:function(_6ca){
this.element.setStyle({backgroundColor:$R(0,2).inject("#",function(m,v,i){
return m+(Math.round(this._base[i]+(this._delta[i]*_6ca)).toColorPart());
}.bind(this))});
},finish:function(){
this.element.setStyle(Object.extend(this.oldStyle,{backgroundColor:this.options.restorecolor}));
}});
Effect.ScrollTo=Class.create();
Object.extend(Object.extend(Effect.ScrollTo.prototype,Effect.Base.prototype),{initialize:function(_6ce){
this.element=$(_6ce);
this.start(arguments[1]||{});
},setup:function(){
Position.prepare();
var _6cf=Position.cumulativeOffset(this.element);
if(this.options.offset){
_6cf[1]+=this.options.offset;
}
var max=window.innerHeight?window.height-window.innerHeight:document.body.scrollHeight-(document.documentElement.clientHeight?document.documentElement.clientHeight:document.body.clientHeight);
this.scrollStart=Position.deltaY;
this.delta=(_6cf[1]>max?max:_6cf[1])-this.scrollStart;
},update:function(_6d1){
Position.prepare();
window.scrollTo(Position.deltaX,this.scrollStart+(_6d1*this.delta));
}});
Effect.Fade=function(_6d2){
_6d2=$(_6d2);
var _6d3=_6d2.getInlineOpacity();
var _6d4=Object.extend({from:_6d2.getOpacity()||1,to:0,afterFinishInternal:function(_6d5){
if(_6d5.options.to!=0){
return;
}
_6d5.element.hide().setStyle({opacity:_6d3});
}},arguments[1]||{});
return new Effect.Opacity(_6d2,_6d4);
};
Effect.Appear=function(_6d6){
_6d6=$(_6d6);
var _6d7=Object.extend({from:(_6d6.getStyle("display")=="none"?0:_6d6.getOpacity()||0),to:1,afterFinishInternal:function(_6d8){
_6d8.element.forceRerendering();
},beforeSetup:function(_6d9){
_6d9.element.setOpacity(_6d9.options.from).show();
}},arguments[1]||{});
return new Effect.Opacity(_6d6,_6d7);
};
Effect.Puff=function(_6da){
_6da=$(_6da);
var _6db={opacity:_6da.getInlineOpacity(),position:_6da.getStyle("position"),top:_6da.style.top,left:_6da.style.left,width:_6da.style.width,height:_6da.style.height};
return new Effect.Parallel([new Effect.Scale(_6da,200,{sync:true,scaleFromCenter:true,scaleContent:true,restoreAfterFinish:true}),new Effect.Opacity(_6da,{sync:true,to:0})],Object.extend({duration:1,beforeSetupInternal:function(_6dc){
Position.absolutize(_6dc.effects[0].element);
},afterFinishInternal:function(_6dd){
_6dd.effects[0].element.hide().setStyle(_6db);
}},arguments[1]||{}));
};
Effect.BlindUp=function(_6de){
_6de=$(_6de);
_6de.makeClipping();
return new Effect.Scale(_6de,0,Object.extend({scaleContent:false,scaleX:false,restoreAfterFinish:true,afterFinishInternal:function(_6df){
_6df.element.hide().undoClipping();
}},arguments[1]||{}));
};
Effect.BlindDown=function(_6e0){
_6e0=$(_6e0);
var _6e1=_6e0.getDimensions();
return new Effect.Scale(_6e0,100,Object.extend({scaleContent:false,scaleX:false,scaleFrom:0,scaleMode:{originalHeight:_6e1.height,originalWidth:_6e1.width},restoreAfterFinish:true,afterSetup:function(_6e2){
_6e2.element.makeClipping().setStyle({height:"0px"}).show();
},afterFinishInternal:function(_6e3){
_6e3.element.undoClipping();
}},arguments[1]||{}));
};
Effect.SwitchOff=function(_6e4){
_6e4=$(_6e4);
var _6e5=_6e4.getInlineOpacity();
return new Effect.Appear(_6e4,Object.extend({duration:0.4,from:0,transition:Effect.Transitions.flicker,afterFinishInternal:function(_6e6){
new Effect.Scale(_6e6.element,1,{duration:0.3,scaleFromCenter:true,scaleX:false,scaleContent:false,restoreAfterFinish:true,beforeSetup:function(_6e7){
_6e7.element.makePositioned().makeClipping();
},afterFinishInternal:function(_6e8){
_6e8.element.hide().undoClipping().undoPositioned().setStyle({opacity:_6e5});
}});
}},arguments[1]||{}));
};
Effect.DropOut=function(_6e9){
_6e9=$(_6e9);
var _6ea={top:_6e9.getStyle("top"),left:_6e9.getStyle("left"),opacity:_6e9.getInlineOpacity()};
return new Effect.Parallel([new Effect.Move(_6e9,{x:0,y:100,sync:true}),new Effect.Opacity(_6e9,{sync:true,to:0})],Object.extend({duration:0.5,beforeSetup:function(_6eb){
_6eb.effects[0].element.makePositioned();
},afterFinishInternal:function(_6ec){
_6ec.effects[0].element.hide().undoPositioned().setStyle(_6ea);
}},arguments[1]||{}));
};
Effect.Shake=function(_6ed){
_6ed=$(_6ed);
var _6ee={top:_6ed.getStyle("top"),left:_6ed.getStyle("left")};
return new Effect.Move(_6ed,{x:20,y:0,duration:0.05,afterFinishInternal:function(_6ef){
new Effect.Move(_6ef.element,{x:-40,y:0,duration:0.1,afterFinishInternal:function(_6f0){
new Effect.Move(_6f0.element,{x:40,y:0,duration:0.1,afterFinishInternal:function(_6f1){
new Effect.Move(_6f1.element,{x:-40,y:0,duration:0.1,afterFinishInternal:function(_6f2){
new Effect.Move(_6f2.element,{x:40,y:0,duration:0.1,afterFinishInternal:function(_6f3){
new Effect.Move(_6f3.element,{x:-20,y:0,duration:0.05,afterFinishInternal:function(_6f4){
_6f4.element.undoPositioned().setStyle(_6ee);
}});
}});
}});
}});
}});
}});
};
Effect.SlideDown=function(_6f5){
_6f5=$(_6f5).cleanWhitespace();
var _6f6=_6f5.down().getStyle("bottom");
var _6f7=_6f5.getDimensions();
return new Effect.Scale(_6f5,100,Object.extend({scaleContent:false,scaleX:false,scaleFrom:window.opera?0:1,scaleMode:{originalHeight:_6f7.height,originalWidth:_6f7.width},restoreAfterFinish:true,afterSetup:function(_6f8){
_6f8.element.makePositioned();
_6f8.element.down().makePositioned();
if(window.opera){
_6f8.element.setStyle({top:""});
}
_6f8.element.makeClipping().setStyle({height:"0px"}).show();
},afterUpdateInternal:function(_6f9){
_6f9.element.down().setStyle({bottom:(_6f9.dims[0]-_6f9.element.clientHeight)+"px"});
},afterFinishInternal:function(_6fa){
_6fa.element.undoClipping().undoPositioned();
_6fa.element.down().undoPositioned().setStyle({bottom:_6f6});
}},arguments[1]||{}));
};
Effect.SlideUp=function(_6fb){
_6fb=$(_6fb).cleanWhitespace();
var _6fc=_6fb.down().getStyle("bottom");
return new Effect.Scale(_6fb,window.opera?0:1,Object.extend({scaleContent:false,scaleX:false,scaleMode:"box",scaleFrom:100,restoreAfterFinish:true,beforeStartInternal:function(_6fd){
_6fd.element.makePositioned();
_6fd.element.down().makePositioned();
if(window.opera){
_6fd.element.setStyle({top:""});
}
_6fd.element.makeClipping().show();
},afterUpdateInternal:function(_6fe){
_6fe.element.down().setStyle({bottom:(_6fe.dims[0]-_6fe.element.clientHeight)+"px"});
},afterFinishInternal:function(_6ff){
_6ff.element.hide().undoClipping().undoPositioned().setStyle({bottom:_6fc});
_6ff.element.down().undoPositioned();
}},arguments[1]||{}));
};
Effect.Squish=function(_700){
return new Effect.Scale(_700,window.opera?1:0,{restoreAfterFinish:true,beforeSetup:function(_701){
_701.element.makeClipping();
},afterFinishInternal:function(_702){
_702.element.hide().undoClipping();
}});
};
Effect.Grow=function(_703){
_703=$(_703);
var _704=Object.extend({direction:"center",moveTransition:Effect.Transitions.sinoidal,scaleTransition:Effect.Transitions.sinoidal,opacityTransition:Effect.Transitions.full},arguments[1]||{});
var _705={top:_703.style.top,left:_703.style.left,height:_703.style.height,width:_703.style.width,opacity:_703.getInlineOpacity()};
var dims=_703.getDimensions();
var _707,_708;
var _709,_70a;
switch(_704.direction){
case "top-left":
_707=_708=_709=_70a=0;
break;
case "top-right":
_707=dims.width;
_708=_70a=0;
_709=-dims.width;
break;
case "bottom-left":
_707=_709=0;
_708=dims.height;
_70a=-dims.height;
break;
case "bottom-right":
_707=dims.width;
_708=dims.height;
_709=-dims.width;
_70a=-dims.height;
break;
case "center":
_707=dims.width/2;
_708=dims.height/2;
_709=-dims.width/2;
_70a=-dims.height/2;
break;
}
return new Effect.Move(_703,{x:_707,y:_708,duration:0.01,beforeSetup:function(_70b){
_70b.element.hide().makeClipping().makePositioned();
},afterFinishInternal:function(_70c){
new Effect.Parallel([new Effect.Opacity(_70c.element,{sync:true,to:1,from:0,transition:_704.opacityTransition}),new Effect.Move(_70c.element,{x:_709,y:_70a,sync:true,transition:_704.moveTransition}),new Effect.Scale(_70c.element,100,{scaleMode:{originalHeight:dims.height,originalWidth:dims.width},sync:true,scaleFrom:window.opera?1:0,transition:_704.scaleTransition,restoreAfterFinish:true})],Object.extend({beforeSetup:function(_70d){
_70d.effects[0].element.setStyle({height:"0px"}).show();
},afterFinishInternal:function(_70e){
_70e.effects[0].element.undoClipping().undoPositioned().setStyle(_705);
}},_704));
}});
};
Effect.Shrink=function(_70f){
_70f=$(_70f);
var _710=Object.extend({direction:"center",moveTransition:Effect.Transitions.sinoidal,scaleTransition:Effect.Transitions.sinoidal,opacityTransition:Effect.Transitions.none},arguments[1]||{});
var _711={top:_70f.style.top,left:_70f.style.left,height:_70f.style.height,width:_70f.style.width,opacity:_70f.getInlineOpacity()};
var dims=_70f.getDimensions();
var _713,_714;
switch(_710.direction){
case "top-left":
_713=_714=0;
break;
case "top-right":
_713=dims.width;
_714=0;
break;
case "bottom-left":
_713=0;
_714=dims.height;
break;
case "bottom-right":
_713=dims.width;
_714=dims.height;
break;
case "center":
_713=dims.width/2;
_714=dims.height/2;
break;
}
return new Effect.Parallel([new Effect.Opacity(_70f,{sync:true,to:0,from:1,transition:_710.opacityTransition}),new Effect.Scale(_70f,window.opera?1:0,{sync:true,transition:_710.scaleTransition,restoreAfterFinish:true}),new Effect.Move(_70f,{x:_713,y:_714,sync:true,transition:_710.moveTransition})],Object.extend({beforeStartInternal:function(_715){
_715.effects[0].element.makePositioned().makeClipping();
},afterFinishInternal:function(_716){
_716.effects[0].element.hide().undoClipping().undoPositioned().setStyle(_711);
}},_710));
};
Effect.Pulsate=function(_717){
_717=$(_717);
var _718=arguments[1]||{};
var _719=_717.getInlineOpacity();
var _71a=_718.transition||Effect.Transitions.sinoidal;
var _71b=function(pos){
return _71a(1-Effect.Transitions.pulse(pos,_718.pulses));
};
_71b.bind(_71a);
return new Effect.Opacity(_717,Object.extend(Object.extend({duration:2,from:0,afterFinishInternal:function(_71d){
_71d.element.setStyle({opacity:_719});
}},_718),{transition:_71b}));
};
Effect.Fold=function(_71e){
_71e=$(_71e);
var _71f={top:_71e.style.top,left:_71e.style.left,width:_71e.style.width,height:_71e.style.height};
_71e.makeClipping();
return new Effect.Scale(_71e,5,Object.extend({scaleContent:false,scaleX:false,afterFinishInternal:function(_720){
new Effect.Scale(_71e,1,{scaleContent:false,scaleY:false,afterFinishInternal:function(_721){
_721.element.hide().undoClipping().setStyle(_71f);
}});
}},arguments[1]||{}));
};
Effect.Morph=Class.create();
Object.extend(Object.extend(Effect.Morph.prototype,Effect.Base.prototype),{initialize:function(_722){
this.element=$(_722);
if(!this.element){
throw (Effect._elementDoesNotExistError);
}
var _723=Object.extend({style:""},arguments[1]||{});
this.start(_723);
},setup:function(){
function parseColor(_724){
if(!_724||["rgba(0, 0, 0, 0)","transparent"].include(_724)){
_724="#ffffff";
}
_724=_724.parseColor();
return $R(0,2).map(function(i){
return parseInt(_724.slice(i*2+1,i*2+3),16);
});
}
this.transforms=this.options.style.parseStyle().map(function(_726){
var _727=this.element.getStyle(_726[0]);
return $H({style:_726[0],originalValue:_726[1].unit=="color"?parseColor(_727):parseFloat(_727||0),targetValue:_726[1].unit=="color"?parseColor(_726[1].value):_726[1].value,unit:_726[1].unit});
}.bind(this)).reject(function(_728){
return ((_728.originalValue==_728.targetValue)||(_728.unit!="color"&&(isNaN(_728.originalValue)||isNaN(_728.targetValue))));
});
},update:function(_729){
var _72a=$H(),_72b=null;
this.transforms.each(function(_72c){
_72b=_72c.unit=="color"?$R(0,2).inject("#",function(m,v,i){
return m+(Math.round(_72c.originalValue[i]+(_72c.targetValue[i]-_72c.originalValue[i])*_729)).toColorPart();
}):_72c.originalValue+Math.round(((_72c.targetValue-_72c.originalValue)*_729)*1000)/1000+_72c.unit;
_72a[_72c.style]=_72b;
});
this.element.setStyle(_72a);
}});
Effect.Transform=Class.create();
Object.extend(Effect.Transform.prototype,{initialize:function(_730){
this.tracks=[];
this.options=arguments[1]||{};
this.addTracks(_730);
},addTracks:function(_731){
_731.each(function(_732){
var data=$H(_732).values().first();
this.tracks.push($H({ids:$H(_732).keys().first(),effect:Effect.Morph,options:{style:data}}));
}.bind(this));
return this;
},play:function(){
return new Effect.Parallel(this.tracks.map(function(_734){
var _735=[$(_734.ids)||$$(_734.ids)].flatten();
return _735.map(function(e){
return new _734.effect(e,Object.extend({sync:true},_734.options));
});
}).flatten(),this.options);
}});
Element.CSS_PROPERTIES=["azimuth","backgroundAttachment","backgroundColor","backgroundImage","backgroundPosition","backgroundRepeat","borderBottomColor","borderBottomStyle","borderBottomWidth","borderCollapse","borderLeftColor","borderLeftStyle","borderLeftWidth","borderRightColor","borderRightStyle","borderRightWidth","borderSpacing","borderTopColor","borderTopStyle","borderTopWidth","bottom","captionSide","clear","clip","color","content","counterIncrement","counterReset","cssFloat","cueAfter","cueBefore","cursor","direction","display","elevation","emptyCells","fontFamily","fontSize","fontSizeAdjust","fontStretch","fontStyle","fontVariant","fontWeight","height","left","letterSpacing","lineHeight","listStyleImage","listStylePosition","listStyleType","marginBottom","marginLeft","marginRight","marginTop","markerOffset","marks","maxHeight","maxWidth","minHeight","minWidth","opacity","orphans","outlineColor","outlineOffset","outlineStyle","outlineWidth","overflowX","overflowY","paddingBottom","paddingLeft","paddingRight","paddingTop","page","pageBreakAfter","pageBreakBefore","pageBreakInside","pauseAfter","pauseBefore","pitch","pitchRange","position","quotes","richness","right","size","speakHeader","speakNumeral","speakPunctuation","speechRate","stress","tableLayout","textAlign","textDecoration","textIndent","textShadow","textTransform","top","unicodeBidi","verticalAlign","visibility","voiceFamily","volume","whiteSpace","widows","width","wordSpacing","zIndex"];
Element.CSS_LENGTH=/^(([\+\-]?[0-9\.]+)(em|ex|px|in|cm|mm|pt|pc|\%))|0$/;
String.prototype.parseStyle=function(){
var _737=Element.extend(document.createElement("div"));
_737.innerHTML="<div style=\""+this+"\"></div>";
var _738=_737.down().style,_739=$H();
Element.CSS_PROPERTIES.each(function(_73a){
if(_738[_73a]){
_739[_73a]=_738[_73a];
}
});
var _73b=$H();
_739.each(function(pair){
var _73d=pair[0],_73e=pair[1],unit=null;
if(_73e.parseColor("#zzzzzz")!="#zzzzzz"){
_73e=_73e.parseColor();
unit="color";
}else{
if(Element.CSS_LENGTH.test(_73e)){
var _740=_73e.match(/^([\+\-]?[0-9\.]+)(.*)$/),_73e=parseFloat(_740[1]),unit=(_740.length==3)?_740[2]:null;
}
}
_73b[_73d.underscore().dasherize()]=$H({value:_73e,unit:unit});
}.bind(this));
return _73b;
};
Element.morph=function(_741,_742){
new Effect.Morph(_741,Object.extend({style:_742},arguments[2]||{}));
return _741;
};
["setOpacity","getOpacity","getInlineOpacity","forceRerendering","setContentZoom","collectTextNodes","collectTextNodesIgnoreClass","morph"].each(function(f){
Element.Methods[f]=Element[f];
});
Element.Methods.visualEffect=function(_744,_745,_746){
s=_745.gsub(/_/,"-").camelize();
effect_class=s.charAt(0).toUpperCase()+s.substring(1);
new Effect[effect_class](_744,_746);
return $(_744);
};
Element.addMethods();
Wagn=new Object();
function warn(_747){
if(typeof (console)!="undefined"){
console.log(_747);
}
}
Wagn.CardTable=$H({});
Object.extend(Wagn.CardTable,{get:function(key){
return this[key];
}});
Wagn.Dummy=Class.create();
Wagn.Dummy.prototype={initialize:function(num){
this.number=num;
}};
var Cookie={set:function(name,_74b,_74c){
var _74d="";
if(_74c!=undefined){
var d=new Date();
d.setTime(d.getTime()+(86400000*parseFloat(_74c)));
_74d="; expires="+d.toGMTString();
}
return (document.cookie=escape(name)+"="+escape(_74b||"")+_74d);
},get:function(name){
var _750=document.cookie.match(new RegExp("(^|;)\\s*"+escape(name)+"=([^;\\s]*)"));
return (_750?unescape(_750[2]):null);
},erase:function(name){
var _752=Cookie.get(name)||true;
Cookie.set(name,"",-1);
return _752;
},accept:function(){
if(typeof navigator.cookieEnabled=="boolean"){
return navigator.cookieEnabled;
}
Cookie.set("_test","1");
return (Cookie.erase("_test")==="1");
}};
Wagn.Messenger={element:function(){
return $("alerts");
},alert:function(_753){
this.element().innerHTML="<span style=\"color:red; font-weight: bold\">"+_753+"</span>";
new Effect.Highlight(this.element(),{startcolor:"#ffff00",endcolor:"#ffffaa",restorecolor:"#ffffaa",duration:1});
},note:function(_754){
this.element().innerHTML=_754;
new Effect.Highlight(this.element(),{startcolor:"#ffff00",endcolor:"#ffffaa",restorecolor:"#ffffaa",duration:1});
},log:function(_755){
this.element().innerHTML=_755;
new Effect.Highlight(this.element(),{startcolor:"#dddddd",endcolor:"#ffffaa",restorecolor:"#ffffaa",duration:1});
},flash:function(){
flash=$("notice").innerHTML+$("error").innerHTML;
if(flash!=""){
this.alert(flash);
}
}};
function openInNewWindow(){
var _756=window.open(this.getAttribute("href"),"_blank");
_756.focus();
return false;
}
function getNewWindowLinks(){
if(document.getElementById&&document.createElement&&document.appendChild){
var link;
var _758=document.getElementsByTagName("a");
for(var i=0;i<_758.length;i++){
link=_758[i];
if(/\bexternal\b/.exec(link.className)){
link.onclick=openInNewWindow;
}
}
objWarningText=null;
}
}
var DEBUGGING=false;
function copy_with_classes(_75a){
copy=document.createElement("span");
copy.innerHTML=_75a.innerHTML;
Element.classNames(_75a).each(function(_75b){
Element.addClassName(copy,_75b);
});
copy.hide();
_75a.parentNode.insertBefore(copy,_75a);
return copy;
}
Object.extend(Wagn,{user:function(){
return $("user");
},card:function(){
return Wagn.Card;
},lister:function(){
return Wagn._lister;
},messenger:function(){
return Wagn.Messenger;
},cardTable:function(){
return Wagn.CardTable;
},title_mouseover:function(_75c){
document.getElementsByClassName(_75c).each(function(elem){
Element.addClassName(elem,"card-highlight");
Element.removeClassName(elem,"card");
});
},title_mouseout:function(_75e){
document.getElementsByClassName(_75e).each(function(elem){
Element.removeClassName(elem,"card-highlight");
Element.addClassName(elem,"card");
});
},grow_line:function(_760){
var _761=Element.getDimensions(_760);
new Effect.BlindDown(_760,{duration:0.5,scaleFrom:100,scaleMode:{originalHeight:_761.height*2,originalWidth:_761.width}});
},line_to_paragraph:function(_762){
var _763=Element.getDimensions(_762);
copy=copy_with_classes(_762);
copy.removeClassName("line");
copy.addClassName("paragraph");
var _764=Element.getDimensions(copy);
copy.viewHeight=_764.height;
copy.remove();
var _765=100*_763.height/_764.height;
var _766=_764;
new Effect.BlindDown(_762,{duration:0.3,scaleFrom:_765,scaleMode:{originalHeight:_766.height,originalWidth:_766.width},afterSetup:function(_767){
_767.element.makeClipping();
_767.element.setStyle({height:"0px"});
_767.element.show();
_767.element.removeClassName("line");
_767.element.addClassName("paragraph");
}});
},paragraph_to_line:function(_768){
var _769=Element.getDimensions(_768);
copy=copy_with_classes(_768);
copy.removeClassName("paragraph");
copy.addClassName("line");
var _76a=Element.getDimensions(copy);
copy.remove();
var _76b=100*_76a.height/_769.height;
return new Effect.Scale(_768,_76b,{duration:0.3,scaleContent:false,scaleX:false,scaleFrom:100,scaleMode:{originalHeight:_769.height,originalWidth:_769.width},restoreAfterFinish:true,afterSetup:function(_76c){
_76c.element.makeClipping();
_76c.element.setStyle({height:"0px"});
_76c.element.show();
},afterFinishInternal:function(_76d){
_76d.element.undoClipping();
_76d.element.removeClassName("paragraph");
_76d.element.addClassName("line");
}});
}});
Wagn.highlight=function(_76e,id){
document.getElementsByClassName(_76e).each(function(elem){
Element.removeClassName(elem.id,"current");
});
Element.addClassName(_76e+"-"+id,"current");
};
Wagn.runQueue=function(_771){
if(typeof (_771)=="undefined"){
return true;
}
result=true;
while(fn=_771.shift()){
if(!fn.call()){
result=false;
}
}
return result;
};
Wagn.onLoadQueue=$A([]);
Wagn.onSaveQueue=$H({});
Wagn.onCancelQueue=$H({});
Wagn.editors=$H({});
onload=function(){
Wagn.Messenger.flash();
Wagn.runQueue(Wagn.onLoadQueue);
setupLinksAndDoubleClicks();
getNewWindowLinks();
setupDoubleClickToEdit();
if(typeof (init_lister)!="undefined"){
Wagn._lister=init_lister();
Wagn._lister.update();
}
};
setupLinksAndDoubleClicks=function(){
getNewWindowLinks();
setupDoubleClickToEdit();
};
setupDoubleClickToEdit=function(_772){
Element.getElementsByClassName(document,"createOnClick").each(function(el){
el.onclick=function(_774){
if(Prototype.Browser.IE){
_774=window.event;
}
element=Event.element(_774);
card_name=getSlotSpan(element).getAttributeNode("cardname").value;
new Ajax.Request("/transclusion/create?context="+getSlotContext(element),{asynchronous:true,evalScripts:true,parameters:"card[name]="+encodeURIComponent(card_name)});
Event.stop(_774);
};
});
Element.getElementsByClassName(document,"editOnDoubleClick").each(function(el){
el.ondblclick=function(_776){
if(Prototype.Browser.IE){
_776=window.event;
}
element=Event.element(_776);
span=getSlotSpan(element);
card_id=span.getAttributeNode("cardid").value;
if(Element.hasClassName(span,"line")){
new Ajax.Request("/card/to_edit/"+card_id+"?context="+getSlotContext(element),{asynchronous:true,evalScripts:true});
}else{
if(Element.hasClassName(span,"paragraph")){
new Ajax.Updater({success:span,failure:span},"/card/edit/"+card_id+"?context="+getSlotContext(element),{asynchronous:true,evalScripts:true});
}else{
new Ajax.Updater({success:span,failure:getNextElement(span,"notice")},"/transclusion/edit/"+card_id+"?context="+getSlotContext(element),{asynchronous:true,evalScripts:true});
}
}
Event.stop(_776);
};
});
};
getOuterSlot=function(_777){
var span=getSlotSpan(_777);
if(span){
outer=getOuterSlot(span.parentNode);
if(outer){
return outer;
}else{
return span;
}
}else{
return null;
}
};
getSlotFromContext=function(_779){
a=_779.split(":");
outer_context=a.shift();
element=$(outer_context);
element=$(outer_context);
while(a.size()>0){
pos=a.shift();
element=$A(document.getElementsByClassName("card-slot",element).concat(document.getElementsByClassName("transcluded",element).concat(document.getElementsByClassName("createOnClick",element)))).find(function(x){
ss=getSlotSpan(x.parentNode);
return (!ss||ss==element)&&x.getAttributeNode("position").value==pos;
});
}
return element;
};
getSlotElement=function(_77b,name){
var span=getSlotSpan(_77b);
return $A(document.getElementsByClassName(name,span)).reject(function(x){
return getSlotSpan(x)!=span;
})[0];
};
getNextElement=function(_77f,name){
var span=null;
if(span=getSlotSpan(_77f)){
if(e=$A(document.getElementsByClassName(name,span))[0]){
return e;
}else{
return getNextElement(span.parentNode,name);
}
}else{
return null;
}
};
getSlotContext=function(_782){
var span=null;
if(span=getSlotSpan(_782)){
var _784=span.getAttributeNode("position").value;
parentContext=getSlotContext(span.parentNode);
return parentContext+":"+_784;
}else{
return getOuterContext(_782);
}
};
getOuterContext=function(_785){
if(typeof (_785.getAttributeNode)!="undefined"&&_785.getAttributeNode("context")!=null){
return _785.getAttributeNode("context").value;
}else{
if(_785.parentNode){
return getOuterContext(_785.parentNode);
}else{
warn("Failed to get Outer Context");
return "page";
}
}
};
getSlotSpan=function(_786){
if(typeof (_786.getAttributeNode)!="undefined"&&_786.getAttributeNode("position")!=null){
return _786;
}else{
if(_786.parentNode){
return getSlotSpan(_786.parentNode);
}else{
return false;
}
}
};
Wadget=Class.create();
Object.extend(Wadget.prototype,{initialize:function(_787){
this._element=$(_787);
this._element.appendChild(document.createTextNode(""));
this.absolute_url_pattern="^(http://[^/]+)/.*$";
},show:function(url){
this.url=url;
this.base_href=this.url.match(this.absolute_url_pattern)[1];
warn("seeting base_href="+this.base_href);
var self=this;
if(url.match("html")){
url=url.gsub(".html",".json");
}else{
url+=".json";
}
this._dojo_args={url:url,transport:"ScriptSrcTransport",jsonParamName:"callback",load:function(type,data,evt,_78d){
self.onLoadCard(data);
},mimetype:"text/json",timeout:function(){
self.onFailure();
},timeoutSeconds:3};
dojo.io.bind(this._dojo_args);
return this;
},onFailure:function(){
err_msg="Sorry, "+this.url+" didn't return valid wadget data";
Element.replace(this._element.firstChild,err_msg);
},onLoadCard:function(data){
Element.replace(this._element.firstChild,data);
warn("base_href: "+this.base_href);
var self=this;
$A(this._element.getElementsByTagName("a")).each(function(e){
e.href=self.absolutize_url(e.getAttribute("href"));
});
$A(this._element.getElementsByTagName("img")).each(function(e){
e.src=self.absolutize_url(e.getAttribute("src"));
});
},is_relative:function(url){
return !url.match("^(http|ftp|https)://[^/]+");
},absolutize_url:function(url){
if(this.is_relative(url)){
return this.base_href+(url.match("^/")?"":"/")+url;
}else{
return url;
}
}});

