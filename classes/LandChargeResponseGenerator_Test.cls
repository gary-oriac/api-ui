@isTest
public class LandChargeResponseGenerator_Test {
    private static final String SAMPLE_GIS_RAW_DATA = '{"QuerySetName":[{"typeOfQuery":"Intersect","queryName":"Advert control","queryConfigurationID":"a3o1q0000001tI9AAI","layerName":"Advert_control","layerDevName":"Advert_control","bufferValue":"0","data":[{"6":{"FID":6,"AREA":0,"PERIMETER":20494.451,"REFDESC":"Aylesbury Area excluded from special advert control","KEYVAL":6,"GlobalID":"2ea26014-c34a-4570-bcdc-1fa0ebc0c392","Shape__Area":26799181.7403564,"Shape__Length":33135.5214377157}}],"mapName":"Planning"},{"typeOfQuery":"Intersect","queryName":"Aero Zones","queryConfigurationID":"a3o1q0000001tRHAAY","layerName":"AERO_Zones","layerDevName":"Aero_Zones","bufferValue":"0","data":[{}],"mapName":"Planning"}]}';

    private static arcuslandcharge__LCApplication__c searchRecord = new arcuslandcharge__LCApplication__c(
        arcuslandcharge__LLC1_1__c = true,
        arcuslandcharge__LLC1_2__c = true,
        arcuslandcharge__LLC1_3__c = true,
        arcuslandcharge__LLC1_4__c = true,
        arcuslandcharge__LLC1_5__c =  true,
        arcuslandcharge__LLC1_6__c = true,
        arcuslandcharge__LLC1_7__c = true,
        arcuslandcharge__LLC1_8__c = true,
        arcuslandcharge__LLC1_9__c = true,
        arcuslandcharge__LLC1_10__c = true,
        arcuslandcharge__LLC1_11__c = true,
        arcuslandcharge__LLC1_12__c = true
    );

    private static testMethod void testDeserialiseGISDataString(){
        Test.startTest();
        List<LandChargeResponseGenerator.GISQueryResult> rawGISData = LandChargeResponseGenerator.deserialiseGISDataString(SAMPLE_GIS_RAW_DATA);
        Map<String, Map<String, Map<String, Object>>> normalisedData = LandChargeResponseGenerator.normaliseGISData(rawGISData);
        Test.stopTest();

        System.assertEquals(2, rawGISData.size(), 'Incorrect length of deserialised data.  Input: ' + SAMPLE_GIS_RAW_DATA + ' Ouptut: ' + rawGISData);
        System.assertEquals('Advert control', rawGISData[0].queryName, 'Incorrect query name. Ouptut: ' + rawGISData[0]);
        System.assertEquals('Aero Zones', rawGISData[1].queryName, 'Incorrect query name. Ouptut: ' + rawGISData[1]);
        System.assertEquals(1, rawGISData[0].data.size(), 'Incorrect length of data attribute in Advert control results.  Input: ' + SAMPLE_GIS_RAW_DATA + ' trimmed Ouptut: ' + rawGISData[0]);
        System.assertEquals('Aylesbury Area excluded from special advert control', rawGISData[0].data.get('6').get('REFDESC'), 'Incorrect value for REFDESC field in GIS data.  Input: ' + SAMPLE_GIS_RAW_DATA + ' trimmed Ouptut: ' + rawGISData[0].data.get('6'));

        System.assertEquals(2, normalisedData.size(), 'Incorrect number of data types in normalised data ' + normalisedData);
        System.assert(normalisedData.containsKey('Advert Control'), 'Advert Control should be in data types' + normalisedData);
        System.assert(normalisedData.containsKey('Aero_Zones'), 'Aero_Zones should be in data types' + normalisedData);
        System.assertEquals(1, normalisedData.get('Advert Control').size(), 'Incorrect number of records in normalised advert Control data ' + normalisedData.get('Advert Control'));
        System.assert(normalisedData.get('Advert Control').containsKey('2ea26014-c34a-4570-bcdc-1fa0ebc0c392'), 'Normalised advert Control data should have one key with value from GlobalID field: ' + normalisedData.get('Advert Control'));
    }

