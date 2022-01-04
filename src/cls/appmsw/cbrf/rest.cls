Include apptools.core

/// The REST interface: class that routes HTTP requests
Class appmsw.cbrf.rest Extends %CSP.REST
{

Parameter CONTENTTYPE = "application/json";

Parameter CHARSET = "UTF-8";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/a/:text" Method="GET" Call="apptools.lte.adminStatic:GetMain"/>
<Route Url="/post-json" Method="POST" Call="jsonrpc"/>
<Route Url="/testget/:text" Method="GET" Call="Test"/>  
<Route Url="/exchange/:date" Method="GET" Call="exchange"/>
</Routes>
}

ClassMethod Test(parameter) As %Status
{
	set %response.CharSet = "utf-8"
    set %response.ContentType = "text/html"
	&html<<h1>Status: OK!</h1><pre>>
	zw %request
	zw %response
	&html<</pre>>
	quit $$$OK
}

/// Search exchange rate by date
/// http://localhost:52774/cbrf-rate/exchange/2021-11-11,2021-11-12
ClassMethod exchange(date = "") As %Status
{
	set from=date
		,to=date
	if date["," {
		set from=$p(date,",",1)
		set to=$p(date,",",2)
	}
	;set sql="select * from appmsw_cbrf.tabex where DateExchangeRates >= '"_from_"' and DateExchangeRates <= '"_to_"'"
	set sql="select CharCode, DateExchangeRates, DateReq, LastChanged, Nominal, NumCode, Value from appmsw_cbrf.tabex where DateExchangeRates >= '"_from_"' and DateExchangeRates <= '"_to_"'"
	#if $$$comClassDefined("%ZEN.Auxiliary.jsonSQLProvider")
		set Provider = ##class(%ZEN.Auxiliary.jsonSQLProvider).%New()
		set Provider.sql = sql
		Set Provider.%Format = $$$formatJSONSQL
		Set Provider.maxRows = 10000
		set st = Provider.%DrawJSON()
	#else
		set st = $$$ERROR($$$GeneralError,"Class %ZEN.Auxiliary.jsonSQLProvider does not exist")
	#endif
	return st
}

/// post http://server:57772/rest/jsonrpc
/// {"jsonrpc":"2.0","method":"GetInfo","params":{"code":"5007092465"},"id":123}
ClassMethod jsonrpc(ns = "", class = "", meth = "") As %Status
{
	set sc = $$$OK
	try {
	 	;merge $$$AppL("MML","%request.Data")=%request.Data
		;set $$$AppL("MML","%request.AppData")=%request.AppData
		;set $$$AppL("MML","req")=$$$AppObJs(%request)
		;if %request.Get("Username")'="",'..Authorize(%request.Get("Username"),%request.Get("Password")) {
		; 	;set %response.Status = "401 Unauthorized" quit
		; 	d ..jsonrpcError(401,"Unauthorized "_%request.Content) 
		;}
		if $isobject(%request.Content) { //POST
			d %request.Content.Rewind() 
			set json=%request.Content.Read($$$MaxStringLength) 
			set json = $ZCVT(json,"I","UTF8") 
			;s $$$AppL("MML","jsonrpc-json")=json
	 		if ($g(json)["{") {
	 			set method={}.$$$jsonFromJSON(json).method
	 			set params={}.$$$jsonFromJSON(json).params
	 			set jsonrpc={}.$$$jsonFromJSON(json).jsonrpc
	 			set id={}.$$$jsonFromJSON(json).id
	 			if jsonrpc'="2.0" w ..jsonrpcError(2,"Version not supported "_jsonrpc) q
	 			s appPar=""
	 			if method[":" { 
	 				if $p(method,":",1)'="" s ns=$p(method,":",1)
					if $p(method,":",2)'="" s class=$p(method,":",2)
					if $p(method,":",3)'="" s meth=$p(method,":",3)
					if $p(method,":",4)'="" s appPar=$p(method,":",4,*)
				}
				if ns'="" zn ns
				if $e(class,1)="^" {
					do @(meth_class_"(.par,.json)") ;??? xec public 
				} else {
					if appPar["~" {
						do ##class(apptools.core.type).ParseURL(appPar,.appPar,"~")  ;parse in array
					}
					elseif appPar["&" {
						d ##class(apptools.core.type).ParseURL(appPar,.appPar,"&")
					}
				   ;set %response.CharSet = "utf-8"
    			;	set %response.ContentType = "text/html"
    				;s appPar("params")=params
    				if $isobject(params) {
	    				d ##class(apptools.core.Action).GetElemParseForm(params.form,.appPar,"z",0)
	    				s appPar("params")=params.%ToJSON()
    				}
    				do $classmethod(class,meth,.appPar) 
					quit
					/*
					if $isobject(params.form) {
	    				d ##class(apptools.core.Action).GetElemParseForm(params.form,.appPar,"z",0)
	    				do $classmethod(class,meth,.appPar) 
    				}
    				elseif $isobject(params) {
	    				do $classmethod(class,meth,.params) 
    				}
	    			else {
		    			;d ##class(apptools.core.Action).GetElemParseForm(params.form,.appPar,"z",0)
      					do $classmethod(class,meth,.appPar) 
	    			}
					quit */
				}
				;w "{""text"":""Hello world"",""inn"":"""_params.inn_"""}" q
				;w $ZCVT(str,"O","UTF8") 
				;w resjson
	 			
	 		}
		} else {
			;s $$$AppL("MML","%request")=$$$AppObJs(%request)
			;m $$$AppL("MML","%request.Data")=%request.Data
			;m $$$AppL("MML","%request.Content")=%request.Content
			;set $$$AppL("MML","%request.AppData")=%request.AppData
			 d ..jsonrpcError(3,"Bad request "_%request.Content)
			 q
		}
	} catch ex {
		set sc = ex.AsStatus()
		;s $$$AppL("MML","jsonrpc-err")=$System.Status.GetErrorText(sc)
		d ..jsonrpcError(4,"exception: "_$zconvert($System.Status.GetErrorText(sc),"O","HTML"))
	}
	return $$$OK
}

ClassMethod jsonrpcError(code, message) As %Status
{
	;w "{""jsonrpc"":""2.0"",""error"":{""code"":"""_code_""",""message"":"""_message_"""}}"
	Set json = $$$NewDynObj
 	s json.jsonrpc="2.0"
	s json.code=code
	s json.message=message
	$$$DynObjToJSON(json)
	q $$$OK
}

}

