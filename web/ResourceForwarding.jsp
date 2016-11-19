<%-- 
    Document   : ResourceForwarding
    Created on : Oct 25, 2016, 11:17:21 PM
    Author     : Harsh
--%>

<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Savepoint"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
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
        <title>ERPiMaC - Forward Resource</title>
        <jsp:include page="WEB-INF/jspf/Header.jspf"/>
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
                <input type="submit" class="flatbutton roundedBoundsNoFocus" value="Add" name="add" />
                <input type="submit" class="flatbutton roundedBoundsNoFocus" value="Clear" name="clear" />
            </form>
            <form method="post">
                <table style="float: none; margin: auto; width: 128px;">
                    <c:forEach var="current" items="${codes}">
                        <tr>
                            <td class="labelcell"><c:out value="${current}" /><span style="font-size: 16px">&nbsp;×</span></td>
                            <td><input type="text" name="${current}" class="roundedBounds" style="width: 64px;" placeholder="#" /></td>
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
                    String error = "";
                    DriverManager.registerDriver(new org.apache.derby.jdbc.ClientDriver());
                    try (Connection con = DriverManager.getConnection("jdbc:derby://localhost:1527/erpimac", "erpimac", "erpimac")) {
                        ArrayList params = getCodeParameters(request);
                        for (Object p : params) {
                            String key = (String) p;
                            con.setAutoCommit(false);
                            Savepoint here = con.setSavepoint();
                            try (PreparedStatement upd = con.prepareStatement("update INVENTORY set quantity = quantity - ? where code = ?")) {
                                int quantity = Integer.parseInt(request.getParameter(key));
                                if (quantity > 0) {
                                    upd.setInt(1, quantity);
                                    upd.setString(2, key);
                                    upd.executeUpdate();
                                    try (PreparedStatement get = con.prepareStatement("select price from INVENTORY where code = ?")) {
                                        get.setString(1, key);
                                        ResultSet set = get.executeQuery();
                                        if (set.next()) {
                                            double ppu = set.getDouble(1);
                                            try (PreparedStatement log = con.prepareStatement("insert into INVLOG values(?,?,?,?,?)")) {
                                                log.setString(1, key);
                                                log.setString(2, "fwd");
                                                log.setTimestamp(3, java.sql.Timestamp.from(java.time.Instant.now()));
                                                log.setInt(4, -quantity);
                                                log.setDouble(5, ppu);
                                                log.executeUpdate();
                                                request.setAttribute("done", true);
                                            } catch (SQLException ex) {
                                                throw ex;
                                            }
                                        }
                                    } catch (SQLException ex) {
                                        throw ex;
                                    }
                                } else {
                                    error += "Quantity cannot be null or negative, " + key + ".\n";
                                }
                            } catch (SQLException ex) {
                                con.rollback(here);
                                throw ex;
                            } finally {
                                con.releaseSavepoint(here);
                                con.setAutoCommit(true);
                            }
                        }
                    } catch (SQLException ex) {
                        String s = ex.toString();
                        if (s.contains("java.sql.SQLIntegrityConstraintViolationException")) {
                            s = "INV Item already exists";
                        }
                        request.setAttribute("sqlError", s);
                    }
                    request.setAttribute("error", error);
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
            <c:if test="${not empty sqlError}">
                <script>
                    (function() {
                        var error = "<%=request.getAttribute("sqlError")%>";
                        if (error !== 'null')
                            log.innerText = (log.innerText + "\n" + error).trim();
                    })();
                </script>
            </c:if>
            <c:if test="${not empty error}">
                <script>
                    (function() {
                        var error = "<%=request.getAttribute("error")%>";
                        if (error !== 'null')
                            log.innerText = (log.innerText + "\n" + error).trim();
                    })();
                </script>
            </c:if>
            <c:if test="${not empty done}">
                <script>
                    (function() {
                        var error = "<%=request.getAttribute("done")%>";
                        if (error !== 'null')
                            log.innerText = error.trim();
                    })();
                </script>
            </c:if>
        </div>
    </body>
</html>
