// query 4: find user pairs such that, one is male, second is female,
// their year difference is less than year_diff, and they live in same
// city and they are not friends with each other. Store each user_id
// pair as arrays and return an array of all the pairs. The order of
// pairs does not matter. Your answer will look something like the following:
// [
//      [userid1, userid2],
//      [userid1, userid3],
//      [userid4, userid2],
//      ...
//  ]
// In the above, userid1 and userid4 are males. userid2 and userid3 are females.
// Besides that, the above constraints are satisifed.
// userid is the field from the userinfo table. Do not use the _id field in that table.
  
function suggest_friends(year_diff, dbname) {
    db = db.getSiblingDB(dbname)
    //implementation goes here
    db.flat_users.drop();
    var res = [];
    db.users.find({gender : "male"}).forEach( function(myDoc) { 
    	var male_id   = myDoc.user_id;
    	var male_city = myDoc.hometown.city;
    	var male_year = myDoc.YOB;
    	var m_array   = myDoc["friends"];

    	db.users.find({gender : "female"}).forEach( function(myDoc2){
    		var female_id   = myDoc2.user_id;
    		var female_city = myDoc2.hometown.city;
    		var female_year = myDoc2.YOB;
    		var f_array   = myDoc2["friends"];
    		if(Math.abs(female_year - male_year) < year_diff){
    			if(female_city == male_city){
    				
    				var isf = false;
    				for(var i =0 ; i < m_array.length;i++){
    					if(m_array[i] == female_id){
    						isf = true;
    						break;
    					}
    				}

    				for(var i =0 ; i < f_array.length;i++){
    					if(f_array[i] == male_id){
    						isf = true;
    						break;
    					}
    				}	

    				if(!isf){
    					res.push([male_id,female_id]);
    				}
    			}
    		}
    	});
    });
    return res;
    // Return an array of arrays.
}
