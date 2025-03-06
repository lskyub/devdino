import 'package:design_systems/b2b/b2b.dart';
import 'package:design_systems/b2b/components/dropdown/dropdown.style.dart';
import 'package:design_systems/b2b/components/dropdown/dropdown.variant.dart';
import 'package:design_systems/design_systems.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mix/mix.dart';
import 'package:nitrogen_flutter_svg/nitrogen_flutter_svg.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class B2bDropdown extends StatefulWidget {
  final String defaultValue;
  final int selectIndex;
  final List<String> dropdownList;
  String errorText;
  final bool isEnabled;
  final bool isError;
  final int visibleCount;

  B2bDropdown({
    super.key,
    required this.defaultValue,
    required List<String> this.dropdownList,
    this.selectIndex = 0,
    this.errorText = '',
    required this.isEnabled,
    required this.isError,
    this.visibleCount = 3,
  });

  @override
  State<B2bDropdown> createState() => _B2bDropdownState();
}

class _B2bDropdownState extends State<B2bDropdown> {
  /// 드롭박스.
  late final OverlayEntry _overlayEntry =
      OverlayEntry(builder: _overlayEntryBuilder);

  B2bDropdownStyle get $style => B2bDropdownStyle(widget.isEnabled
      ? widget.isError && widget.errorText.isNotEmpty
          ? B2bDropdownStatus.error
          : B2bDropdownStatus.defalut
      : B2bDropdownStatus.disabled);

  final LayerLink _dropdownLink = LayerLink();
  final GlobalKey _dropdownKey = GlobalKey();

  final AutoScrollController _scrollController = AutoScrollController();

  /// 선택값.
  late String dropdownValue;

  late int _selectedIndex;

  late SvgPicture arrowIcon;

  @override
  void initState() {
    super.initState();
    arrowIcon = TAssets.icons.arrowDown.call(
      width: 24,
      height: 24,
      colorFilter: widget.isEnabled
          ? null
          : ColorFilter.mode(
              $b2bToken.color.labelDisabled.resolve(context),
              BlendMode.srcIn,
            ),
    );
    _selectedIndex = widget.selectIndex;
    dropdownValue = widget.dropdownList[_selectedIndex];
  }

  void insertOverlay() {
    if (!_overlayEntry.mounted) {
      OverlayState overlayState = Overlay.of(context);
      overlayState.insert(_overlayEntry);
      _scrollController.scrollToIndex(_selectedIndex);
    }
  }

  void removeOverlay() {
    if (_overlayEntry.mounted) {
      _overlayEntry.remove();
    }
  }

  @override
  void dispose() {
    _overlayEntry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PressableBox(
          key: _dropdownKey,
          enabled: widget.isEnabled,
          onPress: () {
            insertOverlay();
          },
          child: CompositedTransformTarget(
            link: _dropdownLink,
            child: Row(
              children: [
                HBox(
                  style: $style.container(),
                  children: [
                    StyledText(
                      style: $style.label(),
                      dropdownValue,
                    ),
                    arrowIcon,
                  ],
                )
              ],
            ),
          ),
        ),
        if (widget.isError) ...{
          Box(
            style: $style.error(),
            child: StyledText(widget.isEnabled ? widget.errorText : ''),
          )
        }
      ],
    );
  }

  // 드롭다운.
  Widget _overlayEntryBuilder(BuildContext context) {
    Offset position = _getOverlayEntryPosition();
    Size size = _getOverlayEntrySize();

    /// 아이템 박스의 경우 최대 visibleCount개를 노출 하며 visibleCount개 이상일 경우 스크롤이 가능하다.
    var maxSize = widget.dropdownList.length > widget.visibleCount
        ? widget.visibleCount
        : widget.dropdownList.length;

    return Positioned(
      left: position.dx,
      top: position.dy,
      width: size.width,

      /// 드롭다운 박스의 경우 padding 이 16이고 item의 경우 12 이기 때문에 높이차(top + bottom)인 8을 빼고 아이템 박스의 padding(top + bottom)인 16을 더해준다.
      height: (size.height - 8) * maxSize + 16,
      child: CompositedTransformFollower(
        link: _dropdownLink,

        /// 드롭다운 박스의 높이에 border 사이즈가 1이므로 1을 더해준다.
        offset: Offset(0, size.height + 1),
        child: Row(
          children: [
            Box(
              style: $style.dropdownBox().merge(
                    Style(
                      $box.shadow(
                        color: const Color.from(
                            alpha: 0.2, red: 0, green: 0, blue: 0),
                        offset: const Offset(0, 4),
                        blurRadius: 5,
                      ),
                      $box.padding.all(8),
                    ),
                  ),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: widget.dropdownList.length,
                itemBuilder: (context, index) {
                  return AutoScrollTag(
                    key: ValueKey(index),
                    controller: _scrollController,
                    index: index,
                    child: PressableBox(
                      onPress: () {
                        setState(() {
                          _selectedIndex = index;
                          dropdownValue = widget.dropdownList[index];
                          removeOverlay();
                        });
                      },
                      child: Row(
                        children: [
                          HBox(
                            style: $style.dropdownlabel().merge(Style(
                                  $box.borderRadius(6),
                                  index == _selectedIndex
                                      ? $box.color.ref($b2bToken
                                          .color.buttonPrimaryLightEnabled)
                                      : null,
                                )),
                            children: [
                              StyledText(
                                style: $style.label(),
                                widget.dropdownList[index],
                              ),
                              if (index == _selectedIndex) ...{
                                Box(
                                  style: $style.circular(),
                                  child: TAssets.icons.toastCheck.call(),
                                ),
                              }
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Offset _getOverlayEntryPosition() {
    RenderBox? renderBox =
        _dropdownKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return const Offset(0, 0);
    }
    return Offset(renderBox.localToGlobal(Offset.zero).dx,
        renderBox.localToGlobal(Offset.zero).dy + renderBox.size.height);
  }

  Size _getOverlayEntrySize() {
    RenderBox? renderBox =
        _dropdownKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return const Size(0, 0);
    }
    return renderBox.size;
  }
}
