public class DeleteContactsHyperBatch implements HyperBatch {

    public HyperBatchObjects.HyperBatchStart start() {
        return new HyperBatchObjects.HyperBatchStart('Contact', 'SELECT Id FROM Contact');     
    }    
    
    public Object execute(List<sObject> scope) {
		delete scope;
        return scope.size();
    }
    
    public void finish(List<Object> state) {
       
        Integer totalDeleted = 0;
        for (Object o: state) {
            totalDeleted += (Integer)o;
        }
		
		String body = 'Successfully deleted ' + totalDeleted + ' contacts.';
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{'hyperbatch@gmail.com'});
        mail.setReplyTo('hyperbatch@gmail.com');
        mail.setSenderDisplayName('Hyper Batch');
        mail.setSubject('DeleteContactsHyperBatch Complete');
        mail.setHtmlBody(body);
        mails.add(mail);
        Messaging.sendEmail(mails);           
        
    }   
}