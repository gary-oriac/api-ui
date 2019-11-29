@isTest
public with sharing class PBHelperAutoCreateDepAnswers_Test {

    @isTest
    static void testCreateDeptAnswers_single(){
        
        List<arcuslandcharge__Standard_Response__c> standardResponses = new List<arcuslandcharge__Standard_Response__c>();
        List<arcuslandcharge__LCApplication__c> lcSearches = new List<arcuslandcharge__LCApplication__c>();
        
        standardResponses.add(
            new arcuslandcharge__Standard_Response__c(
                arcuslandcharge__Response_Type__c = 'DeptAns Config',
                arcuslandcharge__Response__c = '{' +     
                        '\"arcuslandcharge__Usage__c\": \"Auto - Append\",' +
                        '\"arcuslandcharge__Questions_Asked__c\": \"arcuslandcharge__CON29R1_1j__c;arcuslandcharge__CON29R1_1k__c;arcuslandcharge__CON29R1_1l__c;arcuslandcharge__CON29R3_8__c\",' +
                        '\"arcuslandcharge__Respondant__c\": \"Land_Charges_Building_Control\"' +
                    '}'
            )
        );

        lcSearches.add(
            new arcuslandcharge__LCApplication__c(
                arcuslandcharge__CON29R1_1j__c = true,
                arcuslandcharge__Box_C__c = 'box c information'
            )
        );

        insert standardResponses;
        insert lcSearches;

        Test.startTest();
        PBHelperAutoCreateDepartmentalAnswers.createDeptAnswers(new List<Id>((new Map<Id, arcuslandcharge__LCApplication__c>(lcSearches).keyset())));
        Test.stopTest();
        
        List<arcuslandcharge__External_Answer__c> externalAnswers = [
            SELECT Id, arcuslandcharge__Box_C__c, arcuslandcharge__Status__c, arcuslandcharge__Land_Charge__c, arcuslandcharge__Standard_Response__c, arcuslandcharge__Instructions__c
            FROM arcuslandcharge__External_Answer__c
        ];
        
        System.assertEquals(1, externalAnswers.size(), '1 departmental answer should have been created because only 1 template (Standard Response) was matched.');
        System.assertEquals(lcSearches[0].Id, externalAnswers[0].arcuslandcharge__Land_Charge__c, 'Dept answer should lookup to the LC Search.');
        System.assertEquals('New', externalAnswers[0].arcuslandcharge__Status__c, 'Status should have been set.');
        System.assertEquals(standardResponses[0].Id, externalAnswers[0].arcuslandcharge__Standard_Response__c, 'Dept answer should lookup to the template.');
        System.assertEquals('This request was automatically generated - No additional instructions please answer the selected questions', externalAnswers[0].arcuslandcharge__Instructions__c, 'Instructions should have been set.');
        System.assertEquals('box c information', externalAnswers[0].arcuslandcharge__Box_C__c, 'Box C should have been copied over from the LC Search.');
    }

    @isTest
    static void testCreateDeptAnswers_single_negative(){
        
        List<arcuslandcharge__Standard_Response__c> standardResponses = new List<arcuslandcharge__Standard_Response__c>();
        List<arcuslandcharge__LCApplication__c> lcSearches = new List<arcuslandcharge__LCApplication__c>();
        
        standardResponses.add(
            new arcuslandcharge__Standard_Response__c(
                arcuslandcharge__Response_Type__c = 'DeptAns Config',
                arcuslandcharge__Response__c = '{' +     
                        '\"arcuslandcharge__Usage__c\": \"Auto - Append\",' +
                        '\"arcuslandcharge__Questions_Asked__c\": \"arcuslandcharge__CON29R1_1j__c;arcuslandcharge__CON29R1_1k__c;arcuslandcharge__CON29R1_1l__c;arcuslandcharge__CON29R3_8__c\",' +
                        '\"arcuslandcharge__Respondant__c\": \"Land_Charges_Building_Control\"' +
                    '}'
            )
        );

        lcSearches.add(
            new arcuslandcharge__LCApplication__c(
                arcuslandcharge__CON29R3_6f__c = true,
                arcuslandcharge__CON29R3_9e__c = true
            )
        );

        insert standardResponses;
        insert lcSearches;

        Test.startTest();
        PBHelperAutoCreateDepartmentalAnswers.createDeptAnswers(new List<Id>((new Map<Id, arcuslandcharge__LCApplication__c>(lcSearches).keyset())));
        Test.stopTest();
        
        List<arcuslandcharge__External_Answer__c> externalAnswers = [
            SELECT Id
            FROM arcuslandcharge__External_Answer__c
        ];

        System.assertEquals(0, externalAnswers.size(), 'No departmental answers should have been created because no templates matched the questions asked on the LC Search.');
    }

    @isTest
    static void testCreateDeptAnswers_single_brokenTemplate(){
        
        List<arcuslandcharge__Standard_Response__c> standardResponses = new List<arcuslandcharge__Standard_Response__c>();
        List<arcuslandcharge__LCApplication__c> lcSearches = new List<arcuslandcharge__LCApplication__c>();
        
        standardResponses.add(
            new arcuslandcharge__Standard_Response__c(
                arcuslandcharge__Response_Type__c = 'DeptAns Config',
                arcuslandcharge__Response__c = 'this is not a JSON'
            )
        );

        lcSearches.add(
            new arcuslandcharge__LCApplication__c(
                arcuslandcharge__CON29R3_6f__c = true,
                arcuslandcharge__CON29R3_9e__c = true
            )
        );

        insert standardResponses;
        insert lcSearches;

        Test.startTest();
        PBHelperAutoCreateDepartmentalAnswers.createDeptAnswers(new List<Id>((new Map<Id, arcuslandcharge__LCApplication__c>(lcSearches).keyset())));
        Test.stopTest();
        
        List<arcuslandcharge__External_Answer__c> externalAnswers = [
            SELECT Id
            FROM arcuslandcharge__External_Answer__c
        ];

        System.assertEquals(0, externalAnswers.size(), 'No departmental answers should have been created because the template\'s arcuslandcharge__Response__c field was in the wrong format.');
    }

    @isTest
    static void testCreateDeptAnswers_multi(){
        
        List<arcuslandcharge__Standard_Response__c> standardResponses = new List<arcuslandcharge__Standard_Response__c>();
        List<arcuslandcharge__LCApplication__c> lcSearches = new List<arcuslandcharge__LCApplication__c>();
        
        standardResponses.add(
            new arcuslandcharge__Standard_Response__c(
                arcuslandcharge__Response_Type__c = 'DeptAns Config',
                arcuslandcharge__Response__c = '{' +     
                        '\"arcuslandcharge__Usage__c\": \"Auto - Append\",' +
                        '\"arcuslandcharge__Questions_Asked__c\": \"arcuslandcharge__CON29R1_1j__c",' +
                        '\"arcuslandcharge__Respondant__c\": \"Land_Charges_Building_Control\"' +
                    '}'
            )
        );
        standardResponses.add(
            new arcuslandcharge__Standard_Response__c(
                arcuslandcharge__Response_Type__c = 'DeptAns Config',
                arcuslandcharge__Response__c = '{' +     
                        '\"arcuslandcharge__Usage__c\": \"Auto - Append\",' +
                        '\"arcuslandcharge__Questions_Asked__c\": \"arcuslandcharge__CON29R1_1l__c;arcuslandcharge__CON29R3_8__c\",' +
                        '\"arcuslandcharge__Respondant__c\": \"Land_Charges_Building_Control\"' +
                    '}'
            )
        );

        lcSearches.add(
            new arcuslandcharge__LCApplication__c(
                arcuslandcharge__CON29R1_1j__c = true,          //matches standardResponses[0]
                arcuslandcharge__Box_C__c = 'box c information'
            )
        );
        lcSearches.add(
            new arcuslandcharge__LCApplication__c(
                arcuslandcharge__CON29R1_1j__c = true,      //matches standardResponses[0]
                arcuslandcharge__CON29R1_1l__c = true,      //matches standardResponses[1]
                arcuslandcharge__CON29R3_8__c = true,       //matches standardResponses[1]
                arcuslandcharge__Box_C__c = 'box c information'
            )
        );

        insert standardResponses;
        insert lcSearches;

        Test.startTest();
        PBHelperAutoCreateDepartmentalAnswers.createDeptAnswers(new List<Id>((new Map<Id, arcuslandcharge__LCApplication__c>(lcSearches).keyset())));
        Test.stopTest();
        
        List<arcuslandcharge__External_Answer__c> externalAnswers = [
            SELECT Id, arcuslandcharge__Box_C__c, arcuslandcharge__Status__c, arcuslandcharge__Land_Charge__c, arcuslandcharge__Standard_Response__c, arcuslandcharge__Instructions__c
            FROM arcuslandcharge__External_Answer__c
        ];
        
        System.assertEquals(3, externalAnswers.size(), '3 departmental answers should have been created because lcSearches[0] matched standardResponses[0], and lcSearches[1] matched standardResponses[0] and standardResponses[1].');
    }
    
}