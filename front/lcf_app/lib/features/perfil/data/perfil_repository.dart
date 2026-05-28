import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import 'models/perfil_models.dart';

part 'perfil_repository.g.dart';

class PerfilRepository {
  const PerfilRepository(this._dio);
  final Dio _dio;

  Future<UserProfile> getProfile() async {
    final resp = await _dio.get<Map<String, dynamic>>('/users/profile');
    return UserProfile.fromJson(resp.data!);
  }

  Future<UserProfile> updateProfile({
    String? name,
    String? academicPhase,
    int? dailyStudyMins,
  }) async {
    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (academicPhase != null) 'academicPhase': academicPhase,
      if (dailyStudyMins != null) 'dailyStudyMins': dailyStudyMins,
    };
    final resp = await _dio.put<Map<String, dynamic>>(
      '/users/profile',
      data: body,
    );
    return UserProfile.fromJson(resp.data!);
  }
}

@riverpod
PerfilRepository perfilRepository(PerfilRepositoryRef ref) =>
    PerfilRepository(ref.watch(dioProvider));
