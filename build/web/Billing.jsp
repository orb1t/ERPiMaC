<%-- 
    Document   : Billing
    Created on : Oct 26, 2016, 2:53:23 PM
    Author     : Harsh
--%>

<%@page import="java.util.SortedMap"%>
<%@page import="javax.servlet.jsp.jstl.sql.Result"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Timestamp"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Savepoint"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@page import="org.joda.time.Instant"%>
<%@page import="org.joda.time.Days"%>
<%@page import="org.joda.time.DateTime"%>
<%@page import="java.util.Date"%>
<%@page import="java.util.GregorianCalendar"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="erpimac.css" />
        <title>ERPiMaC - Inventory Bill</title>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/1.3.2/jspdf.debug.js"></script>
        <jsp:include page="WEB-INF/jspf/Header.jspf"/>
        <script>
            function onbodyload() {
                try {
                    var fromdate = '<%=request.getParameter("from")%>'.split(/[-| |\:]/);
                    inv_day[parseInt(fromdate[2]) - 1].selected = 'selected';
                    inv_month[parseInt(fromdate[1]) - 1].selected = 'selected';
                    inv_year[new Date().getFullYear() - parseInt(fromdate[0])].selected = 'selected';
                    fromdate = '<%=request.getParameter("to")%>'.split('-');
                    inv_to_day[parseInt(fromdate[2]) - 1].selected = 'selected';
                    inv_to_month[parseInt(fromdate[1]) - 1].selected = 'selected';
                    inv_to_year[new Date().getFullYear() - parseInt(fromdate[0])].selected = 'selected';
                    invcode.value = '<%=request.getParameter("code")%>';
                } catch (e) {
                }
            }
            function update() {
                inv_form.value = inv_year.value + '-' + inv_month.value + '-' + inv_day.value + " 12:00:00";
                inv_to_form.value = inv_to_year.value + '-' + inv_to_month.value + '-' + inv_to_day.value + " 12:00:00";
                form.submit();
            }
        </script>
    </head>
    <sql:setDataSource url="jdbc:derby://localhost:1527/erpimac" user="erpimac" password="erpimac" var="erpimacdb" driver="org.apache.derby.jdbc.ClientDriver"/>
    <body onload="onbodyload()">
        <div style="text-align: center; padding-left: 64px; padding-right: 64px; padding-top: 16px; padding-bottom: 16px; color: black">
            <form id="form" method="post">
                <h3>Please enter the time duration and select item codes to generate bill</h3>
                <table style="float: none; margin: auto;">
                    <tr>
                        <td class="labelcell">From Date</td><td style="width: 32px;" />
                        <td class="contentcell roundedBoundsNoFocus">
                            Day&nbsp;&nbsp;<select type="select" id="inv_day" class="dropdown"></select>
                            Month&nbsp;<select type="select" id="inv_month" class="dropdown"></select>
                            Year&nbsp;&nbsp;<select type="select" id="inv_year" class="dropdown"></select>
                            <input id="inv_form" name="from" type="hidden" />
                        </td>
                    </tr>
                    <tr>
                        <td class="labelcell">To Date</td><td style="width: 32px;" />
                        <td class="contentcell roundedBoundsNoFocus">
                            Day&nbsp;&nbsp;<select type="select" id="inv_to_day" class="dropdown"></select>
                            Month&nbsp;<select type="select" id="inv_to_month" class="dropdown"></select>
                            Year&nbsp;&nbsp;<select type="select" id="inv_to_year" class="dropdown"></select>
                            <input id="inv_to_form" name="to" type="hidden" />
                        </td>
                    </tr>
                    <tr>
                        <td class="labelcell">INV Code</td><td />
                        <td class="contentcell roundedBoundsNoFocus">
                            <sql:query dataSource="${erpimacdb}" var="INVCodes">
                                select code from INVENTORY
                            </sql:query>
                            <select id="invcode" name="code" class="dropdown" style="width: calc(100% + 2px);">
                                <c:forEach var="row" items="${INVCodes.rows}">
                                    <option label="${row.code}" value="${row.code}" />
                                </c:forEach>
                            </select>
                        </td>
                    </tr>
                    <tr style="height: 16px;"></tr>
                    <tr>
                        <td colspan="3">
                            <button class="flatbutton" name="bill" onclick="update()">Generate Bill</button>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="3">
                            <label id="log" style="font-family: Arial; color: #ff6666; font-size: 12px;"/>
                        </td>
                    </tr>
                </table>
                <script>
                    function option(id, text) {
                        var option = document.createElement("option");
                        option.innerHTML = text;
                        id.appendChild(option);
                    }
                    (function() {
                        for (var i = 1; i <= 31; i++) {
                            option(inv_day, i + "");
                            option(inv_to_day, i + "");
                        }
                        for (var i = 1; i <= 12; i++) {
                            option(inv_month, i + "");
                            option(inv_to_month, i + "");
                        }
                        var year = new Date().getFullYear();
                        for (var i = year; i >= year - 10; i--) {
                            option(inv_year, i + "");
                            option(inv_to_year, i + "");
                        }
                    })();
                </script>
            </form>
            <%!
                boolean chainAttribute(boolean previous, HttpServletRequest request, String name, String value) {
                    request.setAttribute(name, value);
                    request.setAttribute("errorFlag", true);
                    return previous && false;
                }
            %>
            <%
                try {
                    String code = request.getParameter("code");
                    boolean noerror = true;
                    if (code != null && code.length() == 0) {
                        noerror = chainAttribute(noerror, request, "codeError", "No code specified.");
                    } else if (code != null && !code.matches("[A-Z]{2,}[0-9]{4,}")) {
                        noerror = chainAttribute(noerror, request, "codeError", "Invalid code specified: '" + code + "'");
                    }
                    String fromStr = request.getParameter("from");
                    String toStr = request.getParameter("to");
                    Date from = null, to = null;
                    int[] fromValues = new int[6], toValues = new int[6];
                    try {
                        String[] split = fromStr.split("-| |:");
                        for (int i = 0; i < 6; i++) {
                            fromValues[i] = Integer.parseInt(split[i]);
                        }
                        from = new Date(fromValues[0] - 1900, fromValues[1] - 1, fromValues[2], fromValues[3], fromValues[4], fromValues[5]);
                    } catch (Exception e) {
                        if (fromStr != null) {
                            noerror = chainAttribute(noerror, request, "fromError", "Invalid date specified: '" + ((fromStr == null) ? "" : fromStr) + "'");
                        }
                    }
                    try {
                        String[] split = toStr.split("-| |:");
                        for (int i = 0; i < 6; i++) {
                            toValues[i] = Integer.parseInt(split[i]);
                        }
                        to = new Date(toValues[0] - 1900, toValues[1] - 1, toValues[2], toValues[3], toValues[4], toValues[5]);
                    } catch (Exception e) {
                        if (toStr != null) {
                            noerror = chainAttribute(noerror, request, "toError", "Invalid date specified: '" + ((toStr == null) ? "" : toStr) + "'");
                        }
                    }
                    if (from != null && to != null) {
                        if (Days.daysBetween(new DateTime(from), new DateTime(to)).getDays() <= 0) {
                            noerror = chainAttribute(noerror, request, "diffError", "INV From date should precede the INV To date.");
                        }
                    }
                    if (noerror) {
                        DriverManager.registerDriver(new org.apache.derby.jdbc.ClientDriver());
                        try (Connection con = DriverManager.getConnection("jdbc:derby://localhost:1527/erpimac", "erpimac", "erpimac")) {
                            con.setAutoCommit(false);
                            Savepoint s = con.setSavepoint();
                            try (PreparedStatement ins = con.prepareStatement("select * from INVLOG where date >= ? and date <= ? and code = ?")) {
                                Timestamp fromTimestamp = new Timestamp(fromValues[0], fromValues[1], fromValues[2], fromValues[3], fromValues[4], fromValues[5], 0);
                                Timestamp toTimestamp = new Timestamp(toValues[0], toValues[1], toValues[2], toValues[3], toValues[4], toValues[5], 0);
                                ins.setTimestamp(1, fromTimestamp);
                                ins.setTimestamp(2, toTimestamp);
                                ins.setString(3, code);
                                ResultSet rows = ins.executeQuery();
                                while (rows.next()) {
                                    String _code = rows.getString(1);
                                    String _action = rows.getString(2);
                                    double _price = rows.getInt(4) * rows.getDouble(5);
                                }
                            } catch (SQLException ex) {
                                con.rollback(s);
                                throw ex;
                            } finally {
                                con.setAutoCommit(true);
                            }
                            try (PreparedStatement ins = con.prepareStatement("select NAME from INVENTORY where code = ?")) {
                                ins.setString(1, code);
                                ResultSet resultSet = ins.executeQuery();
                                if (resultSet.next()) {
                                    request.setAttribute("name", resultSet.getString(1));
                                }
                            } catch (SQLException e) {
                                request.setAttribute("name", "Error fetching name." + e.getMessage());
                            }
                        }
            %>
            <sql:setDataSource url="jdbc:derby://localhost:1527/erpimac" user="erpimac" password="erpimac" var="erpimacdb" driver="org.apache.derby.jdbc.ClientDriver"/>
            <sql:query dataSource="${erpimacdb}" var="logs">
                select action, date, quantity, price, quantity * price as tprice from INVLOG
                where date >= ? and date <= ? and code = ? and (quantity != 0 or action = 'add')
                order by date
                <sql:param value="${param.from}" />
                <sql:param value="${param.to}" />
                <sql:param value='${param.code}' />
            </sql:query>
            <c:if test="${not (logs.rowCount eq 0)}">
                <div id='bill'>
                    <script>
                        form.style.display = 'none';
                        collapseHeader();
                        function printDiv(divName) {
                            document.getElementById('print').style.display = 'none';
                            var printContents = document.getElementById(divName).innerHTML;
                            w = window.open();
                            w.document.write(printContents);
                            w.document.write('<scr' + 'ipt type="text/javascript">' + 'window.onload = function() { window.print(); window.close(); };' + '</sc' + 'ript>');
                            w.document.close(); // necessary for IE >= 10
                            w.focus(); // necessary for IE >= 10
                            document.getElementById('print').style.display = 'inline';
                            return true;
                        }
                    </script>
                    <button id="print" class="flatbutton" style="float: right; display: inline-block;" onclick="printDiv('bill')">
                        <svg style="width: 14px;height: 14px; vertical-align: sub;" viewBox="0 0 24 24">
                        <path fill="#366fb4" d="M18,3H6V7H18M19,12A1,1 0 0,1 18,11A1,1 0 0,1 19,10A1,1 0 0,1 20,11A1,1 0 0,1 19,12M16,19H8V14H16M19,8H5A3,3 0 0,0 2,11V17H6V21H18V17H22V11A3,3 0 0,0 19,8Z" />
                        </svg>
                        Print Bill
                    </button>
                    <button id="back" class="flatbutton" style="float: left;" onclick="restoreHeader()">
                        <svg style="width: 14px;height: 14px; vertical-align: sub;" viewBox="0 0 24 24">
                        <path fill="#000000" d="M21,11H6.83L10.41,7.41L9,6L3,12L9,18L10.41,16.58L6.83,13H21V11Z" />
                        </svg>
                        Back
                    </button><br />
                    <h4>Bill for item ${param.code}</h4>
                    <h5>${name}</h5>
                    <div style="overflow-y: auto;">
                        <table style="margin: auto; font-family: Segoe UI; font-size: 12px;">
                            <thead style="font-family: Renogare; font-size: 12px;">
                            <th>Action Type</th>
                            <th>Date</th>
                            <th>Quantity</th>
                            <th>Price per Unit</th>
                            <th>Amount</th>
                            </thead>
                            <tr style="background-color:  #999999; height: 2px; margin-left: 4px; margin-right: 4px;"><td colspan="5"></td></tr>
                            <c:set var="billtotal" value="0.0"></c:set>
                            <c:forEach var="row" items="${logs.rows}">
                                <tr>
                                    <%
                                        SortedMap row = (SortedMap) pageContext.getAttribute("row");
                                    %>
                                    <td style="font-family: Renogare; font-size: 12px; padding: 4px; text-align: left;">
                                        <c:choose>
                                            <c:when test="${row.action eq 'upd'}">
                                                <span style="color: #6699ff">UPDATE</span>
                                            </c:when>
                                            <c:when test="${row.action eq 'add'}">
                                                <span style="color: #66cc00">ADD</span>
                                            </c:when>
                                            <c:when test="${row.action eq 'fwd'}">
                                                <span style="color: #ff6666">FORWARD</span>
                                            </c:when>
                                        </c:choose>
                                    </td>
                                    <td>${row.date.year + 1900} 
                                        <%! String[] months = {"JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"};%>
                                        <%= months[((Timestamp) row.get("date")).getMonth()]%>
                                        ${row.date.date}
                                    </td>
                                    <td style="text-align: right; padding-right: 8px; font-family: Consolas;">${row.quantity}</td>
                                    <td style="text-align: right; padding-right: 8px; font-family: Consolas;"><span style="float: left; font-size: 14px; padding-left: 8px;">₹</span>${row.price}</td>
                                    <td style="text-align: right; padding-right: 8px; font-family: Consolas;">
                                        <c:if test="${row.tprice eq 0.0}">
                                            <span style='color: #66cc00; font-family: Renogare;'>INITIAL</span>
                                        </c:if>
                                        <c:if test="${not (row.tprice eq 0.0)}">
                                            ${row.tprice}
                                        </c:if>
                                    </td>
                                    <c:set var="billtotal" value="${billtotal + row.tprice}" />
                                </tr>
                            </c:forEach>
                            <tr style="background-color:  #999999; height: 2px; margin-left: 4px; margin-right: 4px;"><td colspan="5"></td></tr>
                            <tr>
                                <td colspan="4" style="text-align: right; font-family: Renogare; padding-right: 8px;">Total : </td>
                                <td style="font-family: Consolas; padding-right: 8px;">${billtotal}</td>
                            </tr>
                        </table>
                    </div>
                </div>
            </c:if>
            <c:if test="${(logs.rowCount eq 0) and (not empty code)}"><h6 style="color: #ff6666">No data found for ${param.code}</h6></c:if>
            <%
                    }
                } catch (SQLException ex) {
                    String s = ex.toString();
                    if (s.contains("java.sql.SQLIntegrityConstraintViolationException")) {
                        s = "INV Item already exists";
                    }
                    chainAttribute(true, request, "sqlError", s);
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
            <c:if test="${not empty fromError}">
                <script>
                    (function() {
                        var error = "<%=request.getAttribute("fromError")%>";
                        if (error !== 'null')
                            log.innerText = (log.innerText + "\n" + error).trim();
                    })();
                </script>
            </c:if>
            <c:if test="${not empty toError}">
                <script>
                    (function() {
                        var error = "<%=request.getAttribute("toError")%>";
                        if (error !== 'null')
                            log.innerText = (log.innerText + "\n" + error).trim();
                    })();
                </script>
            </c:if>
            <c:if test="${not empty diffError}">
                <script>
                    (function() {
                        var error = "<%=request.getAttribute("diffError")%>";
                        if (error !== 'null')
                            log.innerText = (log.innerText + "\n" + error).trim();
                    })();
                </script>
            </c:if>
        </div>
    </body>
</html>
