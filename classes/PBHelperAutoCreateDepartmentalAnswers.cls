public class PBHelperAutoCreateDepartmentalAnswers {
    
    @InvocableMethod(label='Auto Create Dept Answers' 
                     description='Creates departmental answers based on the template records (Standard Response object) that ask questions that are asked on the LC Search record'
                    )

    public static void createDeptAnswers(List<Id> searchIDs) {
        
        Map<Id, arcuslandcharge__LCApplication__c> searchMap = new Map<Id, arcuslandcharge__LCApplication__c>(queryLCSearches(searchIDs));

        List<arcuslandcharge__Standard_Response__c> stdResList = [
            SELECT Id, arcuslandcharge__Response__c
            FROM arcuslandcharge__Standard_Response__c 
            WHERE arcuslandcharge__Response_Type__c = 'DeptAns Config'];


        //for each LC Search, create a Departmental Answer for each template where at least one of the questions is ticked on the LC Search
        List<arcuslandcharge__External_Answer__c> deptAns2Insert = new List<arcuslandcharge__External_Answer__c>();
        for (Id searchID : searchIDs)
        {
            for(arcuslandcharge__Standard_Response__c template : stdResList)
            {
                Boolean thisTemplateIsRelevant = atLeastOneQuestionWasAsked(searchMap.get(searchID), template);
                if(thisTemplateIsRelevant)
                {
                    arcuslandcharge__External_Answer__c extAns = new arcuslandcharge__External_Answer__c();
                    extAns.arcuslandcharge__Land_Charge__c = searchID;
                    extAns.arcuslandcharge__Status__c = 'New';
                    extAns.arcuslandcharge__Standard_Response__c = template.Id;
                    extAns.arcuslandcharge__Instructions__c = 'This request was automatically generated - No additional instructions please answer the selected questions';
                    extAns.arcuslandcharge__Box_C__c = searchMap.get(searchID).arcuslandcharge__Box_C__c;
                    deptAns2Insert.add(extAns);
                }
            }                        
        }
        
        if(deptAns2Insert.size() > 0){
            insert deptAns2Insert;
        }
    }

    private static Boolean atLeastOneQuestionWasAsked(arcuslandcharge__LCApplication__c lcSearch, arcuslandcharge__Standard_Response__c template){
        List<String> questionsAsked = getQuestionsAskedFromTemplateJSON(template.arcuslandcharge__Response__c);

        for(String question : questionsAsked)
        {
            Boolean questionWasAsked = Boolean.valueOf(lcSearch.get(question));
            if(questionWasAsked)
            {
                return true;
            }
        }

        return false;
    }

    private static List<String> getQuestionsAskedFromTemplateJSON(String jsonToParse){
        List<String> output = new List<String>();

        try{
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonToParse);
            String questionsAsked = String.valueOf(responseMap.get('arcuslandcharge__Questions_Asked__c'));
            output = questionsAsked.split(';');
        }
        catch(Exception e){
            //jsonToParse was not in expected format. Silently fail, because we don't want one broken config record to cause loads of exceptions. 
        }

        return output;
    }

    private static List<arcuslandcharge__LCApplication__c> queryLCSearches(List<Id> searchIDs){
        return [
            SELECT  Id, arcuslandcharge__Search_Type__c, arcuslandcharge__Box_C__c, 
                    arcuslandcharge__CON29R1_1a__c, arcuslandcharge__CON29R1_1b__c, arcuslandcharge__CON29R1_1c__c, arcuslandcharge__CON29R1_1d__c, arcuslandcharge__CON29R1_1e__c, 
                    arcuslandcharge__CON29R1_1f__c, arcuslandcharge__CON29R1_1g__c, arcuslandcharge__CON29R1_1h__c, arcuslandcharge__CON29R1_1i__c, arcuslandcharge__CON29R1_1j__c, 
                    arcuslandcharge__CON29R1_1k__c, arcuslandcharge__CON29R1_1l__c, arcuslandcharge__CON29R1_2__c, arcuslandcharge__CON29O10_1__c, arcuslandcharge__CON29O10_2__c, 
                    arcuslandcharge__CON29O10_3__c, arcuslandcharge__CON29O11_1__c, arcuslandcharge__CON29O11_2__c, arcuslandcharge__CON29O12_1__c, arcuslandcharge__CON29O12_2__c, 
                    arcuslandcharge__CON29O12_3__c, arcuslandcharge__CON29O13__c, arcuslandcharge__CON29O14_1__c, arcuslandcharge__CON29O14_2__c, arcuslandcharge__CON29O15__c, 
                    arcuslandcharge__CON29O15_2__c, arcuslandcharge__CON29O16__c, arcuslandcharge__CON29O17_1__c, arcuslandcharge__CON29O17_2a__c, arcuslandcharge__CON29O17_2b__c, 
                    arcuslandcharge__CON29O18__c, arcuslandcharge__CON29O19__c, arcuslandcharge__CON29R2_1a__c, arcuslandcharge__CON29R2_1b__c, arcuslandcharge__CON29R2_1c__c, 
                    arcuslandcharge__CON29R2_1d__c, arcuslandcharge__CON29R2_2__c, arcuslandcharge__CON29R2_3__c, arcuslandcharge__CON29R2_4__c, arcuslandcharge__CON29R2_5__c, 
                    arcuslandcharge__CON29O20_1__c, arcuslandcharge__CON29O20_2a__c, arcuslandcharge__CON29O20_2b__c, arcuslandcharge__CON29O21__c, arcuslandcharge__CON29O22_1__c, 
                    arcuslandcharge__CON29O22_2__c, arcuslandcharge__CON29O22_3__c, arcuslandcharge__CON29R3_1__c, arcuslandcharge__CON29R3_10a__c, arcuslandcharge__CON29R3_10b__c, 
                    arcuslandcharge__CON29R3_10c__c, arcuslandcharge__CON29R3_10d__c, arcuslandcharge__CON29R3_10e__c, arcuslandcharge__CON29R3_10f__c, arcuslandcharge__CON29R3_10g__c, 
                    arcuslandcharge__CON29R3_10h__c, arcuslandcharge__CON29R3_11a__c, arcuslandcharge__CON29R3_11b__c, arcuslandcharge__CON29R3_12__c, arcuslandcharge__CON29R3_13a__c, 
                    arcuslandcharge__CON29R3_13b__c, arcuslandcharge__CON29R3_13c__c, arcuslandcharge__CON29R3_14__c, arcuslandcharge__CON29R3_15a__c, arcuslandcharge__CON29R3_15b__c, 
                    arcuslandcharge__CON29R3_2__c, arcuslandcharge__CON29R3_3a__c, arcuslandcharge__CON29R3_3b__c, arcuslandcharge__CON29R3_3c__c, arcuslandcharge__CON29R3_4a__c, 
                    arcuslandcharge__CON29R3_4b__c, arcuslandcharge__CON29R3_4c__c, arcuslandcharge__CON29R3_4d__c, arcuslandcharge__CON29R3_4e__c, arcuslandcharge__CON29R3_4f__c, 
                    arcuslandcharge__CON29R3_5a__c, arcuslandcharge__CON29R3_5b__c, arcuslandcharge__CON29R3_6a__c, arcuslandcharge__CON29R3_6b__c, arcuslandcharge__CON29R3_6c__c, 
                    arcuslandcharge__CON29R3_6d__c, arcuslandcharge__CON29R3_6e__c, arcuslandcharge__CON29R3_6f__c, arcuslandcharge__CON29R3_6g__c, arcuslandcharge__CON29R3_6h__c, 
                    arcuslandcharge__CON29R3_6i__c, arcuslandcharge__CON29R3_6j__c, arcuslandcharge__CON29R3_6k__c, arcuslandcharge__CON29R3_6l__c, arcuslandcharge__CON29R3_7a__c, 
                    arcuslandcharge__CON29R3_7b__c, arcuslandcharge__CON29R3_7c__c, arcuslandcharge__CON29R3_7d__c, arcuslandcharge__CON29R3_7e__c, arcuslandcharge__CON29R3_7f__c, 
                    arcuslandcharge__CON29R3_7g__c, arcuslandcharge__CON29R3_8__c, arcuslandcharge__CON29R3_9a__c, arcuslandcharge__CON29R3_9b__c, arcuslandcharge__CON29R3_9c__c, 
                    arcuslandcharge__CON29R3_9d__c, arcuslandcharge__CON29R3_9e__c, arcuslandcharge__CON29R3_9f__c, arcuslandcharge__CON29R3_9g__c, arcuslandcharge__CON29R3_9h__c, 
                    arcuslandcharge__CON29R3_9i__c, arcuslandcharge__CON29R3_9j__c, arcuslandcharge__CON29R3_9k__c, arcuslandcharge__CON29R3_9l__c, arcuslandcharge__CON29R3_9m__c, 
                    arcuslandcharge__CON29R3_9n__c, arcuslandcharge__CON29O4a__c, arcuslandcharge__CON29O4b__c, arcuslandcharge__CON29O5_1__c, arcuslandcharge__CON29O5_2__c, 
                    arcuslandcharge__CON29O5_3a__c, arcuslandcharge__CON29O5_3b__c, arcuslandcharge__CON29O5_3c__c, arcuslandcharge__CON29O5_3d__c, arcuslandcharge__CON29O5_3e__c, 
                    arcuslandcharge__CON29O6__c, arcuslandcharge__CON29O6_3a__c, arcuslandcharge__CON29O6_3b__c, arcuslandcharge__CON29O6_3c__c, arcuslandcharge__CON29O6_3d__c, 
                    arcuslandcharge__CON29O6_3e__c, arcuslandcharge__CON29O7_1__c, arcuslandcharge__CON29O7_2__c, arcuslandcharge__CON29O8__c, arcuslandcharge__CON29O9__c
            FROM arcuslandcharge__LCApplication__c 
            WHERE Id IN :searchIDs
        ];
    }

    
}