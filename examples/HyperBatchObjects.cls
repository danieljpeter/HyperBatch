public class HyperBatchObjects {

    //custom class to hold an object name and a query on the object
    public class HyperBatchStart {
        public String objectName {get; set;}
        public String query {get; set;}
        
        public HyperBatchStart(String o, String q) {
            objectName = o;
            query = q;
        }
    }
        
    
    
}