    private static testMethod void testRunTextualSearch(){
        RecordType assetRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Asset' AND DeveloperName = 'Locally_Listed_Heritage_Asset' LIMIT 1];
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;

        arcusgazetteer__BLPU__c testBLPU = new arcusgazetteer__BLPU__c();
        arcusbuiltenv__Planning_Application__c testPlanningApp = new arcusbuiltenv__Planning_Application__c();
        arcusbuiltenv__Building_Control_Application__c testBuildingControlApp = new arcusbuiltenv__Building_Control_Application__c();
        arcusbuiltenv__Enforcement__c testEnforcement = new arcusbuiltenv__Enforcement__c();
        arcusbuiltenv__Tree_Preservation_Order__c testTPO = new arcusbuiltenv__Tree_Preservation_Order__c();
        arcuslandcharge__LC_Register__c testRegistryEntry = new arcuslandcharge__LC_Register__c(
            arcuslandcharge__Originating_Authority__c = 'Buckinghamshire County Council', 
            arcuslandcharge__Register_Part__c = 'Part 1: General Financial Charges',
            arcuslandcharge__Status__c = 'Draft');
        Asset testAsset = new Asset(Name = 'Heritage Asset test', RecordTypeId = assetRT.Id, AccountId = testAccount.Id);

        insert new List<SObject>{testBLPU, searchRecord, testPlanningApp, testBuildingControlApp, testEnforcement, testTPO, testRegistryEntry, testAsset};

        arcusbuiltenv__Appeal__c testAppeal = new arcusbuiltenv__Appeal__c(arcusbuiltenv__Enforcement__c = testEnforcement.Id);
        arcusbuiltenv__Planning_Obligation__c testPlanningObligation = new arcusbuiltenv__Planning_Obligation__c(Name='Planning obligation test', arcusbuiltenv__Planning_Application__c = testPlanningApp.Id);
        arcusbuiltenv__Action__c testEnforcementAction = new arcusbuiltenv__Action__c(arcusbuiltenv__Enforcement__c = testEnforcement.Id);
        insert new List<SObject>{testAppeal, testPlanningObligation, testEnforcementAction};

        arcusgazetteer__Location__c testLocation = new arcusgazetteer__Location__c(arcusgazetteer__BLPU__c = testBLPU.Id);
        insert testLocation;
        List<arcusbuiltenv__Related_Location__c> testRelatedLocations = new List<arcusbuiltenv__Related_Location__c>();
        testRelatedLocations.add(new arcusbuiltenv__Related_Location__c(arcusbuiltenv__Location__c = testLocation.Id,
                                                                        arcusbuiltenv__BLPU__c = testBLPU.Id,
                                                                        arcusbuiltenv__Planning_Application__c = testPlanningApp.Id));
        testRelatedLocations.add(new arcusbuiltenv__Related_Location__c(arcusbuiltenv__Location__c = testLocation.Id,
                                                                        arcusbuiltenv__BLPU__c = testBLPU.Id,
                                                                        arcusbuiltenv__Building_Control_Application__c = testBuildingControlApp.Id));
        testRelatedLocations.add(new arcusbuiltenv__Related_Location__c(arcusbuiltenv__Location__c = testLocation.Id,
                                                                        arcusbuiltenv__BLPU__c = testBLPU.Id,
                                                                        arcusbuiltenv__Enforcement__c = testEnforcement.Id));
        testRelatedLocations.add(new arcusbuiltenv__Related_Location__c(arcusbuiltenv__Location__c = testLocation.Id,
                                                                        arcusbuiltenv__BLPU__c = testBLPU.Id,
                                                                        arcusbuiltenv__Tree_Preservation_Order__c = testTPO.Id));
        testRelatedLocations.add(new arcusbuiltenv__Related_Location__c(arcusbuiltenv__Location__c = testLocation.Id,
                                                                        arcusbuiltenv__BLPU__c = testBLPU.Id,
                                                                        arcuslandcharge__Land_Charge_Register__c = testRegistryEntry.Id));
        testRelatedLocations.add(new arcusbuiltenv__Related_Location__c(arcusbuiltenv__Location__c = testLocation.Id,
                                                                        arcusbuiltenv__BLPU__c = testBLPU.Id,
                                                                        arcuslandcharge__LCApplication__c = searchRecord.Id));
        testRelatedLocations.add(new arcusbuiltenv__Related_Location__c(arcusbuiltenv__Location__c = testLocation.Id,
                                                                        arcusbuiltenv__BLPU__c = testBLPU.Id,
                                                                        arcusbuiltenv__Appeal__c = testAppeal.Id));
        testRelatedLocations.add(new arcusbuiltenv__Related_Location__c(arcusbuiltenv__Location__c = testLocation.Id,
                                                                        arcusbuiltenv__BLPU__c = testBLPU.Id,
                                                                        arcusbuiltenv__Asset__c = testAsset.Id));
        insert testRelatedLocations;

        Test.startTest();
        LandChargeResponseGenerator.SFDataWrapper sfData = LandChargeResponseGenerator.runTextualSearch(searchRecord);
        Map<String, Map<String, Map<String, Object>>> normalisedData = sfData.getNormalisedData();
        Test.stopTest();

        System.assertEquals(1, sfData.planningApps.size(), 'Incorrect number of planning applications');
        System.assertEquals(1, sfData.buildingControlApps.size(), 'Incorrect number of building control applications');
        System.assertEquals(1, sfData.enforcements.size(), 'Incorrect number of enforcements');
        System.assertEquals(1, sfData.landChargeRegistryEntries.size(), 'Incorrect number of land charge register entries');
        System.assertEquals(1, sfData.treePreservationOrders.size(), 'Incorrect number of tree preservation orders');
        System.assertEquals(1, sfData.planningObligations.size(), 'Incorrect number of planning obligations');
        System.assertEquals(1, sfData.appeals.size(), 'Incorrect number of appeals');
        System.assertEquals(1, sfData.assets.size(), 'Incorrect number of assets');
        System.assertEquals(1, sfData.enforcementActions.size(), 'Incorrect number of enforcement actions');

        testPlanningApp = [SELECT Id, Name FROM arcusbuiltenv__Planning_Application__c WHERE Id = :testPlanningApp.Id];

        System.assertEquals(9, normalisedData.size(), 'Incorrect number of keys in normalised data. Keyset: ' + normalisedData.keySet());
        System.assert(normalisedData.containsKey('Planning Application'), 'Normalised data should contain data type \'Planning Application\'. Keyset: ' + normalisedData.keySet());
        System.assert(normalisedData.containsKey('Building Control Application'), 'Normalised data should contain data type \'Building Control Application\'. Keyset: ' + normalisedData.keySet());
        System.assert(normalisedData.containsKey('Enforcement'), 'Normalised data should contain data type \'Enforcement\'. Keyset: ' + normalisedData.keySet());
        System.assert(normalisedData.containsKey('Tree Preservation Order'), 'Normalised data should contain data type \'Tree Preservation Order\'. Keyset: ' + normalisedData.keySet());
        System.assert(normalisedData.containsKey('Land Charge'), 'Normalised data should contain data type \'Planning Application\'. Keyset: ' + normalisedData.keySet());
        System.assert(normalisedData.containsKey('Planning Obligation'), 'Normalised data should contain data type \'Planning Obligation\'. Keyset: ' + normalisedData.keySet());
        System.assert(normalisedData.containsKey('Appeal'), 'Normalised data should contain data type \'Appeal\'. Keyset: ' + normalisedData.keySet());
        System.assert(normalisedData.containsKey('Heritage Asset'), 'Normalised data should contain data type \'Heritage Asset\'. Keyset: ' + normalisedData.keySet());

        System.assertEquals(1, normalisedData.get('Planning Application').size(), 'Incorrect number of Planning Applications. ' + normalisedData.get('Planning Application'));
        System.assert(normalisedData.get('Planning Application').containsKey(testPlanningApp.Name), 'Planning Application data type should contain Name of the test Planning App. name value:' + testPlanningApp.Name + ' full data ' + normalisedData.get('Planning Application'));
        System.assert(normalisedData.get('Planning Application').get(testPlanningApp.Name).containsKey('id'), 'Planning Application record should contain Name field ' + normalisedData.get('Planning Application').get(testPlanningApp.Name));
        System.assertEquals(testPlanningApp.Id, normalisedData.get('Planning Application').get(testPlanningApp.Name).get('id'), 'Incorrect value on id field ' + normalisedData.get('Planning Application').get(testPlanningApp.Name));
    }

