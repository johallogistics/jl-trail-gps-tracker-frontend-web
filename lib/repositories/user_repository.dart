import '../api/api_manager.dart';
import '../api/api_endpoints.dart';
import '../models/user_model.dart';

class UserRepository {
  static Future<UserModel> getUserDetails() async {
    final response = await ApiManager.get(ApiEndpoints.userDetails);
    final data = response.body as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }
}
