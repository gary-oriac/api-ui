@isTest
public class AddCalendarMonthsToDate_Test {
    @IsTest
    public static void test_getAddCalendarMonths() {
        arcusbuiltenv__Planning_Application__c pa =  new arcusbuiltenv__Planning_Application__c();
        pa.arcusbuiltenv__EOT_Start_Date__c = System.today();
        insert pa;

        List<AddCalendarMonthsToDate.Param> params =  new List<AddCalendarMonthsToDate.Param>();
        AddCalendarMonthsToDate.Param param = new AddCalendarMonthsToDate.Param();
        param.currentRecordId = pa.Id;
        param.baseDateFieldApiName = 'arcusbuiltenv__EOT_Start_Date__c';
        param.targetDateFieldApiName = 'arcusbuiltenv__EOT_End_Date__c';
        param.numOfMonths = 2;
        params.add( param );

        AddCalendarMonthsToDate.addCalendarMonths( params );

        arcusbuiltenv__Planning_Application__c insertedPA = [SELECT Id, arcusbuiltenv__EOT_End_Date__c FROM arcusbuiltenv__Planning_Application__c WHERE Id = :pa.Id];               
        Date endDate = pa.arcusbuiltenv__EOT_Start_Date__c.addMonths(2);
        
        System.assertEquals(insertedPA.arcusbuiltenv__EOT_End_Date__c, endDate , 'EOT end date should be 2 months later then EOT start date.' );
    }
}