    private static testMethod void testRunTextualSearchWithLCRegisterEntries(){
        RecordType assetRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Asset' AND DeveloperName = 'Locally_Listed_Heritage_Asset' LIMIT 1];
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;

        arcusgazetteer__BLPU__c testBLPU = new arcusgazetteer__BLPU__c();
        arcusbuiltenv__Planning_Application__c testPlanningApp = new arcusbuiltenv__Planning_Application__c();
        arcusbuiltenv__Building_Control_Application__c testBuildingControlApp = new arcusbuiltenv__Building_Control_Application__c();
        arcusbuiltenv__Enforcement__c testEnforcement = new arcusbuiltenv__Enforcement__c();
        arcusbuiltenv__Tree_Preservation_Order__c testTPO = new arcusbuiltenv__Tree_Preservation_Order__c();
        arcuslandcharge__LC_Register__c testRegistryEntry = new arcuslandcharge__LC_Register__c(
            arcuslandcharge__Originating_Authority__c = 'Buckinghamshire County Council', 
            arcuslandcharge__Register_Part__c = 'Part 1: General Financial Charges',
            arcuslandcharge__Status__c = 'Draft');
        Asset testAsset = new Asset(Name = 'Heritage Asset test', RecordTypeId = assetRT.Id, AccountId = testAccount.Id);

        insert new List<SObject>{testBLPU, searchRecord, testPlanningApp, testBuildingControlApp, testEnforcement, testTPO, testRegistryEntry, testAsset};

        arcusbuiltenv__Appeal__c testAppeal = new arcusbuiltenv__Appeal__c(arcusbuiltenv__Enforcement__c = testEnforcement.Id);
        arcusbuiltenv__Planning_Obligation__c testPlanningObligation = new arcusbuiltenv__Planning_Obligation__c(Name='Planning obligation test', arcusbuiltenv__Planning_Application__c = testPlanningApp.Id);
        arcusbuiltenv__Action__c testEnforcementAction = new arcusbuiltenv__Action__c(arcusbuiltenv__Enforcement__c = testEnforcement.Id);
        insert new List<SObject>{testAppeal, testPlanningObligation, testEnforcementAction};

        arcusgazetteer__Location__c testLocation = new arcusgazetteer__Location__c(arcusgazetteer__BLPU__c = testBLPU.Id);
        insert testLocation;
        List<arcusbuiltenv__Related_Location__c> testRelatedLocations = new List<arcusbuiltenv__Related_Location__c>();
        testRelatedLocations.add(new arcusbuiltenv__Related_Location__c(arcusbuiltenv__Location__c = testLocation.Id,
                                                                        arcusbuiltenv__BLPU__c = testBLPU.Id,
                                                                        arcusbuiltenv__Planning_Application__c = testPlanningApp.Id));
        testRelatedLocations.add(new arcusbuiltenv__Related_Location__c(arcusbuiltenv__Location__c = testLocation.Id,
                                                                        arcusbuiltenv__BLPU__c = testBLPU.Id,
                                                                        arcusbuiltenv__Building_Control_Application__c = testBuildingControlApp.Id));
        testRelatedLocations.add(new arcusbuiltenv__Related_Location__c(arcusbuiltenv__Location__c = testLocation.Id,
                                                                        arcusbuiltenv__BLPU__c = testBLPU.Id,
                                                                        arcusbuiltenv__Enforcement__c = testEnforcement.Id));
        testRelatedLocations.add(new arcusbuiltenv__Related_Location__c(arcusbuiltenv__Location__c = testLocation.Id,
                                                                        arcusbuiltenv__BLPU__c = testBLPU.Id,
                                                                        arcusbuiltenv__Tree_Preservation_Order__c = testTPO.Id));
        testRelatedLocations.add(new arcusbuiltenv__Related_Location__c(arcusbuiltenv__Location__c = testLocation.Id,
                                                                        arcusbuiltenv__BLPU__c = testBLPU.Id,
                                                                        arcuslandcharge__LCApplication__c = searchRecord.Id));
        testRelatedLocations.add(new arcusbuiltenv__Related_Location__c(arcusbuiltenv__Location__c = testLocation.Id,
                                                                        arcusbuiltenv__BLPU__c = testBLPU.Id,
                                                                        arcusbuiltenv__Appeal__c = testAppeal.Id));
        testRelatedLocations.add(new arcusbuiltenv__Related_Location__c(arcusbuiltenv__Location__c = testLocation.Id,
                                                                        arcusbuiltenv__BLPU__c = testBLPU.Id,
                                                                        arcusbuiltenv__Asset__c = testAsset.Id));
        insert testRelatedLocations;

        arcuslandcharge__LC_Register__c testReg1 = new arcuslandcharge__LC_Register__c(
            arcuslandcharge__Planning_Application__c = testPlanningApp.Id, 
            arcuslandcharge__Originating_Authority__c = 'test', 
            arcuslandcharge__Register_Part__c = 'Part 1: General Financial Charges',
            arcuslandcharge__Status__c = 'Active',
            arcuslandcharge__Date_of_Registration__c = Date.today()
        );
        arcuslandcharge__LC_Register__c testReg2 = new arcuslandcharge__LC_Register__c(
            arcuslandcharge__Tree_Preservation_Order__c = testTPO.Id, 
            arcuslandcharge__Originating_Authority__c = 'test', 
            arcuslandcharge__Register_Part__c = 'Part 1: General Financial Charges',
            arcuslandcharge__Status__c = 'Active',
            arcuslandcharge__Date_of_Registration__c = Date.today()
        );
        arcuslandcharge__LC_Register__c testReg3 = new arcuslandcharge__LC_Register__c(
            arcuslandcharge__Asset__c = testAsset.Id, 
            arcuslandcharge__Originating_Authority__c = 'test', 
            arcuslandcharge__Register_Part__c = 'Part 1: General Financial Charges',
            arcuslandcharge__Status__c = 'Active',
            arcuslandcharge__Date_of_Registration__c = Date.today()
        );
        arcuslandcharge__LC_Register__c testReg4 = new arcuslandcharge__LC_Register__c(
            arcuslandcharge__Originating_Authority__c = 'test', 
            arcuslandcharge__Register_Part__c = 'Part 1: General Financial Charges',
            arcuslandcharge__Status__c = 'Active',
            arcuslandcharge__Date_of_Registration__c = Date.today()
        );
        insert new List<SObject>{testReg1, testReg2, testReg3, testReg4};

        //need to update Statuses again because Process Builder 'Land Charge Register Creation' sets the statuses on insert
        testReg1.arcuslandcharge__Status__c = 'Active';
        testReg2.arcuslandcharge__Status__c = 'Active';
        testReg3.arcuslandcharge__Status__c = 'Active';
        testReg4.arcuslandcharge__Status__c = 'Active';
        update new List<SObject>{testReg1, testReg2, testReg3, testReg4};

        Test.startTest();
        LandChargeResponseGenerator.SFDataWrapper sfData = LandChargeResponseGenerator.runTextualSearch(searchRecord);
        Map<String, Map<String, Map<String, Object>>> normalisedData = sfData.getNormalisedData();
        Test.stopTest();

        System.assertEquals(3, sfData.landChargeRegistryEntries.size(), 'Incorrect number of land charge register entries');
        Set<Id> foundIds = new Set<Id>();
        for(arcuslandcharge__LC_Register__c thisReg : sfData.landChargeRegistryEntries){
            foundIds.add(thisReg.Id);
        }
        System.assert(foundIds.contains(testReg1.Id), 'Id ' + testReg1.Id + ' not found in set ' + sfData.landChargeRegistryEntries);
        System.assert(foundIds.contains(testReg2.Id), 'Id ' + testReg2.Id + ' not found in set ' + sfData.landChargeRegistryEntries);
        System.assert(foundIds.contains(testReg3.Id), 'Id ' + testReg3.Id + ' not found in set ' + sfData.landChargeRegistryEntries);
    }

