public class EntryURL {
    @TestVisible
    private static Boolean isFromBrowser = true;
    
    // PUBLIC
    public static Boolean isFromBrowser() {
        return (Test.isRunningTest()) ? isFromBrowser : !String.valueOf(System.URL.getCurrentRequestUrl().getPath()).toLowerCase().contains('/services/data/');
    }
}