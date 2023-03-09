@isTest public class ShowDocumentControllerTest {
    @isTest private static void unit1(){
        Test.StartTest(); 
            PageReference pageRef = Page.ShowDocument; // Add your VF page Name here
            pageRef.getParameters().put('url', 'https://www.google.com');
            pageRef.getParameters().put('type', 'Image');
            Test.setCurrentPage(pageRef);
            ShowDocumentController obj = new ShowDocumentController();
            obj.getIsImage();
            obj.getIsPdf();
            obj.getIsHTML();
            obj.download();
            //testAccPlan.save(); call all your function here
        Test.StopTest();
    }
	 
}