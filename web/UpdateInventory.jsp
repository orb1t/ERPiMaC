<%-- 
    Document   : AddInventory
    Created on : Oct 25, 2016, 11:17:21 PM
    Author     : Harsh
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="erpimac.css" />
        <title>Update Inventory</title>
        <jsp:include page="Header.jspf"/>
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
            <%
                if (request.getParameter("update") != null) {
                    String code = request.getParameter("inv_id");
                    if (code.length() == 0) {
                        request.setAttribute("codeError", "No code specified.");
                    } else if (!code.matches("[A-Z]{2,}[0-9]{4,}")) {
                        request.setAttribute("codeError", "Invalid code specified: '" + code + "'");
                    }
                    int quantity = 0;
                    try {
                        if (request.getParameter("inv_quantity") == null) {
                            request.setAttribute("quantityError", "No quantity specified.");
                        } else {
                            quantity = Integer.parseInt(request.getParameter("inv_quantity"));
                        }
                    } catch (NumberFormatException e) {
                        request.setAttribute("quantityError", "Invalid quantity specified: '" + quantity + "' or NaN");
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
        </div>
    </body>
</html>
