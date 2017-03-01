public class UpdateAccountsBatch implements Database.Batchable<sObject>, Database.Stateful {

    //Database.executeBatch(new UpdateAccountsBatch(), 2000);
    
    public List<Object> state;
    public Datetime startTime;
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        state = new List<Object>();
        startTime = system.now();
        return Database.getQueryLocator('SELECT Id FROM Account');
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        //gather all the Account Ids in the scope
        Set<Id> actIds = new Set<Id>();
        for(sObject s: scope){
        	actIds.add((Id)s.get('Id'));
        }
        
		Map<Id, Account> actUpdateMap = new Map<Id, Account>();   
        
        Double smallestProb;        
        Double largestProb;
        String smallestProbAccountName;            
        String largestProbAccountName;
        
        //get the min Probability for the Accounts
        for (Account a: [SELECT Id, Name,
                         (SELECT Id, Probability__c FROM Contacts ORDER BY Probability__c ASC LIMIT 1) 
                         FROM Account WHERE Id IN: actIds]) {
			
        	Id lowest = (!a.Contacts.isEmpty() ? a.Contacts[0].Id : null);
			actUpdateMap.put(a.Id, new Account(Id = a.Id, Lowest_Probability_Contact__c=lowest));

            if (!a.Contacts.isEmpty()) {
                if (smallestProb == null || a.Contacts[0].Probability__c < smallestProb) {
                    smallestProb = a.Contacts[0].Probability__c;
                    smallestProbAccountName = a.Name;
                }                                         
            }
                                         
        }		

        //get the max Probability for the Accounts
        for (Account a: [SELECT Id, Name,
                         (SELECT Id, Probability__c FROM Contacts ORDER BY Probability__c DESC LIMIT 1) 
                         FROM Account WHERE Id IN: actIds]) {
			
			Id highest = (!a.Contacts.isEmpty() ? a.Contacts[0].Id : null);
 
            Account existing = actUpdateMap.get(a.Id);
            existing.Highest_Probability_Contact__c = highest;            
            actUpdateMap.put(a.Id, existing);
                             
            if (!a.Contacts.isEmpty()) {                 
                if (largestProb == null || a.Contacts[0].Probability__c > largestProb) {
                    largestProb = a.Contacts[0].Probability__c;
                    largestProbAccountName = a.Name;
                }
            }    
        }		        
        
        update actUpdateMap.values();
        
        Map<String, Object> retObj = new Map<String, Object>();
        retObj.put('size', scope.size());
        retObj.put('smallestProb', smallestProb);     
        retObj.put('largestProb', largestProb);
        retObj.put('smallestProbAccountName', smallestProbAccountName);        
        retObj.put('largestProbAccountName', largestProbAccountName);
		state.add(retObj);                 
    }
    
  public void finish(Database.BatchableContext BC) {

        Integer totalUpdated = 0;
      	Double smallestProbOverall;        
      	Double largestProbOverall;
      	String smallestProbAccountNameOverall;        
      	String largestProbAccountNameOverall;      
      
        for (Object o: state) {
            Map<String, Object> objMap = (Map<String, Object>)o;
            totalUpdated += (Integer)objMap.get('size');

            Double smallestProb = (Double)objMap.get('smallestProb');
            Double largestProb = (Double)objMap.get('largestProb');
            String smallestProbAccountName = (String)objMap.get('smallestProbAccountName');
            String largestProbAccountName = (String)objMap.get('largestProbAccountName');
			
            if (smallestProbOverall == null || smallestProb < smallestProbOverall) {
               smallestProbOverall = smallestProb;
               smallestProbAccountNameOverall = smallestProbAccountName;
            } 
            if (largestProbOverall == null || largestProb > largestProbOverall) {
               largestProbOverall = largestProb;
               largestProbAccountNameOverall = largestProbAccountName;
            }             
        }

      	Long milliseconds = System.now().getTime() - startTime.getTime();
      	Long seconds = milliseconds / 1000;            
      
		String body = 'Successfully updated ' + totalUpdated + ' Accounts with Lowest and Highest probability contacts.  ';
      	body += 'Elapsed time: ' + seconds + '.  ';
      	body += 'Lowest probability overall: ' + smallestProbOverall + ', Account: ' + smallestProbAccountNameOverall + '.  ';
      	body += 'Highest probability overall: ' + largestProbOverall + ', Account: ' + largestProbAccountNameOverall + '.  ';
      
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{'hyperbatch@gmail.com'});
        mail.setReplyTo('hyperbatch@gmail.com');
        mail.setSenderDisplayName('Apex Batch');
        mail.setSubject('UpdateAccountsBatch Complete');
        mail.setHtmlBody(body);
        mails.add(mail);
        Messaging.sendEmail(mails);           
        
    }     
}