//query2
//unwind friends and create a new collection called flat_users where each document has the following schema:
/*
{
  user_id:xxx
  friends:xxx
}
*/


function unwind_friends(dbname){
    db = db.getSiblingDB(dbname)
    //implementation goes here
    db.flat_users.drop();
    db.createCollection("flat_users");

    db.users.aggregate([{ $unwind : "$friends" }]).forEach(
    		function(myDoc) { 
    			db.flat_users.insert({user_id : myDoc['user_id'], friends : myDoc['friends']});
    		} 
        );
    // returns nothing. It creates a collection instead as specified above.
}
