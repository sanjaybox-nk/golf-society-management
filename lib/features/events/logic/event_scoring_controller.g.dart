// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_scoring_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EventScoringController)
final eventScoringControllerProvider = EventScoringControllerFamily._();

final class EventScoringControllerProvider
    extends $NotifierProvider<EventScoringController, ProcessedEventData> {
  EventScoringControllerProvider._(
      {required EventScoringControllerFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'eventScoringControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$eventScoringControllerHash();

  @override
  String toString() {
    return r'eventScoringControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EventScoringController create() => EventScoringController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProcessedEventData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProcessedEventData>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventScoringControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventScoringControllerHash() =>
    r'3aa96168cabb015b6a78656bd72959ef8f920685';

final class EventScoringControllerFamily extends $Family
    with
        $ClassFamilyOverride<EventScoringController, ProcessedEventData,
            ProcessedEventData, ProcessedEventData, String> {
  EventScoringControllerFamily._()
      : super(
          retry: null,
          name: r'eventScoringControllerProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  EventScoringControllerProvider call(
    String eventId,
  ) =>
      EventScoringControllerProvider._(argument: eventId, from: this);

  @override
  String toString() => r'eventScoringControllerProvider';
}

abstract class _$EventScoringController extends $Notifier<ProcessedEventData> {
  late final _$args = ref.$arg as String;
  String get eventId => _$args;

  ProcessedEventData build(
    String eventId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ProcessedEventData, ProcessedEventData>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ProcessedEventData, ProcessedEventData>,
        ProcessedEventData,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
