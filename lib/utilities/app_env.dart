import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  static String get gptKey => dotenv.get('GPT_KEY');
  static String get gmapsApiKey => dotenv.get('GMAPS_API_KEY');
}
