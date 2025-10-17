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
}
