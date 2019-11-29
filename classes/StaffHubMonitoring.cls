public class StaffHubMonitoring {
    public static Map<Id,Case> analyse(){
        List<Case> casesStaffHub;
        casesStaffHub = [SELECT Id, Origin, OwnerId, CaseNumber, Contact.Name,Contact.arcuscrm__Linked_Internal_User__c , AccountId, RecordType.Name, CreatedDate, Description  FROM Case WHERE Contact.arcuscrm__Linked_Internal_User__c != NULL AND CreatedDate > 2019-11-19T00:00:00Z ORDER BY CreatedDate];
        Map<Id,Case> casesRequiringSharing = new Map<Id,Case>();
        for(Case i : casesStaffHub){
            if(i.OwnerId != i.Contact.arcuscrm__Linked_Internal_User__c) casesRequiringSharing.put(i.Id, i);
        }
        
        Integer casesRequiringSharingSize = casesRequiringSharing.size();
        System.debug('Cases requiring sharing: ' + casesRequiringSharingSize);
        
        List<CaseShare> caseShares;
        caseShares = [SELECT Id, CaseId,Case.CreatedDate,  Case.CaseNumber, RowCause, UserOrGroupId, UserOrGroup.Name FROM CaseShare WHERE RowCause = 'Manual' ORDER BY Case.CreatedDate];
        
        Integer caseSharesSize = caseShares.size();
        System.debug('Case Shares existing: ' + caseSharesSize);
        
        for(CaseShare x : caseShares){
            //Case bob = casesRequiringSharing.get(x.CaseId);
            casesRequiringSharing.remove(x.CaseId);
        }
        
        Integer casesRequiringSharingSizeAfter = casesRequiringSharing.size();
        System.debug('Cases missing required sharing: ' + casesRequiringSharingSizeAfter);
        
        if(casesRequiringSharing.size()>0){
            System.debug('BROKEN CASES:');
            for(Case y : casesRequiringSharing.values()){System.debug('* * * * * * * * * * * * * * * * * * * *');System.debug('Case: ' + y.CaseNumber);System.debug('Id: ' + y.Id);System.debug('Origin: ' + y.Origin);System.debug('CreatedDate: ' + y.CreatedDate);
            }
        }
        else{
            String message = 'No';
            message = message + 'Broken Cases';
            System.debug(message);
        } 
        
        return casesRequiringSharing;
    }
    
    public static void repair(Map<Id,Case> casesToRepair){
        List<Case> repairTheseCases = new List<Case>();
        if(casesToRepair.size() > 0){
            for(Case c : casesToRepair.values()){
                c.Description = c.Description + ' ';
                repairTheseCases.add(c);
            }
            
            update repairTheseCases;
            System.debug('REPAIRED BROKEN CASES');
        }
        else{
            String message = 'NO';
            message = message + 'CASES TO REPAIR';
            System.debug(message);
        } 
    }
    
    public static void repairAll(){
        Map<Id,Case> casesToRepair = analyse();
        List<Case> repairTheseCases = new List<Case>();
        if(casesToRepair.size() > 0){
            for(Case c : casesToRepair.values()){
                c.Description = c.Description + ' ';
                repairTheseCases.add(c);
            }
            
            update repairTheseCases;
            System.debug('REPAIRED ALL BROKEN CASES');
        }
        else{
            String message = 'NO';
            message = message + 'CASES TO REPAIR';
            System.debug(message);
        } 
    }
}