    private static testMethod void testRunTextualSearchWithLCRegisterEntriesButPartNotSelected(){
        arcusgazetteer__BLPU__c testBLPU = new arcusgazetteer__BLPU__c();
        arcusbuiltenv__Planning_Application__c testPlanningApp = new arcusbuiltenv__Planning_Application__c();
        
        insert new List<SObject>{testBLPU, searchRecord, testPlanningApp};

        arcusgazetteer__Location__c testLocation = new arcusgazetteer__Location__c(arcusgazetteer__BLPU__c = testBLPU.Id);
        insert testLocation;

        List<arcusbuiltenv__Related_Location__c> testRelatedLocations = new List<arcusbuiltenv__Related_Location__c>();
        testRelatedLocations.add(new arcusbuiltenv__Related_Location__c(arcusbuiltenv__Location__c = testLocation.Id,
                                                                        arcusbuiltenv__BLPU__c = testBLPU.Id,
                                                                        arcusbuiltenv__Planning_Application__c = testPlanningApp.Id));
        testRelatedLocations.add(new arcusbuiltenv__Related_Location__c(arcusbuiltenv__Location__c = testLocation.Id,
                                                                        arcusbuiltenv__BLPU__c = testBLPU.Id,
                                                                        arcuslandcharge__LCApplication__c = searchRecord.Id));
        insert testRelatedLocations;

        arcuslandcharge__LC_Register__c testReg1 = new arcuslandcharge__LC_Register__c(
            arcuslandcharge__Planning_Application__c = testPlanningApp.Id, 
            arcuslandcharge__Originating_Authority__c = 'test', 
            arcuslandcharge__Register_Part__c = 'Something wrong',
            arcuslandcharge__Status__c = 'Active',
            arcuslandcharge__Date_of_Registration__c = Date.today()
        );
        insert new List<SObject>{testReg1};

        //need to update Statuses again because Process Builder 'Land Charge Register Creation' sets the statuses on insert
        testReg1.arcuslandcharge__Status__c = 'Active';
        update new List<SObject>{testReg1};

        Test.startTest();
        LandChargeResponseGenerator.SFDataWrapper sfData = LandChargeResponseGenerator.runTextualSearch(searchRecord);
        Test.stopTest();

        System.assertEquals(0, sfData.landChargeRegistryEntries.size(), 'Land charge register entry shouldn\'t have been retrieved because the Register Part was wrong');
    }

    private static testMethod void testRunTextualSearchWithLCRegisterEntriesButNotActive(){
        arcusgazetteer__BLPU__c testBLPU = new arcusgazetteer__BLPU__c();
        arcusbuiltenv__Planning_Application__c testPlanningApp = new arcusbuiltenv__Planning_Application__c();
        
        insert new List<SObject>{testBLPU, searchRecord, testPlanningApp};

        arcusgazetteer__Location__c testLocation = new arcusgazetteer__Location__c(arcusgazetteer__BLPU__c = testBLPU.Id);
        insert testLocation;

        List<arcusbuiltenv__Related_Location__c> testRelatedLocations = new List<arcusbuiltenv__Related_Location__c>();
        testRelatedLocations.add(new arcusbuiltenv__Related_Location__c(arcusbuiltenv__Location__c = testLocation.Id,
                                                                        arcusbuiltenv__BLPU__c = testBLPU.Id,
                                                                        arcusbuiltenv__Planning_Application__c = testPlanningApp.Id));
        testRelatedLocations.add(new arcusbuiltenv__Related_Location__c(arcusbuiltenv__Location__c = testLocation.Id,
                                                                        arcusbuiltenv__BLPU__c = testBLPU.Id,
                                                                        arcuslandcharge__LCApplication__c = searchRecord.Id));
        insert testRelatedLocations;

        arcuslandcharge__LC_Register__c testReg1 = new arcuslandcharge__LC_Register__c(
            arcuslandcharge__Planning_Application__c = testPlanningApp.Id, 
            arcuslandcharge__Originating_Authority__c = 'test', 
            arcuslandcharge__Register_Part__c = 'Part 1: General Financial Charges',
            arcuslandcharge__Status__c = 'Some wrong status',
            arcuslandcharge__Date_of_Registration__c = Date.today()
        );
        insert new List<SObject>{testReg1};

        //need to update Statuses again because Process Builder 'Land Charge Register Creation' sets the statuses on insert
        testReg1.arcuslandcharge__Status__c = 'Some wrong status';
        update new List<SObject>{testReg1};

        Test.startTest();
        LandChargeResponseGenerator.SFDataWrapper sfData = LandChargeResponseGenerator.runTextualSearch(searchRecord);
        Test.stopTest();

        System.assertEquals(0, sfData.landChargeRegistryEntries.size(), 'Land charge register entry shouldn\'t have been retrieved because the Register Part was wrong');
    }

