/// Installer for the container release of PythonGateway
Class isc.py.util.Installer
{

XData Install [ XMLNamespace = INSTALLER ]
{
<Manifest>
  <Default Name="NAMESPACE" Value="PYTHON"/>
  <Default Name="DBNAME" Value="${NAMESPACE}"/>
  <Default Name="SOURCESPATH" Dir='#{$system.Util.GetEnviron("SRC_DIR")}' />
  <Default Name="RESOURCE" Value="%DB_${DBNAME}" /> 
  <Namespace Name="${NAMESPACE}" Code="${DBNAME}CODE" Data="${DBNAME}DATA" Create="yes" Ensemble="1">
    <Configuration>
      <Database Name="${DBNAME}CODE" Dir="${MGRDIR}${DBNAME}CODE" Create="yes" Resource="${RESOURCE}"/>
      <Database Name="${DBNAME}DATA" Dir="${MGRDIR}${DBNAME}DATA" Create="yes" Resource="${RESOURCE}"/>
    </Configuration>

    <Import File="${SOURCESPATH}isc" Recurse="1"/>
    <Import File="${SOURCESPATH}od" Recurse="1"/>
    <Import File="/usr/irissys/csp/python/index.csp"/>
    <Import File="/usr/irissys/csp/python/camera.csp"/>
    <Import File="/usr/irissys/csp/python/WorkFlowForm.csp"/>
    <Import File="/usr/irissys/csp/python/EscalatedWorkFlowForm.csp"/>


	<CSPApplication Url="/csp/${Namespace}" Directory="${CSPDIR}${Namespace}" />
    
    <Log Level="1" Text="Configuring Production"/>
    <Invoke Class="isc.py.util.Installer" Method="ConfigureProduction" CheckStatus="true"/>
 
    <Log Level="1" Text="Configuring Test Process"/>
    <Invoke Class="isc.py.util.Installer" Method="ConfigureTestProcess" CheckStatus="true"/>
	
    <Log Level="1" Text="Configuring BPL Editor"/>
    <Invoke Class="isc.py.util.Installer" Method="PatchBP" CheckStatus="true"/>
        
    <Log Level="1" Text="Enabling OS level Authentication"/>
    <Invoke Class="isc.py.util.Installer" Method="OSAuth" CheckStatus="true"/>
    
    <Log Level="1" Text="Loading %ZSTART, %ZLANGC00 routines"/>
    <Invoke Class="isc.py.util.Installer" Method="LoadZRoutines" CheckStatus="true">
    <Arg Value="${SOURCESPATH}rtn"/>
    </Invoke>

	<Log Level="1" Text="Enabling Analytics"/>
	<Invoke Class="isc.py.util.Installer" Method="EnableAnalytics" CheckStatus="true">
      <Arg Value="/csp/python/"/>
    </Invoke>

	<Log Level="1" Text="Configuring REST"/>
    <Invoke Class="isc.py.util.Installer" Method="CreateREST">
   <Arg Value="${NameSpace}"/>
   <Arg Value="/rest/imageod"/>
   <Arg Value="od.RestServer"/>
   </Invoke>

	<Log Level="1" Text="Configuring Workflow Rules"/>
    <Invoke Class="isc.py.util.Installer" Method="AddWorkflowRules"/>
    <Production Name="isc.py.test.Production"  AutoStart="1" />
  </Namespace>
</Manifest>
}


ClassMethod Setup(ByRef pVars, pLogLevel As %Integer = 3, pInstaller As %Installer.Installer, pLogger As %Installer.AbstractLogger) As %Status [ CodeMode = objectgenerator, Internal ]
{
  Quit ##class(%Installer.Manifest).%Generate(%compiledclass, %code, "Install")
}


/// Set production as default. 
/// Load test data
/// Set libpython3.6m.so as PythonLib
ClassMethod ConfigureProduction() As %Status
{
	set production = "isc.py.test.Production"
	set ^Ens.Configuration("csp","LastProduction") = production
	set sc = ##class(isc.py.test.CannibalizationData).Import()
	quit:$$$ISERR(sc) sc
	
	set setting = ##class(Ens.Config.Setting).%New()
	set setting.Name = "PythonLib"
	set setting.Target = "Host"
	set setting.Value = "libpython3.6m.so"

	set exists = ##class(Ens.Config.Item).NameExists(production, "isc.py.ens.Operation", .itemId)
	set item =  ##class(Ens.Config.Item).%OpenId(itemId)
	do item.Settings.Insert(setting)
	set sc = item.%Save()
	quit:$$$ISERR(sc) sc
	
		
	quit sc
}

/// Try to configure test Process.
/// set sc = ##class(isc.py.util.Installer).ConfigureTestProcess()
ClassMethod ConfigureTestProcess(user As %String = "Admin", password As %String = "SYS", host As %String = "localhost", port As %Integer = 51773, namespace As %String = {$namespace}) As %Status
{
	#include %occJava
	// Try to adjust default process
	set process = "isc.py.test.Process"
	set sc = ##class(%Compiler.UDL.TextServices).GetTextAsString(,process, .code)
	quit:$$$ISERR(sc) sc

	// JDBC	
	
	set sc = ##class(%Net.Remote.Service).GetJARDirectory("1.8", .jarDir)
	quit:$$$ISERR(sc) sc
	set jdbcJar = ##class(%File).NormalizeFilename($$$javaJDBCJAR, jarDir)
	set jdbcJar = ##class(%File).NormalizeFilenameWithSpaces(jdbcJar)
	
	set code = $replace(code, "[""dev"", ""123""]", $$$FormatText("[""%1"", ""%2""]", user, password)) // JDBC access
	set code = $replace(code, "/InterSystems/IRIS/dev/java/lib/JDK18/intersystems-jdbc-3.0.0.jar", jdbcJar) // JDBC Jar path
	set code = $replace(code, "jdbc:IRIS://localhost:51773/Python", $$$FormatText("jdbc:IRIS://%1:%2/%3", host, port, namespace)) // JDBC connection string
	
	/// ODBC
	if $$$isWINDOWS {
		set driver = "InterSystems ODBC35"
	} else {
		set driver = ##class(%File).NormalizeDirectory($System.Util.BinaryDirectory()) _ "libirisodbcu35.so"
	}
	set code = $replace(code, "DSN=ENSEMBLE(PYTHON);UID=dev;PWD=123", $$$FormatText("Driver=%1;Server=%2;Port=%3;database=%4;UID=%5;PWD=%6;" ,driver, host, port, namespace, user, password))
	
	set sc = ##class(%Compiler.UDL.TextServices).SetTextFromString(,process, .code)
	quit:$$$ISERR(sc) sc
	
	set sc = $system.OBJ.Compile(process, "ck")
	
	quit sc
}

/// Enable OS Authentication
ClassMethod OSAuth() As %Status
{
	new $namespace
	set $namespace = "%SYS"
	set sc = ##Class(Security.System).Get($$$SystemSecurityName,.properties)
	quit:$$$ISERR(sc) sc
	
	set autheEnabled = properties("AutheEnabled")
	quit:'$data(autheEnabled) $$$ERROR($$$PropertyDoesNotExist, "AutheEnabled")
	set properties("AutheEnabled") = $ZBOOLEAN(+autheEnabled, $$$AutheOS, 7)
	set sc = ##Class(Security.System).Modify($$$SystemSecurityName, .properties) 
	
	quit sc
}

ClassMethod LoadZRoutines(dir As %String) As %Status
{
	new $namespace
	set $namespace = "%SYS"
	
	set dir = ##class(%File).NormalizeDirectory(dir)
	set sc = $system.OBJ.ImportDir(dir, "*.xml", "c")
	quit sc
}

/// Add magnifying glass to Annotation
/// zw ##class(isc.py.util.Installer).PatchBP()
ClassMethod PatchBP() As %Status
{
	set class = "EnsPortal.BPLEditor"
	set patch = "<!-- PATCH -->"
	$$$QuitOnError(##class(%Compiler.UDL.TextServices).GetTextAsString(, class, .code))
	quit:$find(code, patch) $$$OK 
		
	set oldNS = $namespace
	new $namespace
	set $namespace = "%SYS"
	
	set db = ##class(SYS.Database).%OpenId($system.Util.ManagerDirectory() _ "enslib")
	set bk = db.ReadOnly
	set db.ReadOnly = 0 
	
	$$$QuitOnError(db.%Save())
	
	set $namespace = oldNS
	set line = "<textarea id=""aAnnotation"" label=""Annotation"" rows=""3"" cols=""35"" onchange=""zenPage.activityChange(1);"" onkeyup=""zenPage.textControlKeyUp(zenEvent,zenThis);"" onkeydown=""zenPage.textControlKeyDown(zenThis);""/>"
	set button = "<image src=""deepsee/zoom_16.png"" onclick=""zenPage.editPropertyValue('aAnnotation','code');"" title=""Edit value""/>"
	
	set code = $replace(code, line, line _ $$$NL _ patch _ button)
	
	$$$QuitOnError(##class(%Compiler.UDL.TextServices).SetTextFromString(, class, code))
	$$$QuitOnError($system.OBJ.Compile(class))
	
	set $namespace = "%SYS"
	
	set db.ReadOnly = bk 
	quit db.%Save()
}

ClassMethod CreateREST(namespace2 As %String, url As %String, dispatch As %String) As %Status
{
	#dim sc As %Status = $$$OK
    new $namespace
    set $namespace = "%SYS"
    if '##class(Security.Applications).Exists(url) {
        set props("AutheEnabled") = $$$AutheCache
        set props("NameSpace") = "PYTHON"
        set props("IsNameSpaceDefault") = $$$NO
        set props("DispatchClass") = dispatch
        set props("MatchRoles")=":" _ $$$AllRoleName
        set sc = ##class(Security.Applications).Create(url, .props)
    }
    quit sc
}

ClassMethod EnableAnalytics(pCSPName As %String, url As %String) As %Status
{
  new $namespace
  znspace "%SYS"
  set props("DeepSeeEnabled")=1
  do ##class(Security.Applications).Modify(pCSPName,.props)
  quit $$$OK
 }

ClassMethod AddWorkflowRules() As %Status
{
    do ##class(EnsLib.Workflow.UserDefinition).CreateUser("SuperUser","SU Account")
	do ##class(EnsLib.Workflow.RoleDefinition).CreateRole("OrderTeam")
	do ##class(EnsLib.Workflow.RoleDefinition).AddUserToRole("OrderTeam","SuperUser")
 }

   
 


}
