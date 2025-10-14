class ClothingItem {
  final int id;
  final String name;
  final String category;
  final String brand;
  final String imageUrl;
  final double price;
  final String size;
  final String color;
  final String description;
  final bool isAvailable;
  final String owner;

  ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
    required this.imageUrl,
    required this.price,
    required this.size,
    required this.color,
    required this.description,
    required this.isAvailable,
    required this.owner,
  });

  // Mock data
  static List<ClothingItem> mockData = [
    ClothingItem(
      id: 1,
      name: 'Áo sơ mi trắng classic',
      category: 'Áo sơ mi',
      brand: 'Zara',
      imageUrl: 'https://picsum.photos/id/1018/300/400',
      price: 350000,
      size: 'M',
      color: 'Trắng',
      description: 'Áo sơ mi trắng cổ điển, phù hợp cho môi trường công sở',
      isAvailable: true,
      owner: 'Nguyễn Văn A',
    ),
    ClothingItem(
      id: 2,
      name: 'Váy dạ hội đen',
      category: 'Váy',
      brand: 'H&M',
      imageUrl: 'https://picsum.photos/id/1019/300/400',
      price: 800000,
      size: 'S',
      color: 'Đen',
      description:
          'Váy dạ hội sang trọng, thích hợp cho các sự kiện quan trọng',
      isAvailable: true,
      owner: 'Trần Thị B',
    ),
    ClothingItem(
      id: 3,
      name: 'Quần jeans xanh',
      category: 'Quần',
      brand: 'Levis',
      imageUrl: 'https://picsum.photos/id/1020/300/400',
      price: 450000,
      size: 'L',
      color: 'Xanh',
      description: 'Quần jeans classic fit, thoải mái cho mọi hoạt động',
      isAvailable: false,
      owner: 'Lê Văn C',
    ),
    ClothingItem(
      id: 4,
      name: 'Áo khoác blazer',
      category: 'Áo khoác',
      brand: 'Mango',
      imageUrl: 'https://picsum.photos/id/1021/300/400',
      price: 750000,
      size: 'M',
      color: 'Xám',
      description: 'Áo blazer thanh lịch, hoàn hảo cho style công sở',
      isAvailable: true,
      owner: 'Phạm Thị D',
    ),
    ClothingItem(
      id: 5,
      name: 'Đầm hoa mùa hè',
      category: 'Đầm',
      brand: 'Forever 21',
      imageUrl: 'https://picsum.photos/id/1022/300/400',
      price: 280000,
      size: 'S',
      color: 'Hoa',
      description: 'Đầm hoa tươi mát, lý tưởng cho mùa hè',
      isAvailable: true,
      owner: 'Hoàng Văn E',
    ),
    ClothingItem(
      id: 6,
      name: 'Áo len cổ lọ',
      category: 'Áo len',
      brand: 'Uniqlo',
      imageUrl: 'https://picsum.photos/id/1023/300/400',
      price: 320000,
      size: 'L',
      color: 'Be',
      description: 'Áo len mềm mại, ấm áp cho mùa đông',
      isAvailable: true,
      owner: 'Vũ Thị F',
    ),
    ClothingItem(
      id: 7,
      name: 'Quần short thể thao',
      category: 'Quần',
      brand: 'Nike',
      imageUrl: 'https://picsum.photos/id/1024/300/400',
      price: 180000,
      size: 'M',
      color: 'Đen',
      description: 'Quần short thể thao thoáng mát, phù hợp tập luyện',
      isAvailable: true,
      owner: 'Đặng Văn G',
    ),
    ClothingItem(
      id: 8,
      name: 'Áo thun polo',
      category: 'Áo thun',
      brand: 'Lacoste',
      imageUrl: 'https://picsum.photos/id/1025/300/400',
      price: 420000,
      size: 'XL',
      color: 'Xanh navy',
      description: 'Áo polo lịch sự, phong cách casual',
      isAvailable: false,
      owner: 'Bùi Thị H',
    ),
  ];

  // Search function
  static List<ClothingItem> search(String query) {
    if (query.isEmpty) return mockData;

    return mockData.where((item) {
      return item.name.toLowerCase().contains(query.toLowerCase()) ||
          item.category.toLowerCase().contains(query.toLowerCase()) ||
          item.brand.toLowerCase().contains(query.toLowerCase()) ||
          item.color.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Filter by category
  static List<ClothingItem> filterByCategory(String category) {
    if (category == 'Tất cả') return mockData;
    return mockData.where((item) => item.category == category).toList();
  }

  // Get all categories
  static List<String> getCategories() {
    Set<String> categories = {'Tất cả'};
    for (var item in mockData) {
      categories.add(item.category);
    }
    return categories.toList();
  }
}
