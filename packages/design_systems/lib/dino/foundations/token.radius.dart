import 'package:mix/mix.dart';

class DinoRadiusToken {
  const DinoRadiusToken();
  RadiusToken get none => const RadiusToken('none');
  RadiusToken get xxsmall => const RadiusToken('xxsmall');
  RadiusToken get xsmall => const RadiusToken('xsmall');
  RadiusToken get small => const RadiusToken('small');
  RadiusToken get medium => const RadiusToken('medium');
  RadiusToken get large => const RadiusToken('large');
  RadiusToken get xlarge => const RadiusToken('xlarge');
  RadiusToken get xxlarge => const RadiusToken('xxlarge');
  RadiusToken get circle => const RadiusToken('circle');
}