<%-- 
    Document   : index
    Created on : Oct 26, 2016, 9:20:46 PM
    Author     : Harsh
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="erpimac.css" />
        <title>Home - ERPiMac</title>
        <jsp:include page="WEB-INF/jspf/Header.jspf" />
    </head>
    <body>
        <div style="color: black; text-align: center;">
            <h3 style="font-family: Candara; font-weight: bold; margin-bottom: 2px;">Welcome to the Enterprise Resource Planning</h3>
            <h4 style="font-family: Candara; font-weight: lighter; font-style: italic; margin-top: 2px;">Inventory Management And Control module.</h4>
            <p class="paragraph">
                This project is aimed at building a minimal working representation of an ERP Inventory Management and Control module, which is one of the main parts of the Material Resource Planning modules of an ERP.
            </p>
            <p class="paragraph">
                As the name suggests, this module is responsible for all changes and logging of materials present in a company’s inventory which may include addition/arrival of resources (amount payable, advances, dates, quality checks), forwarding of resources to the manufacturing modules (decrementing resources in blocks, as and when required by the manufacturing module) and quality control. Quality control can be measured by timely checks performed at the warehouse where the inventory is stored. Only one batch from among many of those delivered (for a single product) are to be quality checked. (The quality score will be input by the user).
            </p>
            <p class="paragraph">
                After the forwarding of the resources to the manufacturing plant, the future demand is either predicted or statically determined and sent to the IM&C in-through to the purchasing module.
            </p>
            <p class="paragraph">
                The IM&C module is a very necessary module for the inventory, and everything needs to be logged and tracked. Hence it needs a reporting section, where the operator/administrators can view the daily, weekly, monthly or yearly reports of all transactions done.
            </p>
            <p class="paragraph">
                Modules to be built-
                <ul class="list">
                    <li>
                        Add inventory
                    </li>
                    <li>
                        Update inventory
                    </li>
                    <li>
                        Billing module
                    </li>
                    <li>
                        Resource forwarding and Demand determination module
                    </li>
                    <li>
                        Purchasing module
                    </li>
                    <li>
                        Reporting module
                    </li>
                </ul>
            </p>
        </div>
    </body>
</html>
