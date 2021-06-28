public with sharing class NewsCallout {
    private String searchString;
    public NewsCallout() {

    }


    // TODO: Pass in user's location from LWC component
    public static HttpResponse getQueryResult(String searchString){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        // Hardcoded location
        req.setEndpoint('https://api.bing.microsoft.com/v7.0/news/search?q='+searchString+'&mkt=en-AU');
        req.setMethod('GET');
        req.setHeader('Ocp-Apim-Subscription-Key', 'b10ad8c3dbc74169a72e5bdf55cb58cf');
        // req.setHeader('X-Search-Location', 'lat:55;long:-111;re:22');
        System.debug(req.toString());
        HttpResponse response = http.send(req);
        Map <String, Object> results = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
        // System.debug(results);
        destructureQuery(response, searchString);
        return response;
    }

    public static NewsSearch deserialize(httpResponse res){
		return (NewsSearch)JSON.deserialize(res.getBody(),NewsSearch.class);
	}

    public static void destructureQuery(HttpResponse res, String searchString){
        NewsSearch searchResponse = deserialize(res);
        // Debug variables
        System.debug(searchResponse.totalEstimatedMatches);
        System.debug(searchResponse.value.size());
        System.debug(searchResponse.value[0].category);
        System.debug(searchResponse.value[0].datePublished);
        System.debug(searchResponse.value[0].description);
        System.debug(searchResponse.value[0].name);
        System.debug(searchResponse.value[0].url);
        System.debug(searchResponse.value[0].video);

        // Parent object
        News_Search__c newSearchResult = new News_Search__c();
        newSearchResult.Name = searchString;

        insert newSearchResult;
        List <News_Article__c> newArticles = new List <News_Article__c>();
        // Initialise Child objects
        for (NewsArticle article: searchResponse.value){
            News_Article__c newArticle = new News_Article__c();
            newArticle.News_Search__c = newSearchResult.Id;
            newArticle.Article_Name__c = article.name;
            newArticle.Article_URL__c = article.url;
            newArticle.Category__c = article.category;
            newArticle.Date_Published__c = article.datePublished;
            newArticle.Description__c = article.description;
            if (article.image != null){
                newArticle.Has_Image__c = true;
                newArticle.Image_URL__c = article.image.url;
            }
            if (article.video != null){
                newArticle.Has_Video__c = true;
                newArticle.Video_URL__c = article.video.thumbnailUrl;
            }
            
            String providers = ''; 
            for (Organization provider: article.provider){
                providers+=provider.name+', ';
            }
            newArticle.Providers__c = providers;
            System.debug(newArticle);
            newArticles.add(newArticle);
        }
        
        insert newArticles;
        
    }


    // Helper Classes to destructure fields that are needed
    public class NewsSearch{
        public Integer totalEstimatedMatches;
        public List<NewsArticle> value; 
    }

    public class NewsArticle{
        public String category;
        public Datetime datePublished;
        public String description;
        public Image image;
        public String name;
        public String url;
        public Video video;
        public List<Organization> provider;
    }

    public class Image{
        public String url;
        public Thumbnail thumbnail;
    }

    public class Thumbnail{
        public String contentUrl;
        public Integer height;
        public Integer width;
    }

    public class Video{
        public String name;
        public MediaSize thumbnail;
        public String thumbnailUrl;
    }

    public class Organization{
        public String name;
    }

    public class MediaSize{
        public Integer height;
        public Integer width;
    }

}    



