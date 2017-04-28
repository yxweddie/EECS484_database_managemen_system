//find the oldest friend for each user who has a friend. For simplicity, use only year of birth to determine age, if there is a tie, use the one with smallest user_id
//return a javascript object : key is the user_id and the value is the oldest_friend id
//You may find query 2 and query 3 helpful. You can create selections if you want. Do not modify users collection.
// 
//You should return something like this:(order does not matter)
//{user1:userx1, user2:userx2, user3:userx3,...}

function oldest_friend(dbname){
  db = db.getSiblingDB(dbname);
  db.flat_users.drop();
  //implementation goes here
  var res = {};
  db.createCollection("flat_users");
  db.users.aggregate([{ $unwind : "$friends" }]).forEach(
    	function(myDoc) { 
    		db.flat_users.insert({user_id : myDoc['user_id'], friends : myDoc['friends']});
    	} 
  );

  db.users.find().forEach( function(myDoc) { 
    	var user1 = myDoc.user_id;
    	var oldf  = 99999 ;
    	var oldy  = 99999 ;
    	db.flat_users.find().forEach( function(myDocIn){
    		var userid = myDocIn.user_id;
    		var friendid = myDocIn.friends;
    		if(userid == user1){
    			// so friend is frie
    			var ans = db.users.find({user_id : friendid});
    			ans = ans.next();
    			if(ans["YOB"] < oldy){
    				oldy = ans["YOB"];
    				oldf = friendid;
    			}else if(ans["YOB"] == oldy){
    				if(friendid < oldf){
    					oldf = friends;
    				}
    			}
    		}else if(friendid == user1){
    			// so userid is friend
    			var ans = db.users.find({user_id : userid});
    			ans = ans.next();
    			if(ans["YOB"] < oldy){
    				oldy = ans["YOB"];
    				oldf = userid;
    			}else if(ans["YOB"] == oldy){
    				if(userid < oldf){
    					oldf = userid;
    				}
    			}
    		}
    	});
		res[user1] = oldf;
   } );
  //return an javascript object described above
  return res;
}
