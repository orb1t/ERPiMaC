<%-- 
    Document   : UpdateInventory
    Created on : Oct 25, 2016, 11:17:21 PM
    Author     : Harsh
--%>

<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Savepoint"%>
<%@page import="java.util.Date"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="erpimac.css" />
        <title>ERPiMaC - Update Inventory</title>
        <jsp:include page="WEB-INF/jspf/Header.jspf"/>
        <script>
            function onbodyload() {
                if (<%=request.getParameter("update") != null%>) {
                    inv_id.value = "<%=request.getParameter("inv_id")%>";
                    inv_quantity.value = "<%=request.getParameter("inv_quantity")%>";
                }
            }
        </script>
    </head>
    <%--366FB4--%>
    <body style="font-family: Renogare;" onload="onbodyload()">
        <div style="text-align: center; padding-left: 64px; padding-right: 64px; padding-top: 16px; padding-bottom: 16px; color: black">
            <h3>Please enter the item INV Code and the quantity to update</h3>
            <form method="post">
                <table style="float: none; margin: auto;">
                    <tr>
                        <td class="labelcell">INV Code</td><td style="width: 32px;" />
                        <td><input type="text" id="inv_id" class="roundedBounds" name="inv_id" placeholder="XX####" /></td>
                    </tr>
                    <tr>
                        <td class="labelcell">INV Quantity</td><td />
                        <td><input type="text" id="inv_quantity" class="roundedBounds" name="inv_quantity" placeholder="#" /></td>
                    </tr>
                    <tr style="height: 16px;"></tr>
                    <tr>
                        <td colspan="3">
                            <button type="submit" name="update" class="flatbutton">Update Inventory</button>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="3">
                            <label id="log" style="font-family: Arial; color: #ff6666; font-size: 12px;"/>
                        </td>
                    </tr>
                </table>
            </form>
            <%!
                boolean chainAttribute(boolean previous, HttpServletRequest request, String name, String value) {
                    request.setAttribute(name, value);
                    return previous && false;
                }
            %>
            <%
                if (request.getParameter("update") != null) {
                    String code = request.getParameter("inv_id");
                    boolean noerror = true;
                    if (code.length() == 0) {
                        noerror = chainAttribute(noerror, request, "codeError", "No code specified.");
                    } else if (!code.matches("[A-Z]{2,}[0-9]{4,}")) {
                        noerror = chainAttribute(noerror, request, "codeError", "Invalid code specified: '" + code + "'");
                    }
                    int quantity = 0;
                    try {
                        if (request.getParameter("inv_quantity") == null) {
                            noerror = chainAttribute(noerror, request, "quantityError", "No quantity specified.");
                        } else {
                            quantity = Integer.parseInt(request.getParameter("inv_quantity"));
                            if (quantity <= 0) {
                                noerror = chainAttribute(noerror, request, "quantityError", "Quantity cannot be zero or negative.");
                            }
                        }
                    } catch (NumberFormatException e) {
                        noerror = chainAttribute(noerror, request, "quantityError", "Invalid quantity specified: '" + quantity + "' or NaN");
                    }
                    if (noerror) {
                        DriverManager.registerDriver(new org.apache.derby.jdbc.ClientDriver());
                        try (Connection con = DriverManager.getConnection("jdbc:derby://localhost:1527/erpimac", "erpimac", "erpimac")) {
                            con.setAutoCommit(false);
                            Savepoint s = con.setSavepoint();
                            try (PreparedStatement ins = con.prepareStatement("update INVENTORY set quantity = quantity + ? where code = ?")) {
                                ins.setInt(1, quantity);
                                ins.setString(2, code);
                                ins.executeUpdate();
                                try (PreparedStatement get = con.prepareStatement("select price from INVENTORY where code = ?")) {
                                    get.setString(1, code);
                                    ResultSet set = get.executeQuery();
                                    if (set.next()) {
                                        double ppu = set.getDouble(1);
                                        try (PreparedStatement log = con.prepareStatement("insert into INVLOG values(?,?,?,?,?)")) {
                                            log.setString(1, code);
                                            log.setString(2, "upd");
                                            log.setTimestamp(3, java.sql.Timestamp.from(java.time.Instant.now()));
                                            log.setInt(4, quantity);
                                            log.setDouble(5, ppu);
                                            log.executeUpdate();
                                        } catch (SQLException ex) {
                                            throw ex;
                                        }
                                    }
                                } catch (SQLException ex) {
                                    throw ex;
                                }
                            } catch (SQLException ex) {
                                con.rollback(s);
                                throw ex;
                            } finally {
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
    </body>
</html>
