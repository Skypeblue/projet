import java.sql.*;
import java.io.*;
import java.util.Scanner;

public class Station{
    public static String station_plus(int nb){
      if(nb%8==0)return "'1'";
      else return "'0'";
    }
    public static String station(int nb){
      if(nb%3==0) return "20,20,";
      else return "15,15,";
    }
    public static String change(String name){
      for (int i = 0 ; i<name.length() ;i++ ) {
        if(name.charAt(i)=='\'')name=name.substring(0,i)+name.substring(i+1);
      }
      return "'"+name+"'";
    }
    public static String adresse(String word){
      String[]inArray=word.split(";");
      String[]inArr=inArray[2].split("-");
      word=(inArr.length>1)?inArr[0]:inArray[2];
      return change(word);
    }
    public static void main(String[] args) {
      String inputLine="";
      String path ="velib.csv";
      try{
        Scanner sc = new Scanner(new BufferedReader(new FileReader(path)));
        String ad="";
        Class.forName("org.postgresql.Driver");
        Connection con=DriverManager.getConnection("jdbc:postgresql://localhost:5432/projet","fredo","chien");
        Statement state=con.createStatement();
        int a=0;
        String query="";
        inputLine=sc.nextLine();
        while(a<400){
          inputLine=sc.nextLine();          
          ad=adresse(inputLine);
          query ="INSERT INTO station(adresse,place_totale,place_dispo,velib_plus) VALUES ("+ad+","+station(a)+station_plus(a)+")";
          state.executeUpdate(query);
          a++;
        }
        state.close();
        con.close();
      }
      catch(Exception e){
        e.printStackTrace();
      }
    }
}
