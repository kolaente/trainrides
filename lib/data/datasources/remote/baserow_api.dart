import 'dart:convert';
import 'dart:io';
import '../../models/train_ride.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';

class BaserowApi {
  static final BaserowApi _instance = BaserowApi._internal();
  factory BaserowApi() => _instance;
  BaserowApi._internal();

  final HttpClient _httpClient = HttpClient();
  List<Map<String, dynamic>> _typeOptions = [];

  List<Map<String, dynamic>> get typeOptions => _typeOptions;

  Future<void> loadFields() async {
    try {
      final url = '${ApiConstants.baseUrl}/api/database/fields/table/${ApiConstants.tableId}/';
      final response = await _httpClient.get(url);
      
      if (response.statusCode == 401) {
        throw const AuthException('Authentication failed - Invalid or expired token');
      }
      
      final jsonData = json.decode(response.body);
      
      if (jsonData is List) {
        final typeField = jsonData.firstWhere(
          (field) => field['name'] == 'type',
          orElse: () => null,
        );
        
        if (typeField != null && typeField['select_options'] != null) {
          _typeOptions = List<Map<String, dynamic>>.from(typeField['select_options']);
        }
      }
    } on SocketException {
      throw const NetworkException('No internet connection');
    } on FormatException {
      throw const ApiException('Invalid response format');
    } catch (e) {
      if (e is AppException) rethrow;
      throw ApiException('Failed to load fields: ${e.toString()}');
    }
  }

  Future<List<TrainRide>> getTrainRides({
    int? page,
    int? size,
    String? search,
    String? orderBy,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (size != null) queryParams['size'] = size.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (orderBy != null && orderBy.isNotEmpty) queryParams['order_by'] = orderBy;

      final uri = Uri.parse(ApiConstants.baseApiUrl).replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final response = await _httpClient.get(uri.toString());
      
      if (response.statusCode == 401) {
        throw const AuthException('Authentication failed - Invalid or expired token');
      }
      
      final jsonData = json.decode(response.body);

      if (jsonData['results'] != null) {
        final List<dynamic> results = jsonData['results'];
        return results.map((json) => TrainRide.fromBaserowJson(json)).toList();
      }

      return [];
    } on SocketException {
      throw const NetworkException('No internet connection');
    } on FormatException {
      throw const ApiException('Invalid response format');
    } catch (e) {
      if (e is AppException) rethrow;
      throw ApiException('Failed to fetch train rides: ${e.toString()}');
    }
  }

  Future<TrainRide> getTrainRideById(int id) async {
    try {
      final url = '${ApiConstants.baseApiUrl}$id/';
      final response = await _httpClient.get(url);
      final jsonData = json.decode(response.body);

      return TrainRide.fromBaserowJson(jsonData);
    } on SocketException {
      throw const NetworkException('No internet connection');
    } on FormatException {
      throw const ApiException('Invalid response format');
    } catch (e) {
      if (e is AppException) rethrow;
      throw ApiException('Failed to fetch train ride: ${e.toString()}');
    }
  }

  Future<TrainRide> createTrainRide(TrainRide trainRide) async {
    try {
      final body = json.encode(trainRide.toBaserowJson());
      final response = await _httpClient.post(
        ApiConstants.baseApiUrl,
        body: body,
      );

      final jsonData = json.decode(response.body);
      return TrainRide.fromBaserowJson(jsonData);
    } on SocketException {
      throw const NetworkException('No internet connection');
    } on FormatException {
      throw const ApiException('Invalid response format');
    } catch (e) {
      if (e is AppException) rethrow;
      throw ApiException('Failed to create train ride: ${e.toString()}');
    }
  }

  Future<TrainRide> updateTrainRide(TrainRide trainRide) async {
    if (trainRide.id == null) {
      throw const ValidationException('Cannot update train ride without ID');
    }

    try {
      final body = json.encode(trainRide.toBaserowJson());
      final url = '${ApiConstants.baseApiUrl}${trainRide.id}/';
      final response = await _httpClient.put(url, body: body);

      final jsonData = json.decode(response.body);
      return TrainRide.fromBaserowJson(jsonData);
    } on SocketException {
      throw const NetworkException('No internet connection');
    } on FormatException {
      throw const ApiException('Invalid response format');
    } catch (e) {
      if (e is AppException) rethrow;
      throw ApiException('Failed to update train ride: ${e.toString()}');
    }
  }

  Future<void> deleteTrainRide(int id) async {
    try {
      final url = '${ApiConstants.baseApiUrl}$id/';
      await _httpClient.delete(url);
    } on SocketException {
      throw const NetworkException('No internet connection');
    } catch (e) {
      if (e is AppException) rethrow;
      throw ApiException('Failed to delete train ride: ${e.toString()}');
    }
  }

  Future<bool> testConnection() async {
    try {
      final response = await _httpClient.get(ApiConstants.baseApiUrl);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<TrainRide>> syncTrainRides({
    DateTime? lastSyncTime,
    int retryCount = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'order_by': '-updated_on',
        'size': '100',
      };

      if (lastSyncTime != null) {
        queryParams['filter__updated_on__gte'] = lastSyncTime.toIso8601String();
      }

      final uri = Uri.parse(ApiConstants.baseApiUrl).replace(
        queryParameters: queryParams,
      );

      final response = await _httpClient.get(uri.toString());
      final jsonData = json.decode(response.body);

      if (jsonData['results'] != null) {
        final List<dynamic> results = jsonData['results'];
        return results.map((json) => TrainRide.fromBaserowJson(json)).toList();
      }

      return [];
    } on NetworkException {
      if (retryCount < ApiConstants.maxRetries) {
        await Future.delayed(ApiConstants.retryDelay);
        return syncTrainRides(
          lastSyncTime: lastSyncTime,
          retryCount: retryCount + 1,
        );
      }
      rethrow;
    } on SocketException {
      throw const NetworkException('No internet connection');
    } on FormatException {
      throw const ApiException('Invalid response format');
    } catch (e) {
      if (e is AppException) rethrow;
      throw SyncException('Failed to sync train rides: ${e.toString()}');
    }
  }

  Future<void> batchSync(List<TrainRide> localRides) async {
    for (final ride in localRides) {
      try {
        if (ride.id == null) {
          await createTrainRide(ride);
        } else {
          await updateTrainRide(ride);
        }
      } catch (e) {
        print('Failed to sync ride ${ride.id}: $e');
      }
    }
  }

  Future<bool> isOnline() async {
    try {
      final response = await _httpClient.get(ApiConstants.baseApiUrl);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}