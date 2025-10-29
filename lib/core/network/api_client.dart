import 'dio_client.dart';

class ApiClient {
  final DioClient dioClient;

  ApiClient(this.dioClient);

  // Example API endpoints

  // Get all posts
  Future<dynamic> getPosts() async {
    try {
      final response = await dioClient.get('/posts');
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }

  // Get post by ID
  Future<dynamic> getPost(int id) async {
    try {
      final response = await dioClient.get('/posts/$id');
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch post: $e');
    }
  }

  // Create post
  Future<dynamic> createPost(Map<String, dynamic> post) async {
    try {
      final response = await dioClient.post('/posts', data: post);
      return response.data;
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // Update post
  Future<dynamic> updatePost(int id, Map<String, dynamic> post) async {
    try {
      final response = await dioClient.put('/posts/$id', data: post);
      return response.data;
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  // Delete post
  Future<bool> deletePost(int id) async {
    try {
      await dioClient.delete('/posts/$id');
      return true;
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  // Authentication example
  Future<dynamic> login(String email, String password) async {
    try {
      final response = await dioClient.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return response.data;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Register example
  Future<dynamic> register(Map<String, dynamic> userData) async {
    try {
      final response = await dioClient.post('/auth/register', data: userData);
      return response.data;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Fetch products with optional query parameters (filters)
  Future<dynamic> getProducts({Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await dioClient.get(
        '/products',
        queryParameters: queryParameters,
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  // Fetch available filters (e.g., sizes, colors, props)
  Future<dynamic> getFilters() async {
    try {
      final response = await dioClient.get('/filters');
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch filters: $e');
    }
  }

  // Closet APIs
  Future<dynamic> getClosets() async {
    try {
      final response = await dioClient.get('/closets');
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch closets: $e');
    }
  }

  Future<dynamic> createCloset(Map<String, dynamic> closet) async {
    try {
      final response = await dioClient.post('/closets', data: closet);
      return response.data;
    } catch (e) {
      throw Exception('Failed to create closet: $e');
    }
  }

  Future<dynamic> updateCloset(String id, Map<String, dynamic> closet) async {
    try {
      final response = await dioClient.put('/closets/$id', data: closet);
      return response.data;
    } catch (e) {
      throw Exception('Failed to update closet: $e');
    }
  }

  Future<bool> deleteCloset(String id) async {
    try {
      await dioClient.delete('/closets/$id');
      return true;
    } catch (e) {
      throw Exception('Failed to delete closet: $e');
    }
  }

  // Get closet by ID
  Future<dynamic> getClosetById(String id) async {
    try {
      final response = await dioClient.get('/closets/$id');
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch closet: $e');
    }
  }

  // Closet Items APIs
  Future<dynamic> getClosetItems(String closetId) async {
    try {
      final response = await dioClient.get('/closets/$closetId/items');
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch closet items: $e');
    }
  }

  Future<dynamic> getClosetItemById(String id) async {
    try {
      final response = await dioClient.get('/closet-items/$id');
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch closet item: $e');
    }
  }

  Future<dynamic> createClosetItem(Map<String, dynamic> item) async {
    try {
      final response = await dioClient.post('/closet-items', data: item);
      return response.data;
    } catch (e) {
      throw Exception('Failed to create closet item: $e');
    }
  }

  Future<dynamic> updateClosetItem(String id, Map<String, dynamic> item) async {
    try {
      final response = await dioClient.put('/closet-items/$id', data: item);
      return response.data;
    } catch (e) {
      throw Exception('Failed to update closet item: $e');
    }
  }

  Future<bool> deleteClosetItem(String id) async {
    try {
      await dioClient.delete('/closet-items/$id');
      return true;
    } catch (e) {
      throw Exception('Failed to delete closet item: $e');
    }
  }
}
