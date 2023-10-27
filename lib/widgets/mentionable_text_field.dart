import 'dart:ffi';

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
      this.onChanged});

  final MentionableTextFieldController? controller;
  final InputDecoration? decoration;
  final int? maxLines;
  final void Function(String? query)? onSearch;
  final TextInputType? keyboardType;
  final void Function(String value)? onChanged;

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

        currentlyBeingEdited = currentlyBeingEdited.substring(1);

        if (currentlyBeingEdited.isNotEmpty && currentlyBeingEdited[0] == "@") {
          int charIndex = controller.selection.baseOffset;

          while (currentlyBeingEdited[currentlyBeingEdited.length - 1] != " ") {
            if (charIndex >= valueSize - 1) {
              break;
            } else {
              currentlyBeingEdited +=
                  controller.text.substring(charIndex, charIndex + 1);
            }

            charIndex++;
          }

          controller.findMentionQuery = currentlyBeingEdited.substring(1);
        } else {
          controller.findMentionQuery = null;
        }

        if (widget.onSearch != null) {
          widget.onSearch!(controller.findMentionQuery);
        }

        if (isDeleting && prevValueSize - valueSize <= 2) {
          final cursorOffset = controller.selection.baseOffset;

          for (final match in mentionMatches.reversed) {
            if (cursorOffset >= match.start && cursorOffset <= match.end) {
              final mention = controller.text.substring(match.start, match.end);

              controller.value = TextEditingValue(
                  text: controller.text.replaceAll(mention, " "),
                  selection: TextSelection.collapsed(
                      offset: baseSelectionOffset - mention.length + 1));
              break;
            }
          }
        }
      }

      prevValueSize = valueSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
      maxLines: widget.maxLines ?? 1,
      decoration: widget.decoration,
      controller: controller,
    );
  }
}
