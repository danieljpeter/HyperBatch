public class HyperBatchObjects {

    //custom class to hold an object name and a query on the object
    public class HyperBatchStart {
        String objectName {get; set;}
        String query {get; set;}
        
        public HyperBatchStart(String o, String q) {
            objectName = o;
            query = q;
        }
    }
        
    
    
}