    private static testMethod void testDeduplicateNormalisedData(){
        Map<String, Map<String, Map<String, Object>>> spatialData = new Map<String, Map<String, Map<String, Object>>>{
            'AdvertZoneArbitrarilyNamedDataType'=> new Map<String, Map<String, Object>>{
                '6'=> new Map<String, Object>{
                    'FID'=> 6,
                    'AREA'=> 0,
                    'PERIMETER'=> 20494.451,
                    'REFDESC'=> 'Aylesbury Area excluded from special advert control',
                    'KEYVAL'=> 6,
                    'GlobalID'=> '2ea26014-c34a-4570-bcdc-1fa0ebc0c392',
                    'Shape__Area'=> 26799181.7403564,
                    'Shape__Length'=> 33135.5214377157
                },
                '12'=> new Map<String, Object>{
                    'FID'=> 12,
                    'AREA'=> 0,
                    'PERIMETER'=> 20494.451,
                    'REFDESC'=> 'Aylesbury Area excluded from special advert control 2',
                    'KEYVAL'=> 12,
                    'GlobalID'=> '2ea26014-c34a-4570-bcdc-1fa0ebc0c393',
                    'Shape__Area'=> 26799181.7403564,
                    'Shape__Length'=> 33135.5214377157
                }
            },
            'AreoZoneArbirarilyNamedDataType'=> new Map<String, Map<String, Object>>{
                'ReallyBigAirport'=> new Map<String, Object>{
                    'Name'=> 'Really Big Aiport'
                }
            }
        };
        final Map<String, Map<String, Map<String, Object>>> textualData = new Map<String, Map<String, Map<String, Object>>>{
            'AdvertZoneArbitrarilyNamedDataType' => new Map<String, Map<String, Object>>{
                '12' => new Map<String, Object>{
                    'FID'=> 12,
                    'AREA'=> 0,
                    'PERIMETER'=> 0,
                    'REFDESC'=> 'Aylesbury Area excluded from special advert control 2',
                    'KEYVAL'=> 12,
                    'GlobalID'=> '2ea26014-c34a-4570-bcdc-1fa0ebc0c393',
                    'Shape__Area'=> 0,
                    'Shape__Length'=> 0
                }
            },
            'PlanningApplications' => new Map<String, Map<String, Object>>{
                'DMPA-2019-00007-HQH'=> new Map<String, Object>{
                    'ReferenceNumber'=> 'DMPA-2019-00007-HQH',
                    'Decision'=> 'Rejected'
                },
                'DMPA-2019-00043-HQH'=> new Map<String, Object>{
                    'ReferenceNumber'=> 'DMPA-2019-00043-HQH',
                    'Decision'=> 'Granted'
                }
            }
        };

        Test.startTest();
        LandChargeResponseGenerator.addTextualDataToSpatialData(spatialData, textualData);
        Test.stopTest();

        final Map<String, Map<String, Map<String, Object>>> expectedMergedData = new Map<String, Map<String, Map<String, Object>>>{
            'AdvertZoneArbitrarilyNamedDataType'=>  new Map<String, Map<String, Object>>{
                '6'=> new Map<String, Object>{
                    'FID'=> 6,
                    'AREA'=> 0,
                    'PERIMETER'=> 20494.451,
                    'REFDESC'=> 'Aylesbury Area excluded from special advert control',
                    'KEYVAL'=> 6,
                    'GlobalID'=> '2ea26014-c34a-4570-bcdc-1fa0ebc0c392',
                    'Shape__Area'=> 26799181.7403564,
                    'Shape__Length'=> 33135.5214377157
                },
                '12'=> new Map<String, Object>{
                    'FID'=> 12,
                    'AREA'=> 0,
                    'PERIMETER'=> 0,
                    'REFDESC'=> 'Aylesbury Area excluded from special advert control 2',
                    'KEYVAL'=> 12,
                    'GlobalID'=> '2ea26014-c34a-4570-bcdc-1fa0ebc0c393',
                    'Shape__Area'=> 0,
                    'Shape__Length'=> 0
                }
            },
            'AreoZoneArbirarilyNamedDataType'=>  new Map<String, Map<String, Object>>{
                'ReallyBigAirport'=> new Map<String, Object>{
                    'Name'=> 'Really Big Aiport'
                }
            },
            'PlanningApplications'=>  new Map<String, Map<String, Object>>{
                'DMPA-2019-00007-HQH'=> new Map<String, Object>{
                    'ReferenceNumber'=> 'DMPA-2019-00007-HQH',
                    'Decision'=> 'Rejected'
                },
                'DMPA-2019-00043-HQH'=> new Map<String, Object>{
                    'ReferenceNumber'=> 'DMPA-2019-00043-HQH',
                    'Decision'=> 'Granted'
                }
            }
        };
        System.assertEquals(expectedMergedData, spatialData);
    }

    private static testMethod void testMatchingSFDataFromGIS(){
        insert searchRecord;

        final Map<String, Map<String, Map<String, Object>>> spatialData = new Map<String, Map<String, Map<String, Object>>>{
            'Planning Application' => new Map<String, Map<String, Object>>{
                'DMPA-2019-00007-HQH'=> new Map<String, Object>{
                    'name'=> 'DMPA-2019-00007-HQH'
                },
                'DMPA-2019-00043-HQH'=> new Map<String, Object>{
                    'name'=> 'DMPA-2019-00043-HQH'
                }
            }
        };
        arcusbuiltenv__Planning_Application__c testApp1 = new arcusbuiltenv__Planning_Application__c(Name = 'DMPA-2019-00007-HQH');
        arcusbuiltenv__Planning_Application__c testApp2 = new arcusbuiltenv__Planning_Application__c(Name = 'DMPA-2019-00043-HQH');
        arcusbuiltenv__Planning_Application__c testApp3 = new arcusbuiltenv__Planning_Application__c(Name = 'SomethingElse');
        insert new List<SObject>{testApp1, testApp2, testApp3};

        Test.startTest();
        LandChargeResponseGenerator.SFDataWrapper sfData = LandChargeResponseGenerator.checkForSFDataMatchingGISData(spatialData, searchRecord);
        Test.stopTest();

        System.assertEquals(2, sfData.planningApps.size(), 'Incorrect number of planning applications found');
        Set<Id> foundIds = new Set<Id>();
        for(arcusbuiltenv__Planning_Application__c thisApp : sfData.planningApps){
            foundIds.add(thisApp.Id);
        }
        System.assert(foundIds.contains(testApp1.Id), 'Id ' + testApp1.Id + ' not found in set ' + sfData.planningApps);
        System.assert(foundIds.contains(testApp2.Id), 'Id ' + testApp2.Id + ' not found in set ' + sfData.planningApps);
    }

    private static testMethod void testMatchingSFDataFromGISWithLCRegisterEntries(){
        insert searchRecord;

        final Map<String, Map<String, Map<String, Object>>> spatialData = new Map<String, Map<String, Map<String, Object>>>{
            'Planning Application' => new Map<String, Map<String, Object>>{
                'DMPA-2019-00007-HQH'=> new Map<String, Object>{
                    'name'=> 'DMPA-2019-00007-HQH'
                },
                'DMPA-2019-00043-HQH'=> new Map<String, Object>{
                    'name'=> 'DMPA-2019-00043-HQH'
                }
            }
        };
        arcusbuiltenv__Planning_Application__c testApp1 = new arcusbuiltenv__Planning_Application__c(Name = 'DMPA-2019-00007-HQH');
        arcusbuiltenv__Planning_Application__c testApp2 = new arcusbuiltenv__Planning_Application__c(Name = 'DMPA-2019-00043-HQH');
        arcusbuiltenv__Planning_Application__c testApp3 = new arcusbuiltenv__Planning_Application__c(Name = 'SomethingElse');
        insert new List<SObject>{testApp1, testApp2, testApp3};

        arcuslandcharge__LC_Register__c testReg1 = new arcuslandcharge__LC_Register__c(
            arcuslandcharge__Planning_Application__c = testApp1.Id, 
            arcuslandcharge__Originating_Authority__c = 'test', 
            arcuslandcharge__Register_Part__c = 'Part 3: Planning Charges',
            arcuslandcharge__Status__c = 'Active',
            arcuslandcharge__Date_of_Registration__c = Date.today()
        );
        arcuslandcharge__LC_Register__c testReg2 = new arcuslandcharge__LC_Register__c(
            arcuslandcharge__Planning_Application__c = testApp2.Id, 
            arcuslandcharge__Originating_Authority__c = 'test', 
            arcuslandcharge__Register_Part__c = 'Part 3: Planning Charges',
            arcuslandcharge__Status__c = 'Active',
            arcuslandcharge__Date_of_Registration__c = Date.today()
        );
        arcuslandcharge__LC_Register__c testReg3 = new arcuslandcharge__LC_Register__c(
            arcuslandcharge__Planning_Application__c = testApp3.Id, 
            arcuslandcharge__Originating_Authority__c = 'test', 
            arcuslandcharge__Register_Part__c = 'Part 3: Planning Charges',
            arcuslandcharge__Status__c = 'Active',
            arcuslandcharge__Date_of_Registration__c = Date.today()
        );
        insert new List<SObject>{testReg1, testReg2, testReg3};

        //need to update Statuses again because Process Builder 'Land Charge Register Creation' sets the statuses on insert
        testReg1.arcuslandcharge__Status__c = 'Active';
        testReg2.arcuslandcharge__Status__c = 'Active';
        testReg3.arcuslandcharge__Status__c = 'Active';
        update new List<SObject>{testReg1, testReg2, testReg3};

        Test.startTest();
        LandChargeResponseGenerator.SFDataWrapper sfData = LandChargeResponseGenerator.checkForSFDataMatchingGISData(spatialData, searchRecord);
        Test.stopTest();

        System.assertEquals(2, sfData.landChargeRegistryEntries.size(), 'Incorrect number of land charge register entries found');

        Set<Id> foundIds = new Set<Id>();
        for(arcuslandcharge__LC_Register__c thisReg : sfData.landChargeRegistryEntries){
            foundIds.add(thisReg.Id);
        }
        System.assert(foundIds.contains(testReg1.Id), 'Id ' + testReg1.Id + ' not found in set ' + sfData.landChargeRegistryEntries);
        System.assert(foundIds.contains(testReg2.Id), 'Id ' + testReg2.Id + ' not found in set ' + sfData.landChargeRegistryEntries);
    }

