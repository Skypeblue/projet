import java.sql.*;
import java.util.Random;

public class Signal{
  static String[]motif={"\'frein_avant\'","\'frein_gauche\'","\'pneu_dégonflé\'","\'guidon_absent\'","\'selle_manquante\'","\'dérailleur_non_réglé\'","\'bruit_inquétant_clic\'"};
  static Random rand=new Random();

  public static String pickCause(){
    int alea=(rand.nextInt(814))%motif.length;
    return motif[alea]+")";
  }

  public static String pickUser(){
    return String.valueOf(rand.nextInt(2005))+",";
  }


    public static void main(String[] args) {
      try {
        Class.forName("org.postgresql.Driver");
        Connection con=DriverManager.getConnection("jdbc:postgresql://localhost:5432/projet","fredo","chien");
        Statement state = con.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE,ResultSet.CONCUR_UPDATABLE);
        Statement state_2 = con.createStatement();
        String query_0,query_1,elec,id="";
        query_0="SELECT id FROM velo_casse where id<>5046";
        ResultSet res=state.executeQuery(query_0);
          while(res.next()){
            id=String.valueOf(res.getInt(1))+",";
            query_1="INSERT INTO signale VALUES("+pickUser()+id+pickCause();
            state_2.executeUpdate(query_1);
          }
        state.close();
        state_2.close();
        con.close();
      }
      catch (Exception e) {
        e.printStackTrace();
      }
    }
}
