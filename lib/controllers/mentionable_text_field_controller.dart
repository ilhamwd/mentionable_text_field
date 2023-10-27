import 'package:flutter/material.dart';
import 'package:mentionable_text_field/models/grouped_char_item.dart';

class MentionableTextFieldController extends TextEditingController {
  String? findMentionQuery;

  static final mentionRegExp = RegExp(r"@'([a-zA-Z0-9\s]+)('|\s)?");

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    final groupedCharacters = <GroupedCharItem>[];
    final text = value.text;
    final mentionMatches = mentionRegExp.allMatches(value.text).toList();

    if (mentionMatches.isNotEmpty) {
      groupedCharacters.add(
          GroupedCharItem(char: text.substring(0, mentionMatches.first.start)));

      for (int i = 0; i < mentionMatches.length; i++) {
        final match = mentionMatches[i];
        RegExpMatch? nextMatch;

        try {
          nextMatch = mentionMatches[i + 1];
        } catch (e) {
          nextMatch = null;
        }

        groupedCharacters.add(GroupedCharItem(
            char: text
                .substring(match.start, match.end)
                .replaceAll("'", "\u200B"),
            isMentioning: true));
        groupedCharacters.add(
            GroupedCharItem(char: text.substring(match.end, nextMatch?.start)));
      }
    } else {
      groupedCharacters.add(GroupedCharItem(char: text));
    }

    return TextSpan(
        style: style,
        children: groupedCharacters
            .map((e) => TextSpan(
                text: e.char,
                style: e.isMentioning
                    ? TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        backgroundColor: Colors.blue.withOpacity(.1))
                    : style))
            .toList());
  }

  List<String> get mentionedPeople {
    return mentionRegExp
        .allMatches(text)
        .map((e) => text.substring(e.start + 2, e.end - 1))
        .toList();
  }

  void appendMention(String mentionedValue) {
    value = TextEditingValue(
        text: text.replaceAll("@$findMentionQuery", "@'$mentionedValue' "),
        selection: TextSelection.collapsed(
            offset: selection.baseOffset +
                (mentionedValue.length - findMentionQuery!.length).abs() +
                3));
  }
}
