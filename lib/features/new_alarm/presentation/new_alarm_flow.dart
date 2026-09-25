import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/wizard_bottom_bar.dart';
import '../../../core/widgets/wizard_progress_bar.dart';
import '../domain/created_alarm_summary.dart';
import 'new_alarm_view_model.dart';
import 'steps/step_departure_screen.dart';
import 'steps/step_details_screen.dart';
import 'steps/step_transport_screen.dart';
import 'steps/step_type_screen.dart';

/// Asistente de creación de alarmas.
///
/// Es dueño del `NewAlarmViewModel`: el borrador vive mientras el asistente
/// esté abierto y se descarta al cerrarlo.
class NewAlarmFlow extends StatefulWidget {
  const NewAlarmFlow({super.key});

  @override
  NewAlarmFlowState createState() => NewAlarmFlowState();
}

class NewAlarmFlowState extends State<NewAlarmFlow> {
  final NewAlarmViewModel viewModel = NewAlarmViewModel();
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    viewModel.dispose();
    super.dispose();
  }

  void _goToCurrentStep() {
    _pageController.animateToPage(
      viewModel.currentStep,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  /// Acción izquierda: retrocede o, si ya está en el primer paso, cierra.
  void _onLeading() {
    if (viewModel.back()) {
      _goToCurrentStep();
      return;
    }
    Navigator.of(context).pop();
  }

  /// Acción derecha: avanza o, en el último paso, guarda.
  void _onTrailing() {
    if (viewModel.isLastStep) {
      _save();
      return;
    }
    if (viewModel.next()) {
      _goToCurrentStep();
    }
  }

  /// Reemplaza el asistente por la confirmación: así, al cerrarla, el
  /// usuario vuelve a Inicio y no a un asistente ya terminado.
  void _save() {
    final CreatedAlarmSummary? summary = viewModel.save();
    if (summary == null) {
      return;
    }
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.alarmCreated,
      arguments: summary,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NewAlarmViewModel>.value(
      value: viewModel,
      child: Consumer<NewAlarmViewModel>(
        builder: (BuildContext context, NewAlarmViewModel vm, _) {
          return PopScope<void>(
            // El retroceso del sistema debe comportarse igual que la acción
            // izquierda: retroceder de paso antes de cerrar el asistente.
            canPop: false,
            onPopInvokedWithResult: (bool didPop, _) {
              if (didPop) {
                return;
              }
              _onLeading();
            },
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(LucideIcons.arrowLeft),
                  tooltip: 'Volver',
                  onPressed: _onLeading,
                ),
                title: const Text('Nueva alarma'),
              ),
              body: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenH,
                      AppSpacing.sm,
                      AppSpacing.screenH,
                      0,
                    ),
                    child: WizardProgressBar(
                      currentStep: vm.currentStep,
                      totalSteps: NewAlarmViewModel.totalSteps,
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      // El avance se controla solo con los botones.
                      physics: const NeverScrollableScrollPhysics(),
                      children: const <Widget>[
                        StepTypeScreen(),
                        StepDetailsScreen(),
                        StepTransportScreen(),
                        StepDepartureScreen(),
                      ],
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: WizardBottomBar(
                leadingLabel: vm.isFirstStep ? 'Cancelar' : 'Atrás',
                onLeading: _onLeading,
                trailingLabel: vm.isLastStep ? 'Guardar alarma' : 'Siguiente',
                onTrailing: vm.canAdvance ? _onTrailing : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