    private static testMethod void testMatchingSFDataFromGISWithLCRegisterEntriesButPartNotSelected(){
        insert searchRecord;

        final Map<String, Map<String, Map<String, Object>>> spatialData = new Map<String, Map<String, Map<String, Object>>>{
            'Planning Application' => new Map<String, Map<String, Object>>{
                'DMPA-2019-00007-HQH'=> new Map<String, Object>{
                    'name'=> 'DMPA-2019-00007-HQH'
                },
                'DMPA-2019-00043-HQH'=> new Map<String, Object>{
                    'name'=> 'DMPA-2019-00043-HQH'
                }
            }
        };
        arcusbuiltenv__Planning_Application__c testApp1 = new arcusbuiltenv__Planning_Application__c(Name = 'DMPA-2019-00007-HQH');
        insert new List<SObject>{testApp1};

        arcuslandcharge__LC_Register__c testReg1 = new arcuslandcharge__LC_Register__c(
            arcuslandcharge__Planning_Application__c = testApp1.Id, 
            arcuslandcharge__Originating_Authority__c = 'test', 
            arcuslandcharge__Register_Part__c = 'Something wrong',
            arcuslandcharge__Status__c = 'Active',
            arcuslandcharge__Date_of_Registration__c = Date.today()
        );
        insert new List<SObject>{testReg1};

        //need to update Statuses again because Process Builder 'Land Charge Register Creation' sets the statuses on insert
        testReg1.arcuslandcharge__Status__c = 'Active';
        update new List<SObject>{testReg1};

        Test.startTest();
        LandChargeResponseGenerator.SFDataWrapper sfData = LandChargeResponseGenerator.checkForSFDataMatchingGISData(spatialData, searchRecord);
        Test.stopTest();

        System.assertEquals(0, sfData.landChargeRegistryEntries.size(), 'Shouldn\'t have found an LC Register entry because the register part was wrong.');
    }

    private static testMethod void testMatchingSFDataFromGISWithLCRegisterEntriesButNotActive(){
        insert searchRecord;

        final Map<String, Map<String, Map<String, Object>>> spatialData = new Map<String, Map<String, Map<String, Object>>>{
            'Planning Application' => new Map<String, Map<String, Object>>{
                'DMPA-2019-00007-HQH'=> new Map<String, Object>{
                    'name'=> 'DMPA-2019-00007-HQH'
                },
                'DMPA-2019-00043-HQH'=> new Map<String, Object>{
                    'name'=> 'DMPA-2019-00043-HQH'
                }
            }
        };
        arcusbuiltenv__Planning_Application__c testApp1 = new arcusbuiltenv__Planning_Application__c(Name = 'DMPA-2019-00007-HQH');
        insert new List<SObject>{testApp1};

        arcuslandcharge__LC_Register__c testReg1 = new arcuslandcharge__LC_Register__c(
            arcuslandcharge__Planning_Application__c = testApp1.Id, 
            arcuslandcharge__Originating_Authority__c = 'test', 
            arcuslandcharge__Register_Part__c = 'Part 1: General Financial Charges',
            arcuslandcharge__Status__c = 'Some wrong status',
            arcuslandcharge__Date_of_Registration__c = Date.today()
        );
        insert new List<SObject>{testReg1};

        //need to update Statuses again because Process Builder 'Land Charge Register Creation' sets the statuses on insert
        testReg1.arcuslandcharge__Status__c = 'Some wrong status';
        update new List<SObject>{testReg1};

        Test.startTest();
        LandChargeResponseGenerator.SFDataWrapper sfData = LandChargeResponseGenerator.checkForSFDataMatchingGISData(spatialData, searchRecord);
        Test.stopTest();

        System.assertEquals(0, sfData.landChargeRegistryEntries.size(), 'Shouldn\'t have found an LC Register entry because the register part was wrong.');
    }

    private static testMethod void testMatchingSFDataFromGISWithEnforcement(){
        insert searchRecord;

        final Map<String, Map<String, Map<String, Object>>> spatialData = new Map<String, Map<String, Map<String, Object>>>{
            'Enforcement' => new Map<String, Map<String, Object>>{
                'DMPA-2019-00007-HQH'=> new Map<String, Object>{
                    'name'=> 'DMPA-2019-00007-HQH'
                },
                'DMPA-2019-00043-HQH'=> new Map<String, Object>{
                    'name'=> 'DMPA-2019-00043-HQH'
                }
            }
        };
        arcusbuiltenv__Enforcement__c testEnf = new arcusbuiltenv__Enforcement__c(Name = 'DMPA-2019-00007-HQH');
        insert new List<SObject>{testEnf};

        Test.startTest();
        LandChargeResponseGenerator.SFDataWrapper sfData = LandChargeResponseGenerator.checkForSFDataMatchingGISData(spatialData, searchRecord);
        Test.stopTest();

        System.assertEquals(1, sfData.enforcements.size(), 'Incorrect number of Enforcements found');
        System.assertEquals(testEnf.Id, sfData.enforcements[0].Id, 'Enforcement found was the wrong one');
    }

