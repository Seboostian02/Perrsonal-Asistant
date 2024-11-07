import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'OPS_KEY')
  static const String opsKey = _Env.opsKey;

  @EnviedField(varName: 'WEATHER_KEY')
  static const String weatherKey = _Env.weatherKey;
  @EnviedField(varName: 'TOM_TOM_KEY')
  static const String tomTomKey = _Env.tomTomKey;
}
