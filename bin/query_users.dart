import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final url = 'https://feerlkfvkiqivqvdsezh.supabase.co';
  final key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZlZXJsa2Z2a2lxaXZxdmRzZXpoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc4ODA5NjksImV4cCI6MjA5MzQ1Njk2OX0.iYz694L94SFuKalKkMSUJn1PGhN7NClwmpevZ0qbZX0';
  
  final client = SupabaseClient(url, key);
  
  try {
    // Try inserting a dummy user
    final res = await client.from('users').insert({
      'id': '00000000-0000-0000-0000-000000000000',
      'name': 'Dummy',
      'email': 'dummy@example.com',
      'role': 'user',
    }).select();
    print('Inserted: $res');
  } catch (e) {
    print('Error: $e');
  }
  
  exit(0);
}
