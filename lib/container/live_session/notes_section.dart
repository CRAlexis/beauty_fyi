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
              hintText: "notes",
              labelText: "",
              textInputType: TextInputType.multiline,
              defaultTextAreaController: textAreaController,
              onSaved: (String? value) {},
              onChanged: (String value) {
                try {
                   context.read(liveSessionNotifierProvider.notifier).updateNotes(
                    value.isNotEmpty ? value : "",
                    widget.sessionModel as SessionModel);
                } catch (e) {
                  print(e);
                }
              },
              disableTextFields: false,
              stylingIndex: 2,
              maxLength: 2500,
              maxLines: null,
            ),
          )),
    );
  }
}
