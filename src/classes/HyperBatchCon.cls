public class HyperBatchCon {

    //batchService.doBatch();
    
    @RemoteAction
    //this method takes in the name of a class which implements Database.Batchable
    //dynamically instantiates it, runs the hyperStart method, and returns HyperBatchStart object
    //which has the object name and the query on the object
    //also a passthrough parameter as to whether we are running this in async mode
    public static Map<String, Object> getHyperBatchStart(String batchClassName, Boolean isAsync) {
        Type batchClass = Type.forName(batchClassName);
		HyperBatch b = (HyperBatch)batchClass.newInstance();
        return new Map<String, Object>{'HyperBatchStart' => b.start(), 'batchClassName' => batchClassName, 'isAsync' => isAsync};
	}
    
    @RemoteAction
    public static Object doHyperBatchFinishAsync(String batchClassName, List<String> AsyncApexJobIds) {
        Map<String, Object> retObj = new Map<String, Object>();
        retObj.put('batchClassName', batchClassName);
        retObj.put('AsyncApexJobIds', AsyncApexJobIds);
        
        finishAsync fa = new finishAsync();
        fa.batchClassName = batchClassName;
        fa.AsyncApexJobIds = AsyncApexJobIds;
		Id jobId = System.enqueueJob(fa);
        retObj.put('jobId', jobId);        
        
        return retObj; 
	}    
	
    @RemoteAction
    public static Object doHyperBatchFinishSync(String batchClassName, String state) {
		List<Object> stateList = (List<Object>)JSON.deserializeUntyped(state);

        Map<String, Object> retObj = new Map<String, Object>();
        retObj.put('batchClassName', batchClassName);
		
		Type batchClass = Type.forName(batchClassName);
        HyperBatch b = (HyperBatch)batchClass.newInstance();
        b.finish(stateList);        
        
        return retObj;
	}    	
    
    
    @RemoteAction
    public static List<AsyncApexJob> getAsyncJobStatus(List<Id> jobIds) {
		return [SELECT Id, Status, ExtendedStatus FROM AsyncApexJob WHERE Id IN: jobIds];
	}
        

    
    @RemoteAction
    public static executeResponse executeAsync(String firstId, String lastId, Boolean isLast, String query, String batchClassName) {
        executeResponse er = new executeResponse();
        er.success = true;
        er.msg = '';
        er.isAsync = true;
        
        execAsync ea = new execAsync();
        ea.firstId = firstId;
        ea.lastId = lastId;
        ea.isLast = isLast;
        ea.query = query;
        ea.batchClassName = batchClassName;
        
		Id jobId = System.enqueueJob(ea);
        er.jobId = (jobId+'').left(15);
        
        return er;
	}        
    
    @RemoteAction
    public static executeResponse executeSync(String firstId, String lastId, Boolean isLast, String query, String batchClassName, String guid) {
        executeResponse er = new executeResponse();
        er.success = true;
        er.msg = '';
        er.isAsync = false;
        er.jobId = guid;

        //add the Id ranges on to the query
        query = HyperBatchCon.addChunkFilter(query, firstId, lastId, isLast);
        
        Type batchClass = Type.forName(batchClassName);
        HyperBatch b = (HyperBatch)batchClass.newInstance();        
        er.state = b.execute(Database.query(query));        

        return er;
	}            
    
    
    
    
	public static String addChunkFilter(String query, String firstId, String lastId, Boolean isLast) {
	    //create our Id chunk filter
	    String chunkEndOperator = isLast ? '<=' : '<';
	    String chunkIdFilter = 'Id >= \''+ firstId +'\' AND Id ' + chunkEndOperator + ' \'' + lastId + '\'';
	    
	    //add our chunk filter to the query
	    if (query.containsIgnoreCase(' where ')) {
	        chunkIdFilter = ' AND ' + chunkIdFilter;
	    } else {
	        chunkIdFilter = ' WHERE ' + chunkIdFilter;
	    }
	    query += chunkIdFilter;	
		
		return query;
	}    
        
    
    
public class executeResponse {
    public Boolean success {get; set;}
    public String msg {get; set;} 
    public String jobId {get; set;}
    public Boolean isAsync {get; set;}
    public Object state {get; set;}
}
    
public class execAsync implements Queueable {
	
    String firstId {get; set;}
    String lastId {get; set;}
    Boolean isLast {get; set;}
    String query {get; set;}
    String batchClassName {get; set;}   
        
        
    public execAsync() {
    }
	
    public void execute(QueueableContext context) {
        //add the Id ranges on to the query
        query = HyperBatchCon.addChunkFilter(query, firstId, lastId, isLast);
        
        Type batchClass = Type.forName(batchClassName);
        HyperBatch b = (HyperBatch)batchClass.newInstance();        
        String state = JSON.serialize(b.execute(Database.query(query)));
        
        //write the state out to the DB
        String jobId15 = (context.getJobId()+'').left(15);
        HyperBatchOutput__c hbo = new HyperBatchOutput__c(AsyncApexJobId__c=jobId15);

        Boolean hasMore = true;
		Integer intCount = 1;
        //chunk up the JSON state into 131072 long text area fields
        while (hasMore) {
            if (intCount == 13) {
                throw new HyperBatchException('Batch State Exceeds 1,572,864 chars');   
            }
            Integer len = state.length();
            if (len > 131072) {
            	len = 131072;   
            }
			hbo.put('BatchState'+intCount+'__c', state.left(len));
            state = state.substring(len);
            if (state == '') {
            	hasMore = false;  
            }
        	intCount++;   
        }
        insert hbo;
    }
}


public class finishAsync implements Queueable {
	
    public String batchClassName {get; set;}
    public List<String> AsyncApexJobIds {get; set;}
        
    public finishAsync() {
    }
	
    public void execute(QueueableContext context) {
        Type batchClass = Type.forName(batchClassName);
        List<Object> state = new List<Object>();
		
        String soql = 'SELECT Id, AsyncApexJobId__c';
        for (Integer i=1; i<=12; i++) {
        	soql += ', BatchState' + i + '__c';  
        }
        soql += ' FROM HyperBatchOutput__c WHERE AsyncApexJobId__c IN: AsyncApexJobIds';
        
        List<Id> hboIds = new List<Id>(); 
        for (HyperBatchOutput__c hbo : Database.query(soql)) {
            String hboState = '';
            for (Integer i=1; i<=12; i++) {
                String hboStatePart = (String)hbo.get('BatchState' + i + '__c');
                if (String.isBlank(hboStatePart)) {
                	break;    
                } else {
                    hboState += hboStatePart;
                }
            }
            if (String.isNotBlank(hboState)) {
            	state.add(JSON.deserializeUntyped(hboState));   
            }
        }
    
        HyperBatch b = (HyperBatch)batchClass.newInstance();
        b.finish(state);
        
        Database.delete(hboIds);
    }
}



    
public class HyperBatchException extends Exception {}    
    
    
}