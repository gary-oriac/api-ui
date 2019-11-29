public with sharing class CRM_FireAssignmentRuleForCases  implements Queueable{

    
    private Set<Id> caseIds;

    public CRM_FireAssignmentRuleForCases(Set<Id> caseIds) {
        this.caseIds = caseIds;
    }

    public void execute(QueueableContext context){
        List<Case> casesToUpdate = [SELECT Id FROM Case WHERE Id IN :caseIds];
        System.debug('CRM_FireAssignmentRuleForCases ');
        System.debug('CRM_FireAssignmentRuleForCases  caseIds = ' + caseIds);
        System.debug('CRM_FireAssignmentRuleForCases  casesToUpdate = ' + casesToUpdate);
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;
                    
        for(Case c : casesToUpdate){
            c.setOptions(dmo);
        }

        update casesToUpdate;
    }
}