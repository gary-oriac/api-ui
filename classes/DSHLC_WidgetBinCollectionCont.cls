/*
Company    :    Arcus Global
Product    :    Arcus DSH
Purpose    :    An apex page controller for the Bin collection homepage widget
Notes      :
 */
public with sharing class DSHLC_WidgetBinCollectionCont {

	@AuraEnabled
	public static arcusgazetteer__Location__c getRouteDetail(String recordId) {
		arcusgazetteer__Location__c location;
        String locationId;
		if(recordId != null ) {
			Contact c = [SELECT Id, arcusgazetteer__Mailing_Address__c FROM Contact WHERE Id = :recordId];
			if (c != null) {
				locationId = c.arcusgazetteer__Mailing_Address__c;
			}
		} else {
			User loggedInUser = DSHLC_UserContact.getUserContact();
    		locationId = loggedInUser.Contact.arcusgazetteer__Mailing_Address__c;
		}

		if (String.isNotBlank(locationId)) {
			location = [
				SELECT
					Id,
					arcusgazetteer__BLPU__r.Landfill_Waste_Route__r.Name,
					arcusgazetteer__BLPU__r.Landfill_Waste_Route__r.Type_of_Round__c,
					arcusgazetteer__BLPU__r.Landfill_Waste_Route__r.Next_Execution_Date__c,
					arcusgazetteer__BLPU__r.Landfill_Waste_Route__r.Previous_Scheduled_Date__c,
					arcusgazetteer__BLPU__r.Landfill_Waste_Route__r.Second_Execution_Date__c,
					arcusgazetteer__BLPU__r.Landfill_Waste_Route__r.Schedule_Day__c,
					arcusgazetteer__BLPU__r.Landfill_Waste_Route__r.Schedule_URL__c,
					arcusgazetteer__BLPU__r.Landfill_Waste_Route__r.Route_Description__c,

					arcusgazetteer__BLPU__r.Recycling_Waste_Route__r.Name,
					arcusgazetteer__BLPU__r.Recycling_Waste_Route__r.Type_of_Round__c,
					arcusgazetteer__BLPU__r.Recycling_Waste_Route__r.Next_Execution_Date__c,
					arcusgazetteer__BLPU__r.Recycling_Waste_Route__r.Previous_Scheduled_Date__c,
					arcusgazetteer__BLPU__r.Recycling_Waste_Route__r.Second_Execution_Date__c,
					arcusgazetteer__BLPU__r.Recycling_Waste_Route__r.Schedule_Day__c,
					arcusgazetteer__BLPU__r.Recycling_Waste_Route__r.Schedule_URL__c,
					arcusgazetteer__BLPU__r.Recycling_Waste_Route__r.Route_Description__c,

					arcusgazetteer__BLPU__r.Food_Waste_Route__r.Name,
					arcusgazetteer__BLPU__r.Food_Waste_Route__r.Type_of_Round__c,
					arcusgazetteer__BLPU__r.Food_Waste_Route__r.Next_Execution_Date__c,
					arcusgazetteer__BLPU__r.Food_Waste_Route__r.Previous_Scheduled_Date__c,
					arcusgazetteer__BLPU__r.Food_Waste_Route__r.Second_Execution_Date__c,
					arcusgazetteer__BLPU__r.Food_Waste_Route__r.Schedule_Day__c,
					arcusgazetteer__BLPU__r.Food_Waste_Route__r.Schedule_URL__c,
					arcusgazetteer__BLPU__r.Food_Waste_Route__r.Route_Description__c,

					arcusgazetteer__BLPU__r.Garden_Waste_Route__r.Name,
					arcusgazetteer__BLPU__r.Garden_Waste_Route__r.Type_of_Round__c,
					arcusgazetteer__BLPU__r.Garden_Waste_Route__r.Next_Execution_Date__c,
					arcusgazetteer__BLPU__r.Garden_Waste_Route__r.Previous_Scheduled_Date__c,
					arcusgazetteer__BLPU__r.Garden_Waste_Route__r.Second_Execution_Date__c,
					arcusgazetteer__BLPU__r.Garden_Waste_Route__r.Schedule_Day__c,
					arcusgazetteer__BLPU__r.Garden_Waste_Route__r.Schedule_URL__c,
					arcusgazetteer__BLPU__r.Garden_Waste_Route__r.Route_Description__c

				FROM arcusgazetteer__Location__c
				WHERE Id = :locationId
				LIMIT 1
			];
		}

        return location;
	}

}