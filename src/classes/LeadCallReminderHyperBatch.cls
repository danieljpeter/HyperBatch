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

        return null;        
    }
    
    public void finish(List<Object> state) {
    }   
}