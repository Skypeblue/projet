import java.sql.*;
import java.io.*;
import java.util.Scanner;
import java.util.LinkedList;
import java.util.Random;

public class User{
  static LinkedList<String> first_name=new LinkedList<String>();
  static LinkedList<String> last_name=new LinkedList<String>();
  static Random alea = new Random();
  /*public User(){
    first_name=new LinkedList<String>();
     last_name=new LinkedList<String>();
  }*/
  public static void init(){
    try {
      String input="";
      Scanner sc_f_n = new Scanner(new BufferedReader(new FileReader("f_n.csv")));
      Scanner sc_l_n = new Scanner(new BufferedReader(new FileReader("l_n.csv")));
      input=sc_l_n.nextLine();
      while(sc_l_n.hasNextLine()){
          input=sc_l_n.nextLine();
          last_name.add(input);
      }
      input=sc_f_n.nextLine();
      while(sc_f_n.hasNextLine()){
        input=sc_f_n.nextLine();
        first_name.add(input);
      }
    }
    catch (Exception e) {
      e.printStackTrace();
    }
  }
  public static String year(){
    return String.valueOf(1960+alea.nextInt(43));
  }
  public static String abo(int age){
    if(age>=15 && age<25){
      return "\'jeune\')";
    }
    else if (age>=25 && age<60) {
      return "\'normal\')";
    }
    else{
      return "\'senior\')";
    }
  }
  public static String change(String word){
    if(word.contains("\'")){
      String n_word=first_name.get(alea.nextInt(200));
      return change(n_word);
    }
    return word;
  }
  public static String nameAndSurname(){
    int size= first_name.size();
    String f_name="'"+change(first_name.get(alea.nextInt(size)))+"',";
    String l_name="'"+change(last_name.get(alea.nextInt(size)))+"',";
    return f_name+l_name;
  }

  public static void main(String[] args) {
    init();
    try {
      String ad="";
      Class.forName("org.postgresql.Driver");
      Connection con=DriverManager.getConnection("jdbc:postgresql://localhost:5432/projet","fredo","chien");
      Statement state=con.createStatement();
      int a=0;
      String query="";
      int age=0;
      while (a!=2000) {
          String annee=year();
          age=2017-Integer.parseInt(annee);
          query="INSERT INTO users(prenom,nom,annaiss,credit,abonnement) VALUES("+nameAndSurname()+annee+",0,"+abo(age);
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
