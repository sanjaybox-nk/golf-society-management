// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_play_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CurrentMatchController)
final currentMatchControllerProvider = CurrentMatchControllerFamily._();

final class CurrentMatchControllerProvider
    extends $AsyncNotifierProvider<CurrentMatchController, MatchData?> {
  CurrentMatchControllerProvider._({
    required CurrentMatchControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'currentMatchControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$currentMatchControllerHash();

  @override
  String toString() {
    return r'currentMatchControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CurrentMatchController create() => CurrentMatchController();

  @override
  bool operator ==(Object other) {
    return other is CurrentMatchControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$currentMatchControllerHash() =>
    r'560d184628841e7a07f8435588d82c7b4b57700f';

final class CurrentMatchControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          CurrentMatchController,
          AsyncValue<MatchData?>,
          MatchData?,
          FutureOr<MatchData?>,
          String
        > {
  CurrentMatchControllerFamily._()
    : super(
        retry: null,
        name: r'currentMatchControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CurrentMatchControllerProvider call(String eventId) =>
      CurrentMatchControllerProvider._(argument: eventId, from: this);

  @override
  String toString() => r'currentMatchControllerProvider';
}

abstract class _$CurrentMatchController extends $AsyncNotifier<MatchData?> {
  late final _$args = ref.$arg as String;
  String get eventId => _$args;

  FutureOr<MatchData?> build(String eventId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<MatchData?>, MatchData?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<MatchData?>, MatchData?>,
              AsyncValue<MatchData?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
