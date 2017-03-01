public interface HyperBatch {
    HyperBatchObjects.HyperBatchStart start();
    Object execute(List <sObject> scope);
    void finish(List<Object> state);
}