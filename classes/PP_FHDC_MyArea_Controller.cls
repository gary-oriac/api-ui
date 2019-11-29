/*
    TODO: discuss the User,Contact, gazetteer objs field access with Doug
*/
public without sharing class PP_FHDC_MyArea_Controller
{
    //call the MyArea API integration to to retrieve latest C.Tax and bin collections info
    @AuraEnabled
    public static String requestLatestMyAreaData(Id contactId)
    {
        String friendlyMessage = 'success';
        try
        {
            //get 'Synced' arcusgazetteer__Location__c RT Id (to check for FHDC locations only)
            Id syncedLocationRtId = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'arcusgazetteer__Location__c' AND Name = 'Synced' LIMIT 1].Id;
            //check if there is Location linked to the contact
            //query location link (?) for the contactId 
            List<arcusgazetteer__Location_Link__c> locLinkList = [
                SELECT Id, arcusgazetteer__Location__c, arcusgazetteer__Location__r.arcusgazetteer__UPRN__c, arcusgazetteer__Location__r.arcusgazetteer__BLPU__c, arcusgazetteer__Location__r.RecordTypeId
                FROM arcusgazetteer__Location_Link__c 
                WHERE arcusgazetteer__Contact__c = :contactId
                // AND arcusgazetteer__Location__r.RecordTypeId = :syncedLocationRtId
                LIMIT 1
            ];

            arcusgazetteer__Location_Link__c locLink;
            if(!locLinkList.isEmpty()){locLink = locLinkList[0];}

            if(locLink == null)
            {
                friendlyMessage = 'Sorry we cannot show you this now because you have not set an address on the Profile Details page';
            }
            else
            {
                // has location linked
                //
                //now check if FHDC location
                if(locLink.arcusgazetteer__Location__r.RecordTypeId != syncedLocationRtId)
                {
                    //return an error saying that address not supported
                    friendlyMessage = 'Sorry, this is service is only for residents of the Folkestone and Hythe Council Area';
                }
                else if(locLink.arcusgazetteer__Location__r.arcusgazetteer__BLPU__c != null)//if the lcation record is linked to a BLPU record
                {
                    //do stuff
                    //
                    //get Existing Routes data
                    arcusgazetteer__BLPU__c relatedBlpu;
                    List<arcusgazetteer__BLPU__c> relatedBlpuList = [
                        SELECT Id, Council_Tax_Band__c, Garden_Waste_Route__c, Garden_Waste_Route__r.Next_Execution_Date__c, Landfill_Waste_Route__c, Landfill_Waste_Route__r.Next_Execution_Date__c, Recycling_Waste_Route__c, Recycling_Waste_Route__r.Next_Execution_Date__c//, Food_Waste_Route__c, Food_Waste_Route__r.Next_Execution_Date__c
                        FROM arcusgazetteer__BLPU__c
                        WHERE Id = :locLink.arcusgazetteer__Location__r.arcusgazetteer__BLPU__c
                    ];
                    
                    if(!relatedBlpuList.isEmpty()) relatedBlpu = relatedBlpuList[0];
                    if(relatedBlpu != null)
                    {
                        //*****call the MyArea API integration********************* */
                        ArcI_DataMyArea pData = new ArcI_DataMyArea();
                        pData.uprn = locLink.arcusgazetteer__Location__r.arcusgazetteer__UPRN__c;
                        if(Test.isRunningTest() == true)
                        {
                            System.debug('about to Twist some fingers...');
                            pData.isSuccess = true;
                            String jsonToDeserialize = ArcI_ConnMyAreaMain_Mock.jsonStr;
                            jsonToDeserialize = jsonToDeserialize.replaceFirst('([a-zA-Z]*)TownCouncil', 'TownCouncil');
                            jsonToDeserialize = jsonToDeserialize.replaceFirst('([a-zA-Z]*)Special([a-zA-Z]*)', 'Special');
                            pData.MyAreaData = (ArcI_DataMyArea.MyAreaData)JSON.deserialize(jsonToDeserialize, ArcI_DataMyArea.MyAreaData.class);
                        }
                        else
                        {
                            ArcI_ServiceMyArea.getMyAreaBinsAndCtaxData(pData);
                        }
                        //*********************************************** */

                        //handle Bin Collections data
                        List<Route__c> routesToUpsert = new List<Route__c>();

                        //garden waste
                        if(pData.MyAreaData.HasGardenCollection != null && pData.MyAreaData.HasGardenCollection)//if there is no garden collection data avaialble then no point in doing further checks
                        {
                            Route__c gardenR = new Route__c();
                            gardenR.Previous_Scheduled_Date__c = Date.valueOf(pData.MyAreaData.GardenCollection.LastCollection);
                            gardenR.Next_Execution_Date__c = Date.valueOf(pData.MyAreaData.GardenCollection.NextCollection);
                            gardenR.Second_Execution_Date__c = Date.valueOf(pData.MyAreaData.GardenCollection.FutureCollection);
                            gardenR.Type_of_Round__c = 'Garden';

                            if(relatedBlpu.Garden_Waste_Route__c != null)
                            {
                                //check if update needed
                                if(relatedBlpu.Garden_Waste_Route__r.Next_Execution_Date__c == null || Date.today() > relatedBlpu.Garden_Waste_Route__r.Next_Execution_Date__c)
                                {
                                    gardenR.Id = relatedBlpu.Garden_Waste_Route__c;
                                    routesToUpsert.add(gardenR); //add to the list as we need to update the existing Route
                                }
                            }
                            else
                            {
                                //create new Route
                                routesToUpsert.add(gardenR); //add to list as we need to creat garden waste collection Route
                            }
                        }
                        
                        //recycling waste
                        if(pData.MyAreaData.HasRecyclingCollection != null && pData.MyAreaData.HasRecyclingCollection)//if there is no garden collection data avaialble then no point in doing further checks
                        {
                            Route__c recycleR = new Route__c();
                            recycleR.Previous_Scheduled_Date__c = Date.valueOf(pData.MyAreaData.RecyclingCollection.LastCollection);
                            recycleR.Next_Execution_Date__c = Date.valueOf(pData.MyAreaData.RecyclingCollection.NextCollection);
                            recycleR.Second_Execution_Date__c = Date.valueOf(pData.MyAreaData.RecyclingCollection.FutureCollection);
                            recycleR.Type_of_Round__c = 'Recycling';

                            if(relatedBlpu.Garden_Waste_Route__c != null)
                            {
                                //check if update needed
                                if(relatedBlpu.Recycling_Waste_Route__r.Next_Execution_Date__c == null || Date.today() > relatedBlpu.Recycling_Waste_Route__r.Next_Execution_Date__c)
                                {
                                    recycleR.Id = relatedBlpu.Recycling_Waste_Route__c;
                                    routesToUpsert.add(recycleR); //add to the list as we need to update the existing Route
                                }
                            }
                            else
                            {
                                //create new Route
                                routesToUpsert.add(recycleR); //add to list as we need to creat recycling waste collection Route
                            }
                        }

                        //landfill/refuse waste
                        if(pData.MyAreaData.HasRefuseCollection != null && pData.MyAreaData.HasRefuseCollection)//if there is no garden collection data avaialble then no point in doing further checks
                        {
                            Route__c landfillR = new Route__c();
                            landfillR.Previous_Scheduled_Date__c = Date.valueOf(pData.MyAreaData.RefuseCollection.LastCollection);
                            landfillR.Next_Execution_Date__c = Date.valueOf(pData.MyAreaData.RefuseCollection.NextCollection);
                            landfillR.Second_Execution_Date__c = Date.valueOf(pData.MyAreaData.RefuseCollection.FutureCollection);
                            landfillR.Type_of_Round__c = 'Landfill';

                            if(relatedBlpu.landfill_Waste_Route__c != null)
                            {
                                //check if update needed
                                if(relatedBlpu.Landfill_Waste_Route__r.Next_Execution_Date__c == null || Date.today() > relatedBlpu.Landfill_Waste_Route__r.Next_Execution_Date__c)
                                {
                                    landfillR.Id = relatedBlpu.landfill_Waste_Route__c;
                                    routesToUpsert.add(landfillR); //add to the list as we need to update the existing Route
                                }
                            }
                            else
                            {
                                //create new Route
                                routesToUpsert.add(landfillR); //add to list as we need to creat landfill waste collection Route
                            }
                        }


                        if(routesToUpsert.size() > 0) upsert routesToUpsert;
                        //populate the relevant Route lookups on the BLPU record and update the record
                        for(Route__c upsertedR: routesToUpsert)
                        {
                            if(upsertedR.Id != null)
                            {
                                if(upsertedR.Type_of_Round__c == 'Garden' && relatedBlpu.Garden_Waste_Route__c == null)
                                {
                                    relatedBlpu.Garden_Waste_Route__c = upsertedR.Id;
                                }
                                else if(upsertedR.Type_of_Round__c == 'Recycling' && relatedBlpu.Recycling_Waste_Route__c == null)
                                {
                                    relatedBlpu.Recycling_Waste_Route__c = upsertedR.Id;
                                }
                                else if(upsertedR.Type_of_Round__c == 'Landfill' && relatedBlpu.Landfill_Waste_Route__c == null)
                                {
                                    relatedBlpu.Landfill_Waste_Route__c = upsertedR.Id;
                                }
                            }
                        }
                        
                        //*******Council Tax data***************
                        //*********************************** */
                        if(pData.MyAreaData.HasCouncilTax)
                        {
                            if(String.isNotBlank(pData.MyAreaData.CouncilTax.Year) && String.isNotBlank(pData.MyAreaData.CouncilTax.Banding))
                            {
                                //set the C tax banding for the related BLPU record
                                relatedBlpu.Council_Tax_Band__c = pData.MyAreaData.CouncilTax.Banding;
                                
                                //find the existing band for the year
                                Council_Tax_Band__c cTaxBand;
                                List<Council_Tax_Band__c> cTaxBandList = [
                                    SELECT Id
                                    FROM Council_Tax_Band__c 
                                    WHERE Council_Tax_Year__c = :pData.MyAreaData.CouncilTax.Year AND Council_Tax_Band__c = :pData.MyAreaData.CouncilTax.Banding
                                    LIMIT 1
                                ];
                                // if band found, update the details
                                
                                if(!cTaxBandList.isEmpty())
                                {
                                    cTaxBand = cTaxBandList[0];
                                    //update the existing C tax band record
                                    if(String.isNotBlank(pData.MyAreaData.CouncilTax.TotalCharge)) cTaxBand.Council_Tax_Amount__c = Decimal.valueOf(pData.MyAreaData.CouncilTax.TotalCharge.replaceAll(',', ''));
                                    if(String.isNotBlank(pData.MyAreaData.CouncilTax.Precepts.KentCountyCouncil)) cTaxBand.County_Council_Amount__c = Decimal.valueOf(pData.MyAreaData.CouncilTax.Precepts.KentCountyCouncil.replaceAll(',', ''));
                                    if(String.isNotBlank(pData.MyAreaData.CouncilTax.Precepts.FolkestoneAndHytheDistrictCouncil)) cTaxBand.District_Council_Amount__c = Decimal.valueOf(pData.MyAreaData.CouncilTax.Precepts.FolkestoneAndHytheDistrictCouncil.replaceAll(',', ''));
                                    if(String.isNotBlank(pData.MyAreaData.CouncilTax.Precepts.KentFireAndRescueService)) cTaxBand.Fire_And_Rescue_Amount__c = Decimal.valueOf(pData.MyAreaData.CouncilTax.Precepts.KentFireAndRescueService.replaceAll(',', ''));
                                    if(String.isNotBlank(pData.MyAreaData.CouncilTax.Precepts.ThePoliceAndCrimeCommissionerForKent)) cTaxBand.Police_And_Crime_Amount__c = Decimal.valueOf(pData.MyAreaData.CouncilTax.Precepts.ThePoliceAndCrimeCommissionerForKent.replaceAll(',', ''));
                                    if(String.isNotBlank(pData.MyAreaData.CouncilTax.Precepts.KccAdultSocialCare)) cTaxBand.Social_Care_Amount__c = Decimal.valueOf(pData.MyAreaData.CouncilTax.Precepts.KccAdultSocialCare.replaceAll(',', ''));
                                    if(String.isNotBlank(pData.MyAreaData.CouncilTax.Precepts.TownCouncil)) cTaxBand.Town_Council_Amount__c = Decimal.valueOf(pData.MyAreaData.CouncilTax.Precepts.TownCouncil.replaceAll(',', ''));
                                    if(String.isNotBlank(pData.MyAreaData.CouncilTax.Precepts.Special)) cTaxBand.Special_1_Amount__c = Decimal.valueOf(pData.MyAreaData.CouncilTax.Precepts.Special.replaceAll(',', ''));
                                }
                                else
                                {
                                    //create a new ctax band (custom settings) record
                                    cTaxBand = new Council_Tax_Band__c();
                                    cTaxBand.Name = pData.MyAreaData.CouncilTax.Year + ' - Band ' + pData.MyAreaData.CouncilTax.Banding;
                                    cTaxBand.Council_Tax_Band__c = pData.MyAreaData.CouncilTax.Banding;
                                    cTaxBand.Council_Tax_Year__c = pData.MyAreaData.CouncilTax.Year;
                                    if(String.isNotBlank(pData.MyAreaData.CouncilTax.TotalCharge)) cTaxBand.Council_Tax_Amount__c = Decimal.valueOf(pData.MyAreaData.CouncilTax.TotalCharge.replaceAll(',', ''));
                                    if(String.isNotBlank(pData.MyAreaData.CouncilTax.Precepts.KentCountyCouncil)) cTaxBand.County_Council_Amount__c = Decimal.valueOf(pData.MyAreaData.CouncilTax.Precepts.KentCountyCouncil.replaceAll(',', ''));
                                    if(String.isNotBlank(pData.MyAreaData.CouncilTax.Precepts.FolkestoneAndHytheDistrictCouncil)) cTaxBand.District_Council_Amount__c = Decimal.valueOf(pData.MyAreaData.CouncilTax.Precepts.FolkestoneAndHytheDistrictCouncil.replaceAll(',', ''));
                                    if(String.isNotBlank(pData.MyAreaData.CouncilTax.Precepts.KentFireAndRescueService)) cTaxBand.Fire_And_Rescue_Amount__c = Decimal.valueOf(pData.MyAreaData.CouncilTax.Precepts.KentFireAndRescueService.replaceAll(',', ''));
                                    if(String.isNotBlank(pData.MyAreaData.CouncilTax.Precepts.ThePoliceAndCrimeCommissionerForKent)) cTaxBand.Police_And_Crime_Amount__c = Decimal.valueOf(pData.MyAreaData.CouncilTax.Precepts.ThePoliceAndCrimeCommissionerForKent.replaceAll(',', ''));
                                    if(String.isNotBlank(pData.MyAreaData.CouncilTax.Precepts.KccAdultSocialCare)) cTaxBand.Social_Care_Amount__c = Decimal.valueOf(pData.MyAreaData.CouncilTax.Precepts.KccAdultSocialCare.replaceAll(',', ''));
                                    System.debug('pData.MyAreaData.CouncilTax.Precepts: ' + pData.MyAreaData.CouncilTax.Precepts);
                                    System.debug('pData.MyAreaData.CouncilTax.Precepts.TownCouncil: ' + pData.MyAreaData.CouncilTax.Precepts.TownCouncil);
                                    if(String.isNotBlank(pData.MyAreaData.CouncilTax.Precepts.TownCouncil)) cTaxBand.Town_Council_Amount__c = Decimal.valueOf(pData.MyAreaData.CouncilTax.Precepts.TownCouncil.replaceAll(',', ''));
                                    if(String.isNotBlank(pData.MyAreaData.CouncilTax.Precepts.Special)) cTaxBand.Special_1_Amount__c = Decimal.valueOf(pData.MyAreaData.CouncilTax.Precepts.Special.replaceAll(',', ''));
                                }

                                upsert cTaxBand;
                            }
                        }
                        //update the BLPU record
                        update relatedBlpu;
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.debug('<ARCUS-PP_FHDC_MyArea_Controller.requestLatestMyAreaData()> !!ERRROr!! there was an error (line) >>> ' + ex.getLineNumber());
            System.debug('<ARCUS-PP_FHDC_MyArea_Controller.requestLatestMyAreaData()> !!ERRROr!! there was an error >>> ' + ex.getMessage());
            // friendlyMessage = 'Something went wrong. Unable to retrieve the up-to-date information || exception msg ('+ex.getLineNumber()+'): '+ex.getMessage();
            friendlyMessage = 'Something went wrong. Unable to retrieve the up-to-date information';
        }

        return friendlyMessage;
    }

    @AuraEnabled
    public static String refreshCouncillorsData()
    {
        String friendlyMessage = 'success';
        try
        {
            List<Councillor_Details__c> existingCouncillors = [
                SELECT Id, CreatedDate 
                FROM Councillor_Details__c
                ORDER BY CreatedDate ASC
            ];

            if(existingCouncillors == null || existingCouncillors.size() == 0 || existingCouncillors.size() > 0 && existingCouncillors[0].CreatedDate < Date.today())
            {
                //calls all the ModGov webservices and re-creates the Councillor_Details__c custom setting records
                List<Councillor_Details__c> councillorsAndMpsToInsertList = new List<Councillor_Details__c>();

                //county councillors
                arcusint.ArcI_DataMODGOVCountyCouncillors countyReqData = new arcusint.ArcI_DataMODGOVCountyCouncillors();
                countyReqData.sShortName = 'RParl';
                countyReqData.sOrder = '0';
                //call the external webservice
                arcusint.ArcI_ServiceMODGOV.getCountyCouncillors(countyReqData);

                if(Test.isRunningTest() == true)
                {
                    countyReqData = PP_FHDC_MyArea_Controller_MOCK.getCountyCouncillorsData();
                }

                if(countyReqData.isSuccess == true && countyReqData.countyCouncillorsList != null)
                {
                    for(arcusint.ArcI_DataMODGOVCommon.Member m: countyReqData.countyCouncillorsList)
                    {
                        //add to list of councillor custom setting
                        Councillor_Details__c councillor = new Councillor_Details__c(
                            // Ward_Code__c = ,
                            Political_Party__c = m.politicalPartyTitle,
                            Councillor_Type__c = 'County',//'Ward'//'MP'//'MEP'
                            Councillor_Phone__c = String.isNotBlank(m.workAddress.phone) ? m.workAddress.phone : String.isNotBlank(m.workAddress.mobile) ? m.workAddress.mobile : String.isNotBlank(m.homeAddress.mobile) ? m.homeAddress.mobile : m.homeAddress.phone,
                            // Councillor_Info_URL__c = ,
                            Councillor_Image_URL__c = m.photoBigUrl,
                            Councillor_Email__c = m.workAddress.email,
                            Name = m.fullusername
                        );

                        //add to the list
                        councillorsAndMpsToInsertList.add(councillor);
                    }
                }
                //ward councillors
                arcusint.ArcI_DataMODGOVWardCouncillors wardReqData = new arcusint.ArcI_DataMODGOVWardCouncillors();
                //call the external webservice
                arcusint.ArcI_ServiceMODGOV.getWardCouncillors(wardReqData);

                if(Test.isRunningTest() == true)
                {
                    wardReqData = PP_FHDC_MyArea_Controller_MOCK.getCouncillorsByWardData();
                }

                if(wardReqData.isSuccess == true && wardReqData.wardsList != null)
                {
                    for(arcusint.ArcI_DataMODGOVWardCouncillors.Ward w: wardReqData.wardsList)
                    {
                        String wardCode = getWardCode(w.wardTitle);
                    
                        for(arcusint.ArcI_DataMODGOVCommon.Member m: w.wardCouncillorsList)
                        {
                            //add to list of councillor custom setting
                            Councillor_Details__c councillor = new Councillor_Details__c(
                                Ward_Code__c = wardCode,
                                Political_Party__c = m.politicalPartyTitle,
                                Councillor_Type__c = 'Ward',//'MP'//'MEP'
                                Councillor_Phone__c = String.isNotBlank(m.workAddress.phone) ? m.workAddress.phone : String.isNotBlank(m.workAddress.mobile) ? m.workAddress.mobile : String.isNotBlank(m.homeAddress.mobile) ? m.homeAddress.mobile : m.homeAddress.phone,
                                // Councillor_Info_URL__c = ,
                                Councillor_Image_URL__c = m.photoBigUrl,
                                Councillor_Email__c = m.workAddress.email,
                                Name = m.fullusername
                            );

                            //add to the list
                            councillorsAndMpsToInsertList.add(councillor);
                        }
                    }
                }

                //mps
                arcusint.ArcI_DataMODGOVMps mpsReqData = new arcusint.ArcI_DataMODGOVMps();
                mpsReqData.bIsMPs = true;
                //call the external webservice
                arcusint.ArcI_ServiceMODGOV.getMps(mpsReqData);

                if(Test.isRunningTest() == true)
                {
                    mpsReqData = PP_FHDC_MyArea_Controller_MOCK.getMpsData();
                }

                if(mpsReqData.isSuccess == true && mpsReqData.mpsList != null)
                {
                    for(arcusint.ArcI_DataMODGOVCommon.Member m: mpsReqData.mpsList)
                    {
                        //add to list of councillor custom setting
                        Councillor_Details__c councillor = new Councillor_Details__c(
                            // Ward_Code__c = ,
                            Political_Party__c = m.politicalPartyTitle,
                            Councillor_Type__c = 'MP',//'MEP'
                            Councillor_Phone__c = String.isNotBlank(m.workAddress.phone) ? m.workAddress.phone : String.isNotBlank(m.workAddress.mobile) ? m.workAddress.mobile : String.isNotBlank(m.homeAddress.mobile) ? m.homeAddress.mobile : m.homeAddress.phone,
                            // Councillor_Info_URL__c = ,
                            Councillor_Image_URL__c = m.photoBigUrl,
                            Councillor_Email__c = m.workAddress.email,
                            Name = m.fullusername
                        );

                        //add to the list
                        councillorsAndMpsToInsertList.add(councillor);
                    }
                }

                if(councillorsAndMpsToInsertList.size() > 0)
                {
                    //delete existing records (we want to delete records only if there are new councillors & MPs to insert)
                    if(existingCouncillors.size() > 0) delete existingCouncillors;
                    //insert new records
                    insert councillorsAndMpsToInsertList;
                }
            }
        }
        catch (Exception ex)
        {
            System.debug('<ARCUS-PP_FHDC_MyArea_Controller.refreshCouncillorsData()> !!ERRROr!! there was an error (line) >>> ' + ex.getLineNumber());
            System.debug('<ARCUS-PP_FHDC_MyArea_Controller.refreshCouncillorsData()> !!ERRROr!! there was an error >>> ' + ex.getMessage());
            // friendlyMessage = 'Something went wrong. Unable to retrieve the up-to-date information || exception msg ('+ex.getLineNumber()+'): '+ex.getMessage();
            friendlyMessage = 'Something went wrong. Unable to retrieve the up-to-date information';
        }

        return friendlyMessage;
    }

    // public static String getPhoneNumber
    public static String getWardCode(String wardTitle)
    {
        Schema.DescribeFieldResult wardsPicklist = arcusgazetteer__BLPU__c.arcusgazetteer__Ward_Name__c.getDescribe();
        List<Schema.PicklistEntry> wardsPicklistValues = wardsPicklist.getPicklistValues();

        Map<String, String> wardTitleToWardCodeMap = new Map<String, String>();
        for(Schema.PicklistEntry picklistEntry: wardsPicklistValues)
        {
            // System.debug(picklistEntry);
            wardTitleToWardCodeMap.put(picklistEntry.getLabel(), picklistEntry.getValue());
        }
        // System.debug('wardTitleToWardCodeMap.get(\'Hythe Ward\') code: '+wardTitleToWardCodeMap.get('Hythe Ward'));
        return (wardTitle == 'Cheriton Ward') ? wardTitleToWardCodeMap.get('Cheriton') : (wardTitle == 'Sandgate and West Folkestone Ward') ? wardTitleToWardCodeMap.get('Sandgate & West Folkestone Ward') : wardTitleToWardCodeMap.get(wardTitle);
    }
}