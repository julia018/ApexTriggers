public with sharing class PDFCreator {

    public static Pagereference createPDF(Id accId) {

        Pagereference pr = createAccAttachment(accId);        
        return pr;
    }

    private static Pagereference createAccAttachment(Id accId) {
        PageReference pdf = Page.AccountDetailsForPDFV2;
        System.debug(pdf);
        pdf.getParameters().put('id', '' + accId);
        Blob data = pdf.getContent();

        Attachment attachment = new Attachment(
            Name = 'AccountDetails.pdf',
            Body = data,
            ParentId = '' + accId
        );

        insert attachment;

        return pdf;
    }
}
