import 'package:freezed_annotation/freezed_annotation.dart';

enum HandicapSystem {
  igolf,
  ghin,
  golfIreland,
  golfLink,
  whs,
}

extension HandicapSystemX on HandicapSystem {
  String get idLabel {
    switch (this) {
      case HandicapSystem.igolf:
        return 'IGOLF NO';
      case HandicapSystem.ghin:
        return 'GHIN NO';
      case HandicapSystem.golfIreland:
        return 'GOLF IRELAND ID';
      case HandicapSystem.golfLink:
        return 'GOLF LINK NO';
      case HandicapSystem.whs:
        return 'WHS NUMBER';
    }
  }

  String get shortName {
    switch (this) {
      case HandicapSystem.igolf:
        return 'iGolf';
      case HandicapSystem.ghin:
        return 'GHIN';
      case HandicapSystem.golfIreland:
        return 'Golf Ireland';
      case HandicapSystem.golfLink:
        return 'Golf Link';
      case HandicapSystem.whs:
        return 'WHS';
    }
  }

  String get hintText {
    switch (this) {
      case HandicapSystem.igolf:
        return 'e.g. WHS100046';
      case HandicapSystem.ghin:
        return '7-8 digit GHIN number';
      case HandicapSystem.golfIreland:
        return 'Local ID number';
      case HandicapSystem.golfLink:
        return '10-digit number';
      case HandicapSystem.whs:
        return 'National ID / WHS Number';
    }
  }
}
