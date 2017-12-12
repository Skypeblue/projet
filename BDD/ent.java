import java.sql.*;

public class ent{
  public static void main(String[] args) {
    try{
      Class.forName("org.postgresql.Driver");
      Connection con=DriverManager.getConnection("jdbc:postgresql://localhost:5432/projet","fredo","chien");
      Statement state=con.createStatement();
      String query="";
      int a=2000;
      while(a!=0){
        query ="INSERT INTO ent(inte) VALUES ("+String.valueOf(a)+")";
        state.executeUpdate(query);
        a--;
      }
      state.close();
      con.close();
    }
    catch(Exception e){
      e.printStackTrace();
    }
  }
}
