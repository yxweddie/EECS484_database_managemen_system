import java.io.FileWriter;
import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.TreeSet;
import java.util.Vector;



//json.simple 1.1
// import org.json.simple.JSONObject;
// import org.json.simple.JSONArray;

// Alternate implementation of JSON modules.
import org.json.JSONObject;
import org.json.JSONArray;

public class GetData{
	
    static String prefix = "crowella.";
	
    // You must use the following variable as the JDBC connection
    Connection oracleConnection = null;
	
    // You must refer to the following variables for the corresponding 
    // tables in your database

    String cityTableName = null;
    String userTableName = null;
    String friendsTableName = null;
    String currentCityTableName = null;
    String hometownCityTableName = null;
    String programTableName = null;
    String educationTableName = null;
    String eventTableName = null;
    String participantTableName = null;
    String albumTableName = null;
    String photoTableName = null;
    String coverPhotoTableName = null;
    String tagTableName = null;

    // This is the data structure to store all users' information
    // DO NOT change the name
    JSONArray users_info = new JSONArray();		// declare a new JSONArray

	
    // DO NOT modify this constructor
    public GetData(String u, Connection c) {
	super();
	String dataType = u;
	oracleConnection = c;
	// You will use the following tables in your Java code
	cityTableName = prefix+dataType+"_CITIES";
	userTableName = prefix+dataType+"_USERS";
	friendsTableName = prefix+dataType+"_FRIENDS";
	currentCityTableName = prefix+dataType+"_USER_CURRENT_CITY";
	hometownCityTableName = prefix+dataType+"_USER_HOMETOWN_CITY";
	programTableName = prefix+dataType+"_PROGRAMS";
	educationTableName = prefix+dataType+"_EDUCATION";
	eventTableName = prefix+dataType+"_USER_EVENTS";
	albumTableName = prefix+dataType+"_ALBUMS";
	photoTableName = prefix+dataType+"_PHOTOS";
	tagTableName = prefix+dataType+"_TAGS";
    }
	
	
    //implement this function
    @SuppressWarnings("unchecked")
    public JSONArray toJSON() throws SQLException{ 
		
	// Your implementation goes here....	
		JSONArray users_info = new JSONArray();	
    	try(Statement stmt = oracleConnection.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_READ_ONLY)) {
            ResultSet rst = stmt.executeQuery(
                            "select u.user_id, u.first_name, u.last_name, u.year_of_birth, u.month_of_birth, u.day_of_birth, u.gender, " +
    					    "c.city_name, c.state_name, c.country_name " +
    					    "from " + userTableName + " u, " + hometownCityTableName + " h, " + cityTableName + " c " +
    					    "where u.user_id = h.user_id and h.hometown_city_id = c.city_id");
    		while(rst.next()){
                JSONObject single_user = new JSONObject();
    			Long   user_id = rst.getLong(1);
    			String first_name = rst.getString(2);
    			String last_name  = rst.getString(3);
    			int    year_of_birth = rst.getInt(4);
    			int    month_of_birth = rst.getInt(5);
    			int    day_of_birth   = rst.getInt(6);
    			String gender = rst.getString(7);
    			String city_name  = rst.getString(8);
    			String state_name = rst.getString(9);
    			String country    = rst.getString(10);

    			
    			JSONArray friends = new JSONArray();
                try(Statement stmt2 = oracleConnection.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
                ResultSet.CONCUR_READ_ONLY)){
                    ResultSet rst2 = stmt2.executeQuery("select user2_id from " + friendsTableName + " where user1_id = " + user_id);
                    while(rst2.next()){
                        friends.put(rst2.getLong(1));
                    }
                    rst2.close();
                    stmt2.close();

                }catch (SQLException err) {
                    System.err.println(err.getMessage());
                }

    			single_user.put("first_name",first_name);
    			single_user.put("friends",friends);
    			JSONObject hometwon = new JSONObject();
    			hometwon.put("state",state_name);
    			hometwon.put("country",country);
    			hometwon.put("city",city_name);
    			single_user.put("hometown",hometwon);
    			single_user.put("DOB",day_of_birth);
    			single_user.put("MOB",month_of_birth);
    			single_user.put("last_name",last_name);
    			single_user.put("gender",gender);
    			single_user.put("YOB",year_of_birth);
    			single_user.put("user_id",user_id);
    			users_info.put(single_user);
    		}

    		rst.close();
			stmt.close();
		} catch (SQLException err) {
			System.err.println(err.getMessage());
		}
		return users_info;
    }

    // This outputs to a file "output.json"
    public void writeJSON(JSONArray users_info) {
	// DO NOT MODIFY this function
	try {
	    FileWriter file = new FileWriter(System.getProperty("user.dir")+"/output.json");
	    file.write(users_info.toString());
	    file.flush();
	    file.close();

	} catch (IOException e) {
	    e.printStackTrace();
	}
		
    }
}

