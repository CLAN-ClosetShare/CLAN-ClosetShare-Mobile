import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/network_image.dart';
import '../../data/models/closet_model.dart';
import '../../data/models/closet_item_model.dart';
import '../bloc/closet_item_bloc.dart';
import '../bloc/closet_item_event.dart';
import '../bloc/closet_item_state.dart';

class ClosetDetailPage extends StatefulWidget {
  final ClosetModel closet;

  const ClosetDetailPage({super.key, required this.closet});

  @override
  State<ClosetDetailPage> createState() => _ClosetDetailPageState();
}

class _ClosetDetailPageState extends State<ClosetDetailPage> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Load closet items when page opens
    context.read<ClosetItemBloc>().add(LoadClosetItems(widget.closet.id));
  }

  Future<void> _showCreateEditItemModal({ClosetItemModel? editItem}) async {
    final isEdit = editItem != null;
    final nameCtrl = TextEditingController(text: editItem?.name ?? '');
    final brandCtrl = TextEditingController(text: editItem?.brand ?? '');
    final colorCtrl = TextEditingController(text: editItem?.color ?? '');
    final priceCtrl = TextEditingController(
      text: editItem?.price.toString() ?? '',
    );
    final descriptionCtrl = TextEditingController(
      text: editItem?.description ?? '',
    );

    String selectedCategory =
        editItem?.category ?? ClosetItemModel.commonCategories.first;
    String selectedSize = editItem?.size ?? ClosetItemModel.commonSizes.first;
    String selectedCondition = editItem?.condition ?? 'GOOD';
    List<XFile> pickedImages = [];
    bool isAvailable = editItem?.isAvailable ?? true;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            Future<void> pickImages() async {
              final List<XFile> images = await _picker.pickMultiImage(
                imageQuality: 80,
              );
              if (images.isNotEmpty) {
                setStateModal(() => pickedImages.addAll(images));
              }
            }

            void removeImage(int index) {
              setStateModal(() => pickedImages.removeAt(index));
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEdit ? 'Sửa sản phẩm' : 'Thêm sản phẩm mới',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Tên sản phẩm *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Brand & Category
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: brandCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Thương hiệu *',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedCategory,
                              decoration: const InputDecoration(
                                labelText: 'Danh mục',
                                border: OutlineInputBorder(),
                              ),
                              items: ClosetItemModel.commonCategories
                                  .map(
                                    (category) => DropdownMenuItem(
                                      value: category,
                                      child: Text(category),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) => setStateModal(
                                () => selectedCategory = value!,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Color, Size & Price
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: colorCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Màu sắc *',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedSize,
                              decoration: const InputDecoration(
                                labelText: 'Size',
                                border: OutlineInputBorder(),
                              ),
                              items: ClosetItemModel.commonSizes
                                  .map(
                                    (size) => DropdownMenuItem(
                                      value: size,
                                      child: Text(size),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setStateModal(() => selectedSize = value!),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: priceCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Giá (VND)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Condition
                      DropdownButtonFormField<String>(
                        value: selectedCondition,
                        decoration: const InputDecoration(
                          labelText: 'Tình trạng',
                          border: OutlineInputBorder(),
                        ),
                        items: ClosetItemModel.conditionTypes
                            .map(
                              (condition) => DropdownMenuItem(
                                value: condition,
                                child: Text(
                                  ClosetItemModel.getConditionDisplayName(
                                    condition,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setStateModal(() => selectedCondition = value!),
                      ),
                      const SizedBox(height: 16),

                      // Availability (for edit only)
                      if (isEdit)
                        CheckboxListTile(
                          title: const Text('Có sẵn'),
                          value: isAvailable,
                          onChanged: (value) =>
                              setStateModal(() => isAvailable = value!),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),

                      // Description
                      TextFormField(
                        controller: descriptionCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Mô tả',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Images
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: pickImages,
                            icon: const Icon(Icons.add_photo_alternate),
                            label: const Text('Thêm ảnh'),
                          ),
                        ],
                      ),

                      if (pickedImages.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: pickedImages.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(pickedImages[index].path),
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () => removeImage(index),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],

                      // Show existing images for edit
                      if (isEdit && editItem.images.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Ảnh hiện tại:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: editItem.images.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SharedNetworkImage(
                                    imageUrl: editItem.images[index],
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Hủy'),
                          ),
                          const SizedBox(width: 16),
                          BlocConsumer<ClosetItemBloc, ClosetItemState>(
                            listener: (context, state) {
                              if (state is ClosetItemOperationSuccess) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(state.message)),
                                );
                              } else if (state is ClosetItemError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(state.message),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            builder: (context, state) {
                              final isLoading =
                                  state is ClosetItemOperationInProgress;

                              return ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        final name = nameCtrl.text.trim();
                                        final brand = brandCtrl.text.trim();
                                        final color = colorCtrl.text.trim();
                                        final priceText = priceCtrl.text.trim();

                                        if (name.isEmpty ||
                                            brand.isEmpty ||
                                            color.isEmpty) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Vui lòng nhập đầy đủ thông tin bắt buộc',
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        final price =
                                            double.tryParse(priceText) ?? 0.0;
                                        final images = pickedImages
                                            .map((img) => img.path)
                                            .toList();

                                        if (isEdit) {
                                          context.read<ClosetItemBloc>().add(
                                            UpdateClosetItemEvent(
                                              id: editItem.id,
                                              closetId: widget.closet.id,
                                              name: name,
                                              brand: brand,
                                              category: selectedCategory,
                                              color: color,
                                              size: selectedSize,
                                              price: price,
                                              images: images.isNotEmpty
                                                  ? images
                                                  : null,
                                              description:
                                                  descriptionCtrl.text
                                                      .trim()
                                                      .isNotEmpty
                                                  ? descriptionCtrl.text.trim()
                                                  : null,
                                              condition: selectedCondition,
                                              isAvailable: isAvailable,
                                            ),
                                          );
                                        } else {
                                          context.read<ClosetItemBloc>().add(
                                            CreateClosetItemEvent(
                                              closetId: widget.closet.id,
                                              name: name,
                                              brand: brand,
                                              category: selectedCategory,
                                              color: color,
                                              size: selectedSize,
                                              price: price,
                                              images: images,
                                              description:
                                                  descriptionCtrl.text
                                                      .trim()
                                                      .isNotEmpty
                                                  ? descriptionCtrl.text.trim()
                                                  : null,
                                              condition: selectedCondition,
                                            ),
                                          );
                                        }
                                      },
                                child: isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(isEdit ? 'Lưu' : 'Thêm'),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showDeleteItemDialog(ClosetItemModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (confirm == true) {
      context.read<ClosetItemBloc>().add(
        DeleteClosetItemEvent(id: item.id, closetId: widget.closet.id),
      );
    }
  }

  Widget _buildItemCard(ClosetItemModel item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Show item details in dialog or navigate to detail page
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.images.isNotEmpty
                    ? SharedNetworkImage(
                        imageUrl: item.images.first,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.checkroom),
                      ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.brand} • ${item.category}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${item.color} • ${item.size}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        if (item.price > 0)
                          Text(
                            '₫${item.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action menu
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showCreateEditItemModal(editItem: item);
                  } else if (value == 'delete') {
                    _showDeleteItemDialog(item);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16),
                        SizedBox(width: 8),
                        Text('Sửa'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Xóa', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.closet.name),
        actions: [
          IconButton(
            onPressed: () {
              context.read<ClosetItemBloc>().add(
                RefreshClosetItems(widget.closet.id),
              );
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Closet info header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: widget.closet.image != null
                      ? SharedNetworkImage(
                          imageUrl: widget.closet.image!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.checkroom),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.closet.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ClosetModel.getTypeDisplayName(widget.closet.type),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      if (widget.closet.description?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.closet.description!,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Items list
          Expanded(
            child: BlocConsumer<ClosetItemBloc, ClosetItemState>(
              listener: (context, state) {
                if (state is ClosetItemOperationSuccess) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              builder: (context, state) {
                if (state is ClosetItemLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ClosetItemError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Thử lại',
                          onPressed: () {
                            context.read<ClosetItemBloc>().add(
                              LoadClosetItems(widget.closet.id),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }

                final items = (state is ClosetItemLoaded)
                    ? state.items
                    : (state is ClosetItemOperationSuccess)
                    ? state.items
                    : <dynamic>[];

                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Chưa có sản phẩm nào',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Thêm sản phẩm đầu tiên vào tủ đồ này',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: 'Thêm sản phẩm',
                          onPressed: () => _showCreateEditItemModal(),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<ClosetItemBloc>().add(
                      RefreshClosetItems(widget.closet.id),
                    );
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index] as ClosetItemModel;
                      return _buildItemCard(item);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateEditItemModal(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        label: const Text('Thêm sản phẩm'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
