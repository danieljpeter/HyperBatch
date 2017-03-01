public class CreateContactsHyperBatch implements HyperBatch {

    public HyperBatchObjects.HyperBatchStart start() {
        return new HyperBatchObjects.HyperBatchStart('Account', 'SELECT Id, Name FROM Account');       
    }    
    
    public Object execute(List<sObject> scope) {
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
            
		return retObj;        
    }
    
    public void finish(List<Object> state) {
		
        Integer totalCreated = 0;
        for (Object o: state) {
            Map<String, Object> objMap = (Map<String, Object>)o;
            totalCreated += (Integer)objMap.get('size');
        }
        
		String body = 'Successfully created ' + totalCreated + ' contacts.';
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{'hyperbatch@gmail.com'});
        mail.setReplyTo('hyperbatch@gmail.com');
        mail.setSenderDisplayName('Hyper Batch');
        mail.setSubject('CreateContactsHyperBatch Complete');
        mail.setHtmlBody(body);
        mails.add(mail);
        Messaging.sendEmail(mails);   
        
    }   
}