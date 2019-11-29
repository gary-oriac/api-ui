public without sharing class PR_QueryWithoutSharing {
    
    public static List<SObject> query(String query){
        return Database.query(query);
    }

}