import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:iterasi1/model/itinerary.dart';
import 'package:iterasi1/utilities/app_env.dart';

class ItineraryService {
  final String apiUrl = "https://api.openai.com/v1/chat/completions";

  Future<Itinerary> fetchItinerary({
    required String departure,
    required String destination,
    required List<String> dates,
    required int numberOfPeople,
    List<String> vibes = const [],
    String notes = '',
    String pace = '',
    String companions = '',
    bool returnToOrigin = true,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AppEnv.gptKey}',
    };

    final String vibeLine = vibes.isNotEmpty
        ? 'Tipe trip yang diinginkan: ${vibes.join(', ')}.'
        : '';
    final String notesLine =
        notes.trim().isNotEmpty ? 'Catatan dari pengguna: "${notes.trim()}"' : '';
    final String vibeRule = vibes.isNotEmpty
        ? '- Sesuaikan pilihan tempat dan aktivitas dengan tipe trip: ${vibes.join(', ')}.'
        : '';
    const Map<String, String> paceGuidance = {
      'Santai': 'jadwal longgar, sedikit aktivitas per hari, banyak waktu santai/istirahat',
      'Balanced': 'jumlah aktivitas seimbang, tidak terlalu padat maupun terlalu kosong',
      'Padat': 'jadwal padat, banyak aktivitas dalam sehari, manfaatkan waktu secara maksimal',
    };
    final String paceRule = pace.isNotEmpty
        ? '- Gaya perjalanan: $pace${paceGuidance[pace] != null ? ' (${paceGuidance[pace]})' : ''}.'
        : '';
    final String companionRule = companions.isNotEmpty
        ? '- Perjalanan ini bersama: $companions. Sesuaikan pilihan aktivitas agar cocok (mis. ramah anak untuk "Anak kecil", suasana romantis untuk "Couple").'
        : '';
    final String returnRule = returnToOrigin
        ? '- Hari terakhir WAJIB diakhiri dengan aktivitas perjalanan pulang/kembali ke kota asal ($departure).'
        : '- Ini hanya 3 hari pertama dari perjalanan yang lebih panjang. JANGAN buat aktivitas pulang/kembali ke kota asal; hari terakhir harus tetap berada di $destination.';

    String content =
        """Buatkan itinerary wisata dalam Indonesia pada tanggal ${dates.toString()} dari $departure ke $destination.

        $vibeLine
        $notesLine

        ATURAN WAJIB:
        - Jika $destination BUKAN lokasi di Indonesia, jangan buat itinerary. Kembalikan JSON dengan field "error": "OUTSIDE_INDONESIA", "message": "<penjelasan singkat>", dan "itinerary": [] (array kosong).
        - Jika lokasi valid di Indonesia, kembalikan itinerary lengkap dengan "error": null dan "message": null.
        - Bahasa wajib Bahasa Indonesia.
        - Tanggal pada field date harus format 'DD/MM/YYYY'.
        - PENTING: Setiap tanggal hanya boleh muncul SATU KALI dalam array itinerary. Gabungkan aktivitas di tanggal yang sama.
        - Untuk tempat wisata: sertakan latitude & longitude yang akurat (contoh: Kebun Binatang Surabaya 7.2962, 112.7366).
        - Untuk hotel/perjalanan/transit: isi latitude & longitude dengan null.
        - Kolom lokasi wajib format: "Nama Tempat, Kota" (contoh: "Tegallalang Rice Terraces, Ubud").
        $vibeRule
        $paceRule
        $companionRule
        $returnRule
        - activities berisikan title, location, start_time ('HH.mm'), end_time ('HH.mm') dan description.
        - Buat aktivitas yang bervariasi dan realistis (perjalanan antar kota, makan, wisata, istirahat).
        - Untuk aktivitas berikut: hotel/penginapan, makan, tiket wisata, transport,
          WAJIB sertakan estimasi budget di akhir field description.
          Format: "... | Estimasi: Rp XXX (Y orang)" di mana Y = $numberOfPeople.
          Budget adalah total untuk seluruh rombongan, bukan per orang.
          Contoh: "Check-in hotel bintang 3 di pusat kota | Estimasi: Rp 600.000 (4 orang)"
          Contoh: "Makan siang nasi campur Bali | Estimasi: Rp 200.000 (4 orang)"
          Aktivitas lain (jalan-jalan, foto, istirahat, explore) TIDAK perlu estimasi budget.
        """;

    final body = jsonEncode({
      "model": "gpt-4o-2024-08-06",
      "messages": [
        {
          "role": "system",
          "content": "You are a helpful travel itinerary assistant."
        },
        {"role": "user", "content": content}
      ],
      "response_format": {
        "type": "json_schema",
        "json_schema": {
          "name": "create_itinerary",
          "strict": true,
          "schema": {
            "type": "object",
            "properties": {
              "error": {
                "type": ["string", "null"]
              },
              "message": {
                "type": ["string", "null"]
              },
              "itinerary": {
                "type": "array",
                "items": {
                  "type": "object",
                  "properties": {
                    "date": {"type": "string"},
                    "activities": {
                      "type": "array",
                      "items": {
                        "type": "object",
                        "properties": {
                          "title": {"type": "string"},
                          "location": {"type": "string"},
                          "start_time": {"type": "string"},
                          "end_time": {"type": "string"},
                          "description": {"type": "string"},
                          "latitude": {
                            "type": ["number", "null"]
                          },
                          "longitude": {
                            "type": ["number", "null"]
                          }
                        },
                        "required": [
                          "title",
                          "location",
                          "start_time",
                          "end_time",
                          "description",
                          "latitude",
                          "longitude"
                        ],
                        "additionalProperties": false
                      }
                    }
                  },
                  "required": ["date", "activities"],
                  "additionalProperties": false
                }
              }
            },
            "required": ["error", "message", "itinerary"],
            "additionalProperties": false
          }
        }
      }
    });

    try {
      final response =
          await http.post(Uri.parse(apiUrl), headers: headers, body: body);
      // final rawData = await rootBundle.loadString('assets/response.json');
      // log('raw data: $rawData');
      // final jsonResponse = jsonDecode(rawData);
      // final content =
      //     jsonDecode(jsonResponse['choices'][0]['message']['content']);
      // log('isi itinerary data: ${content['itinerary']}');
      // return Itinerary.fromJsonGPT(content);
      log(response.body);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        // log(jsonResponse['choices'][0]['message']['content']);
        final content =
            jsonDecode(jsonResponse['choices'][0]['message']['content']);
        if (content['error'] != null &&
            content['error'].toString() == 'OUTSIDE_INDONESIA') {
          throw Exception(
              'OUTSIDE_INDONESIA: ${content['message'] ?? 'Destinasi di luar Indonesia'}');
        }
        return Itinerary.fromJsonGPT(content);
      } else {
        throw Exception("Failed to fetch itinerary: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
