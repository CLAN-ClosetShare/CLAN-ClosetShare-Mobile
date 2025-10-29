import '../models/closet_model.dart';
import '../models/closet_item_model.dart';

abstract class ClosetRemoteDataSource {
  Future<List<ClosetModel>> getClosets();
  Future<ClosetModel> getClosetById(String id);
  Future<ClosetModel> createCloset(ClosetModel closet);
  Future<ClosetModel> updateCloset(String id, ClosetModel closet);
  Future<void> deleteCloset(String id);

  Future<List<ClosetItemModel>> getClosetItems(String closetId);
  Future<ClosetItemModel> getClosetItemById(String id);
  Future<ClosetItemModel> createClosetItem(ClosetItemModel item);
  Future<ClosetItemModel> updateClosetItem(String id, ClosetItemModel item);
  Future<void> deleteClosetItem(String id);
}
