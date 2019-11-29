@isTest
public class CRM_TriggerHandlerCase_Test {

    @testSetup
    static void setupTestData(){
        /**
        List<String> returnStrList1 = arcshared.TriggerDispatcher.constructValues('TriggerHandlerCase', 'Case', 1, null);
        System.debug('After load config - returnStrList =  ' + returnStrList1 );
        String returnStr1 = returnStrList1[0];
        System.debug('After load config - returnStr =  ' + returnStr1 );
        arcshared.AppConfigSupport.setting newSetting1 = new arcshared.AppConfigSupport.setting('EBC.Case 1', 'TriggerSetting', returnStr1 , returnStr1 , 1, true, false);
        arcshared.AppConfigSupport.setSingleRecord('TriggerHandlers', newSetting1, null );
		**/
    }
    
    static testMethod void initialCaseSetupTest(){
        
        Test.startTest();
        
        Case myNewCase = new Case( arcuscrm__Target_Case_Resolution_Days__c = 10, Origin = 'Web');
        insert myNewCase;
        
        Case myNewCaseBack = [SELECT Id, arcuscrm__Target_Resolution_Date__c FROM Case WHERE Id = :myNewCase.Id LIMIT 1];
        
        System.assertNotEquals(null, myNewCaseBack.Id, 'Should have found a case after inserting it');
        System.assertNotEquals(null, myNewCaseBack.arcuscrm__Target_Resolution_Date__c, 'The new case should have a target resolution date populated.');
        
		Test.stopTest();        
        
    }
    
}