/**
 * CompanyServiceCallbackHandler.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis2 version: 1.7.3  Built on : May 30, 2016 (04:08:57 BST)
 */
package com.huawei.webservice.wb.company;


/**
 *  CompanyServiceCallbackHandler Callback class, Users can extend this class and implement
 *  their own receiveResult and receiveError methods.
 */
public abstract class CompanyServiceCallbackHandler {
    protected Object clientData;

    /**
     * User can pass in any object that needs to be accessed once the NonBlocking
     * Web service call is finished and appropriate method of this CallBack is called.
     * @param clientData Object mechanism by which the user can pass in user data
     * that will be avilable at the time this callback is called.
     */
    public CompanyServiceCallbackHandler(Object clientData) {
        this.clientData = clientData;
    }

    /**
     * Please use this constructor if you don't want to set any clientData
     */
    public CompanyServiceCallbackHandler() {
        this.clientData = null;
    }

    /**
     * Get the client data
     */
    public Object getClientData() {
        return clientData;
    }

    /**
     * auto generated Axis2 call back method for getFlowCodes method
     * override this method for handling normal response from getFlowCodes operation
     */
    public void receiveResultgetFlowCodes(
    		com.huawei.webservice.wb.company.CompanyServiceStub.GetFlowCodesResponse result) {
    }

    /**
     * auto generated Axis2 Error handler
     * override this method for handling error response from getFlowCodes operation
     */
    public void receiveErrorgetFlowCodes(java.lang.Exception e) {
    }

    /**
     * auto generated Axis2 call back method for getEUserWobeiInfo method
     * override this method for handling normal response from getEUserWobeiInfo operation
     */
    public void receiveResultgetEUserWobeiInfo(
        com.huawei.webservice.wb.company.CompanyServiceStub.GetEUserWobeiInfoResponse result) {
    }

    /**
     * auto generated Axis2 Error handler
     * override this method for handling error response from getEUserWobeiInfo operation
     */
    public void receiveErrorgetEUserWobeiInfo(java.lang.Exception e) {
    }

    /**
     * auto generated Axis2 call back method for getFlowResult method
     * override this method for handling normal response from getFlowResult operation
     */
    public void receiveResultgetFlowResult(
        com.huawei.webservice.wb.company.CompanyServiceStub.GetFlowResultResponse result) {
    }

    /**
     * auto generated Axis2 Error handler
     * override this method for handling error response from getFlowResult operation
     */
    public void receiveErrorgetFlowResult(java.lang.Exception e) {
    }

    /**
     * auto generated Axis2 call back method for giveFlow method
     * override this method for handling normal response from giveFlow operation
     */
    public void receiveResultgiveFlow(
        com.huawei.webservice.wb.company.CompanyServiceStub.GiveFlowResponse result) {
    }

    /**
     * auto generated Axis2 Error handler
     * override this method for handling error response from giveFlow operation
     */
    public void receiveErrorgiveFlow(java.lang.Exception e) {
    }

    /**
     * auto generated Axis2 call back method for getUserNetType method
     * override this method for handling normal response from getUserNetType operation
     */
    public void receiveResultgetUserNetType(
        com.huawei.webservice.wb.company.CompanyServiceStub.GetUserNetTypeResponse result) {
    }

    /**
     * auto generated Axis2 Error handler
     * override this method for handling error response from getUserNetType operation
     */
    public void receiveErrorgetUserNetType(java.lang.Exception e) {
    }
}
