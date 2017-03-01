public class LeadCallReminderHyperBatch implements HyperBatch {

    public HyperBatchObjects.HyperBatchStart start() {
        return new HyperBatchObjects.HyperBatchStart('Lead', 'SELECT Id FROM Lead');       
    }    
    
    public Object execute(List<sObject> scope) {
        List<Task> tl = new List<Task>();

        for(sobject s : scope){
            tl.add(
                new Task(
                    WhoId = (Id)s.get('Id'),
                    ActivityDate = date.today(),
                    Subject = 'Call this person!',
                    Priority = 'Normal',
                    Status = 'Not Started',
                    Description = 'see if they want to buy something'
                )
            );
        }
        insert tl;

        Map<String, Object> retObj = new Map<String, Object>();
        retObj.put('size', tl.size());
            
		return retObj;          
    }
    
    public void finish(List<Object> state) {
        Integer totalCreated = 0;
        for (Object o: state) {
            Map<String, Object> objMap = (Map<String, Object>)o;
            totalCreated += (Integer)objMap.get('size');
        }
		String body = 'Successfully created ' + totalCreated + ' Lead Reminders.';
		system.debug('LeadCallReminderHyperBatch finish: ' + body);
    }   
}