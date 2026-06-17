import '../repositories/banks_repository.dart';
import '../models/bank.dart';

class BankStorageService {

  static void salva(Bank bank){

    BanksRepository.addBank(bank);

  }

  static List<Bank> elenco(){

    return BanksRepository.getBanks();

  }

}