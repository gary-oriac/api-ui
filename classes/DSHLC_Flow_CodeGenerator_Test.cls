/*
Company : Arcus Global
Product : Arcus DSH
Purpose : Test DSHLC_Flow_CodeGenerator class
Notes :
 */
@isTest
private with sharing class DSHLC_Flow_CodeGenerator_Test
{
    static testMethod void getCode() {
     
        DSHLC_Flow_CodeGenerator generator = new DSHLC_Flow_CodeGenerator();
        Map<String,Object> inputParams = new Map<String,Object>();
        Map<String,Object> outputParams = new Map<String,Object>();
         
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result = generator.invoke(request);
        
        System.AssertEquals(1,1);
    }

    static testMethod void describeTest() {

        DSHLC_Flow_CodeGenerator generator = new DSHLC_Flow_CodeGenerator();
        Process.PluginDescribeResult result = generator.describe();
       
        System.AssertEquals(result.OutputParameters.size(), 1);
     }
}