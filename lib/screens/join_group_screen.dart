import 'package:flutter/material.dart';
import 'package:dhanwiser_fixed/widgets/bouncing_button.dart';
import 'package:provider/provider.dart';
import '../providers/server_provider.dart';
import '../services/server_service.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class JoinGroupScreen extends StatefulWidget {
  final int serverId;

  const JoinGroupScreen({super.key, required this.serverId});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  bool _isJoining = false;
  String? _error;

  Future<void> _joinGroup() async {
    setState(() {
      _isJoining = true;
      _error = null;
    });

    try {
      await ServerService.joinServer(widget.serverId);
      if (!mounted) return;
      
      // Refresh the user's servers list
      await Provider.of<ServerProvider>(context, listen: false).fetchServers();
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Successfully joined the group!'),
          backgroundColor: DhanWiserColors.of(context).primary,
        ),
      );
      
      // Go to home and let them click into the new server,
      // or replace with server detail directly.
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isJoining = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Join Group'),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.group_add_rounded, size: 40, color: cs.onPrimaryContainer),
              ),
              const SizedBox(height: 24),
              Text(
                'You\'ve been invited!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Join group #${widget.serverId} to start splitting expenses.',
                textAlign: TextAlign.center,
                style: DhanWiserTextStyles.bodyRegular(context).copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    _error!,
                    style: DhanWiserTextStyles.caption(context).copyWith(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ),
                
              SizedBox(
                width: double.infinity,
                child: PremiumElevatedButton(
                  onPressed: _isJoining ? null : _joinGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isJoining 
                    ? const SizedBox(
                        width: 20, 
                        height: 20, 
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                      )
                    : Text('Accept Invite & Join', style: DhanWiserTextStyles.buttonLarge(context)),
                ),
              ),
              const SizedBox(height: 16),
              PremiumTextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: Text('Cancel', style: DhanWiserTextStyles.buttonLarge(context).copyWith(color: cs.onSurfaceVariant)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
