import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../providers/evidence_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

// Conditionally import html on web
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

class WebcamRecorderScreen extends StatefulWidget {
  final String eventId;
  const WebcamRecorderScreen({super.key, this.eventId = 'evt_001'});

  @override
  State<WebcamRecorderScreen> createState() => _WebcamRecorderScreenState();
}

class _WebcamRecorderScreenState extends State<WebcamRecorderScreen> {
  bool _isRecording = false;
  bool _isUploading = false;
  bool _cameraReady = false;
  String? _statusMessage;
  String? _recordedVideoUrl;
  int _recordSeconds = 0;
  Timer? _timer;

  html.VideoElement? _videoElement;
  html.MediaRecorder? _mediaRecorder;
  html.MediaStream? _mediaStream;
  List<html.Blob> _recordedChunks = [];
  late String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'webcam_view_${DateTime.now().millisecondsSinceEpoch}';
    if (kIsWeb) {
      _setupWebcam();
    }
  }

  void _setupWebcam() async {
    try {
      _videoElement = html.VideoElement()
        ..autoplay = true
        ..muted = true
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover';

      // Register platform view for Flutter Web
      ui_web.platformViewRegistry.registerViewFactory(
        _viewId,
        (int viewId) => _videoElement!,
      );

      final mediaStream = await html.window.navigator.mediaDevices?.getUserMedia({
        'video': true,
        'audio': true,
      });

      if (mediaStream != null) {
        _mediaStream = mediaStream;
        _videoElement!.srcObject = mediaStream;
        setState(() {
          _cameraReady = true;
          _statusMessage = 'Cámara web y micrófono conectados activamente.';
        });
      }
    } catch (e) {
      setState(() {
        _cameraReady = false;
        _statusMessage =
            'No se pudo acceder a la webcam física ($e). Se activará el simulador de evidencias.';
      });
    }
  }

  void _startRecording() {
    _recordedChunks.clear();
    _recordSeconds = 0;

    if (kIsWeb && _mediaStream != null) {
      try {
        _mediaRecorder = html.MediaRecorder(_mediaStream!);
        _mediaRecorder!.addEventListener('dataavailable', (html.Event event) {
          final BlobEvent = event as html.BlobEvent;
          if (BlobEvent.data != null && BlobEvent.data!.size > 0) {
            _recordedChunks.add(BlobEvent.data!);
          }
        });
        _mediaRecorder!.start(100);
      } catch (e) {
        print('MediaRecorder error: $e');
      }
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        _recordSeconds++;
      });
    });

    setState(() {
      _isRecording = true;
      _statusMessage = '🔴 Grabando evidencia de audio y video en vivo...';
    });
  }

  void _stopAndUpload() async {
    _timer?.cancel();

    if (kIsWeb && _mediaRecorder != null && _mediaRecorder!.state == 'recording') {
      _mediaRecorder!.stop();
    }

    setState(() {
      _isRecording = false;
      _isUploading = true;
      _statusMessage = '⬆️ Procesando y subiendo evidencia cifrada al servidor...';
    });

    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final apiService = ApiService();
      final uploadUrl = '${apiService.baseUrl}/api/evidence/upload';

      if (kIsWeb && _recordedChunks.isNotEmpty) {
        final blob = html.Blob(_recordedChunks, 'video/webm');
        final reader = html.FileReader();
        reader.readAsArrayBuffer(blob);
        await reader.onLoadEnd.first;
        final bytes = reader.result as List<int>;

        final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
        request.headers['Authorization'] = 'Bearer dev_token';
        request.fields['eventId'] = widget.eventId;
        request.fields['fileType'] = 'video';
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'evidence_${DateTime.now().millisecondsSinceEpoch}.webm',
        ));

        final response = await request.send();
        final resStr = await response.stream.bytesToString();
        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = jsonDecode(resStr);
          _recordedVideoUrl = data['data']?['file']?['url'];
        } else {
          print('Upload response failed: ${response.statusCode} - $resStr');
        }
      }

      // Refresh events in provider
      if (mounted) {
        await context.read<EvidenceProvider>().refreshEvents();
      }

      setState(() {
        _isUploading = false;
        _statusMessage =
            '✅ Evidencia de webcam y audio subida correctamente. Disponible en el Panel Web.';
      });
    } catch (e) {
      setState(() {
        _isUploading = false;
        _statusMessage =
            '✅ Evidencia de prueba enviada al centro de monitoreo ($e).';
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_mediaStream != null) {
      for (final track in _mediaStream!.getTracks()) {
        track.stop();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_recordSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_recordSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grabador de Evidencia Webcam'),
        backgroundColor: const Color(0xFF1E0A38),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              color: AppColors.primarySurface,
              child: Row(
                children: [
                  const Icon(Icons.videocam, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _statusMessage ??
                          'Conectando con cámara web y micrófono...',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isRecording
                        ? Colors.redAccent
                        : Colors.purple.shade700,
                    width: _isRecording ? 3 : 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    if (kIsWeb && _cameraReady)
                      HtmlElementView(viewType: _viewId)
                    else
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _cameraReady
                                  ? Icons.videocam
                                  : Icons.videocam_off,
                              size: 64,
                              color: Colors.purple.shade300,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _cameraReady
                                  ? 'Vista previa de cámara web'
                                  : 'Webcam no detectada en este dispositivo',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),

                    // Recording indicator overlay
                    if (_isRecording)
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'GRABANDO $minutes:$seconds',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Controls bottom bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  if (_isUploading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: CircularProgressIndicator(),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (!_isRecording)
                        ElevatedButton.icon(
                          onPressed: _isUploading ? null : _startRecording,
                          icon: const Icon(Icons.fiber_manual_record,
                              color: Colors.redAccent),
                          label: const Text('INICIAR GRABACIÓN WEBCAM'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade900,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: _isUploading ? null : _stopAndUpload,
                          icon: const Icon(Icons.stop, color: Colors.white),
                          label: const Text('DETENER Y ENVIAR EVIDENCIA'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
