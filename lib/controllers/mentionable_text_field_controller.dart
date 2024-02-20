import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mentionable_text_field/models/grouped_char_item.dart';

class MentionableTextFieldController extends TextEditingController {
  String? findMentionQuery;
  String? prefix;

  static final mentionRegExp = RegExp(r"@'([a-zA-Z0-9\s]+)('|\s)?");

  static final hashtagRegExp = RegExp(r"#(\S)+");

  static TextSpan textSpanBuilder(
      {required String text,
      TextStyle? style,
      void Function(String label)? onMentionClicked}) {
    final groupedCharactersRaw = <List<int>>[];
    final groupedCharacters = <GroupedCharItem>[];
    final mentionMatches = mentionRegExp.allMatches(text).toList();
    final hashtagMatrches = hashtagRegExp.allMatches(text).toList();
    final highlightedMatches = [...mentionMatches, ...hashtagMatrches];

    highlightedMatches.sort((a, b) {
      return a.start.compareTo(b.start);
    });

    // Separate mentionables from regular texts
    if (highlightedMatches.isNotEmpty) {
      for (int i = 0; i < highlightedMatches.length; i++) {
        final match = highlightedMatches[i];
        var nextCharRange = <int>[0, 0];

        try {
          final nextMatch = highlightedMatches[i + 1];
          nextCharRange = [match.end, nextMatch.start, 0];
        } catch (e) {
          nextCharRange = [match.end, text.length, 0];
        }

        if (i < 1) {
          groupedCharactersRaw.add([0, match.start, 0]);
        }

        groupedCharactersRaw.addAll([
          [match.start, match.end, 1],
          nextCharRange
        ]);
      }
    } else {
      groupedCharactersRaw.add([0, text.length, 0]);
    }

    groupedCharacters.addAll(groupedCharactersRaw.map((e) {
      var trimmedText = text.substring(e[0], e[1]);

      // Mention renderer
      if (trimmedText.isNotEmpty && trimmedText[0] == "@") {
        trimmedText = trimmedText.replaceAll("'", "\u200B");
      }

      return GroupedCharItem(char: trimmedText, isMentioning: e[2] == 1);
    }));

    return TextSpan(
        style: style,
        children: groupedCharacters
            .map(
              (e) => TextSpan(
                  text: e.char,
                  style: e.isMentioning
                      ? TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          backgroundColor: Colors.blue.withOpacity(.1))
                      : style,
                  recognizer: onMentionClicked == null
                      ? null
                      : (TapGestureRecognizer()
                        ..onTap = () => onMentionClicked(e.char))),
            )
            .toList());
  }

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    return textSpanBuilder(text: text, style: style);
  }

  List<String> get mentionedPeople {
    return mentionRegExp
        .allMatches(text)
        .map((e) => text.substring(e.start + 2, e.end - 1))
        .toList();
  }

  void appendMention(String mentionedValue) {
    var val = text;

    if (findMentionQuery == null || findMentionQuery!.isEmpty) {
      final cursorOffset = selection.baseOffset;
      final headChars = text.substring(0, cursorOffset);
      final tailChars = text.substring(cursorOffset);

      val = "$headChars'$mentionedValue' $tailChars";
    } else {
      val = text.replaceAll("@$findMentionQuery", "@'$mentionedValue' ");
    }

    value = TextEditingValue(
        text: val,
        selection: TextSelection.collapsed(
            offset: selection.baseOffset +
                (mentionedValue.length - findMentionQuery!.length).abs() +
                3));
  }
}