    private static testMethod void testMatchingSFDataFromGISWithEnforcementAndActions(){
        insert searchRecord;

        final Map<String, Map<String, Map<String, Object>>> spatialData = new Map<String, Map<String, Map<String, Object>>>{
            'Enforcement' => new Map<String, Map<String, Object>>{
                'DMPA-2019-00007-HQH'=> new Map<String, Object>{
                    'name'=> 'DMPA-2019-00007-HQH'
                },
                'DMPA-2019-00043-HQH'=> new Map<String, Object>{
                    'name'=> 'DMPA-2019-00043-HQH'
                }
            }
        };
        arcusbuiltenv__Enforcement__c testEnf = new arcusbuiltenv__Enforcement__c(Name = 'DMPA-2019-00007-HQH');
        insert new List<SObject>{testEnf};
        
        List<arcusbuiltenv__Action__c> acts = new List<arcusbuiltenv__Action__c>();
        arcusbuiltenv__Action__c act1 = new arcusbuiltenv__Action__c(
            arcusbuiltenv__Enforcement__c = testEnf.Id
        );
        arcusbuiltenv__Action__c act2 = new arcusbuiltenv__Action__c(
            arcusbuiltenv__Enforcement__c = testEnf.Id
        );
        insert new List<arcusbuiltenv__Action__c>{act1, act2};

        Test.startTest();
        LandChargeResponseGenerator.SFDataWrapper sfData = LandChargeResponseGenerator.checkForSFDataMatchingGISData(spatialData, searchRecord);
        Test.stopTest();

        System.assertEquals(2, sfData.enforcementActions.size(), 'Incorrect number of Enforcement Actions found');
        Set<Id> foundIds = new Set<Id>();
        for(arcusbuiltenv__Action__c thisAct : sfData.enforcementActions){
            foundIds.add(thisAct.Id);
        }
        System.assert(foundIds.contains(act1.Id), 'Id ' + act1.Id + ' not found in set ' + sfData.enforcementActions);
        System.assert(foundIds.contains(act2.Id), 'Id ' + act2.Id + ' not found in set ' + sfData.enforcementActions);
    }

    private static testMethod void testMatchingSFDataFromGISWithTPO(){
        insert searchRecord;
        
        arcusbuiltenv__Tree_Preservation_Order__c testRecord = new arcusbuiltenv__Tree_Preservation_Order__c(Name = 'something irrelevant');
        insert new List<SObject>{testRecord};
        
        final Map<String, Map<String, Map<String, Object>>> spatialData = new Map<String, Map<String, Map<String, Object>>>{
            'Tree Preservation Order' => new Map<String, Map<String, Object>>{
                testRecord.Id => new Map<String, Object>{}
            }
        };
        
        Test.startTest();
        LandChargeResponseGenerator.SFDataWrapper sfData = LandChargeResponseGenerator.checkForSFDataMatchingGISData(spatialData, searchRecord);
        Test.stopTest();

        System.assertEquals(1, sfData.treePreservationOrders.size(), 'Incorrect number of TPOs found');
        System.assertEquals(testRecord.Id, sfData.treePreservationOrders[0].Id, 'TPO found was the wrong one');
    }

    private static testMethod void testMatchingSFDataFromGISWithPlanningObligation(){
        insert searchRecord;

        final Map<String, Map<String, Map<String, Object>>> spatialData = new Map<String, Map<String, Map<String, Object>>>{
            'Planning Obligation' => new Map<String, Map<String, Object>>{
                'DMPA-2019-00007-HQH'=> new Map<String, Object>{
                    'name'=> 'DMPA-2019-00007-HQH'
                },
                'DMPA-2019-00043-HQH'=> new Map<String, Object>{
                    'name'=> 'DMPA-2019-00043-HQH'
                }
            }
        };
        arcusbuiltenv__Planning_Obligation__c testRecord = new arcusbuiltenv__Planning_Obligation__c(Name = 'DMPA-2019-00007-HQH');
        insert new List<SObject>{testRecord};

        Test.startTest();
        LandChargeResponseGenerator.SFDataWrapper sfData = LandChargeResponseGenerator.checkForSFDataMatchingGISData(spatialData, searchRecord);
        Test.stopTest();

        System.assertEquals(1, sfData.planningObligations.size(), 'Incorrect number of Planning Obligations found');
        System.assertEquals(testRecord.Id, sfData.planningObligations[0].Id, 'Planning Obligation found was the wrong one');
    }

    private static testMethod void testMatchingSFDataFromGISWithAsset(){
        insert searchRecord;
        Account testAcc = new Account(Name = 'Test Acc');
        insert testAcc;

        final Map<String, Map<String, Map<String, Object>>> spatialData = new Map<String, Map<String, Map<String, Object>>>{
            'Heritage Asset' => new Map<String, Map<String, Object>>{
                'DMPA-2019-00007-HQH'=> new Map<String, Object>{
                    'name'=> 'DMPA-2019-00007-HQH'
                },
                'DMPA-2019-00043-HQH'=> new Map<String, Object>{
                    'name'=> 'DMPA-2019-00043-HQH'
                }
            }
        };
        Id assetRTId = arcshared.Utils.getRecordTypeIdByNamespacedsObjectAndDeveloperNameAndNamespacePrefix('Asset', 'Locally_Listed_Heritage_Asset', 'arcusbuiltenv');
        Asset testRecord = new Asset(Name = 'DMPA-2019-00007-HQH', AccountId = testAcc.Id, RecordTypeId = assetRTId);
        insert new List<SObject>{testRecord};

        Test.startTest();
        LandChargeResponseGenerator.SFDataWrapper sfData = LandChargeResponseGenerator.checkForSFDataMatchingGISData(spatialData, searchRecord);
        Test.stopTest();

        System.assertEquals(1, sfData.assets.size(), 'Incorrect number of Assets found');
        System.assertEquals(testRecord.Id, sfData.assets[0].Id, 'Asset found was the wrong one');
    }

    private static testMethod void testBuildingCON29WithNoData(){
        arcuslandcharge__LCApplication__c search = new arcuslandcharge__LCApplication__c();
        search.arcuslandcharge__CON29O13__c = true;
        insert search;

        Test.startTest();
        search = LandChargeResponseGenerator.getLandChargeSearchRecord(search.Id); // ensures all fields are queried
        arcuslandcharge__CON29_Response__c response = LandChargeResponseGenerator.buildCON29Response(new Map<String, Map<String, Map<String, Object>>>(), search);
        Test.stopTest();

        System.assertEquals(search.Id, response.arcuslandcharge__LCApplication__c, 'Response should lookup to search.');
        System.assertEquals('None.', response.arcuslandcharge__CON29O13__c, 'Question was asked, so should have template no-data response.');
        System.assertEquals('This question was not asked.', response.arcuslandcharge__CON29O20_1__c, 'Question was not asked, so should have standard non-response.');
    }

