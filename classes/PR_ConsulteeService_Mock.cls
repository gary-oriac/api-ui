public with sharing class PR_ConsulteeService_Mock extends PR_ConsulteeService {
	public override Map<String, Object> getViewConsultationsConfig(String configDevName, String filter) {
		return new Map<String, Object>();
	}

	public override Boolean hasConsultationRequest(Map<String, String> params) {
		return true;
	}

	public override void saveComment(arcshared__Web_Comment__c comment, List<Id> documentIds, Map<String, String> params) {
	}
}