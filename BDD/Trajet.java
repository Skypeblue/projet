import java.sql.*;
import java.util.Random;

public class Trajet {
  static Random alea = new Random();

  public static String heure(){
    String min,sec;
    int minutes,secondes;
    minutes=alea.nextInt(60);
    min=(minutes<10)?"0"+String.valueOf(minutes):String.valueOf(minutes);
    secondes=alea.nextInt(60);
    sec=(secondes<10)?"0"+String.valueOf(secondes):String.valueOf(secondes);
    return "'00:"+min+":"+sec+"',";
  }
  public static String date(){
    String year,month,day;
    int mois,jour;
    year=String.valueOf(2016+alea.nextInt(2));
    mois= alea.nextInt(12)+1;
    month=(mois<10)?"0"+String.valueOf(mois):String.valueOf(mois);
    jour=alea.nextInt(28)+1;
    day=(jour<10)?"0"+String.valueOf(jour):String.valueOf(jour);
    return "'"+year+"-"+month+"-"+day+"',";
  }
  public static String userAndVelo(){
    String id_user=String.valueOf(alea.nextInt(2000)+1)+",";
    String id_velo=String.valueOf(alea.nextInt(6670)+1)+",";
    return id_user+id_velo;
  }

  public static void main(String[] args) {
    try {
      Class.forName("org.postgresql.Driver");
      Connection con=DriverManager.getConnection("jdbc:postgresql://localhost:5432/projet","fredo","chien");
      Statement state=con.createStatement();
      String query="";
      int a =0;
      while(a<4000){
        int stat_d=alea.nextInt(400)+1;
        int stat_a=alea.nextInt(400)+1;
        String station_dep=String.valueOf(stat_d)+",";
        String station_arr=(stat_d==stat_a)?String.valueOf(alea.nextInt(400)+1):String.valueOf(stat_a);
        query="INSERT INTO trajet(date_trajet,duree,id_users,id_velo,station_dep,station_arr) VALUES("+date()+heure()+userAndVelo()+station_dep+station_arr+")";
        state.executeUpdate(query);
        a++;
      }
      state.close();
      con.close();
    }
    catch (Exception e) {
      e.printStackTrace();
    }
  }
}
