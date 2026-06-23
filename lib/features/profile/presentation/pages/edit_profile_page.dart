import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_textfield.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/profile_entity.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();

  String _imageUrl = '';
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileSuccess) {
      _setControllers(state.profile);
    } else {
      context.read<ProfileBloc>().add(const ProfileRequested());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _setControllers(ProfileEntity profile) {
    if (_initialized) return;
    _nameController.text = profile.name;
    _emailController.text = profile.email;
    _bioController.text = profile.bio;
    _imageUrl = profile.imageUrl;
    _initialized = true;
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<ProfileBloc>().add(
      ProfileUpdateSubmitted(
        name: _nameController.text,
        email: _emailController.text,
        bio: _bioController.text,
        imageUrl: _imageUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listenWhen: (previous, current) =>
            current is ProfileSuccess || current is ProfileFailure,
        listener: (context, state) {
          if (state is ProfileSuccess) {
            _setControllers(state.profile);
            if (state.message != null) {
              SnackbarHelper.showSuccess(context, state.message!);
              Navigator.of(context).pop();
            }
          } else if (state is ProfileFailure) {
            SnackbarHelper.showError(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is ProfileLoading;
          if (isLoading && !_initialized) {
            return const LoadingWidget(message: 'Loading profile...');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person_outline,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppTextField(
                        controller: _nameController,
                        label: 'Name',
                        textInputAction: TextInputAction.next,
                        validator: Validators.name,
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validators.email,
                        readOnly: true,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _bioController,
                        label: 'Bio',
                        maxLines: 4,
                        validator: Validators.bio,
                        prefixIcon: const Icon(Icons.notes_outlined),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: 'Save',
                        icon: Icons.save_outlined,
                        isLoading: isLoading,
                        onPressed: isLoading ? null : _save,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                          label: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
