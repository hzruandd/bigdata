 PUT /test/
{   
    "mappings": {
        "test_ts1": {
       
            "properties": {
       
                "timestamp": {
                    "type": "date",
                    "include_in_all": true
                }
            }   
        }
  }   
} 

GET /_cat/indices?v


get /test_ts2/test_ts2/_search
delete /test_ts2
delete /err_afe/err_afe/_query
{
"query": { "match": { "_id": "2248" } }
}'

delete  /demo-afe2016.12.13

GET _search
{
  "query": {
    "match_all": {}
  }
}


GET /demo-afe2016.12.08/kafka2logstash/_search

get /err_afe/err_afe/_search

PUT /last_index/last_index/77775
{
          "count": 8551,
          "date": 1479287457,
          "fake": "2016-11-16 17:10:57",
          "fake1": "2016-11-16 17:10:57",
          "id": 7777,
          "timestamp":"2016-11-16",
          "type": "jake DATA TO ES",
          "value": "[only test message for rdd]"
  
}
        
PUT /test/test_ts1/5
{
          "count": 8551,
          "date": 1479287457,
          "fake": "2016-11-16 17:10:57",
          "fake1": "2016-11-16 17:10:57",
          "id": 5,
          "date":"2016-11-16 22:22:22",
          "type": "jake DATA TO ES",
          "value": "[only test message for rdd]"
        }
        
        
get /demo_test/demo_test/_search
{}

POST /test/type1/_bulk
{ "index" : { "_index" : "test", "_type" : "type1", "_id" : "1" } }
{ "field1" : "value1" }
{ "delete" : { "_index" : "test", "_type" : "type1", "_id" : "2" } }
{ "create" : { "_index" : "test", "_type" : "type1", "_id" : "3" } }
{ "field1" : "value3" }
{ "update" : {"_id" : "1", "_type" : "type1", "_index" : "test"} }
{ "doc" : {"field2" : "value2"} }

put /test/test_ts1/4
{
      

 "id": "4",
 "timestamp": "2016-12-15T01:54:52.359Z"
}

put /test/test_ts1/10
{
      
 "id": "10",
 "timestamp": "2016-12-15 10:01:22"
}

PUT /err/
{   
    "mappings": {
        "err": {
       
            "properties": {
       
                "date": {
                    "type": "date",
                    "include_in_all": true
                },  
                "value": {
                    "type": "string",
                    "include_in_all": true
              },  
                "type": {
                    "type": "string",
                    "include_in_all": true
                },  
                "count": {
                    "type": "long",
                    "index": "not_analyzed"
                } 
            }   
        }        }   
}  
