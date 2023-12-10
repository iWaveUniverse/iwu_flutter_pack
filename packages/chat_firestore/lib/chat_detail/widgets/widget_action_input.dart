import 'package:_private_core/_private_core.dart';
import 'package:flutter/material.dart';
import 'package:_private_core/widgets/widgets.dart';

import 'package:flutter/services.dart';

import 'package:_iwu_pack_chat_firestore/_iwu_pack_chat_firestore.dart';

class WidgetActionsInput extends StatefulWidget {
  final Widget child;
  const WidgetActionsInput({Key? key, required this.child}) : super(key: key);

  @override
  State<WidgetActionsInput> createState() => _WidgetActionsInputState();
}

class _WidgetActionsInputState extends State<WidgetActionsInput> {
  double get widthButton => 140;
  TextEditingController get inputController => chatDetailBloc.inputController;

  @override
  Widget build(BuildContext context) {
    return WidgetOverlayActions(
      gestureType: GestureType.rightClick,
      builder: (child, size, childPosition, pointerPosition, animationValue,
          hide, context) {
        if (MediaQuery.sizeOf(context).width <
            pointerPosition!.dx + widthButton * 1.05) {
          return Positioned(
            bottom: MediaQuery.sizeOf(context).height - pointerPosition.dy + 4,
            right: 24,
            child: Transform.scale(
                scale: animationValue,
                alignment: Alignment.bottomCenter,
                child: _buildActions(hide)),
          );
        } else {
          return Positioned(
            bottom: MediaQuery.sizeOf(context).height - pointerPosition.dy + 4,
            left: pointerPosition.dx - widthButton / 3 < 20
                ? 20
                : pointerPosition.dx - widthButton / 3,
            child: Transform.scale(
                scale: animationValue,
                alignment: Alignment.bottomCenter,
                child: _buildActions(hide)),
          );
        }
      },
      child: widget.child,
    );
  }

  Widget _buildActions(hide) => Container(
        width: widthButton,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: appColors.appBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: appBoxShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildButton(
              index: 0,
              onTap: () {
                hide();
                if (chatDetailBloc.textSelectedInTextField.isNotEmpty) {
                  Clipboard.setData(ClipboardData(
                      text: chatDetailBloc.textSelectedInTextField));
                }
              },
              icon: Icons.copy,
              label: appTranslateText('Copy'),
            )
                .opacity(
                    chatDetailBloc.textSelectedInTextField.isNotEmpty ? 1 : .1)
                .ignore(!chatDetailBloc.textSelectedInTextField.isNotEmpty),
            _buildButton(
              index: 1,
              onTap: () {
                hide();
                if (chatDetailBloc.textSelectedInTextField.isNotEmpty) {
                  Clipboard.setData(ClipboardData(
                      text: chatDetailBloc.textSelectedInTextField));
                  chatDetailBloc.add(ChatDetailPastTextInputEvent(
                      inputController.text.replaceRange(
                          inputController.selection.start,
                          inputController.selection.end,
                          '')));
                }
              },
              icon: Icons.cut,
              label: appTranslateText('Cut'),
            )
                .opacity(
                    chatDetailBloc.textSelectedInTextField.isNotEmpty ? 1 : .1)
                .ignore(!chatDetailBloc.textSelectedInTextField.isNotEmpty),
            FutureBuilder<ClipboardData?>(
                future: Clipboard.getData('text/plain'),
                builder: (_, snapshot) {
                  bool enable = snapshot.data != null;
                  return _buildButton(
                    index: 2,
                    onTap: () {
                      hide();
                      chatDetailBloc.add(
                          ChatDetailPastTextInputEvent(snapshot.data!.text));
                    },
                    icon: Icons.paste,
                    label: appTranslateText('Past'),
                  ).opacity(enable ? 1 : .1).ignore(!enable);
                })
          ],
        ),
      );

  Widget _buildButton(
      {required index, required onTap, required label, required icon}) {
    return WidgetAnimationStaggeredItem(
      duration: const Duration(milliseconds: 250),
      index: index + 1,
      type: AnimationStaggeredType.leftToRight,
      child: WidgetInkWellTransparent(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$label',
                  style: w500TextStyle(
                    color: appColors.text.withOpacity(0.9),
                  ),
                ),
              ),
              Icon(
                icon,
                color: appColors.text.withOpacity(0.85),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

get appBoxShadow => [
      BoxShadow(
        color: appColors.text.withOpacity(0.06),
        blurRadius: 4,
        spreadRadius: 0,
      )
    ];
