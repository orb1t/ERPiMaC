<%-- 
    Document   : InventoryBill
    Created on : Oct 26, 2016, 2:53:23 PM
    Author     : Harsh
--%>

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
        <title>Inventory Bill</title>
        <jsp:include page="Header.jspf"/>
        <script>
            function onbodyload() {
                try {
                    var fromdate = '<%=request.getParameter("from")%>'.split('-');
                    inv_day[parseInt(fromdate[0]) - 1].selected = 'selected';
                    inv_month[parseInt(fromdate[1]) - 1].selected = 'selected';
                    inv_year[new Date().getFullYear() - parseInt(fromdate[2])].selected = 'selected';
                    fromdate = '<%=request.getParameter("to")%>'.split('-');
                    inv_to_day[parseInt(fromdate[0]) - 1].selected = 'selected';
                    inv_to_month[parseInt(fromdate[1]) - 1].selected = 'selected';
                    inv_to_year[new Date().getFullYear() - parseInt(fromdate[2])].selected = 'selected';
                    inv_id.value = '<%=request.getParameter("code")%>';
                } catch (e) {
                }
            }
            function update() {
                inv_form.value = inv_day.value + '-' + inv_month.value + '-' + inv_year.value;
                inv_to_form.value = inv_to_day.value + '-' + inv_to_month.value + '-' + inv_to_year.value;
                form.submit();
            }
        </script>
    </head>
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
                        <td><input type="text" id="inv_id" name="code" class="roundedBounds" style="width: 95%;" /></td>
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
            <%
                try {
                    String code = request.getParameter("code");
                    if (code.length() == 0) {
                        request.setAttribute("codeError", "No code specified.");
                    } else if (!code.matches("[A-Z]{2,}[0-9]{4,}")) {
                        request.setAttribute("codeError", "Invalid code specified: '" + code + "'");
                    }
                    String fromStr = request.getParameter("from");
                    String toStr = request.getParameter("to");
                    Date from = null, to = null;
                    try {
                        int[] values = new int[3];
                        String[] split = fromStr.split("-");
                        for (int i = 0; i < 3; i++) {
                            values[i] = Integer.parseInt(split[i]);
                        }
                        from = new Date(values[2] - 1900, values[1], values[0]);
                    } catch (Exception e) {
                        request.setAttribute("fromError", "Invalid date specified: '" + ((fromStr == null) ? "" : fromStr) + "'");
                    }
                    try {
                        int[] values = new int[3];
                        String[] split = toStr.split("-");
                        for (int i = 0; i < 3; i++) {
                            values[i] = Integer.parseInt(split[i]);
                        }
                        to = new Date(values[2] - 1900, values[1], values[0]);
                    } catch (Exception e) {
                        request.setAttribute("toError", "Invalid date specified: '" + ((toStr == null) ? "" : toStr) + "'");
                    }
                    if(from != null && to != null) {
                        if(Days.daysBetween(new DateTime(from), new DateTime(to)).getDays() <= 0)
                            request.setAttribute("diffError", "INV From date should precede the INV To date.");
                    }
                } catch (Exception ex) {

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