    private static testMethod void testBuildingCON29WithEthelData(){
        final Map<String, Map<String, Map<String, Object>>> normalisedData = new Map<String, Map<String, Map<String, Object>>>{
            'Planning Application' => new Map<String, Map<String, Object>>{
                'DMPA-2019-00007-HQH'=> new Map<String, Object>{
                    'name'=> 'DMPA-2019-00007-HQH',
                    'potato' => 'Ethel'
                },
                'DMPA-2019-00043-HQH'=> new Map<String, Object>{
                    'name' => 'DMPA-2019-00043-HQH',
                    'potato' => 'Not Ethel'
                }
            }
        };
        arcuslandcharge__LCApplication__c search = new arcuslandcharge__LCApplication__c();
        search.arcuslandcharge__CON29O13__c = true;
        search.arcuslandcharge__CON29R3_9n__c = true;
        insert search;

        Test.startTest();
        search = LandChargeResponseGenerator.getLandChargeSearchRecord(search.Id); // ensures all fields are queried
        arcuslandcharge__CON29_Response__c response = LandChargeResponseGenerator.buildCON29Response(normalisedData, search);
        Test.stopTest();

        System.assertEquals(search.Id, response.arcuslandcharge__LCApplication__c, 'Response should lookup to search.');
        System.assertEquals('Name: DMPA-2019-00007-HQH\r\nName: DMPA-2019-00043-HQH', response.arcuslandcharge__CON29O13__c, 'Question was asked and has no filter, so both records should be returned.');
        System.assertEquals('Name: DMPA-2019-00007-HQH', response.arcuslandcharge__CON29R3_9n__c, 'Question was asked and has ethel filter, so one record should be returned.');
        System.assertEquals('This question was not asked.', response.arcuslandcharge__CON29O20_1__c, 'Question was not asked, so should have standard non-response.');
    }

    private static testMethod void testLLC1ConfigGetRecords(){
        LandChargeResponseGenerator.LLC1Config testConfig = new LandChargeResponseGenerator.LLC1Config();
        testConfig.fieldTemplates = new Map<String, String>{
            'arcuslandcharge__Land_Charge_Register__c' => '{!Salesforce Id}',
            'arcuslandcharge__Register_Part_Full__c' => '{!Register Part}'
        };

        arcuslandcharge__LCApplication__c testSearch = new arcuslandcharge__LCApplication__c();
        insert testSearch;

        final Id fakeId = arcuslandcharge__LC_Register__c.SObjectType.getDescribe().getKeyPrefix() + '000000000000';
        final Map<String, Map<String, Object>> filteredLandChargeData = new Map<String, Map<String, Object>>{
            'Charge Number 1'=> new Map<String, Object>{
                'name'=> 'Charge Number 1',
                'Salesforce Id' => fakeId,
                'Register Part' => 'Part 1'
            },
            'Charge Number 2'=> new Map<String, Object>{
                'name' => 'Charge Number 2',
                'Salesforce Id' => fakeId,
                'Register Part' => 'Part 2'
            }
        };

        Test.startTest();
        List<arcuslandcharge__LLC1_Response__c> responses = testConfig.getRecords(filteredLandChargeData, testSearch.Id);
        Test.stopTest();

        System.assertEquals(2, responses.size(), 'Incorrect number of LLC1 responses. input: ' + filteredLandChargeData + ' output: ' + responses);
        System.assertEquals(testSearch.Id, responses[0].arcuslandcharge__LC_Application__c, 'Responses should lookup to test search');
        System.assertEquals(testSearch.Id, responses[1].arcuslandcharge__LC_Application__c, 'Responses should lookup to test search');
        System.assertEquals(fakeId, responses[0].arcuslandcharge__Land_Charge_Register__c, 'Responses should lookup to fakeId of register.');
        System.assertEquals(fakeId, responses[1].arcuslandcharge__Land_Charge_Register__c, 'Responses should lookup to fakeId of register.');
        System.assertEquals('Part 1', responses[0].arcuslandcharge__Register_Part_Full__c, 'Incorrect value for register part.');
        System.assertEquals('Part 2', responses[1].arcuslandcharge__Register_Part_Full__c, 'Incorrect value for register part.');
    }

    private static testMethod void missingMergeFieldsOnCon29AreRemoved() {
        final Map<String, Map<String, Map<String, Object>>> normalisedData = new Map<String, Map<String, Map<String, Object>>>{
            'Planning Application' => new Map<String, Map<String, Object>>{
                'DMPA-2019-00007-HQH'=> new Map<String, Object>{
                    'pizza' => 'DMPA-2019-00007-HQH',
                    'potato' => 'Ethel'
                }
            }
        };

        LandChargeResponseGenerator.DataTypeConfig ethelDataTypeConfig = new LandChargeResponseGenerator.DataTypeConfig();
        CriteriaMatcherClone.Rule ethelRule = new CriteriaMatcherClone.Rule();
        ethelRule.field = 'potato';
        ethelRule.firstValue = 'Ethel';
        ethelRule.type = 'string';
        ethelRule.comparator = 'equals';
        ethelDataTypeConfig.criteria.add(ethelRule);
        Map<String, LandChargeResponseGenerator.DataTypeConfig> datatypeMap = new Map<String, LandChargeResponseGenerator.DataTypeConfig>{
            'Planning Application' => ethelDataTypeConfig
        };

        Map<String, Set<String>> mergeTokens = LandChargeResponseGenerator.extractMergeTokens(normalisedData);
        LandChargeResponseGenerator.QuestionConfig questionConfig = new LandChargeResponseGenerator.QuestionConfig();
        questionConfig.dataTypes = datatypeMap;
        String returnedAnswer = questionConfig.getAnswer(normalisedData, mergeTokens);    
        
        System.assert(!returnedAnswer.contains('{!'));
    }

    @isTest
    private static void returnsTrueIfExistingCON29Response() {
        arcuslandcharge__LCApplication__c searchRecord = new arcuslandcharge__LCApplication__c();
        insert searchRecord;
        arcuslandcharge__CON29_Response__c conResponse = new arcuslandcharge__CON29_Response__c(arcuslandcharge__LCApplication__c = searchRecord.Id);
        insert conResponse;

        Boolean hasConResponse = LandChargeResponseGenerator.hasRunCON29(searchRecord);

        System.assertEquals(true, hasConResponse);
    }

    @isTest
    private static void returnsFalseIfExistingCON29Response() {
        arcuslandcharge__LCApplication__c searchRecord = new arcuslandcharge__LCApplication__c();
        insert searchRecord;

        Boolean hasConResponse = LandChargeResponseGenerator.hasRunCON29(searchRecord);

        System.assertEquals(false, hasConResponse);
    }
}