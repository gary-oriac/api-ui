/*
Company    :    Arcus Global
Product    :    Arcus DSH (Lightning DSH Core)
Purpose    :    Apex controller for Councillor Homepage Widget
Notes      :
*/
public with sharing class DSHLC_WidgetCouncillorCont extends DSHLC_ConfigSettings {

	@AuraEnabled
	public static Map<String, Object> getData(String recordId) {
		Map<String, Object> data = new Map<String, Object>();

		String wardCode = getContextWardCode(recordId);
		List<Councillor_Details__c> councillors = getCouncillorsDetails(wardCode);
		Map<String, String> wardCodeToLabelMap = getWardCodeToLabelMap();
		data.put('wardCode', wardCode);
		data.put('councillors', councillors);
		data.put('wardCodeToLabelMap', wardCodeToLabelMap);

		return data;
	}

	@TestVisible
	private static String getContextWardCode(String recordId) {
		String wardcode;

		if(String.isNotBlank(recordId)) {
			List<Contact> contacts = [SELECT Id, arcusgazetteer__Mailing_Address__r.arcusgazetteer__Ward_Name__c FROM Contact WHERE Id = :recordId AND arcusgazetteer__Mailing_Address__c != NULL LIMIT 1];
			if (!contacts.isEmpty()) {
				wardcode = contacts[0].arcusgazetteer__Mailing_Address__r.arcusgazetteer__Ward_Name__c;
			}
		} else {
			User loggedInUser = DSHLC_UserContact.getUserContact();

			if (loggedInUser.ContactId != null && loggedInUser.Contact.arcusgazetteer__Mailing_Address__c != null) {
				wardcode = [SELECT arcusgazetteer__Ward_Name__c FROM arcusgazetteer__Location__c WHERE Id = :loggedInUser.Contact.arcusgazetteer__Mailing_Address__c].arcusgazetteer__Ward_Name__c;
			}
		}

		return wardCode;
	}

	@TestVisible
	private static List<Councillor_Details__c> getCouncillorsDetails(String wardCode) {
		List<Councillor_Details__c> councillors = new List<Councillor_Details__c>();

		if (String.isNotBlank(wardcode)) {
			councillors = [
				SELECT 
					Name,
					Councillor_Email__c,
					Councillor_Image_URL__c,
					Councillor_Info_URL__c,
					Councillor_Phone__c,
					Councillor_Type__c,
					Political_Party__c,
					Ward_Code__c

				FROM Councillor_Details__c 
				WHERE Ward_Code__c = :wardcode
				OR Councillor_Type__c = 'County'
				OR Councillor_Type__c = 'District'
				OR Councillor_Type__c = 'MP'
				OR Councillor_Type__c = 'MEP'
				ORDER BY Name ASC NULLS LAST
			];
		}

		return councillors;
	}

	@TestVisible
	private static Map<String, String> getWardCodeToLabelMap() {
		Map<String, String> wardCodeToLabelMap = new Map<String, String>();
		for (Schema.PicklistEntry entry : arcusgazetteer__Location__c.arcusgazetteer__Ward_Name__c.getDescribe().getPicklistValues()) {
			wardCodeToLabelMap.put(entry.getValue(), entry.getLabel());
		}

		return wardCodeToLabelMap;
	}
}