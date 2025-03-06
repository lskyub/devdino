import 'package:design_systems/b2b/b2b.dart';
import 'package:design_systems/b2b/components/text/text.variant.dart';
import 'package:mix/mix.dart';

class B2bTextStyle {
  B2bTextStyle(this.weight);

  final B2bTextWeight weight;

  Style style(B2bTextType type) {
    Iterable<Attribute> typeStype = [];
    switch (type) {
      case B2bTextType.display:
        typeStype = display();
        break;
      case B2bTextType.headerline1:
        typeStype = headerline1();
        break;
      case B2bTextType.headerline2:
        typeStype = headerline2();
        break;
      case B2bTextType.title1:
        typeStype = title1();
        break;
      case B2bTextType.title2:
        typeStype = title2();
        break;
      case B2bTextType.title3:
        typeStype = title3();
        break;
      case B2bTextType.body1:
        typeStype = body1();
        break;
      case B2bTextType.body2:
        typeStype = body2();
        break;
      case B2bTextType.body3:
        typeStype = body3();
        break;
      case B2bTextType.body4:
        typeStype = body4();
        break;
      case B2bTextType.caption1:
        typeStype = caption1();
        break;
      case B2bTextType.caption2:
        typeStype = caption2();
        break;
    }
    return Style().addAll(typeStype)
        .applyVariants([weight]);
  }

  Iterable<Attribute> display() {
    return [
      B2bTextWeight.bold(
        $text.style.ref(
          $b2bToken.textStyle.displaybold,
        ),
      ),
      B2bTextWeight.medium(
        $text.style.ref(
          $b2bToken.textStyle.displaymedium,
        ),
      ),
      B2bTextWeight.regular(
        $text.style.ref(
          $b2bToken.textStyle.displayregular,
        ),
      ),
    ];
  }

  Iterable<Attribute> headerline1() {
    return [
      B2bTextWeight.bold(
        $text.style.ref(
          $b2bToken.textStyle.headline1bold,
        ),
      ),
      B2bTextWeight.medium(
        $text.style.ref(
          $b2bToken.textStyle.headline1medium,
        ),
      ),
      B2bTextWeight.regular(
        $text.style.ref(
          $b2bToken.textStyle.headline1regular,
        ),
      ),
    ];
  }

  Iterable<Attribute> headerline2() {
    return [
      B2bTextWeight.bold(
        $text.style.ref(
          $b2bToken.textStyle.headline2bold,
        ),
      ),
      B2bTextWeight.medium(
        $text.style.ref(
          $b2bToken.textStyle.headline2medium,
        ),
      ),
      B2bTextWeight.regular(
        $text.style.ref(
          $b2bToken.textStyle.headline2regular,
        ),
      ),
    ];
  }

  Iterable<Attribute> title1() {
    return [
      B2bTextWeight.bold(
        $text.style.ref(
          $b2bToken.textStyle.title1bold,
        ),
      ),
      B2bTextWeight.medium(
        $text.style.ref(
          $b2bToken.textStyle.title1medium,
        ),
      ),
      B2bTextWeight.regular(
        $text.style.ref(
          $b2bToken.textStyle.title1regular,
        ),
      ),
    ];
  }

  Iterable<Attribute> title2() {
    return [
      B2bTextWeight.bold(
        $text.style.ref(
          $b2bToken.textStyle.title2bold,
        ),
      ),
      B2bTextWeight.medium(
        $text.style.ref(
          $b2bToken.textStyle.title2medium,
        ),
      ),
      B2bTextWeight.regular(
        $text.style.ref(
          $b2bToken.textStyle.title2regular,
        ),
      ),
    ];
  }

  Iterable<Attribute> title3() {
    return [
      B2bTextWeight.bold(
        $text.style.ref(
          $b2bToken.textStyle.title3bold,
        ),
      ),
      B2bTextWeight.medium(
        $text.style.ref(
          $b2bToken.textStyle.title3medium,
        ),
      ),
      B2bTextWeight.regular(
        $text.style.ref(
          $b2bToken.textStyle.title3regular,
        ),
      ),
    ];
  }

  Iterable<Attribute> body1() {
    return [
      B2bTextWeight.bold(
        $text.style.ref(
          $b2bToken.textStyle.body1bold,
        ),
      ),
      B2bTextWeight.medium(
        $text.style.ref(
          $b2bToken.textStyle.body1medium,
        ),
      ),
      B2bTextWeight.regular(
        $text.style.ref(
          $b2bToken.textStyle.body1regular,
        ),
      ),
    ];
  }

  Iterable<Attribute> body2() {
    return [
      B2bTextWeight.bold(
        $text.style.ref(
          $b2bToken.textStyle.body2bold,
        ),
      ),
      B2bTextWeight.medium(
        $text.style.ref(
          $b2bToken.textStyle.body2medium,
        ),
      ),
      B2bTextWeight.regular(
        $text.style.ref(
          $b2bToken.textStyle.body2regular,
        ),
      ),
    ];
  }

  Iterable<Attribute> body3() {
    return [
      B2bTextWeight.bold(
        $text.style.ref(
          $b2bToken.textStyle.body3bold,
        ),
      ),
      B2bTextWeight.medium(
        $text.style.ref(
          $b2bToken.textStyle.body3medium,
        ),
      ),
      B2bTextWeight.regular(
        $text.style.ref(
          $b2bToken.textStyle.body3regular,
        ),
      ),
    ];
  }

  Iterable<Attribute> body4() {
    return [
      B2bTextWeight.bold(
        $text.style.ref(
          $b2bToken.textStyle.body4bold,
        ),
      ),
      B2bTextWeight.medium(
        $text.style.ref(
          $b2bToken.textStyle.body4medium,
        ),
      ),
      B2bTextWeight.regular(
        $text.style.ref(
          $b2bToken.textStyle.body4regular,
        ),
      ),
    ];
  }

  Iterable<Attribute> caption1() {
    return [
      B2bTextWeight.bold(
        $text.style.ref(
          $b2bToken.textStyle.caption1bold,
        ),
      ),
      B2bTextWeight.medium(
        $text.style.ref(
          $b2bToken.textStyle.caption1medium,
        ),
      ),
      B2bTextWeight.regular(
        $text.style.ref(
          $b2bToken.textStyle.caption1regular,
        ),
      ),
    ];
  }

  Iterable<Attribute> caption2() {
    return [
      B2bTextWeight.bold(
        $text.style.ref(
          $b2bToken.textStyle.caption2bold,
        ),
      ),
      B2bTextWeight.medium(
        $text.style.ref(
          $b2bToken.textStyle.caption2medium,
        ),
      ),
      B2bTextWeight.regular(
        $text.style.ref(
          $b2bToken.textStyle.caption2regular,
        ),
      ),
    ];
  }
}
