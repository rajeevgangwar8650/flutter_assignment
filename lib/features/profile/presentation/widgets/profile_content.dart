
import 'package:flutter/material.dart';
import 'package:flutter_assignment/core/utils/extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/profile_entity.dart';

class ProfileContent extends StatelessWidget {
  final ProfileEntity profile;
  final VoidCallback onLogout;

  const ProfileContent({super.key, required this.profile, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CircleAvatar(
                radius: 52,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: profile.name[0].toUpperCase().textExtraLarge(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 24),
              profile.name.textExtraLarge(
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              profile.email.textRegular(
                textAlign: TextAlign.center,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 28),
              _ProfileField(
                icon: Icons.info_outline,
                label: 'Bio',
                value: profile.bio.isEmpty ? 'No bio added.' : profile.bio,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Edit Profile',
                icon: Icons.edit_outlined,
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.editProfile);
                },
              ),
              const SizedBox(height: 12),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  return SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: isLoading ? null : onLogout,
                      icon: isLoading
                          ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Icon(Icons.logout),
                      label: "Logout".textMedium(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileField({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                label.textRegular(),
                const SizedBox(height: 4),
                value.textRegular(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}