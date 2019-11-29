/* 
Company    :    Arcus Global
Product    :    Arcus DSH 
Purpose    :    An apex page controller for the Case History page
Notes      :    
*/
public without sharing class DSHLC_CaseHistoryCont extends DSHLC_ConfigSettings {
    @AuraEnabled
    public static List<CaseListWrapper> getCases() {
        User loggedInUser = DSHLC_UserContact.getUserContact();
        Id ContactId = loggedInUser.Contact.Id;
        List<Case> caseList = [
            SELECT 
                CaseNumber, 
                ClosedDate, 
                CreatedDate,
                Status, 
                Subject, 
                Description,
                RecordTypeId
            FROM 
                Case 
            WHERE 
                ContactId = :ContactId 
            AND
                Status != 'Draft'
            ORDER BY
            	CreatedDate DESC
        ];
        List<CaseListWrapper> caseListWrapper = new List<CaseListWrapper>();
        for(case caseDetail:caseList) {
            caseListWrapper.add(new CaseListWrapper(caseDetail));
        }

        return caseListWrapper;
    }


    public class CaseListWrapper {
        @AuraEnabled public String CaseNumber;
        @AuraEnabled public String createdDate;
        @AuraEnabled public String Status;
        @AuraEnabled public String Subject;
        @AuraEnabled public String Description;

        public CaseListWrapper(case caseDetail){
            CaseNumber = caseDetail.CaseNumber;
            createdDate = caseDetail.CreatedDate.format('dd/MM/YYYY');
            Status = caseDetail.Status;
            Subject = caseDetail.Subject;
            Description = caseDetail.Description;
        }

    }
}