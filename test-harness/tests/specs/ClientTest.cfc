component extends="BaseModelTest" appMapping="root" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		super.beforeAll();
		setup();

		variables.model = getWirebox().getInstance( "Client@cbmeilisearch" );
	}

	/*********************************** BDD SUITES ***********************************/

	function run(){
		describe( "cbmeilisearch.Client", function(){
			it( "can initiate", function(){
				expect( variables.model ).toBeInstanceOf( "Client" );
			} );

			describe( "Indexes", function(){
				it( "can create index", function(){
					var response = variables.model.createIndex( "movies", { "primaryKey" : "id" } );
					expect( response.isSuccess() ).toBeTrue();
					var resultTask = response.json();
					variables.model.waitForTask( resultTask.taskUid );
				} );

				it( "can get index", function(){
					variables.model.getIndex( "movies" );
				} );

				it( "can get ALL indexes", function(){
					variables.model.getAllIndexes( { "limit" : 20, "offset" : 1 } );
				} );

				it( title = "can swap indexes", body = function(){
					var response = model.swapIndexes( "movies", "films" );
					// debug( response );
					expect( response.isSuccess() ).toBeTrue();
					expect( response.json().type ).toBe( "indexSwap" );
				}, skip = parseVersion( this.MEILISEARCH_VERSION ) < parseVersion( "v0.30.0" ) );

				it( "can delete index", function(){
					variables.model.deleteIndex( "movies" );
				} );
			} );

			describe( "Documents", function(){
				it( "can get single document", function(){
					var testDocument = createTestDocument();
					variables.model.getDocument( "products", testDocument.id );
				} );
				it( "can get all documents", function(){
					variables.model.getDocuments( "products", { "limit" : 50, "offset" : "12" } );
				} );
				it( "can add multiple documents", function(){
					var documents = [
						{
							"id"       : "111",
							"title"    : "Deluxe Silver Digital Watch",
							"category" : "watches"
						},
						{
							"id"       : "217",
							"title"    : "Deluxe Leather Analog Watch",
							"category" : "watches"
						},
						{
							"id"       : "3767",
							"title"    : "Men's Leather Billfold",
							"category" : "wallets"
						}
					];
					var response = model.addDocuments(
						index      = "products",
						documents  = documents,
						primaryKey = "id"
					);
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();

					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "type" );
					expect( result.type ).toBe( "documentAdditionOrUpdate" );
				} );
				it( "can update multiple documents", function(){
					var documents = [
						{
							"id"              : "111",
							"title"           : "Deluxe Silver Digital Watch",
							"category"        : "watches",
							"manufactureYear" : "2016"
						},
						{
							"id"              : "217",
							"title"           : "Deluxe Leather Analog Watch",
							"category"        : "watches",
							"manufactureYear" : "2016"
						},
						{
							"id"              : "3767",
							"title"           : "Men's Leather Billfold",
							"category"        : "wallets",
							"manufactureYear" : "2008"
						},
						{
							"id"              : "22",
							"title"           : "Groundhog Day",
							"category"        : "jackets",
							"manufactureYear" : "1993"
						}
					];
					var response = model.updateDocuments(
						index      = "products",
						documents  = documents,
						primaryKey = "id"
					);
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();

					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "type" );
					expect( result.type ).toBe( "documentAdditionOrUpdate" );
				} );

				it( "can delete one document", function(){
					var response = model.deleteDocument( index = "products", document_id = "111" );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();

					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "type" );
					expect( result.type ).toBe( "documentDeletion" );
				} );

				it( "can delete by batch", function(){
					var response = model.deleteDocuments( index = "products", document_ids = [ "3767", "22" ] );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();

					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "type" );
					expect( result.type ).toBe( "documentDeletion" );
				} );

				it( "can delete all documents", function(){
					var response = model.deleteAllDocuments( "products" );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();

					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "type" );
					expect( result.type ).toBe( "documentDeletion" );
				} );
			} );

			describe( "Tasks", function(){
				it( "can get tasks", function(){
					variables.model.getAllTasks();
				} );

				it( "can get single task", function(){
					var response = variables.model.createIndex( "example" );
					expect( response.isSuccess() ).toBeTrue();
					var exampleTask = response.json();
					variables.model.getTask( exampleTask.taskUid );
				} );
				it( title = "can cancel tasks", body = function(){
					var response = variables.model.cancelTasks({
						"uids" : 1
					});
					expect( response.isSuccess() ).toBeTrue();
					expect( response.json().status ).toBe( "enqueued" );
					expect( response.json().type ).toBe( "taskCancelation" );
				}, skip = parseVersion( this.MEILISEARCH_VERSION ) < parseVersion( "v0.30.0" ) );
				it( title = "can delete tasks which succeeded or canceled before 2023", body = function(){
					var response = variables.model.deleteTasks({
						"statuses" :"succeeded,canceled",
						"beforeStartedAt" : "2023-01-01T10:00:00.000000Z"
					});
					expect( response.isSuccess() ).toBeTrue();
					expect( response.json().status ).toBe( "enqueued" );
					expect( response.json().type ).toBe( "taskDeletion" );
				}, skip = parseVersion( this.MEILISEARCH_VERSION ) < parseVersion( "v0.30.0" ) );
			} );

			describe( "Keys", function(){
				beforeEach( function(){
					if ( !variables.keyExists( "testKey" ) ) {
						var response = variables.model.createKey( {
							"name"        : "Basic API key",
							"description" : "Only used for searching.",
							"actions"     : [ "search" ],
							"indexes"     : [ "*" ],
							"expiresAt"   : javacast( "null", 0 )
						} );
						variables.model.parseAndThrow( response );
						expect( response.isSuccess() ).toBeTrue();
						variables.testKey = response.json();
					}
				} );

				it( "can get keys", function(){
					variables.model.getAllKeys();
				} );

				it( "can create key", function(){
					expect( variables.testKey ).toBeStruct().toHaveKey( "uid" );
				} );

				it( "can get single key", function(){
					variables.model.getKey( variables.testKey.uid );
				} );

				it( "can update key", function(){
					var key = variables.model.updateKey(
						variables.testKey.uid,
						{
							"name"        : "Search-only API key",
							"description" : "Only used for searching."
						}
					);
				} );

				it( "can delete key", function(){
					variables.model.deleteKey( variables.testKey.uid );
					// TODO: Uncomment when we switch to returning the HyperResponse object.
					// var isDeleted = variables.model.getKey( variables.testKey.uid );
					// expect( isDeleted.getStatusCode() ).toBe( 404 );
				} );
			} );

			describe( "Settings", function(){
				variables.taskIds = [];
				it( "getSettings", function(){
					var response = model.getSettings( "products" );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();

					// debug( result );
					expect( result ).toBeStruct();
				} );
				it( "updateSettings", function(){
					var response = model.updateSettings(
						"products",
						{
							"filterableAttributes" : [ "category" ],
							"stopWords"            : [ "the", "and", "or", "but", "not" ]
						}
					);
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();

					// debug( result );
					expect( result ).toBeStruct();
					variables.taskIds.append( result.taskUid );
				} );
				it( "resetSettings", function(){
					var response = model.resetSettings( "products" );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "enqueuedAt" );
					variables.taskIds.append( result.taskUid );
				} );
				it( "getDisplayedAttributes", function(){
					var response = model.getDisplayedAttributes( "products" );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeArray().toHaveLength( 1 );
					expect( result.first() ).toBe( "*" );
				} );
				it( "updateDisplayedAttributes", function(){
					var response = model.updateDisplayedAttributes( "products", [ "title", "price" ] );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "enqueuedAt" );
					variables.taskIds.append( result.taskUid );
				} );
				it( "resetDisplayedAttributes", function(){
					var response = model.resetDisplayedAttributes( "products" );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "enqueuedAt" );
					variables.taskIds.append( result.taskUid );
				} );
				it( "getDistinctAttribute", function(){
					var response = model.getDistinctAttribute( "products" );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					expect( isNull( result ) ).toBeTrue();
				} );
				it( "updateDistinctAttribute", function(){
					var response = model.updateDistinctAttribute( "products", "id" );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "enqueuedAt" );
					variables.taskIds.append( result.taskUid );
				} );
				it( "resetDistinctAttribute", function(){
					var response = model.resetDistinctAttribute( "products" );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "enqueuedAt" );
					variables.taskIds.append( result.taskUid );
				} );
				it( "getFacetingSettings", function(){
					var response = model.getFacetingSettings( "products" );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "maxValuesPerFacet" );
				} );
				it( "updateFacetingSettings", function(){
					var response = model.updateFacetingSettings( "products", { "maxValuesPerFacet" : 20 } );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "enqueuedAt" );
					variables.taskIds.append( result.taskUid );
				} );
				it( "resetFacetingSettings", function(){
					var response = model.resetFacetingSettings( "products" );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "enqueuedAt" );
					variables.taskIds.append( result.taskUid );
				} );
				it( "getFilterableAttributes", function(){
					var response = model.getFilterableAttributes( "products" );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeArray().toHaveLength( 0 );
				} );
				it( "updateFilterableAttributes", function(){
					var response = model.updateFilterableAttributes( "products", [ "price", "category" ] );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "enqueuedAt" );
					variables.taskIds.append( result.taskUid );
				} );
				it( "resetFilterableAttributes", function(){
					var response = model.resetFilterableAttributes( "products" );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "enqueuedAt" );
					variables.taskIds.append( result.taskUid );
				} );
				it( "getPaginationSettings", function(){
					var response = model.getPaginationSettings( "products" );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "maxTotalHits" );
				} );
				it( "updatePaginationSettings", function(){
					var response = model.updatePaginationSettings( "products", { "maxTotalHits" : 20 } );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "enqueuedAt" );
					variables.taskIds.append( result.taskUid );
				} );
				it( "resetPaginationSettings", function(){
					var response = model.resetPaginationSettings( "products" );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "enqueuedAt" );
					variables.taskIds.append( result.taskUid );
				} );
				it( "getRankingRules", function(){
					var response = model.getRankingRules( "products" );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeArray().toHaveLength( 6 );
				} );
				it( "updateRankingRules", function(){
					var response = model.updateRankingRules(
						"products",
						[
							"words",
							"typo",
							"proximity",
							"attribute",
							"sort",
							"exactness",
							"release_date:desc"
						]
					);
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "enqueuedAt" );
					variables.taskIds.append( result.taskUid );
				} );
				it( "resetRankingRules", function(){
					var response = model.resetRankingRules( "products" );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "enqueuedAt" );
					variables.taskIds.append( result.taskUid );
				} );
				it( "getSearchableAttributes", function(){
					var response = model.getSearchableAttributes( "products" );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeArray().toHaveLength( 1 );
					expect( result.first() ).toBe( "*" );
				} );
				it( "updateSearchableAttributes", function(){
					var response = model.updateSearchableAttributes( "products", [ "title", "price" ] );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "enqueuedAt" );
				} );
				it( "resetSearchableAttributes", function(){
					var response = model.resetSearchableAttributes( "products" );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "enqueuedAt" );
					variables.taskIds.append( result.taskUid );
				} );
				it( "getSortableAttributes", function(){
					var response = model.getSortableAttributes( "products" );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeArray().toHaveLength( 0 );
				} );
				it( "updateSortableAttributes", function(){
					var response = model.updateSortableAttributes( "products", [ "title", "price" ] );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "enqueuedAt" );
					variables.taskIds.append( result.taskUid );
				} );
				it( "resetSortableAttributes", function(){
					var response = model.resetSortableAttributes( "products" );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "enqueuedAt" );
					variables.taskIds.append( result.taskUid );
				} );
				it( "getStopWords", function(){
					var response = model.getStopWords( "products" );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeArray().toHaveLength( 0 );
				} );
				it( "updateStopWords", function(){
					var response = model.updateStopWords( "products", [ "of", "the", "and" ] );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "enqueuedAt" );
					variables.taskIds.append( result.taskUid );
				} );
				it( "resetStopWords", function(){
					var response = model.resetStopWords( "products" );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "enqueuedAt" );
					variables.taskIds.append( result.taskUid );
				} );
				it( "getSynonyms", function(){
					var response = model.getSynonyms( "products" );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeStruct().toBeEmpty();
				} );
				it( "updateSynonyms", function(){
					var response = model.updateSynonyms(
						"products",
						{
							"Michael" : [ "strong", "intelligent" ],
							"Born"    : [ "Bourne", "Jason" ]
						}
					);
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "enqueuedAt" );
					variables.taskIds.append( result.taskUid );
				} );
				it( "resetSynonyms", function(){
					var response = model.resetSynonyms( "products" );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "enqueuedAt" );
					variables.taskIds.append( result.taskUid );
				} );
				it( "getTypoTolerance", function(){
					var response = model.getTypoTolerance( "products" );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "minWordSizeForTypos" );
				} );
				it( "updateTypoTolerance", function(){
					var response = model.updateTypoTolerance(
						"products",
						{
							"enabled"             : true,
							"disableOnWords"      : [ "lowes" ],
							"disableOnAttributes" : [ "name" ]
						}
					);
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "enqueuedAt" );
					variables.taskIds.append( result.taskUid );
				} );
				it( "resetTypoTolerance", function(){
					var response = model.resetTypoTolerance( "products" );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();
					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "enqueuedAt" );
					variables.taskIds.append( result.taskUid );
				} );
				it( "All tasks succeeded", function(){
					variables.taskIds.each( ( taskUID ) => {
						var response = model.getTask( taskUID );
						expect( response.isSuccess() ).toBeTrue();
						var result = response.json();
						// debug( result );
						expect( result.status ).toBe( "succeeded" );
					} )
				} );
			} );
			describe( "Dumps", function(){
				it( "can create dump", function(){
					var response = model.createDump();
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();

					// debug( result );
					expect( result ).toBeStruct();
				} );
			} );
			describe( "Version", function(){
				it( "can get version", function(){
					var response = model.version();
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();

					// debug( result );
					expect( result ).toBeStruct();
				} );
			} );
			describe( "Stats", function(){
				it( "can get individual index stats", function(){
					var response = model.stats( "products" );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();

					// debug( result );
					expect( result ).toBeStruct();
				} );

				it( "can get all stats for all indexes", function(){
					var response = model.stats();
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();

					// debug( result );
					expect( result ).toBeStruct();
				} );
			} );
			describe( "Search", function(){
				beforeEach( function(){
					if ( !variables.keyExists( "testDocument" ) ) {
						variables.testDocument = createTestDocument();
					}
				} );
				it( "can search with POST method", function(){
					var response = model.search( "products", {
						"q" : "watch",
						"attributesToHighlight" : [ "title" ]
					} );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();

					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "hits" );
					expect( arrayFirst( result.hits ) ).toHaveKey( "_formatted" );
				} );

				it( "can search with GET method", function(){
					var response = model.searchWithGet( "products", {
						"q" : "watch",
						// TODO: Investigate  array-to-string casting issue in Hyper.
						"attributesToHighlight" : "title"
					} );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();

					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "hits" );
					expect( arrayFirst( result.hits ) ).toHaveKey( "_formatted" );
				} );

				it( "can do multi-index search", function(){
					var response = model.multiSearch( [ {
							"q" : "Owls",
							"indexUid" : "books",
							"limit" : 5
						},{
							"q" : "Owls",
							"indexUid" : "movies",
							"limit" : 5
						} );
					expect( response.isSuccess() ).toBeTrue();
					var result = response.json();

					// debug( result );
					expect( result ).toBeStruct().toHaveKey( "hits" );
					expect( arrayFirst( result.hits ) ).toHaveKey( "_formatted" );
				} );
			} );
		} );
	}

	function createTestDocument(){
		var testDocument = {
			"id"       : createUUID(),
			"title"    : "Deluxe Silver Digital Watch",
			"category" : "watches"
		};
		var response = variables.model.addDocuments( "products", [ testDocument ] );
		expect( response.isSuccess() ).toBeTrue();
		var resultTask = response.json();
		variables.model.waitForTask( resultTask.taskUid );
		return testDocument;
	}

}
