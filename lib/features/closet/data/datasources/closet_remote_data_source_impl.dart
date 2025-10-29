import '../../../../core/network/api_client.dart';
import '../models/closet_model.dart';
import '../models/closet_item_model.dart';
import 'closet_remote_data_source.dart';

class ClosetRemoteDataSourceImpl implements ClosetRemoteDataSource {
  final ApiClient apiClient;

  ClosetRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<ClosetModel>> getClosets() async {
    try {
      final response = await apiClient.getClosets();

      // Handle different response formats
      if (response is Map<String, dynamic>) {
        // Response wrapped in object
        final data = response['closets'] ?? response['data'] ?? [];
        if (data is List) {
          return ClosetModel.fromJsonList(data);
        }
      } else if (response is List) {
        // Direct array response
        return ClosetModel.fromJsonList(response);
      }

      return [];
    } catch (e) {
      throw Exception('Failed to fetch closets: $e');
    }
  }

  @override
  Future<ClosetModel> getClosetById(String id) async {
    try {
      final response = await apiClient.getClosetById(id);

      if (response is Map<String, dynamic>) {
        final data = response['closet'] ?? response['data'] ?? response;
        return ClosetModel.fromJson(data as Map<String, dynamic>);
      }

      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to fetch closet: $e');
    }
  }

  @override
  Future<ClosetModel> createCloset(ClosetModel closet) async {
    try {
      final response = await apiClient.createCloset(closet.toCreateJson());

      if (response is Map<String, dynamic>) {
        final data = response['closet'] ?? response['data'] ?? response;
        return ClosetModel.fromJson(data as Map<String, dynamic>);
      }

      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to create closet: $e');
    }
  }

  @override
  Future<ClosetModel> updateCloset(String id, ClosetModel closet) async {
    try {
      final response = await apiClient.updateCloset(id, closet.toUpdateJson());

      if (response is Map<String, dynamic>) {
        final data = response['closet'] ?? response['data'] ?? response;
        return ClosetModel.fromJson(data as Map<String, dynamic>);
      }

      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to update closet: $e');
    }
  }

  @override
  Future<void> deleteCloset(String id) async {
    try {
      await apiClient.deleteCloset(id);
    } catch (e) {
      throw Exception('Failed to delete closet: $e');
    }
  }

  @override
  Future<List<ClosetItemModel>> getClosetItems(String closetId) async {
    try {
      final response = await apiClient.getClosetItems(closetId);

      if (response is Map<String, dynamic>) {
        final data = response['items'] ?? response['data'] ?? [];
        if (data is List) {
          return ClosetItemModel.fromJsonList(data);
        }
      } else if (response is List) {
        return ClosetItemModel.fromJsonList(response);
      }

      return [];
    } catch (e) {
      throw Exception('Failed to fetch closet items: $e');
    }
  }

  @override
  Future<ClosetItemModel> getClosetItemById(String id) async {
    try {
      final response = await apiClient.getClosetItemById(id);

      if (response is Map<String, dynamic>) {
        final data = response['item'] ?? response['data'] ?? response;
        return ClosetItemModel.fromJson(data as Map<String, dynamic>);
      }

      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to fetch closet item: $e');
    }
  }

  @override
  Future<ClosetItemModel> createClosetItem(ClosetItemModel item) async {
    try {
      final response = await apiClient.createClosetItem(item.toCreateJson());

      if (response is Map<String, dynamic>) {
        final data = response['item'] ?? response['data'] ?? response;
        return ClosetItemModel.fromJson(data as Map<String, dynamic>);
      }

      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to create closet item: $e');
    }
  }

  @override
  Future<ClosetItemModel> updateClosetItem(
    String id,
    ClosetItemModel item,
  ) async {
    try {
      final response = await apiClient.updateClosetItem(
        id,
        item.toUpdateJson(),
      );

      if (response is Map<String, dynamic>) {
        final data = response['item'] ?? response['data'] ?? response;
        return ClosetItemModel.fromJson(data as Map<String, dynamic>);
      }

      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to update closet item: $e');
    }
  }

  @override
  Future<void> deleteClosetItem(String id) async {
    try {
      await apiClient.deleteClosetItem(id);
    } catch (e) {
      throw Exception('Failed to delete closet item: $e');
    }
  }
}
