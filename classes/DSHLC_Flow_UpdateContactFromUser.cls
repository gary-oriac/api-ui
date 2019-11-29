/*
Author     :    Jonathan Dobbs
Company    :    Arcus Global
Product    :    Arcus Citizen
Date       :    
Purpose    :    
Notes      :    The Apex Plug-in for a flow must implement the Apex Process.Plugin Interface
Modified   :    
*/
global with sharing class DSHLC_Flow_UpdateContactFromUser implements Process.Plugin {
    private string userID {get; set;}

    
    // This is the main method the Flow engine calls at run-time.
    global Process.PluginResult invoke(Process.PluginRequest request) {
    
        // Get all the inputs from the Flow
        userID = (String) request.inputParameters.get('UserID');
        
        return DSHLC_ContactUtility.ProcessCon(userID);
     }
 

    /* 
    * This is the method the Cloud Flow Designer calls to show the Apex Plug-ins to the flow author
    * The implementation of this method drives how author of the flow interacts in the the Cloud Flow Designer 
    */   
    global Process.PluginDescribeResult describe() {
 
    Process.PluginDescribeResult result = new Process.PluginDescribeResult();
        // Shows the description visible in the Palette tab of the Cloud Flow Designer.
        result.description = 'This Flow plug-in updates the email address of a contact that is associated to a user';
       
        // Setting the 'tag' gives the Apex Plug-in its own section on the Cloud Flow Designer Palette tab.
        // Use this attribute to group related Apex Plug-ins together in the Cloud Flow Designer.
        result.tag = 'Contact';
        
        // Setting the 'name' gives the Apex Plug-in its unique name as displayed in the Cloud Flow Designer.
        result.name = 'Contact Email Update'; 

        // All the Inputs needed, their data type and the requiredness
        result.inputParameters = new List<Process.PluginDescribeResult.InputParameter>{
            new Process.PluginDescribeResult.InputParameter('UserID', 
                Process.PluginDescribeResult.ParameterType.STRING, true)
                };
         
        return result;   
    }         
}