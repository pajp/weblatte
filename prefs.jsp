<%@ page language='java' import='nu.dll.lyskom.*' %>
<%@ page pageEncoding='iso-8859-1' contentType='text/html; charset=utf-8' %>
<%@ include file='kom.jsp' %>
<%!
    void printBlockPrefs(JspWriter out, String blockName, KomPreferences block)
    throws IOException {
	List pmds = (List) PreferencesMetaData.getInstance().blocks.get(blockName);
	out.println("<input type=\"hidden\" name=\"saveBlock\" value=\"" + blockName + "\">");
	out.println("<table>");
	for (Iterator i = pmds.iterator(); i.hasNext();) {
	    PreferenceMetaData pmd = (PreferenceMetaData) i.next();
	    out.print("<tr>");
	    out.print("<td>" + pmd.description + "</td>");
	    out.print("<td>");
	    if (pmd.type.equals("boolean")) {
		out.print("<select name=\"" + pmd.key + "\">");
		out.print("<option value=\"1\" " + 
			(block.getBoolean(pmd.key) ? "selected" : "") +
			">P�</option>");
		out.print("<option value=\"0\" " + 
			(!block.getBoolean(pmd.key) ? "selected" : "") +
			">Av</option>");
	    } else if (pmd.type.equals("integer")) {
	        out.println("<input type=\"text\" size=\"5\" value=\"" +
	            block.getInt(pmd.key) + "\" name=\"" + 
	            pmd.key + "\" />");
	    } else if (pmd.type.equals("single-select")) {
	        out.println("<select name=\"" + pmd.key + "\">");
	        for (int j=0; j < pmd.alternatives.length; j++) {
	    	    out.print("<option ");
		    if (block.getString(pmd.key).toLowerCase().equals(pmd.alternatives[j].toLowerCase())) {
			out.print("selected ");
		    }
		    out.print("value=\"" + pmd.alternatives[j] + "\">");
		    out.print(pmd.alternatives[j]);
		    out.println("</option>");
	        }
		out.println("</select>");
	    } else {
		out.println("<i class=\"statusError\">Fel: ok�nd datatyp \"" + pmd.type + "\".</i>");
	    }
	    out.print("</td>");
	    out.println("</tr>");
	}
	out.println("<tr><td colspan=\"2\">" +
		"<input type=\"submit\" value=\"Spara �ndringar\"></td></tr>");
	out.println("</table>");
    }
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <link rel="stylesheet" href="lattekom.css" />
    <title>Inst�llningar</title>
  </head>
  <body>
<%
    if (lyskom == null) {
	session.setAttribute("goto", myURI(request) + (request.getQueryString() != null ? "?"+request.getQueryString() : ""));
	response.sendRedirect(basePath);
	return;
    }
    if (request.getParameter("clearUserArea") != null) {
	int oldUserAreaTextNo = lyskom.getMyPerson().getUserArea();
	lyskom.setUserArea(0);
	clearPreferenceCache(lyskom);
	out.println("<div class=\"statusSuccess\">User-Area nollst�lld!" + 
	" (var: " + oldUserAreaTextNo + ")</div>");
	out.flush();
    }
%>
<%@ include file='prefs_inc.jsp' %>
<%

    if (request.getParameter("saveBlock") != null) {
	String blockName = request.getParameter("saveBlock");
	Enumeration parameterNames = request.getParameterNames();
	KomPreferences block = blockName.equals("common") ? commonPreferences : preferences;

	while (parameterNames.hasMoreElements()) {
	    String parameterName = (String) parameterNames.nextElement();
	    if (!PreferencesMetaData.getInstance().containsKey(blockName, parameterName)) {
		continue;
	    }
	    block.set(parameterName, request.getParameter(parameterName));
	}
	userArea.setBlock(blockName, block.getData());

	try {
	    lyskom.saveUserArea(userArea);
	    clearPreferenceCache(lyskom);
	    response.sendRedirect(myURI(request) + "?status=ok&block=" + blockName);
	} catch (RpcFailure ex1) {
	    ex1.printStackTrace();
	    response.sendRedirect(myURI(request) + "?status=err&error=" +
		ex1.getError() + "&err-stat=" + ex1.getErrorStatus());
        }
	return;
    }
%>
<%
    if (request.getParameter("status") != null) {
	String status = request.getParameter("status");
	if (status.equals("ok")) {
	    out.println("<div class=\"statusSuccess\">OK: inst�llningarna har sparats.</div>");
	} else {
	    out.println("<div class=\"statusError\">Fel: felkod " + request.getParameter("error") + "</div>");
	}
     }
     if (Debug.ENABLED) {
	out.println("<div>Inst�llningar fr�n user-area-text " + (userArea.getTextNo() != 0 ? textLink(request, lyskom, userArea.getTextNo()) : "0") + "</div>");
     }
%>
    <form method="post" class="boxed">
	<b>Gemensamma inst�llningar</b>
	<div>Inst�llningar i denna kategori kan p�verka �ven andra
	   LysKOM-klienter, till exempel elisp-klienten.</div>
	<%
	    printBlockPrefs(out, "common", commonPreferences);
	%>
    </form>
    <br/>
    <form method="post" class="boxed">
	<b>Inst�llningar f�r WebLatte</b>
	<div>Inst�llningar i denna kategori g�ller enbart Weblatte</div>
	<%
	    printBlockPrefs(out, "weblatte", preferences);
	%>
    </form>
    <form method="post" class="boxed">
	<b>T�m anv�ndararea</b>
	<div>Denna funktion nollst�ller anv�ndararean (user-area) p� servern
	   s� att alla inst�llningar �terf�r sitt standardv�rde. Notera att
           detta �ven g�ller inst�llningar specifika f�r andra klienter som
           lagrats p� servern.
	</div>
	<input type="submit" name="clearUserArea" value="T�m User-Area"
	 onClick="return confirm('Vill du verkligen nollst�lla _alla_ klientinst�llningar lagrade p� servern?');">
    </form>
    <br />
    >> <a href="<%= basePath %>">�ter till huvudsidan</a><br/>
  </body>
</html>
