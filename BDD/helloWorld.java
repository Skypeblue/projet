import java.sql.*;
import java.lang.Exception;
class helloWorld {
   public static void main (String args[]) {
      try {
         Class.forName("org.postgresql.Driver");
         Connection connection = DriverManager.getConnection(
         "jdbc:postgresql://localhost:5432/projet","fredo","chien");
         // build query, here we get info about all databases"

         Statement statement = connection.createStatement ();
         String query = "INSERT INTO movie VALUES ('La La Land','Chazelle','Emma Stone')";
         int a = 5;
           while(a!=0){
             statement.executeUpdate(query);
             a--;
           }
           statement.close();
         }
         /*System.out.println(connection);
         // execute query



         // return query result
         while ( rs.next () )
            // display table name
            System.out.println ("PostgreSQL Query result: " + rs.getString ("datname"));
         connection.close ();*/
      catch (Exception e) {
         e.printStackTrace();
      }
   }
}
