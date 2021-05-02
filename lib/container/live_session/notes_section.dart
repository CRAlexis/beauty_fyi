import 'dart:async';

import 'package:beauty_fyi/container/textfields/default_textarea.dart';
import 'package:beauty_fyi/models/session_model.dart';
import 'package:flutter/material.dart';

class NotesSection extends StatefulWidget {
  final SessionModel sessionModel;
  NotesSection({this.sessionModel});
  @override
  _NotesSectionState createState() => _NotesSectionState();
}

class _NotesSectionState extends State<NotesSection> {
  final TextEditingController textAreaController = TextEditingController();
  String sessionNotesValue = "";
  Timer timer;
  @override
  void dispose() {
    super.dispose();
    widget.sessionModel.setNotes = sessionNotesValue;
    widget.sessionModel.updateSession(widget.sessionModel);
    try {
      timer.cancel();
    } catch (e) {}
  }

  Widget build(BuildContext context) {
    textAreaController.text = widget.sessionModel.notes;
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
              onSaved: (String value) {
                sessionNotesValue = value;
              },
              onChanged: (String value) {
                sessionNotesValue = value;
                try {
                  timer.cancel();
                } catch (e) {}
                timer = new Timer(Duration(seconds: 5), () {
                  widget.sessionModel.setNotes = sessionNotesValue;
                  widget.sessionModel.updateSession(widget.sessionModel);
                });
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
