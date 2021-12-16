<%@ page import="java.security.cert.X509Certificate" %>
<%@ page import="java.security.Principal" %>
<head><title>SSL JSP from <%=request.getServerName() %> </title></head>
<body>
<% X509Certificate certChain[] = (X509Certificate[]) request.getAttribute("javax.servlet.request.X509Certificate");
  if (certChain != null) {
    /* for debug ...
    for (int i = 0; i < certChain.length; i++) {
      out.println ("Client Certificate [" + i + "] = "
                      + certChain[i].toString());
    }
     */
    X509Certificate principalCert = certChain[0];
    Principal principal = principalCert.getSubjectDN();
    out.println ("Name: " + principal.getName());
  } else {
    out.println ("Fail no cert :-(");
  }

 %>
</body>
