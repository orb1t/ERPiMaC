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
        <title>Add to Inventory</title>
        <jsp:include page="Header.jspf"/>
        <script>
            function onbodyload() {
                if (<%=request.getParameter("add") != null%>) {
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
            </form>
            <%
                if (request.getParameter("add") != null) {
                    String code = request.getParameter("code");
                    String name = request.getParameter("name");
                    if (name.length() == 0) {
                        request.setAttribute("nameError", "INV Name: Cannot be empty.");
                    }
                    if (code.length() == 0) {
                        request.setAttribute("codeError", "INV Code: No code specified.");
                    } else if (!code.matches("[A-Z]{2,}[0-9]{4,}")) {
                        request.setAttribute("codeError", "INV Code: Invalid code specified: '" + code + "'");
                    }
                    int quantity = 0;
                    try {
                        if (request.getParameter("quantity") == null) {
                            request.setAttribute("quantityError", "INV Quantity: No quantity specified.");
                        } else {
                            quantity = Integer.parseInt(request.getParameter("quantity"));
                        }
                    } catch (NumberFormatException e) {
                        request.setAttribute("quantityError", "INV Quantity: Invalid quantity specified: '" + quantity + "' or NaN");
                    }
                    double ppu = 0.0;
                    try {
                        if (request.getParameter("ppu") == null) {
                            request.setAttribute("ppuError", "INV Price/Unit: No quantity specified.");
                        } else {
                            ppu = Double.parseDouble(request.getParameter("ppu"));
                        }
                    } catch (NumberFormatException e) {
                        request.setAttribute("ppuError", "INV Price/Unit: Invalid price specified, Format #.#");
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
        </div>
    </body>
</html>
