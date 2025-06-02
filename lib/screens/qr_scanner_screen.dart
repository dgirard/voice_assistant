import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/voice_assistant_provider.dart';
import '../services/ai_service.dart';
import '../models/assistant.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({Key? key}) : super(key: key);

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isProcessing = false;
  bool _flashOn = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Scanner QR Assistant',
          style: TextStyle(
            fontFamily: 'Chakra Petch',
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              _flashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: () async {
              await controller?.toggleFlash();
              setState(() {
                _flashOn = !_flashOn;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _resetScanner,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scanner camera
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: const Color(0xFF6B7FD7),
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: 300,
            ),
          ),
          
          // Overlay avec instructions
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Positionnez le QR code dans le cadre',
                    style: TextStyle(
                      fontFamily: 'Chakra Petch',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Le QR code doit contenir le nom de l\'assistant',
                    style: TextStyle(
                      fontFamily: 'Chakra Petch',
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          // Loading overlay
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(
                      color: Color(0xFF6B7FD7),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Recherche de l\'assistant...',
                      style: TextStyle(
                        fontFamily: 'Chakra Petch',
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      _onQrCodeDetected(scanData);
    });
  }

  void _onQrCodeDetected(Barcode scanData) async {
    if (_isProcessing) return;
    
    final String? qrText = scanData.code;
    if (qrText == null || qrText.isEmpty) return;
    
    print('🔍 QR Code détecté: "$qrText"');
    
    // Pause le scanner pendant le traitement
    await controller?.pauseCamera();
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      await _processQrCode(qrText.trim());
    } catch (e) {
      print('❌ Erreur traitement QR: $e');
      _showErrorDialog('Erreur lors du traitement du QR code');
      
      // Relancer le scanner en cas d'erreur
      await _resetScanner();
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
  
  Future<void> _resetScanner() async {
    try {
      print('🔄 Reset du scanner...');
      
      // Reset l'état de traitement
      setState(() {
        _isProcessing = false;
      });
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted && controller != null) {
        await controller!.resumeCamera();
        print('📷 Scanner redémarré et prêt');
      }
      
      // Afficher un message de confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Scanner réinitialisé'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Erreur reset scanner: $e');
    }
  }

  Future<void> _processQrCode(String qrText) async {
    final provider = context.read<VoiceAssistantProvider>();
    final assistants = provider.availableAssistants;
    
    print('🔍 QR Code détecté: "$qrText"');
    print('📋 Assistants disponibles: ${assistants.map((a) => a.name).toList()}');
    
    // 1. Recherche directe par nom
    Assistant? selectedAssistant = assistants.firstWhere(
      (assistant) => assistant.name.toLowerCase() == qrText.toLowerCase(),
      orElse: () => assistants.firstWhere(
        (assistant) => assistant.name.toLowerCase().contains(qrText.toLowerCase()),
        orElse: () => Assistant.gemini(), // Valeur par défaut temporaire
      ),
    );
    
    // Si pas de correspondance directe, demander à Gemini
    if (selectedAssistant.name == 'Gemini' && 
        !qrText.toLowerCase().contains('gemini')) {
      print('🤖 Aucune correspondance directe, demande à Gemini...');
      selectedAssistant = await _findAssistantWithGemini(qrText, assistants);
    }
    
    // Sélectionner l'assistant trouvé
    await provider.selectAssistant(selectedAssistant);
    
    // Afficher confirmation et retourner
    if (mounted) {
      _showSuccessDialog(selectedAssistant.name);
    }
  }

  Future<Assistant> _findAssistantWithGemini(String qrText, List<Assistant> assistants) async {
    try {
      final aiService = AIService();
      
      // Créer la liste des assistants pour Gemini
      final assistantsList = assistants.map((a) => '- ${a.name}').join('\n');
      
      final prompt = '''
Voici une liste d'assistants disponibles:
$assistantsList

Un QR code contient le texte: "$qrText"

Trouve l'assistant qui correspond le mieux à ce texte. Réponds UNIQUEMENT par le nom exact de l'assistant de la liste, sans explication.
Si aucun ne correspond, réponds "Gemini".
''';

      final response = await aiService.generateResponse(prompt);
      final suggestedName = response.trim();
      
      print('🎯 Gemini suggère: "$suggestedName"');
      
      // Rechercher l'assistant suggéré par Gemini
      final foundAssistant = assistants.firstWhere(
        (assistant) => assistant.name.toLowerCase() == suggestedName.toLowerCase(),
        orElse: () => assistants.isNotEmpty ? assistants.first : Assistant.gemini(),
      );
      
      return foundAssistant;
    } catch (e) {
      print('❌ Erreur Gemini: $e');
      // Fallback: prendre le premier assistant ou Gemini
      return assistants.isNotEmpty ? assistants.first : Assistant.gemini();
    }
  }

  void _showSuccessDialog(String assistantName) {
    // Fermer immédiatement le scanner pour revenir à l'écran principal
    Navigator.of(context).pop();
    
    // Afficher le message de succès sur l'écran principal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Assistant "$assistantName" sélectionné',
                    style: const TextStyle(
                      fontFamily: 'Chakra Petch',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Vous pouvez maintenant poser des questions et mentionner le nom de l\'assistant',
              style: TextStyle(
                fontFamily: 'Chakra Petch',
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Erreur QR Code',
                style: TextStyle(
                  fontFamily: 'Chakra Petch',
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Chakra Petch',
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Chakra Petch',
                color: Color(0xFF6B7FD7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}