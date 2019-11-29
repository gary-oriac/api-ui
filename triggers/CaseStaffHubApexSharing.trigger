trigger CaseStaffHubApexSharing on Case (after insert, after update) {
    if(trigger.isUpdate && trigger.isAfter){
        List<CaseShare> caseShares = new List<CaseShare>();
        List<Case> eligibleCases = new List<Case>();
        
        List<Case> newCases = [SELECT Id, OwnerId, ContactID, Contact.arcuscrm__Linked_Internal_User__c FROM Case WHERE Id IN :trigger.new];
        for(Case ca : newCases){
            //Sort only cases that are relevant
            if(ca.ContactId != null && ca.Contact.arcuscrm__Linked_Internal_User__c != null){
                if(ca.OwnerId != ca.Contact.arcuscrm__Linked_Internal_User__c){
                	eligibleCases.add(ca);    
                }
            }
        }

        for(Case c : eligibleCases){
            CaseShare customerShare = new CaseShare();
            customerShare.CaseId = c.Id;
            customerShare.UserOrGroupId = c.Contact.arcuscrm__Linked_Internal_User__c;
            customerShare.CaseAccessLevel = 'edit';
            customerShare.RowCause = 'Manual';
            //customerShare.RowCause = Schema.CaseShare.RowCause.ContactId; //This doesn't seem to work in any form
            caseShares.add(customerShare);
        }

        Database.SaveResult[] lsr = Database.insert(caseShares,false);
        
        for(Database.SaveResult sr : lsr){
            if(!sr.isSuccess()){
                System.debug('Error: ' + sr.getErrors()[0].getMessage());
            }
        }
    }
}