import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../data/mock_alarm_repository.dart';
import '../domain/alarm.dart';
import 'home_state.dart';
import 'home_view_model.dart';
import 'widgets/alarm_card.dart';
import 'widgets/alarms_empty_state.dart';
import 'widgets/alarms_error_state.dart';
import 'widgets/alarms_skeleton.dart';
import 'widgets/greeting_header.dart';

/// Pantalla de Inicio.
///
/// Crea su propio `HomeViewModel` con el repositorio simulado. Las pruebas
/// pasan el suyo por `viewModel` para controlar el estado que se dibuja.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.viewModel});

  /// Solo para pruebas: si viene, se usa en lugar de crear uno nuevo.
  final HomeViewModel? viewModel;

  @override
  Widget build(BuildContext context) {
    final HomeViewModel? inyectado = viewModel;

    if (inyectado != null) {
      return ChangeNotifierProvider<HomeViewModel>.value(
        value: inyectado,
        child: const _HomeView(),
      );
    }

    return ChangeNotifierProvider<HomeViewModel>(
      create: (_) => HomeViewModel(MockAlarmRepository())..load(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final HomeViewModel vm = context.watch<HomeViewModel>();
    final HomeState estado = vm.state;

    final int conteo = estado is HomeLoaded ? estado.alarms.length : 0;

    return Scaffold(
      appBar: AppBar(
        leading: const IconButton(
          icon: Icon(LucideIcons.menu),
          tooltip: 'Abrir menú',
          // El menú lateral está fuera del alcance actual.
          onPressed: null,
        ),
        title: const Text('Siempre a Tiempo'),
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.screenH),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.surfaceMuted,
              child: Icon(
                LucideIcons.user,
                size: 18,
                color: AppColors.textSecondary,
                semanticLabel: 'Tu perfil',
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.md,
              AppSpacing.screenH,
              AppSpacing.lg,
            ),
            sliver: SliverToBoxAdapter(
              child: GreetingHeader(userName: vm.userName, alarmCount: conteo),
            ),
          ),
          if (estado is HomeLoaded)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
              sliver: SliverToBoxAdapter(
                child: Text('PRÓXIMAS ALARMAS', style: AppTypography.labelSection),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.sm,
              AppSpacing.screenH,
              // Espacio para que el botón flotante no tape la última tarjeta.
              AppSpacing.xl * 3,
            ),
            sliver: switch (estado) {
              HomeLoading() => const SliverToBoxAdapter(child: AlarmsSkeleton()),
              HomeEmpty() => const SliverToBoxAdapter(child: AlarmsEmptyState()),
              HomeError(:final String message) => SliverToBoxAdapter(
                  child: AlarmsErrorState(message: message, onRetry: vm.load),
                ),
              HomeLoaded(:final List<Alarm> alarms) => SliverList.separated(
                  itemCount: alarms.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (_, int index) => AlarmCard(alarm: alarms[index]),
                ),
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.newAlarm),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Nueva alarma'),
        // El tema no define estilo para el botón extendido y caería en Roboto.
        extendedTextStyle: AppTypography.labelButton,
        shape: const StadiumBorder(),
      ),
    );
  }
}
