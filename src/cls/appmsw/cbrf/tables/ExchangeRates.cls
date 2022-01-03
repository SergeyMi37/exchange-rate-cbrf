/// Daily Loading the Exchange rate of the Central Bank of the Russian Federation
Class appmsw.cbrf.tables.ExchangeRates Extends (%Persistent, %XML.Adaptor)
{

Property DateReq As %Date(FORMAT = 3);

Index DateReqIndex On DateReq;

Property DateExchangeRates As %String;

Property LastChanged As %String;

Property Date As %Date(FORMAT = 3, XMLNAME = "Date", XMLPROJECTION = "attribute");

Property ID As %String(XMLNAME = "ID", XMLPROJECTION = "attribute");

Property NumCode As %String(XMLNAME = "NumCode");

Property CharCode As %String(XMLNAME = "CharCode");

Property Name As %String(XMLNAME = "Name");

Property Nominal As %Integer(XMLNAME = "Nominal");

/// The value of the exchange rate against the ruble
Property Value As %String(XMLNAME = "Value");

Storage Default
{
<Data name="ExchangeRatesDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>DateReq</Value>
</Value>
<Value name="3">
<Value>LastChanged</Value>
</Value>
<Value name="4">
<Value>Date</Value>
</Value>
<Value name="5">
<Value>ID</Value>
</Value>
<Value name="6">
<Value>NumCode</Value>
</Value>
<Value name="7">
<Value>CharCode</Value>
</Value>
<Value name="8">
<Value>Name</Value>
</Value>
<Value name="9">
<Value>Nominal</Value>
</Value>
<Value name="10">
<Value>Value</Value>
</Value>
<Value name="11">
<Value>DateExchangeRates</Value>
</Value>
</Data>
<DataLocation>^appmsw.cbrfA329.ExchangeRatesD</DataLocation>
<DefaultData>ExchangeRatesDefaultData</DefaultData>
<IdLocation>^appmsw.cbrfA329.ExchangeRatesD</IdLocation>
<IndexLocation>^appmsw.cbrfA329.ExchangeRatesI</IndexLocation>
<StreamLocation>^appmsw.cbrfA329.ExchangeRatesS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

