public with sharing class PR_ViewConsultationsCont {
	
	@AuraEnabled
	public static Map<String, Object> getConfigurations(String serviceClassName, String configDevName, String filter) {
		Map<String, Object> config = new Map<String, Object>();
		if (String.isNotBlank(serviceClassName) && String.isNotBlank(configDevName)) {
			PR_ConsulteeService service = (PR_ConsulteeService)Type.forName(serviceClassName).newInstance();
			config = service.getViewConsultationsConfig(configDevName, filter);
		}

		return config;
	}
}