import java.sql.*;
import java.util.Random;
public class Velo_loue {
  static Random alea = new Random();
  public static void main(String[] args) {

    try {
      Class.forName("org.postgresql.Driver");
      Connection con=DriverManager.getConnection("jdbc:postgresql://localhost:5432/projet","fredo","chien");
      Statement state = con.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE,ResultSet.CONCUR_UPDATABLE);
      int a=0;
      String query,queryPrep,elec,id="";
      queryPrep="SELECT elec FROM velo_dispo where id = ?";
      PreparedStatement prepState= con.prepareStatement(queryPrep);
      while(a!=1000){
        int rand = alea.nextInt(6670)+1;
        id=String.valueOf(rand);
        prepState.setInt(1,rand);
        ResultSet res=prepState.executeQuery();
        if(res.next()){
          elec =(res.getBoolean(1))?"'1'":"'0'";
          query="DELETE FROM velo_dispo where id="+id;
          state.executeUpdate(query);
          query="INSERT INTO velo_loue VALUES("+id+","+elec+")";
          state.executeUpdate(query);
          a++;
        }
      }
      state.close();
      prepState.close();
      con.close();
    }
    catch (Exception e) {
      e.printStackTrace();
    }
  }
}
