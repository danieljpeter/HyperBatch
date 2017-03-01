@isTest
public with sharing class HyperBatchTest {
	
	private static testMethod void HyperBatchCon_getHyperBatchStart_Test() {
		Map<String, Object> retMap = HyperBatchCon.getHyperBatchStart('CreateContactsHyperBatch', true);
		
		HyperBatchObjects.HyperBatchStart hbs = (HyperBatchObjects.HyperBatchStart)retMap.get('HyperBatchStart');
		String batchClassName = (String)retMap.get('batchClassName');
		Boolean isAsync = (Boolean)retMap.get('isAsync');
		
		system.assertEquals('Account', hbs.objectName);		
		system.assertEquals('SELECT Id, Name FROM Account', hbs.query);	
		
		system.assertEquals('CreateContactsHyperBatch', batchClassName);			
		
		system.assertEquals(true, isAsync);			
    }
    
    
   	private static testMethod void HyperBatchCon_doHyperBatchFinishAsync_Test() {
   		//mock up some state from a CreateContactsHyperBatch execute
        String state = JSON.serialize(new Map<String, Object>{'size' => 5});    		
   		
   		//mock up a HyperBatchOutput__c
   		HyperBatchOutput__c hbo = new HyperBatchOutput__c(
   			AsyncApexJobId__c = '7074100000spG1A',
   			BatchState1__c = state
   		);
   		insert hbo;
   		
   		Test.startTest();
	   		Object retObj = HyperBatchCon.doHyperBatchFinishAsync('CreateContactsHyperBatch', new List<String>{'7074100000spG1A'});
  		Test.stopTest();
  		
  		Map<String, Object> retObjMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(retObj));
  
		//The ID of a queueable Apex job isn’t returned in test context: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_queueing_jobs.htm  		
  		system.assertEquals(null, retObjMap.get('jobId')); 
    }
    
   	private static testMethod void HyperBatchCon_doHyperBatchFinishSync_Test() {
   		//mock up some state from a CreateContactsHyperBatch execute
        String state = JSON.serialize(new List<Object>{new Map<String, Object>{'size' => 5}});
        
		Object retObj = HyperBatchCon.doHyperBatchFinishSync('CreateContactsHyperBatch', state);        
		Map<String, Object> retObjMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(retObj));	
		
		system.assertEquals('CreateContactsHyperBatch', (String)retObjMap.get('batchClassName'));
    }    
    
   	private static testMethod void HyperBatchCon_getAsyncJobStatus_Test() {
		system.assertEquals(0, HyperBatchCon.getAsyncJobStatus(new List<Id>{'7074100000spG1A'}).size()); 
    }        
    
   	private static testMethod void HyperBatchCon_executeAsync_Test() {
		//TODO: data factory, create some accounts and contacts
		
		Map<String, Object> retMap = HyperBatchCon.getHyperBatchStart('CreateContactsHyperBatch', true);
		HyperBatchObjects.HyperBatchStart hbs = (HyperBatchObjects.HyperBatchStart)retMap.get('HyperBatchStart');
		
		system.assertEquals('Account', hbs.objectName);		
		system.assertEquals('SELECT Id, Name FROM Account', hbs.query);	

   		HyperBatchCon.executeResponse er = HyperBatchCon.executeAsync('', '', false, hbs.query, 'CreateContactsHyperBatch');
		
		//TODO: add assertions
    }        
        
        
   	private static testMethod void HyperBatchCon_executeSync_Test() {
		//TODO: data factory, create some accounts and contacts
		
		Map<String, Object> retMap = HyperBatchCon.getHyperBatchStart('CreateContactsHyperBatch', true);
		HyperBatchObjects.HyperBatchStart hbs = (HyperBatchObjects.HyperBatchStart)retMap.get('HyperBatchStart');
		
		system.assertEquals('Account', hbs.objectName);		
		system.assertEquals('SELECT Id, Name FROM Account', hbs.query);	

   		HyperBatchCon.executeResponse er = HyperBatchCon.executeSync('', '', false, hbs.query, 'CreateContactsHyperBatch', 'guid-123');
		
		//TODO: add assertions
    }                

	 
	
	
}