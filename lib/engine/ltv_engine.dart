class LtvEngine {

  static double calcolaLTV(

    double mutuo,

    double valore,

  ) {

    if(valore==0){

      return 0;

    }

    return (mutuo/valore)*100;

  }

}