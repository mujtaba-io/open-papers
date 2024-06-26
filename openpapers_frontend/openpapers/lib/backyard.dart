import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

const String DOMAIN = 'http://localhost:7860'; // do NOT include trailing slash

Dio dio = Dio();

String makeUrl(String path) {
  if (path.startsWith('/')) {
    return '$DOMAIN$path';
  } else {
    return '$DOMAIN/$path';
  }
}

// Replace 'your_api_endpoint' with the actual endpoint URL
Future<dynamic> fetchData(
    {required String endpoint, Map<String, dynamic>? data}) async {
  try {
    Response response;
    if (data != null) {
      // POST request with data
      response = await dio.post(endpoint, data: data);
    } else {
      // GET request (same logic from previous example)
      response = await dio.get(endpoint);
    }
    if (response.statusCode == 200) {
      // Parse the JSON response and convert to a Map with String keys
      return jsonDecode(response.data);
    } else {
      // Handle error based on status code
      throw Exception(
          'API request failed with status code: ${response.statusCode}');
    }
  } on DioException catch (e) {
    // Handle Dio specific errors
    throw Exception('API request failed: ${e.message}');
  }
}

Future<List<String>?> getDirectoryContents(String path) async {
  try {
    dynamic response = await fetchData(endpoint: makeUrl(path));
    List<String> responseData = List<String>.from(response);
    print(responseData);
    return responseData;
  } catch (e) {
    print('Error: $e');
  }
  return null;
}

int countFolders(String path) {
  // Remove leading and trailing slashes
  String cleanedPath = path.trim().replaceAll(RegExp(r'^/+|/+$'), '');
  // Split the path by slashes
  List<String> folders = cleanedPath.split('/');
  // If the cleaned path is empty, return 0
  if (cleanedPath.isEmpty) {
    return 0;
  }
  // Return the number of folders
  return folders.length;
}
