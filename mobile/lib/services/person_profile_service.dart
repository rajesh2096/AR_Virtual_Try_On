import 'dart:io';
import '../core/network/api_client.dart';
import '../models/person_profile_model.dart';

class PersonProfileService {
  static Future<List<PersonProfileModel>> getPersonProfiles() async {
    final response = await ApiClient.get('/person-models');
    if (response is List) {
      return response.map((item) => PersonProfileModel.fromJson(item)).toList();
    }
    return [];
  }

  static Future<PersonProfileModel> getPersonProfileById(int id) async {
    final response = await ApiClient.get('/person-models/$id');
    return PersonProfileModel.fromJson(response);
  }

  static Future<PersonProfileModel> uploadPersonProfile({
    required String title,
    required File imageFile,
    bool isDefault = false,
  }) async {
    final response = await ApiClient.uploadMultipart(
      endpoint: '/person-models/upload',
      fileField: 'file',
      file: imageFile,
      fields: {
        'title': title,
        'is_default': isDefault.toString(),
      },
    );
    return PersonProfileModel.fromJson(response);
  }

  static Future<PersonProfileModel> setDefaultPersonProfile(int id) async {
    final response = await ApiClient.put('/person-models/$id/default');
    return PersonProfileModel.fromJson(response);
  }

  static Future<PersonProfileModel> updateTitle(int id, String title) async {
    final response = await ApiClient.put('/person-models/$id', body: {
      'title': title,
    });
    return PersonProfileModel.fromJson(response);
  }

  static Future<bool> deletePersonProfile(int id) async {
    final response = await ApiClient.delete('/person-models/$id');
    return response != null;
  }
}
