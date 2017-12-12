import java.sql.*;
import java.io.*;
import java.util.Scanner;

public class Cen_rep{
    public static String nb_place(int a){
      if(a%5==0)return "20,20)";
      else if(a%7==0)return "15,15)";
      else return "10,10)";
    }
    public static void main(String[] args) {
      try{
        String path="velib.csv";
        Scanner sc = new Scanner(new BufferedReader(new FileReader(path)));
        Class.forName("org.postgresql.Driver");
        Connection con=DriverManager.getConnection("jdbc:postgresql://localhost:5432/projet","fredo","chien");
        Statement state=con.createStatement();
        int a=0;int b=0;
        String query,inputLine,ad="";
        while(a<100){
          while(b<500){
            sc.nextLine();
            b++;
          }
          inputLine=sc.nextLine();
          ad=Station.adresse(inputLine);
          query="INSERT INTO centre_reparation(adresse,place_tot,place_dispos) VALUES("+ad+','+nb_place(a+b);
          state.executeUpdate(query);
          a++;
        }
      }
      catch (Exception e) {
        e.printStackTrace();
      }
    }
}
