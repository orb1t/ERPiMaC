<%-- 
    Document   : AddInventory
    Created on : Oct 25, 2016, 11:17:21 PM
    Author     : Harsh
--%>

<%@page import="java.sql.Savepoint"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.util.Enumeration"%>
<%@page import="java.util.TreeMap"%>
<%@page import="java.util.SortedMap"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Date"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Statement"%>
<%@page import="javax.sql.DataSource"%>
<%@page import="javax.naming.InitialContext"%>
<%@page import="javax.naming.Context"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="erpimac.css" />
        <title>ERPiMaC - Add to Inventory</title>
        <jsp:include page="WEB-INF/jspf/Header.jspf"/>
        <script>
            function onbodyload() {
                if (<%=request.getParameter("add") != null%> && <%=request.getAttribute("errorFlag") == null%>) {
                    inv_id.value = "<%=request.getParameter("code")%>";
                    inv_name.value = "<%=request.getParameter("name")%>";
                    inv_quantity.value = "<%=request.getParameter("quantity")%>";
                    inv_ppu.value = "<%=request.getParameter("ppu")%>";
                }
            }
        </script>
    </head>

    <%--366FB4--%>
    <body style="font-family: Renogare;" onload="onbodyload()">

        <div style="text-align: center; padding-left: 64px; padding-right: 64px; padding-top: 16px; padding-bottom: 16px; color: black">
            <form method="post">
                <button type="submit" name="inv" class="flatbutton">Add Inventory</button>
                <button type="submit" name="prod" class="flatbutton">Add Product</button>
                <%
                    String subpage = "";
                    if (request.getParameter("inv") != null) {
                        subpage = "inv";
                    } else if (request.getParameter("prod") != null) {
                        subpage = "prod";
                    }
                    if (subpage.equals("inv")) {
                %>
                <div id="prod">
                    <h3>Please enter the information to add items to Inventory</h3>
                    <table style="float: none; margin: auto;">
                        <tr>
                            <td class="labelcell">INV Code</td><td style="width: 32px;" />
                            <td><input type="text" id="inv_id" class="roundedBounds" name="code" placeholder="XX####" /></td>
                        </tr>
                        <tr>
                            <td class="labelcell">INV Name</td><td />
                            <td><input type="text" id="inv_name" class="roundedBounds" name="name" placeholder="Name" /></td>
                        </tr>
                        <tr>
                            <td class="labelcell">INV Quantity</td><td />
                            <td><input type="text" id="inv_quantity" class="roundedBounds" name="quantity" placeholder="#" /></td>
                        </tr>
                        <tr>
                            <td class="labelcell">INV Price/Unit</td><td />
                            <td><input type="text" id="inv_ppu" class="roundedBounds" name="ppu" placeholder="#.#" /></td>
                        </tr>
                        <tr style="height: 16px;"></tr>
                        <tr>
                            <td colspan="3">
                                <button class="flatbutton" name="add" type="submit">Add Inventory</button>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <label id="log" style="font-family: Arial; color: #ff6666; font-size: 12px;"/>
                            </td>
                        </tr>
                    </table>
                    <%!
                        boolean chainAttribute(boolean previous, HttpServletRequest request, String name, String value) {
                            request.setAttribute(name, value);
                            request.setAttribute("errorFlag", true);
                            return previous && false;
                        }
                    %>
                    <%
                        if (request.getParameter("add") != null) {
                            String code = request.getParameter("code");
                            String name = request.getParameter("name");
                            boolean noerror = true;
                            if (name.length() == 0) {
                                noerror = chainAttribute(noerror, request, "nameError", "INV Name: Cannot be empty.");
                            }
                            if (code.length() == 0) {
                                noerror = chainAttribute(noerror, request, "codeError", "INV Code: No code specified.");
                            } else if (!code.matches("[A-Z]{2,}[0-9]{4,}")) {
                                noerror = chainAttribute(noerror, request, "codeError", "INV Code: Invalid code specified: '" + code + "'");
                            }
                            int quantity = 0;
                            try {
                                if (request.getParameter("quantity") == null) {
                                    noerror = chainAttribute(noerror, request, "quantityError", "INV Quantity: No quantity specified.");
                                } else {
                                    quantity = Integer.parseInt(request.getParameter("quantity"));
                                }
                            } catch (NumberFormatException e) {
                                noerror = chainAttribute(noerror, request, "quantityError", "INV Quantity: Invalid quantity specified: '" + quantity + "' or NaN");
                            }
                            double ppu = 0.0;
                            try {
                                if (request.getParameter("ppu") == null) {
                                    noerror = chainAttribute(noerror, request, "ppuError", "INV Price/Unit: No quantity specified.");
                                } else {
                                    ppu = Double.parseDouble(request.getParameter("ppu"));
                                }
                            } catch (NumberFormatException e) {
                                noerror = chainAttribute(noerror, request, "ppuError", "INV Price/Unit: Invalid price specified, Format #.#");
                            }
                            if (noerror) {
                                DriverManager.registerDriver(new org.apache.derby.jdbc.ClientDriver());
                                try (Connection con = DriverManager.getConnection("jdbc:derby://localhost:1527/erpimac", "erpimac", "erpimac")) {
                                    try (PreparedStatement ins = con.prepareStatement("insert into INVENTORY values (?,?,?,?)")) {
                                        ins.setString(1, code);
                                        ins.setString(2, name);
                                        ins.setInt(3, quantity);
                                        ins.setDouble(4, ppu);
                                        ins.executeUpdate();
                                        request.setAttribute("errorFlag", null);
                                        try (PreparedStatement log = con.prepareStatement("insert into INVLOG values(?,?,?,?,?)")) {
                                            log.setString(1, code);
                                            log.setString(2, "add");
                                            log.setTimestamp(3, java.sql.Timestamp.from(java.time.Instant.now()));
                                            log.setInt(4, quantity);
                                            log.setDouble(5, ppu);
                                            log.executeUpdate();
                                        } catch (SQLException ex) {
                                            throw ex;
                                        }
                                    } catch (SQLException ex) {
                                        throw ex;
                                    }
                                } catch (SQLException ex) {
                                    String s = ex.toString();
                                    if (s.contains("java.sql.SQLIntegrityConstraintViolationException")) {
                                        s = "INV Item already exists";
                                    }
                                    chainAttribute(true, request, "sqlError", s);
                                }
                            }
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
                    <c:if test="${not empty nameError}">
                        <script>
                            (function() {
                                var error = "<%=request.getAttribute("nameError")%>";
                                if (error !== 'null')
                                    log.innerText = (log.innerText + "\n" + error).trim();
                            })();
                        </script>
                    </c:if>
                    <c:if test="${not empty ppuError}">
                        <script>
                            (function() {
                                var error = "<%=request.getAttribute("ppuError")%>";
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
                </div>
                <%
                } else if (subpage.equals("prod")) {
                %>
                <%! SortedMap<String, Integer> codes = new TreeMap<>();%>
                <div>
                    <h3>Please enter the information to add items to Inventory</h3>
                    <table style="float: none; margin: auto;">
                        <tr>
                            <td class="labelcell">INV Code</td><td style="width: 32px;" />
                            <td><input type="text" id="inv_id" class="roundedBounds" style="width: 100%;" name="code" placeholder="XX####" /></td>
                        </tr>
                        <tr>
                            <td class="labelcell">INV Name</td><td />
                            <td><input type="text" id="inv_name" class="roundedBounds" style="width: 100%;" name="name" placeholder="Name" /></td>
                        </tr>
                        <tr>
                            <td class="labelcell">INV Quantity</td><td />
                            <td><input type="text" id="inv_quantity" class="roundedBounds" style="width: 100%;" name="quantity" placeholder="#" /></td>
                        </tr>
                        <tr>
                            <td class="labelcell" style="vertical-align: sub; padding-top: 4px;">INV Components</td><td />
                            <td>
                                <sql:setDataSource url="jdbc:derby://localhost:1527/erpimac" user="erpimac" password="erpimac" var="erpimacdb" driver="org.apache.derby.jdbc.ClientDriver"/>
                                <sql:query dataSource="${erpimacdb}" var="items">
                                    select code, name from INVENTORY
                                </sql:query>
                                <script>
                                    function itemChecked(chk) {
                                        if (document.getElementById(chk.id + "check").checked) {
                                            if (document.getElementById(chk.id + "quantity").value == 0)
                                                document.getElementById(chk.id + "quantity").value = 1;
                                        } else {
                                            document.getElementById(chk.id + "quantity").value = 0;
                                        }
                                    }
                                </script>
                                <div class="roundedBoundsNoFocus" style="margin-right: -16px;">
                                    <div style="height: 128px; overflow-y: scroll; text-align: left;">
                                        <c:forEach var="row" items="${items.rows}">
                                            <label id="${row.code}" style="font-size: 14px; font-family: Candara;" onclick="itemChecked(this)">
                                                <input id="${row.code}check" type="checkbox" name="${row.code}" style="vertical-align: sub;">
                                                <input id="${row.code}quantity" type="number" name="${row.code}quantity" min="0" class="roundedBoundsNoFocus" style="width: 48px;" value="0">
                                                x&nbsp;&nbsp;${row.code} - ${row.name}
                                            </label><br />
                                        </c:forEach>
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr style="height: 16px;"></tr>
                        <tr>
                            <td colspan="3">
                                <button class="flatbutton" name="prod" type="submit">Add Product</button>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <label id="log" style="font-family: Arial; color: #ff6666; font-size: 12px;"/>
                            </td>
                        </tr>
                    </table>
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
                    %>
                    <%
                        if (request.getParameter("prod") != null) {
                            String code = request.getParameter("code");
                            String name = request.getParameter("name");
                            boolean noerror = true;
                            if (name.length() == 0) {
                                noerror = chainAttribute(noerror, request, "nameError", "INV Name: Cannot be empty.");
                            }
                            if (code.length() == 0) {
                                noerror = chainAttribute(noerror, request, "codeError", "INV Code: No code specified.");
                            } else if (!code.matches("[A-Z]{2,}[0-9]{4,}")) {
                                noerror = chainAttribute(noerror, request, "codeError", "INV Code: Invalid code specified: '" + code + "'");
                            }
                            int quantity = 0;
                            try {
                                if (request.getParameter("quantity") == null) {
                                    noerror = chainAttribute(noerror, request, "quantityError", "INV Quantity: No quantity specified.");
                                } else {
                                    quantity = Integer.parseInt(request.getParameter("quantity"));
                                }
                            } catch (NumberFormatException e) {
                                noerror = chainAttribute(noerror, request, "quantityError", "INV Quantity: Invalid quantity specified: '" + quantity + "' or NaN");
                            }
                            ArrayList<String> params = getCodeParameters(request);
                            if (params.size() == 0) {
                                noerror = chainAttribute(noerror, request, "compError", "INV Components: Select Components needed.");
                            }
                            if (noerror) {
                                double ppu = 0.0;
                                DriverManager.registerDriver(new org.apache.derby.jdbc.ClientDriver());
                                try (Connection con = DriverManager.getConnection("jdbc:derby://localhost:1527/erpimac", "erpimac", "erpimac")) {
                                    con.setAutoCommit(false);
                                    Savepoint save = con.setSavepoint();
                                    try {
                                        for (String s : params) {
                                            String val = request.getParameter(s + "quantity");
                                            int quantitys = Integer.parseInt(val);
                                            try (PreparedStatement get = con.prepareStatement("select price from INVENTORY where code=?")) {
                                                get.setString(1, s);
                                                ResultSet set = get.executeQuery();
                                                if (set.next()) {
                                                    double ppus = set.getDouble(1);
                                                    ppu += ppus * quantitys;
                                                    set.close();
                                                    try (PreparedStatement upd = con.prepareStatement("update INVENTORY set quantity = quantity - ? where code = ?")) {
                                                        upd.setInt(1, quantity);
                                                        upd.setString(2, s);
                                                        upd.executeUpdate();
                                                        try (PreparedStatement log = con.prepareStatement("insert into INVLOG values(?,?,?,?,?)")) {
                                                            log.setString(1, s);
                                                            log.setString(2, "fwd");
                                                            log.setTimestamp(3, java.sql.Timestamp.from(java.time.Instant.now()));
                                                            log.setInt(4, -quantitys * quantity);
                                                            log.setDouble(5, ppus);
                                                            log.executeUpdate();
                                                            request.setAttribute("done", true);
                                                        } catch (SQLException ex) {
                                                            throw ex;
                                                        }
                                                    } catch (SQLException ex) {
                                                        throw ex;
                                                    }
                                                    try (PreparedStatement sub = con.prepareStatement("insert into PRODUCTS values (?,?,?)")) {
                                                        sub.setString(1, code);
                                                        sub.setString(2, s);
                                                        sub.setInt(3, quantitys);
                                                        sub.executeUpdate();
                                                    } catch (SQLException e) {
                                                        throw e;
                                                    }
                                                }
                                            } catch (SQLException e) {
                                                throw e;
                                            }
                                        }
                                        try (PreparedStatement ins = con.prepareStatement("insert into INVENTORY values (?,?,?,?)")) {
                                            ins.setString(1, code);
                                            ins.setString(2, name);
                                            ins.setInt(3, quantity);
                                            ins.setDouble(4, ppu);
                                            ins.executeUpdate();
                                            request.setAttribute("errorFlag", null);
                                            try (PreparedStatement log = con.prepareStatement("insert into INVLOG values(?,?,?,?,?)")) {
                                                log.setString(1, code);
                                                log.setString(2, "add");
                                                log.setTimestamp(3, java.sql.Timestamp.from(java.time.Instant.now()));
                                                log.setInt(4, quantity);
                                                log.setDouble(5, ppu);
                                                log.executeUpdate();
                                            } catch (SQLException ex) {
                                                throw ex;
                                            }
                                        } catch (SQLException ex) {
                                            throw ex;
                                        }
                                    } catch (SQLException e) {
                                        con.rollback(save);
                                    } finally {
                                        con.releaseSavepoint(save);
                                        con.setAutoCommit(true);
                                    }
                                } catch (SQLException ex) {
                                    String s = ex.toString();
                                    if (s.contains("java.sql.SQLIntegrityConstraintViolationException")) {
                                        s = "INV Item already exists";
                                    }
                                    chainAttribute(true, request, "sqlError", s);
                                }
                            }
                        }
                    %>
                    <c:if test="${not empty nameError}">
                        <script>
                            (function() {
                                var error = "<%=request.getAttribute("nameError")%>";
                                if (error !== 'null')
                                    log.innerText = (log.innerText + "\n" + error).trim();
                            })();
                        </script>
                    </c:if>
                    <c:if test="${not empty codeError}">
                        <script>
                            (function() {
                                var error = "<%=request.getAttribute("codeError")%>";
                                if (error !== 'null')
                                    log.innerText = (log.innerText + "\n" + error).trim();
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
                    <c:if test="${not empty compError}">
                        <script>
                            (function() {
                                var error = "<%=request.getAttribute("compError")%>";
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
                </div>
                <%                    }
                %>
            </form>
        </div>
    </body>
</html>
