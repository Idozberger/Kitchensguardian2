// ignore_for_file: pattern_never_matches_value_type
// Analyzer is conservative on sealed/runtime state shapes for AI setup events.

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/error/user_facing_error_mapper.dart';
import 'package:foodkitchen/core/services/document_scanning/document_scanning_service.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/data/models/kitchen_section_model.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/domain/usecases/scan_kitchen_images.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/domain/usecases/skip_kitchen_setup.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/presentation/bloc/smart_kitchen_setup_event.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/presentation/bloc/smart_kitchen_setup_state.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/presentation/data/kitchen_section_data.dart';

class SmartKitchenSetupBloc
    extends Bloc<SmartKitchenSetupEvent, SmartKitchenSetupState> {
  final UserCubit _userCubit;
  final ScanKitchenImagesUseCase _scanKitchenImagesUseCase;
  final SkipKitchenSetup _skipKitchenSetup;

  SmartKitchenSetupBloc({
    required UserCubit userCubit,
    required ScanKitchenImagesUseCase scanKitchenImagesUseCase,
    required SkipKitchenSetup skipKitchenSetup,
  }) : _userCubit = userCubit,
       _scanKitchenImagesUseCase = scanKitchenImagesUseCase,
       _skipKitchenSetup = skipKitchenSetup,
       super(SmartKitchenSetupState.initial()) {
    on<SmartKitchenSetupStarted>(_onStarted);
    on<SmartKitchenSetupScanRequested>(_onScanRequested);
    on<SmartKitchenSetupSectionCleared>(_onSectionCleared);
    on<SmartKitchenSetupConfirmed>(_onConfirmed);
    on<SmartKitchenSetupApiCalled>(_onApiCalled);
    on<SkipKitchenSetupEvent>(_onSkipKitchenSetupEvent);
    on<AddDefaultStoragesEvent>(_onAddDefaultStoragesEvent);
  }

  void _onAddDefaultStoragesEvent(
    AddDefaultStoragesEvent event,
    Emitter<SmartKitchenSetupState> emit,
  ) async {
    final result = await _skipKitchenSetup(
      SkipKitchenSetupParams(kitchenId: event.kitchenId),
    );

    await result.fold(
      (failure) {
        emit(
          state.copyWith(errorMessage: failure.userMessage, isSkipping: false),
        );
      },
      (successMessage) async {
        await _userCubit.getUserStorageArea(kitchenId: event.kitchenId);
      },
    );
  }

  void _onSkipKitchenSetupEvent(
    SkipKitchenSetupEvent event,
    Emitter<SmartKitchenSetupState> emit,
  ) async {
    emit(state.copyWith(isSkipping: true));
    final result = await _skipKitchenSetup(
      SkipKitchenSetupParams(kitchenId: event.kitchenId),
    );

    await result.fold(
      (failure) {
        emit(
          state.copyWith(errorMessage: failure.userMessage, isSkipping: false),
        );
      },
      (successMessage) async {
        await _userCubit.getUserStorageArea(kitchenId: event.kitchenId);
        emit(
          state.copyWith(
            isSkipping: false,
            skipSuccessMessage: "Skipped Successful",
          ),
        );
      },
    );
  }

  void _onStarted(
    SmartKitchenSetupStarted event,
    Emitter<SmartKitchenSetupState> emit,
  ) {
    emit(
      state.copyWith(
        isInitial: false,
        sections: List<KitchenSection>.from(kSections),
      ),
    );
  }

  Future<void> _onScanRequested(
    SmartKitchenSetupScanRequested event,
    Emitter<SmartKitchenSetupState> emit,
  ) async {
    emit(
      state.copyWith(
        isScanning: true,
        activeSectionId: event.section.id,
        clearError: true,
      ),
    );

    try {
      final result = await DocumentScannerService().scanAndGetPath();
      devLog('scanning result: $result');

      if (result == null) {
        emit(state.copyWith(isScanning: false, clearActiveSection: true));
        return;
      }

      final String? path = switch (result) {
        String r when r.isNotEmpty => r,
        List r when r.isNotEmpty => r.first.toString(),
        _ => null,
      };

      if (path == null) {
        emit(state.copyWith(isScanning: false, clearActiveSection: true));
        return;
      }

      final updatedSections = _updateSection(state.sections, event.section.id, [
        path,
      ]);

      emit(
        state.copyWith(
          sections: updatedSections,
          isScanning: false,
          clearActiveSection: true,
        ),
      );
    } on PlatformException catch (e) {
      final userMessage = UserFacingErrorMapper.fromPlatform(
        e,
        fallbackUserMessage:
            "We couldn't scan that. Please try again or pick another image.",
      ).userMessage;
      emit(
        state.copyWith(
          isScanning: false,
          clearActiveSection: true,
          errorMessage: userMessage,
        ),
      );
    } catch (_) {
      emit(state.copyWith(isScanning: false, clearActiveSection: true));
    }
  }

  void _onSectionCleared(
    SmartKitchenSetupSectionCleared event,
    Emitter<SmartKitchenSetupState> emit,
  ) {
    final updatedSections = _updateSection(
      state.sections,
      event.section.id,
      [],
    );
    emit(state.copyWith(sections: updatedSections, clearError: true));
  }

  void _onConfirmed(
    SmartKitchenSetupConfirmed event,
    Emitter<SmartKitchenSetupState> emit,
  ) {
    add(
      SmartKitchenSetupApiCalled(
        kitchenId: event.kitchenId,
        payload: state.payload,
      ),
    );
  }

  Future<void> _onApiCalled(
    SmartKitchenSetupApiCalled event,
    Emitter<SmartKitchenSetupState> emit,
  ) async {
    if (state.isLoading) return;
    emit(state.copyWith(isScanning: true, clearError: true, isLoading: true));

    final params = ScanKitchenImagesUseCaseParams(
      kitchenId: event.kitchenId,
      fridgeFilePaths: event.payload['fridge'] ?? [],
      freezerFilePaths: event.payload['freezer'] ?? [],
      pantryFilePaths: event.payload['pantry'] ?? [],
      spicesFilePaths: event.payload['spices'] ?? [],
      miscFilePaths: event.payload['misc'] ?? [],
    );

    devLog(
      'API params: fridge=${params.fridgeFilePaths}, freezer=${params.freezerFilePaths}, '
      'pantry=${params.pantryFilePaths}, spices=${params.spicesFilePaths}, '
      'misc=${params.miscFilePaths}',
    );

    final result = await _scanKitchenImagesUseCase(params);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isScanning: false,
            errorMessage: failure.userMessage,
            isLoading: false,
          ),
        );
      },
      (scannedItems) {
        emit(
          state.copyWith(
            isScanning: false,
            isConfirmed: true,
            isLoading: false,
            scannedItems: scannedItems,
          ),
        );
      },
    );
  }

  List<KitchenSection> _updateSection(
    List<KitchenSection> sections,
    String id,
    List<String> imagePaths,
  ) {
    return sections.map((s) {
      if (s.id == id) return s.copyWith(imagePaths: imagePaths);
      return s;
    }).toList();
  }
}
