<%-- 
    Document   : Reporting
    Created on : Nov 18, 2016, 3:41:01 PM
    Author     : Harsh
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.Timestamp"%>
<%@page import="java.util.SortedMap"%>
<%@page import="java.lang.reflect.Array"%>
<%@page import="java.util.Enumeration"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="erpimac.css" />
        <title>ERPiMaC - Reporting</title>
        <script src="Chart.js"></script>
        <jsp:include page="WEB-INF/jspf/Header.jspf"/>
        <script>
            function onbodyload() {
                if (<%=request.getParameter("invcode") != null%> && document.getElementById('invcode') != null) {
                    document.getElementById('invcode').value = "<%=(String) request.getAttribute("invcode")%>";
                }
            }
        </script>
    </head>

    <%--366FB4--%>
    <body style="font-family: Renogare;" onload="onbodyload()">

        <div style="text-align: center; padding-left: 64px; padding-right: 64px; padding-top: 8px; padding-bottom: 16px; color: black">
            <form method="post">
                <button type="submit" name="invstat" class="flatbutton">Inventory Status</button>
                <button type="submit" name="invtrends" class="flatbutton">Inventory Trends</button>
                <button type="submit" name="itemstat" class="flatbutton">Item Status</button>
                <button type="submit" name="itemtrends" class="flatbutton">Item Trends</button>
                <%
                    String subpage = "";
                    if (request.getParameter("invstat") != null) {
                        subpage = "invstat";
                    } else if (request.getParameter("invtrends") != null) {
                        subpage = "invtrends";
                    } else if (request.getParameter("itemstat") != null) {
                        subpage = "itemstat";
                    } else if (request.getParameter("itemtrends") != null) {
                        subpage = "itemtrends";
                    }
                    if (subpage.equals("itemstat")) {
                %>
                <div style="margin-top: 32px;">

                </div>
                <%
                } else if (subpage.equals("itemtrends")) {
                %>
                <div style="margin-top: 16px;">
                    <sql:setDataSource url="jdbc:derby://localhost:1527/erpimac" user="erpimac" password="erpimac" var="erpimacdb" driver="org.apache.derby.jdbc.ClientDriver"/>
                    <sql:query dataSource="${erpimacdb}" var="INVCodes">
                        select code from INVENTORY
                    </sql:query>
                    <span style="font-size: 14px; font-family: Candara;">Select Item</span>
                    <select id="invcode" name="invcode" class="dropdown" style="border-bottom: 1px solid #366FB4; border-radius: 0px;">
                        <option label="" />
                        <c:forEach var="row" items="${INVCodes.rows}">
                            <option label="${row.code}" value="${row.code}" />
                        </c:forEach>
                    </select>
                    <button type="submit" name="itemtrends" class="toolbutton">Show Status</button><br />
                    <div style="width: 960px; height: 360px; float: none; margin: auto; padding: 16px;">
                        <canvas id="itemstatcanvas" style=" height: 320px; " />
                    </div>
                    <span style="color: black">
                        <sql:query dataSource="${erpimacdb}" var="logs">
                            select date, sum(quantity) as totalqt, price from INVLOG where (code = ?) group by CODE, date, price
                            <sql:param value='${param.invcode}' />
                        </sql:query>
                        <script>
                            var ctx = document.getElementById("itemstatcanvas");
                            var labels = [];
                            var months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
                            var data = [];
                            var prices = [];
                            (function() {
                            <c:forEach var="row" items="${logs.rows}">
                                labels.push(months[${row.date.month}] + ' ' + ${row.date.date} + ' ' + ${row.date.hours} + ':' +${row.date.minutes});
                                data.push(${row.totalqt});
                                prices.push(${row.price});
                            </c:forEach>
                            })();
                            document.title = 'Trends - ${param.invcode}';
                            var itemstatchart = new Chart(ctx, {
                                type: 'bar',
                                data: {
                                    labels: labels,
                                    datasets: [{
                                            label: 'Price',
                                            type: 'line',
                                            fill: false,
                                            data: prices,
                                            borderColor: '#71B37C',
                                            backgroundColor: '#71B37C',
                                            pointBorderColor: '#71B37C',
                                            pointBackgroundColor: '#71B37C',
                                            pointHoverBackgroundColor: '#71B37C',
                                            pointHoverBorderColor: '#71B37C',
                                            yAxisID: 'y-axis-2'
                                        }, {
                                            label: 'Quantity',
                                            data: data,
                                            backgroundColor: '#366FB4',
                                            borderColor: '#366FB4',
                                            hoverBackgroundColor: '#366FB4',
                                            hoverBorderColor: '#366FB4',
                                            yAxisID: 'y-axis-1'
                                        }]
                                },
                                options: {
                                    scales: {
                                        xAxes: [{
                                                display: true,
                                                gridLines: {
                                                    display: false
                                                },
                                                labels: {
                                                    show: true,
                                                }
                                            }],
                                        yAxes: [{
                                                type: "linear",
                                                display: true,
                                                position: "right",
                                                id: "y-axis-2",
                                                gridLines: {
                                                    display: false
                                                },
                                                labels: {
                                                    show: true,
                                                },
                                                ticks: {
                                                    beginAtZero: true
                                                }
                                            }, {
                                                type: "linear",
                                                display: true,
                                                position: "left",
                                                id: "y-axis-1",
                                                gridLines: {
                                                    display: false
                                                },
                                                labels: {
                                                    show: true,
                                                },
                                                ticks: {
                                                    beginAtZero: true,
                                                }
                                            }]
                                    }
                                }
                            });
                            collapseHeader();
                            caption.innerText = 'ERPiMac (Trends - ${param.invcode})';
                        </script>
                </div>
                <%
                } else if (subpage.equals("invstat")) {
                %>
                <sql:setDataSource url="jdbc:derby://localhost:1527/erpimac" user="erpimac" password="erpimac" var="erpimacdb" driver="org.apache.derby.jdbc.ClientDriver"/>
                <sql:query dataSource="${erpimacdb}" var="items">
                    select INVENTORY.code as code, name, INVENTORY.quantity as quantity, INVENTORY.price as price, date
                    from INVENTORY, INVLOG
                    where INVENTORY.code = INVLOG.code and action = 'add'
                </sql:query>
                <br /><br />    
                <table style="margin: auto; font-family: Segoe UI; font-size: 12px;">
                    <thead style="font-family: Candara; font-size: 14px; color: #366fb4">
                    <th style="padding-left: 8px; padding-right: 8px; text-align: left;">Item Code</th>
                    <th style="padding-left: 8px; padding-right: 8px; text-align: left;">Name</th>
                    <th style="padding-left: 8px; padding-right: 8px;">Quantity</th>
                    <th style="padding-left: 8px; padding-right: 8px;">Price per Unit</th>
                    <th style="padding-left: 8px; padding-right: 8px;">Net Item Worth</th>
                    <th style="padding-left: 8px; padding-right: 8px;">Added On</th>
                    </thead>
                    <c:set var="billtotal" value="0.0" />
                    <tr style="background-color:  #dddddd; height: 2px; margin-left: 4px; margin-right: 4px;"><td colspan="5"></td></tr>

                    <c:forEach var="row" items="${items.rows}">
                        <tr>
                            <%
                                SortedMap row = (SortedMap) pageContext.getAttribute("row");
                            %>
                            <td style="font-family: Consolas; font-size: 12px; text-align: left; padding-left: 8px;">${row.code}</td>
                            <td style="text-align: left; padding-left: 8px;">${row.name}</td>
                            <td style="text-align: right; font-family: Consolas; font-size: 12px; padding-right: 8px;">${row.quantity}</td>
                            <td style="text-align: right; font-family: Consolas; font-size: 12px; padding-right: 8px;">
                                <span style="float: left; font-size: 14px; padding-left: 8px;">₹</span>
                                <fmt:formatNumber type="number" maxFractionDigits="2" value="${row.price}" />
                            </td>
                            <td style="text-align: right; font-family: Consolas; font-size: 12px; padding-right: 8px;">
                                <span style="float: left; font-size: 14px; padding-left: 8px;">₹</span>
                                <fmt:formatNumber type="number" maxFractionDigits="2" value="${row.price * row.quantity}" />
                            </td>
                            <td>${row.date.year + 1900} 
                                <%! String[] months = {"JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"};%>
                                <%= months[((Timestamp) row.get("date")).getMonth()]%>
                                ${row.date.date}
                            </td>
                            <c:set var="billtotal" value="${billtotal + row.price * row.quantity}" />
                        </tr>
                    </c:forEach>
                    <tr style="background-color:  #dddddd; height: 2px; margin-left: 4px; margin-right: 4px;"><td colspan="5"></td></tr>
                    <tr>
                        <td colspan="4" style="text-align: right; font-family: Renogare; padding-right: 8px;">Total Asset Worth : </td>
                        <td style="font-family: Consolas; padding-right: 8px; text-align: right;">
                            <span style="float: left; font-size: 14px; padding-left: 8px;">₹</span>
                            <fmt:formatNumber type="number" maxFractionDigits="2" value="${billtotal}" />
                        </td>
                    </tr>
                </table>
                <%
                    }
                %>
            </form>
        </div>
    </body>
</html>
