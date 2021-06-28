public with sharing class GetArticleData {
    public GetArticleData() {

    }

    @AuraEnabled(cacheable=true)
    public static List<News_Article__c> getAllNewsArticles(){
        try {
            return [SELECT Id,Article_Name__c,Category__c, Date_Published__c,
            Description__c, Article_URL__c, Has_Image__c, Has_Video__c, 
            Image_URL__c, News_Search__c, Providers__c, Video_URL__c FROM News_Article__c];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    
    // Make secure and dynamic
    @AuraEnabled(cacheable=true)
    public static Map<News_Article__c> getAllNewsArticles(String articleName){
        try {
            return [SELECT Id,Article_Name__c,Category__c, Date_Published__c,
            Description__c, Article_URL__c, Has_Image__c, Has_Video__c, 
            Image_URL__c, News_Search__c, Providers__c, Video_URL__c FROM News_Article__c
            WHERE Article_Name__c LIKE :articleName]
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
