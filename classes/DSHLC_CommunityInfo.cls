/*
Author     :    Robert Meadows
Company    :    Arcus Global
Product    :    Arcus Citizen
Date       :    
Purpose    :    A method to get the current community name (formatted)
Notes      :    
Modified   :    
 */
public with sharing class DSHLC_CommunityInfo {
    private static Map<String, StringWrapper>  comm = new Map<String, StringWrapper>();
    public static final String DEFAULT_LIGHTNING_COMMUNITY_RESIDENT = 'resident2';
    public static final String DEFAULT_LIGHTNING_COMMUNITY_BUSINESS = 'business2';
    public static String defaultCommunity = DEFAULT_LIGHTNING_COMMUNITY_RESIDENT;

    @testVisible
    private static StringWrapper obtainCommunity() {
        StringWrapper result = new StringWrapper('');
        if (Network.getNetworkId() != null) {
            result = comm.get(Network.getNetworkId());
            if (result == null) {
                result = new StringWrapper([SELECT id, name FROM Network WHERE id =:Network.getNetworkId() LIMIT 1].name);
                comm.put(Network.getNetworkId(), result);
            }
        } else {
            result = new StringWrapper(defaultCommunity);
        }
        System.debug('<ARCUS> the value of community is '+result);
        return result;
    }

    @TestVisible
    public static StringWrapper getCommunity() {
        return obtainCommunity();
    }

    @TestVisible
    public static String getCommunityType() {
        String communitySC = getCommunity().SC;
        String communityType = communitySC.removeEnd('2');
        return communityType;
    }

    public class StringWrapper{
        public String ORIGINAL {get;private set;}

        public String UC {
            get{
                return ORIGINAL.toUpperCase();
            }
        }
        public String LC {
            get{
                return ORIGINAL.toLowerCase();
            }
        }
        public String SC {
            get{
                return ORIGINAL.subString ( 0 , 1 ).toUpperCase() + ORIGINAL.substring(1).toLowerCase();
            }
        }

        public StringWrapper(String s){
            this.ORIGINAL = s;
        }
    }
}