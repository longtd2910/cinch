import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class PhotoPermissionScreen extends StatefulWidget {
  const PhotoPermissionScreen({super.key});

  @override
  State<PhotoPermissionScreen> createState() => _PhotoPermissionScreenState();
}

class _PhotoPermissionScreenState extends State<PhotoPermissionScreen>
    with WidgetsBindingObserver {
  PermissionState? _permission;
  bool _requesting = false;
  bool _returnedFromSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _returnedFromSettings) {
      _returnedFromSettings = false;
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    final ps = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.image,
          mediaLocation: false,
        ),
      ),
    );
    if (!mounted) return;

    if (ps.isAuth) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() => _permission = ps);
  }

  Future<void> _requestPermission() async {
    if (_requesting) return;
    setState(() => _requesting = true);

    final ps = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.image,
          mediaLocation: false,
        ),
      ),
    );

    if (!mounted) return;

    if (ps.isAuth) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _permission = ps;
      _requesting = false;
    });
  }

  Future<void> _openSettings() async {
    _returnedFromSettings = true;
    await PhotoManager.openSetting();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDenied = _permission != null && !_permission!.hasAccess;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.photo_library_outlined,
                  size: 48,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Photo Access Required',
                style: tt.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isDenied
                    ? 'Photo access was denied. Please grant full photo access in Settings so Cinch can scan your photos for transactions.'
                    : 'Cinch needs access to your photo library to scan for transaction receipts and screenshots.',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: isDenied
                    ? FilledButton.icon(
                        onPressed: _openSettings,
                        icon: const Icon(Icons.settings),
                        label: const Text('Open Settings'),
                      )
                    : FilledButton(
                        onPressed: _requesting ? null : _requestPermission,
                        child: Text(
                          _requesting ? 'Requesting...' : 'Grant Access',
                        ),
                      ),
              ),
              if (isDenied) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _requesting ? null : _requestPermission,
                  child: const Text('Try Again'),
                ),
              ],
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
