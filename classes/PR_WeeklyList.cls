public with sharing class PR_WeeklyList {
    public String name {get;set;}
    public String label {get;set;}
    public String restriction_field {get;set;}

    public static List<PR_WeeklyList> parse(String weeklyListJson) {
        return (List<PR_WeeklyList>)JSON.deserialize(weeklyListJson, List<PR_WeeklyList>.class);
    }
}