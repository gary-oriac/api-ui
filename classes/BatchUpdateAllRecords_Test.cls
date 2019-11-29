@isTest
public class BatchUpdateAllRecords_Test {

    @isTest
    public static void testBatchable(){
        Boolean isErrored = false;
        String errorMessage;

        List<arcusbuiltenv__Planning_Application__c> planningApplications = new List<arcusbuiltenv__Planning_Application__c>();
        planningApplications.add(new arcusbuiltenv__Planning_Application__c(Name = 'PA1'));
        planningApplications.add(new arcusbuiltenv__Planning_Application__c(Name = 'PA2'));
        insert planningApplications;

        planningApplications = [SELECT Id, Name, LastModifiedDate FROM arcusbuiltenv__Planning_Application__c ORDER BY Name];

        Test.startTest();
        try{
              
            // Integer start = System.Now().millisecond() + 5;
            // Integer atm = System.Now().millisecond();
            // while(atm < start){ 
            //     atm = System.Now().millisecond();
            // }

            BatchUpdateAllRecords buar = new BatchUpdateAllRecords(arcusbuiltenv__Planning_Application__c.sObjectType, 30);
            Database.executeBatch(buar);
        }
        catch(Exception e){
            isErrored = true;
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        List<arcusbuiltenv__Planning_Application__c> planningApplicationsUpdated = [SELECT Id, Name, LastModifiedDate FROM arcusbuiltenv__Planning_Application__c ORDER BY Name];

        System.assertEquals(false, isErrored, 'Should not error! Error: ' + errorMessage);
        //System.assertNotEquals(planningApplications[0].LastModifiedDate, planningApplicationsUpdated[0].LastModifiedDate, 'The records LastModifiedDate should not be the same');
        //System.assertNotEquals(planningApplications[1].LastModifiedDate, planningApplicationsUpdated[1].LastModifiedDate, 'The records LastModifiedDate should not be the same');
    }
}