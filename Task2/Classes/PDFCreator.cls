public with sharing class PDFCreator {
    
    @future (callout=true)
    public static void createPDFs(List<Id> accIds)
    {
        List<Attachment> attachments = new List<Attachment>();
        for(Id accId: accIds) {
            Attachment accAttachment = createAccAttachment(accId);
            attachments.add(accAttachment);
        }
        insert attachments;
    }

    private static Attachment createAccAttachment(Id accId) {
        PageReference pdf = Page.AccDetailsForPDF;
        System.debug(pdf);
        pdf.getParameters().put('id', '' + accId);
        Blob data = pdf.getContent();

        return new Attachment(
            Name = 'AccountDetails.pdf',
            Body = data,
            ParentId = '' + accId
        );
    }
}
