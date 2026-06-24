import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/dialog_helper.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/empty_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_content.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const ProfileRequested());
  }

  Future<void> _logout() async {
    final confirmed = await DialogHelper.confirm(
      context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmLabel: 'Logout',
    );
    if (!confirmed || !mounted) return;
    context.read<AuthBloc>().add(const AuthLogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.read<ProfileBloc>().add(const ProfileResetRequested());
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
        } else if (state is AuthFailure) {
          SnackbarHelper.showError(context, state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: BlocConsumer<ProfileBloc, ProfileState>(
          listenWhen: (previous, current) =>
              current is ProfileFailure ||
              current is ProfileSuccess && current.message != null,
          listener: (context, state) {
            if (state is ProfileFailure) {
              SnackbarHelper.showError(context, state.message);
            } else if (state is ProfileSuccess && state.message != null) {
              SnackbarHelper.showSuccess(context, state.message!);
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const LoadingWidget(message: 'Loading profile...');
            }
            if (state is ProfileFailure) {
              return AppErrorWidget(
                message: state.message,
                onRetry: () {
                  context.read<ProfileBloc>().add(const ProfileRequested());
                },
              );
            }
            if (state is ProfileSuccess) {
              return ProfileContent(profile: state.profile, onLogout: _logout);
            }
            return const EmptyWidget(message: 'Profile is not available.');
          },
        ),
      ),
    );
  }
}
