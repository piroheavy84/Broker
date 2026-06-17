import '../models/practice.dart';
import 'practice_service.dart';

class NavigationService {

  static Practice startNewPractice() {

    return PracticeService.nuovaPratica();

  }

}