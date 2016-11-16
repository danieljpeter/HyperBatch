public class CreateContactsBatch implements Database.Batchable<sObject>, Database.Stateful {

    //Database.executeBatch(new CreateContactsBatch(), 2000);
    
    public List<Object> state;
    public Datetime startTime;
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        state = new List<Object>();
        startTime = system.now();
        return Database.getQueryLocator('SELECT Id, Name FROM Account');
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Contact> cl = new List<Contact>();

        for(sobject s : scope){
            for (Integer i=1; i<=3; i++) {
                Double prob = Math.random();
                cl.add(new Contact(AccountId=(Id)s.get('Id'), LastName = s.get('Name') + ' ' +  i, Probability__c=prob));    
            }
        }
        insert cl;
        
        Map<String, Object> retObj = new Map<String, Object>();
        retObj.put('size', cl.size());
		state.add(retObj);              
    }
    
    public void finish(Database.BatchableContext BC) {
        
        Integer totalCreated = 0;
        for (Object o: state) {
            Map<String, Object> objMap = (Map<String, Object>)o;
            totalCreated += (Integer)objMap.get('size');
        }

      	Long milliseconds = System.now().getTime() - startTime.getTime();
      	Long seconds = milliseconds / 1000;   
        
		String body = 'Successfully created ' + totalCreated + ' contacts.';
      	body += 'Elapsed time: ' + seconds + '.  ';        
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{'hyperbatch@gmail.com'});
        mail.setReplyTo('hyperbatch@gmail.com');
        mail.setSenderDisplayName('Apex Batch');
        mail.setSubject('CreateContactsBatch Complete');
        mail.setHtmlBody(body);
        mails.add(mail);
        Messaging.sendEmail(mails);   
        
    }   
}