Include apptools.core

Class appmsw.cbrf.util [ Abstract ]
{

ClassMethod init() As %Status
{
	do ##class(Ens.Director).StartProduction("appmsw.cbrf.production")
    return $$$OK
}

/// do ##class(appmsw.cbrf.util).makeproject("d:\_proj\!\cbrf\src")
ClassMethod makeproject(dir = "d:\_proj\!\cbrf\") As %Status
{
	do ##class(apptools.core.code).exp(dir,"appmsw")
	set List("appmsw.cbrf.tabexDayD.GBL")=""
	set List("appmsw.cbrf.tabexD.GBL")=""
	s target=dir_$$$slash_"gbl"_$$$slash_"cbrf.xml"
	Write $SYSTEM.OBJ.Export(.List, target)
    return $$$OK
}

/// do ##class(appmsw.cbrf.util).initDb("2021-01-01","2021-01-10")
ClassMethod initDb(from = "2021-01-01", to = "2021-12-31") As %Status
{
	for h=$zdh(from,3):1:$zdh(to,3) {
		set Date=$zd(h,3) write !,Date
		do ##class(appmsw.cbrf.tabexDay).CheckDay(Date,.count)
		if $g(count) write " missed" continue
		set st=##class(appmsw.cbrf.tabexDay).LoadDay("http://www.cbr.ru/scripts/xml_daily.asp?date_req=",Date)
		if st {	write " loaded"
		}
	}
    return $$$OK
}

}

