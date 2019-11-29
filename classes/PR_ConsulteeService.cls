public with sharing abstract class PR_ConsulteeService {

	public static Boolean isAuthenticatedConsultee(){
		//This query is not CRUD checked as it used to restrict functionality for a particular profile.
		if(UserInfo.getUserType() == 'Guest') return false;
		else{
			User user = [SELECT ContactId FROM User WHERE Id =: UserInfo.getUserId()];
			if(user.ContactId == null) return false;
			else return true;
		}
	}

	public abstract Map<String, Object> getViewConsultationsConfig(String configDevName, String filter);
	public abstract Boolean hasConsultationRequest(Map<String, String> params);
	public abstract void saveComment(arcshared__Web_Comment__c comment, List<Id> documentIds, Map<String, String> params);
}