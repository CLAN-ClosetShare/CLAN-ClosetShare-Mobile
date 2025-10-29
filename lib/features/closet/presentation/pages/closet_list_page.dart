import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/widgets/network_image.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../shared/widgets/custom_button.dart';
import '../../data/models/closet_model.dart';
import '../bloc/closet_bloc.dart';
import '../bloc/closet_event.dart';
import '../bloc/closet_state.dart';
import '../bloc/closet_item_bloc.dart';
import 'closet_detail_page.dart';

class ClosetListPage extends StatefulWidget {
  const ClosetListPage({super.key});

  @override
  State<ClosetListPage> createState() => _ClosetListPageState();
}

class _ClosetListPageState extends State<ClosetListPage> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Load closets when page opens
    context.read<ClosetBloc>().add(LoadClosets());
  }

  Future<void> _showCreateEditClosetModal({ClosetModel? editCloset}) async {
    final isEdit = editCloset != null;
    final nameCtrl = TextEditingController(text: editCloset?.name ?? '');
    final descriptionCtrl = TextEditingController(
      text: editCloset?.description ?? '',
    );
    String selectedType = editCloset?.type ?? ClosetModel.closetTypes.first;
    XFile? pickedImage;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            Future<void> pickImage() async {
              final XFile? img = await _picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 80,
              );
              if (img != null) {
                setStateModal(() => pickedImage = img);
              }
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
                        isEdit ? 'Sửa tủ đồ' : 'Tạo tủ đồ mới',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Tên tủ đồ',
                          hintText: 'VD: Áo thu đông',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Loại tủ đồ',
                          border: OutlineInputBorder(),
                        ),
                        items: ClosetModel.closetTypes
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(
                                  ClosetModel.getTypeDisplayName(type),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setStateModal(() => selectedType = value!),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: descriptionCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Mô tả (tùy chọn)',
                          hintText: 'Mô tả về tủ đồ này...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Image picker
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: pickImage,
                            icon: const Icon(Icons.image),
                            label: const Text('Chọn ảnh'),
                          ),
                          const SizedBox(width: 16),
                          // selected image / existing image / placeholder
                          if (pickedImage != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(pickedImage!.path),
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ] else if (isEdit && editCloset.image != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SharedNetworkImage(
                                imageUrl: editCloset.image,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ] else ...[
                            Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Hủy'),
                          ),
                          const SizedBox(width: 16),
                          BlocConsumer<ClosetBloc, ClosetState>(
                            listener: (context, state) {
                              if (state is ClosetOperationSuccess) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(state.message)),
                                );
                              } else if (state is ClosetError) {
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
                                  state is ClosetOperationInProgress;

                              return ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        final name = nameCtrl.text.trim();
                                        final description = descriptionCtrl.text
                                            .trim();

                                        if (name.isEmpty) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Vui lòng nhập tên tủ đồ',
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        if (isEdit) {
                                          context.read<ClosetBloc>().add(
                                            UpdateClosetEvent(
                                              id: editCloset.id,
                                              name: name,
                                              type: selectedType,
                                              description:
                                                  description.isNotEmpty
                                                  ? description
                                                  : null,
                                              image: pickedImage?.path,
                                            ),
                                          );
                                        } else {
                                          context.read<ClosetBloc>().add(
                                            CreateClosetEvent(
                                              name: name,
                                              type: selectedType,
                                              description:
                                                  description.isNotEmpty
                                                  ? description
                                                  : null,
                                              image: pickedImage?.path,
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
                                    : Text(isEdit ? 'Lưu' : 'Tạo'),
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

  Future<void> _showDeleteConfirmDialog(ClosetModel closet) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa tủ đồ "${closet.name}"?\n\nTất cả sản phẩm trong tủ đồ này cũng sẽ bị xóa.',
        ),
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
      context.read<ClosetBloc>().add(DeleteClosetEvent(closet.id));
    }
  }

  Widget _buildClosetCard(ClosetModel closet) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => di.sl<ClosetItemBloc>(),
                child: ClosetDetailPage(closet: closet),
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: (closet.image != null)
                    ? SharedNetworkImage(
                        imageUrl: closet.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.checkroom,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          closet.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showCreateEditClosetModal(editCloset: closet);
                          } else if (value == 'delete') {
                            _showDeleteConfirmDialog(closet);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Sửa'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Xóa',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          ClosetModel.getTypeDisplayName(closet.type),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${closet.itemCount} sản phẩm',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  if (closet.description?.isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Text(
                      closet.description!,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tủ đồ của tôi'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              context.read<ClosetBloc>().add(RefreshClosets());
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocConsumer<ClosetBloc, ClosetState>(
        listener: (context, state) {
          if (state is ClosetOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is ClosetLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ClosetError) {
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
                      context.read<ClosetBloc>().add(LoadClosets());
                    },
                  ),
                ],
              ),
            );
          }

          final closets = (state is ClosetLoaded)
              ? state.closets
              : (state is ClosetOperationSuccess)
              ? state.closets
              : <dynamic>[];

          if (closets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.checkroom_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có tủ đồ nào',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tạo tủ đồ đầu tiên để bắt đầu quản lý quần áo của bạn',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Tạo tủ đồ đầu tiên',
                    onPressed: () => _showCreateEditClosetModal(),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ClosetBloc>().add(RefreshClosets());
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: (() {
                final all = closets.cast<ClosetModel>();
                final Map<String, List<ClosetModel>> grouped = {};
                for (final c in all) {
                  grouped.putIfAbsent(c.type, () => []).add(c);
                }

                final orderedTypes = ClosetModel.closetTypes
                    .where((t) => grouped[t]?.isNotEmpty == true)
                    .toList();

                final List<Widget> widgets = [];
                for (final type in orderedTypes) {
                  final list = grouped[type]!;
                  widgets.add(
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(
                        ClosetModel.getTypeDisplayName(type),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                  widgets.addAll(list.map((c) => _buildClosetCard(c)).toList());
                }

                // If somehow nothing matched (shouldn't happen because we handled empty earlier), show fallback
                if (widgets.isEmpty) {
                  return [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.checkroom_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            const Text('Chưa có tủ đồ nào'),
                          ],
                        ),
                      ),
                    ),
                  ];
                }

                return widgets;
              })(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateEditClosetModal(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        label: const Text('Tạo tủ đồ'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
