import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

final userViewModelProvider = StateNotifierProvider<UserViewModel, AsyncValue<UserModel>>((ref) {
  return UserViewModel(ref.read(apiServiceProvider));
});

class UserViewModel extends StateNotifier<AsyncValue<UserModel>> {
  final ApiService _apiService;

  UserViewModel(this._apiService) : super(const AsyncValue.loading());

  Future<void> fetchUser() async {
    try {
      state = const AsyncValue.loading();
      final user = await _apiService.getUser();
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
} 