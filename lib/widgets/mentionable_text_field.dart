import 'package:flutter/material.dart';
import 'package:mentionable_text_field/controllers/mentionable_text_field_controller.dart';

class MentionableTextField extends StatefulWidget {
  const MentionableTextField(
      {super.key,
      this.controller,
      this.maxLines,
      this.decoration,
      this.onSearch,
      this.keyboardType,
      this.onChanged,
      this.focusNode,
      this.enabled});

  final MentionableTextFieldController? controller;
  final InputDecoration? decoration;
  final int? maxLines;
  final void Function(String? query, String? prefix)? onSearch;
  final TextInputType? keyboardType;
  final void Function(String value)? onChanged;
  final FocusNode? focusNode;
  final bool? enabled;

  @override
  State<MentionableTextField> createState() => _MentionableTextFieldState();
}

class _MentionableTextFieldState extends State<MentionableTextField> {
  late MentionableTextFieldController controller;
  int prevValueSize = 0;
  int cursorOffset = 0;

  @override
  initState() {
    super.initState();

    controller = widget.controller ?? MentionableTextFieldController();

    controller.addListener(() {
      final valueSize = controller.text.length;
      final isDeleting = valueSize < prevValueSize;
      var baseSelectionOffset = controller.selection.baseOffset;

      if (valueSize > 0) {
        final mentionMatches = MentionableTextFieldController.mentionRegExp
            .allMatches(controller.text)
            .toList();

        String currentlyBeingEdited = "";
        int charIndex = controller.selection.baseOffset - 1;

        while (!currentlyBeingEdited.contains(RegExp(r"\s|'"))) {
          if (charIndex >= valueSize - 1) {
            currentlyBeingEdited =
                controller.text[valueSize - 1] + currentlyBeingEdited;
          } else {
            currentlyBeingEdited =
                controller.text.substring(charIndex, charIndex + 1) +
                    currentlyBeingEdited;
          }

          charIndex--;

          if (charIndex < 0) break;
        }

        currentlyBeingEdited = currentlyBeingEdited[0] == " "
            ? currentlyBeingEdited.substring(1)
            : currentlyBeingEdited;

        if (currentlyBeingEdited.isNotEmpty) {
          // Mention functionality
          if (["@"].contains(currentlyBeingEdited[0])) {
            int charIndex = controller.selection.baseOffset;

            while (![10, 32].contains(
                currentlyBeingEdited[currentlyBeingEdited.length - 1]
                    .codeUnits[0])) {
              if (charIndex >= valueSize - 1) {
                break;
              } else {
                currentlyBeingEdited +=
                    controller.text.substring(charIndex, charIndex + 1);
              }

              charIndex++;
            }

            controller
              ..prefix = currentlyBeingEdited[0]
              ..findMentionQuery = currentlyBeingEdited
                  .substring(1)
                  .replaceAll(RegExp(r"\s|\n"), "");
          } else {
            controller
              ..prefix = null
              ..findMentionQuery = null;
          }

          if (widget.onSearch != null) {
            widget.onSearch!(controller.findMentionQuery, controller.prefix);
          }

          if (isDeleting && prevValueSize - valueSize <= 2) {
            final cursorOffset = controller.selection.baseOffset;

            for (final match in mentionMatches.reversed) {
              if (cursorOffset >= match.start && cursorOffset <= match.end) {
                final mention =
                    controller.text.substring(match.start, match.end);

                controller.value = TextEditingValue(
                    text: controller.text.replaceAll(mention, " "),
                    selection: TextSelection.collapsed(
                        offset: baseSelectionOffset - mention.length + 1));
                break;
              }
            }
          }

          // Hashtag functionality
          if (currentlyBeingEdited[0] == "#") {
            controller
              ..prefix = "#"
              ..findMentionQuery = currentlyBeingEdited.substring(1);

            if (widget.onSearch != null) {
              widget.onSearch!(controller.findMentionQuery, controller.prefix);
            }
          }
        }
      } else {
        if (widget.onSearch != null) {
          widget.onSearch!(null, null);
        }
      }

      prevValueSize = valueSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
      maxLines: widget.maxLines ?? 1,
      decoration: widget.decoration,
      controller: controller,
    );
  }
}
