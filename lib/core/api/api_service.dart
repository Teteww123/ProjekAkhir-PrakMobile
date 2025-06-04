import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/gadget.dart';

class ApiService {
  static const String baseUrl = 'https://api.restful-api.dev';

  // GET: List all objects
Future<List<Gadget>> fetchGadgets() async {
  final response = await http.get(Uri.parse('$baseUrl/objects'));
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => Gadget.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load gadgets');
  }
}


  // GET: List objects by IDs
  Future<List<Gadget>> fetchGadgetsByIds(List<String> ids) async {
    final query = ids.map((id) => 'id=$id').join('&');
    final response = await http.get(Uri.parse('$baseUrl/objects?$query'));
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List data = body['data'];
      return data.map((json) => Gadget.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load gadgets by ids');
    }
  }

  // GET: Single object by ID
  Future<Gadget> fetchGadgetById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/objects/$id'));
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final data = body['data'];
      return Gadget.fromJson(data);
    } else {
      throw Exception('Failed to load gadget by id');
    }
  }


  // POST: Add object
  Future<Gadget> addGadget(Gadget gadget) async {
    final response = await http.post(
      Uri.parse('$baseUrl/objects'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(gadget.toApiJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return Gadget.fromJson(data);
    } else {
      throw Exception('Failed to add gadget');
    }
  }

  // PUT: Update object
  Future<Gadget> updateGadget(String id, Gadget gadget) async {
    final response = await http.put(
      Uri.parse('$baseUrl/objects/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(gadget.toApiJson()),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Gadget.fromJson(data);
    } else {
      throw Exception('Failed to update gadget');
    }
  }

  // PATCH: Partially update object
  Future<Gadget> patchGadget(String id, Map<String, dynamic> patchData) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/objects/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(patchData),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Gadget.fromJson(data);
    } else {
      throw Exception('Failed to patch gadget');
    }
  }

  // DELETE: Delete object
  Future<String> deleteGadget(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/objects/$id'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['message'] ?? "Deleted";
    } else {
      throw Exception('Failed to delete gadget');
    }
  }
}

