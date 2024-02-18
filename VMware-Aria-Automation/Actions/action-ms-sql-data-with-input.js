//--------------------------Returns all Server Builds----------------------------------------
// ############# Section 1: Get the database connection #############
// get all of the databases that are registered to the SQL Manager

var databases = SQLDatabaseManager.getDatabases();

// a variable to hold our database

var database = null;

// loop through them until we find our database, using the friendly name we configured

for each (var db in databases) {
   if (db.name == "MSSQL") {
  database = db;
   break;
   }
}

// a bit of checking to make sure our database was found

if (database == null) {
   throw "Unable to find database!";
}

// ############# Section 2: Query the database #############
// the SQL query we want to execute. Javascript does not support multi-line strings
// so we append the each "line" to the same variable to keep it readable, but make
// a single long string

var query = "";
// query += "SELECT Distinct GPTTYpe FROM GPT order by GPTTYpe";
query += "SELECT Distinct GPTTYpe FROM GPT where topic = '" + topic + "' order by GPTTYpe";



// execute the query
var result = database.readCustomQuery(query);
// a bit of info to log
System.debug("Database query for GPTType returned " + result.length + " records");

// ############# Section 3: Parse the result and return values #############
var data = new Array();

for (var i = 0; i < result.length; i++) {
  System.debug(result[i].getProperty("GPTTYpe"));
  data[i] = result[i].getProperty("GPTTYpe").trim();
}

// return the data

return data
