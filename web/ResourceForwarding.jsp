<%-- 
    Document   : AddInventory
    Created on : Oct 25, 2016, 11:17:21 PM
    Author     : Harsh
--%>

<%@page import="java.util.Enumeration"%>
<%@page import="java.util.Collections"%>
<%@page import="java.util.LinkedList"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="java.util.ArrayList"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%!
    ArrayList getCodeParameters(HttpServletRequest request) {
        Enumeration<String> e = request.getParameterNames();
        ArrayList list = new ArrayList();
        while (e.hasMoreElements()) {
            String param = e.nextElement();
            if (param.matches("[A-Z]{2,}[0-9]{4,}")) {
                list.add(param);
            }
        }
        return list;
    }

    ArrayList getClearParameters(HttpServletRequest request) {
        Enumeration<String> e = request.getParameterNames();
        ArrayList list = new ArrayList();
        while (e.hasMoreElements()) {
            String param = e.nextElement();
            if (param.matches("[A-Z]{2,}[0-9]{4,}clear")) {
                list.add(param);
            }
        }
        return list;
    }
%>
<%
    ArrayList codes, paramcodes = getCodeParameters(request);
    if (getServletContext().getAttribute("codes") != null) {
        codes = (ArrayList) getServletContext().getAttribute("codes");
    } else {
        codes = new ArrayList();
    }
    getServletContext().setAttribute("codes", codes);
    if (request.getParameter("add") != null) {
        String toAdd = request.getParameter("inv_id");
        if (toAdd != null) {
            if (toAdd.length() == 0) {
                request.setAttribute("addError", "Cannot add, Invalid code specified: '" + toAdd + "'");
            } else if (!codes.contains(toAdd)) {
                codes.add(toAdd);
            } else {
                request.setAttribute("addError", "Cannot add, already added!");
            }
        }
    } else if ((paramcodes = getClearParameters(request)).size() != 0) {
        for (Object s : paramcodes) {
            String id = (String) s;
            codes.remove(id.substring(0, id.indexOf("clear")));
        }
    } else if (request.getParameter("clear") != null) {
        codes.clear();
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="erpimac.css" />
        <title>Forward Resource</title>
        <jsp:include page="Header.jspf"/>
        <script>
            function onbodyload() {
                if (<%=request.getParameter("forward") != null%>) {
                    var val = "<%=request.getParameter("inv_id")%>";
                    inv_id.value = (val !== 'null') ? val : "";
                }
            }
        </script>
    </head>
    <%--366FB4--%>
    <body style="font-family: Renogare;" onload="onbodyload()">
        <div style="text-align: center; padding-left: 64px; padding-right: 64px; padding-top: 16px; padding-bottom: 16px; color: black">
            <h3>Select the Code and Quantity of resources to forward</h3>
            <form id="add_form" method="post">
                <span class="labelcell">INV Code</span>
                <input type="text" id="inv_id" class="roundedBounds" name="inv_id" placeholder="XX####" />
                <input type="submit" class="flatbutton" value="Add" name="add" />
                <input type="submit" class="flatbutton" value="Clear" name="clear" />
            </form>
            <form method="post">
                <table style="float: none; margin: auto; width: 128px;">
                    <c:forEach var="current" items="${codes}">
                        <tr>
                            <td class="labelcell"><c:out value="${current}" /><span style="font-size: 16px">&nbsp;×</span></td>
                            <td><input type="text" name="${current}" class="roundedBounds" style="width: 64px;" name="inv_quantity" placeholder="#" /></td>
                            <td><input type="submit" class="flatbutton" name="${current}clear" value="×"/></td>
                        </tr>
                    </c:forEach>
                </table>
                <table style="float: none; margin: auto; width: 345px;">
                    <tr style="height: 16px;"></tr>
                    <tr>
                        <td colspan="3">
                            <button type="submit" name="forward" class="flatbutton">Forward Resource</button>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="3">
                            <label id="log" style="font-family: Arial; color: #ff6666; font-size: 12px;"/>
                        </td>
                    </tr>
                </table>
            </form>
            <%
                if (request.getParameter("forward") != null) {
                    //To-do forwarding module here
                }
            %>
            <c:if test="${not empty codeError}">
                <script>
                    (function() {
                        var error = "<%=request.getAttribute("codeError")%>";
                        if (error !== 'null')
                            log.innerText = error;
                    })();
                </script>
            </c:if>
            <c:if test="${not empty quantityError}">
                <script>
                    (function() {
                        var error = "<%=request.getAttribute("quantityError")%>";
                        if (error !== 'null')
                            log.innerText = (log.innerText + "\n" + error).trim();
                    })();
                </script>
            </c:if>
            <c:if test="${not empty addError}">
                <script>
                    (function() {
                        var error = "<%=request.getAttribute("addError")%>";
                        if (error !== 'null')
                            log.innerText = (log.innerText + "\n" + error).trim();
                    })();
                </script>
            </c:if>
        </div>
    </body>
</html>
