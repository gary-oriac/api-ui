public class PBHelperDoNothing {
    
    @InvocableMethod(label='Do Nothing' description='Does nothing')
	public static void doNothing(List<id> ids) {
     	//This method does nothing, is just used to terminate process builder logic chains
    	return;
    }


}