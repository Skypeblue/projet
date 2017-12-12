import java.sql.*;

public class Velo{
  public Connection con;
    public Velo(){
        try {
          con = DriverManager.getConnection("jdbc:postgresql://localhost:5432/projet","fredo","chien");
        }
        catch (Exception e) {
          e.printStackTrace();
        }
    }
  static Velo a= new Velo();
  public static String elecOrNot(int index){
    return (index<=2001)?"'1')":"'0')";
  }
  public static int station_atVelo(int index,int station,int place_dispo){
    try {
      String query="";
      Class.forName("org.postgresql.Driver");
      Statement state = a.con.createStatement();
      for (int i = 0 ; i < place_dispo ; i++) {
        query="INSERT INTO velo_dispo VALUES("+String.valueOf(index)+","+String.valueOf(station)+","+elecOrNot(index);
        state.executeUpdate(query);
        index++;
      }
    }
    catch (Exception e) {
      e.printStackTrace();
    }
    return index;
  }
  public static void main(String[] args) {
    try {
      int station,place_dispo;
      int index=1;
       Class.forName("org.postgresql.Driver");
       Statement statement = a.con.createStatement();
       String query="SELECT id,place_dispo from station";
       ResultSet res= statement.executeQuery(query);
         while(res.next()){
           station=res.getInt(1);
           place_dispo=res.getInt(2);
           index = station_atVelo(index,station,place_dispo);
         }
         statement.close();
    }
    catch (Exception e) {
       e.printStackTrace();
    }
  }
}
