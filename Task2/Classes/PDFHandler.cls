public with sharing class PDFHandler {

    private final Account a; 

	public PDFHandler(ApexPages.StandardController standardPageController) {
		a = (Account)standardPageController.getRecord(); //instantiate the Account object for the current record
	}

    public Pagereference attachPDF() {
        PageReference pr = PDFCreator.createPDF(a.Id);
        return pr;
    }
}
