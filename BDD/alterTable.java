import java.sql.*;

public class alterTable{
    public static int cost(int duree){
      if(duree<30)return 0;
      else{
        int res= ((duree-30)/15);
        return res*2;
      }
    }
    public static void init(Statement stmt,String query){
      try {
        ResultSet res =stmt.executeQuery(query);
        while(res.next()){
          int id = res.getInt(1);
          int time = res.getInt(2);
          int price = cost(time);
          res.updateInt(3,price);
          res.updateRow();          
        }
      }
      catch (Exception e) {
        e.printStackTrace();
      }
    }
    public static void main(String[] args) {
      try{
        Class.forName("org.postgresql.Driver");
        Connection con=DriverManager.getConnection("jdbc:postgresql://localhost:5432/projet","fredo","chien");
        Statement state=con.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE,ResultSet.CONCUR_UPDATABLE);
        String query="SELECT id_trajet,CAST(date_part(\'minutes\',duree) as INTEGER),cout FROM trajet";
        init(state,query);
      /*  while(a<size){
          query="ALTER TABLE trajet SET cout = "+String.valueOf(cost.get(a).price)+" WHERE id_trajet ="+String.valueOf(cost.get(a).index);
          state.executeUpdate(query);
          a++;
        }*/
      }
      catch (Exception e) {
        e.printStackTrace();
      }
    }
}
