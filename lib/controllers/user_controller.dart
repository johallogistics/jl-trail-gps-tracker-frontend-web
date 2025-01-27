import 'package:get/get.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class UserController extends GetxController {
  var user = UserModel().obs;

  Future<void> fetchUserDetails() async {
    final userDetails = await UserRepository.getUserDetails();
    user.value = userDetails;
  }
}
