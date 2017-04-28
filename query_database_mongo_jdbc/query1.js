//query1 : find users who live in the specified city. 
// Returns an array of user_ids.

function find_user(city, dbname){
    db = db.getSiblingDB(dbname)
    //implementation goes here
    var res = [];

    db.users.find().forEach( function(myDoc) { 
    	if (myDoc['hometown']['city'] == city){
    		res.push(myDoc['user_id']);
    	} 
    } );

    return res;
    // returns a Javascript array. See test.js for a partial correctness check.  
    // This will be  an array of integers. The order does not matter.                                                               
}
