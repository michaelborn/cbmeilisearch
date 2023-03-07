/**
 * I model the Meilisearch Search API
 *
 * @link https://docs.meilisearch.com/reference/api/search.html
 */
component accessors="true" extends="BaseRequest" {

	/**
	 * Search in an index using a POST API call. This is the preferred method, per Meilisearch. If no API key is required, use `searchWithGet()`.
	 *
	 * <code>
	 * 	search( "products", { "q" : "Wallet" } )
	 * </code>
	 *
	 * For an example, you can use the `limit` and `offset` parameters to fetch the second page of 25 records:
	 *
	 * <code>
	 * 	search( "products", {
	 * 		"q" : "Wallet",
	 * 		"limit" : 25,
	 * 		"offset" : 25
	 * 	} )
	 * </code>
	 *
	 * Please see the Meilisearch docs for more info on search parameters.
	 *
	 * @link https://docs.meilisearch.com/reference/api/search.html#search-in-an-index-with-post-route
	 */
	public HyperResponse function search( required string index, struct params = {} ){
		return HyperClient
			.asJson()
			.setURL( "/indexes/#arguments.index#/search" )
			.setBody( arguments.params )
			.setMethod( "POST" )
			.send();
	}

	/**
	 * Search in an index with GET route.
	 *
	 * <code>
	 * 	searchWithGet( "products", { "q" : "Wallet" } )
	 * </code>
	 *
	 * For an example, you can use the `limit` and `offset` parameters to fetch the second page of 25 records:
	 *
	 * <code>
	 * 	searchWithGet( "products", {
	 * 		"q" : "Wallet",
	 * 		"limit" : 25,
	 * 		"offset" : 25
	 * 	} )
	 * </code>
	 *
	 * Please see the Meilisearch docs for more info on search parameters.
	 *
	 * @link https://docs.meilisearch.com/reference/api/search.html#search-in-an-index-with-get-route
	 */
	public HyperResponse function searchWithGet( required string index, struct params = {} ){
		return HyperClient
			.withQueryParams( arguments.params )
			.asJson()
			.setURL( "/indexes/#arguments.index#/search" )
			.setMethod( "GET" )
			.send();
	}

	/**
	 * Search multiple indexes simultaneously.
	 * 
	 * <code>
	 * 	multiSearch( [ {
	 * 		"q" : "Owls",
	 * 		"indexUid" : "books",
	 * 		"limit" : 5
	 * 	},{
	 * 		"q" : "Owls",
	 * 		"indexUid" : "movies",
	 * 		"limit" : 5
	 * 	} )
	 * </code>
	 *
	 * @queries An array of query objects
	 */
	public HyperResponse function multiSearch( required array queries ){
		return HyperClient
			.asJson()
			.setURL( "/indexes/#arguments.index#/search" )
			.setBody({
				"queries" : arguments.queries
			})
			.setMethod( "POST" )
			.send();
	}
}
