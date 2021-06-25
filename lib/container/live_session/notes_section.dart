import 'dart:async';

import 'package:beauty_fyi/container/textfields/default_textarea.dart';
import 'package:beauty_fyi/models/session_model.dart';
import 'package:beauty_fyi/providers/liveSession/live_session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final liveSessionNotifierProvider =
    StateNotifierProvider((ref) => LiveSessionNotifier(null));

class NotesSection extends StatefulWidget {
  final SessionModel? sessionModel;
  NotesSection({this.sessionModel});
  @override
  _NotesSectionState createState() => _NotesSectionState();
}

class _NotesSectionState extends State<NotesSection> {
  final TextEditingController textAreaController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    textAreaController.text = widget.sessionModel!.notes!;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Container(
            child: DefaultTextArea(
              iconData: null,
              hintText: "Session notes",
              invalidMessage: "Invalid name",
              labelText: "",
              textInputType: TextInputType.name,
              defaultTextAreaController: textAreaController,
              onSaved: (String? value) {},
              onChanged: (String value) {
                context
                    .read(liveSessionNotifierProvider.notifier)
                    .updateNotes(value);
              },
              disableTextFields: false,
              stylingIndex: 1,
              maxLength: 2500,
              maxLines: null,
            ),
          )),
    );
  }
}
