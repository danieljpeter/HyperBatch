public class DeleteContactsBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    //Database.executeBatch(new DeleteContactsBatch(), 2000);    
    
    public List<Object> state;
    public Datetime startTime;
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        state = new List<Object>();
        startTime = system.now();
        return Database.getQueryLocator('SELECT Id FROM Contact');
    }    
    
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
		delete scope;
		state.add(scope.size());   
    }
    
    public void finish(Database.BatchableContext BC) {
       
        Integer totalDeleted = 0;
        for (Object o: state) {
            totalDeleted += (Integer)o;
        }
		
      	Long milliseconds = System.now().getTime() - startTime.getTime();
      	Long seconds = milliseconds / 1000;             
        
		String body = 'Successfully deleted ' + totalDeleted + ' contacts.  ';
      	body += 'Elapsed time: ' + seconds + '.  ';

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{'hyperbatch@gmail.com'});
        mail.setReplyTo('hyperbatch@gmail.com');
        mail.setSenderDisplayName('Apex Batch');
        mail.setSubject('DeleteContactsBatch Complete');
        mail.setHtmlBody(body);
        mails.add(mail);
        Messaging.sendEmail(mails);           
        
    }   
}