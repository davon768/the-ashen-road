import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

const _model = 'black-forest-labs/flux-schnell';

/// Handles all Replicate image generation with a built-in concurrency limiter.
/// Max [_maxConcurrent] requests run at once; additional calls queue and wait.
class ReplicateService {
  final String apiKey;

  static const int _maxConcurrent = 3;
  int _active = 0;
  final _waiters = <Completer<void>>[];

  ReplicateService(this.apiKey);

  /// Generate an image and return its URL, or null on permanent failure.
  /// Automatically throttles concurrent requests and retries up to 3 times.
  Future<String?> generateImage(String prompt, {String aspectRatio = '2:3'}) async {
    await _acquire();
    try {
      return await _withRetries(prompt, aspectRatio);
    } finally {
      _release();
    }
  }

  // ─── CONCURRENCY SEMAPHORE ───────────────────────────────────────────────

  Future<void> _acquire() async {
    if (_active < _maxConcurrent) {
      _active++;
      return;
    }
    final slot = Completer<void>();
    _waiters.add(slot);
    await slot.future;
    _active++;
  }

  void _release() {
    _active--;
    if (_waiters.isNotEmpty) {
      _waiters.removeAt(0).complete();
    }
  }

  // ─── RETRY WRAPPER ───────────────────────────────────────────────────────

  Future<String?> _withRetries(String prompt, String aspectRatio) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      if (attempt > 0) {
        await Future.delayed(Duration(seconds: 4 * attempt));
      }
      final url = await _singleAttempt(prompt, aspectRatio);
      if (url != null) return url;
    }
    return null;
  }

  // ─── SINGLE ATTEMPT: CREATE → POLL ───────────────────────────────────────

  Future<String?> _singleAttempt(String prompt, String aspectRatio) async {
    try {
      // Step 1 — create the prediction
      final createRes = await http
          .post(
            Uri.parse(
                'https://api.replicate.com/v1/models/$_model/predictions'),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'input': {
                'prompt': prompt,
                'num_outputs': 1,
                'aspect_ratio': aspectRatio,
                'output_format': 'webp',
                'output_quality': 80,
                'num_inference_steps': 4,
              },
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (createRes.statusCode != 200 && createRes.statusCode != 201) {
        return null;
      }

      final body = jsonDecode(createRes.body) as Map<String, dynamic>;

      // Already done (rare but possible)
      if (body['status'] == 'succeeded') {
        return _extractUrl(body['output']);
      }

      final id = body['id'] as String?;
      if (id == null) return null;

      // Step 2 — poll until complete (max ~90 s, 2 s intervals)
      for (var i = 0; i < 45; i++) {
        await Future.delayed(const Duration(seconds: 2));

        final pollRes = await http
            .get(
              Uri.parse('https://api.replicate.com/v1/predictions/$id'),
              headers: {'Authorization': 'Bearer $apiKey'},
            )
            .timeout(const Duration(seconds: 15));

        if (pollRes.statusCode != 200) return null;

        final data = jsonDecode(pollRes.body) as Map<String, dynamic>;
        final status = data['status'] as String?;

        if (status == 'succeeded') return _extractUrl(data['output']);
        if (status == 'failed' || status == 'canceled') return null;
      }
      return null; // timed out
    } catch (_) {
      return null;
    }
  }

  static String? _extractUrl(dynamic output) {
    if (output is List && output.isNotEmpty) return output.first as String?;
    return null;
  }
}
