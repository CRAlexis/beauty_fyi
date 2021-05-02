import 'package:beauty_fyi/container/alert_dialoges/message_alert_dialog.dart';
import 'package:beauty_fyi/container/textfields/default_textfield.dart';
import 'package:beauty_fyi/models/client_model.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';

class ClientsTab extends StatefulWidget {
  @override
  _ClientsTabState createState() => _ClientsTabState();
}

class _ClientsTabState extends State<ClientsTab> {
  Future<List<ClientModel>> clients;

  void initState() {
    super.initState();
    refreshFuture();
  }

  void refreshFuture() async {
    clients = fetchClients();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                // colorStyles['blue'],
                colorStyles['cream'],
                colorStyles['cream'],
              ]))),
      Container(
          height: double.infinity,
          child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 20.0,
              ),
              child: Column(children: [
                FutureBuilder<List<ClientModel>>(
                    future: clients,
                    builder: (context, clients) {
                      print("refreshing future");
                      if (clients.connectionState == ConnectionState.none ||
                          !clients.hasData) {
                        return Align(
                          alignment: Alignment.center,
                          child: Text("Unable to load clients."),
                        );
                      }
                      return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: clients.data.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, 'client-screen',
                                    arguments: {
                                      'clientId': clients.data[index].clientId,
                                      'clientName':
                                          clients.data[index].clientName
                                    });
                                // var addClientAAlertDialog;
                                /*  addClientAAlertDialog = AddClientAlertDialog(
                                    context: context,
                                    clientName: clients.data[index].clientName,
                                    leftButtonText: "DELETE",
                                    rightButtonText: "SAVE",
                                    onLeftButton: () {
                                      addClientAAlertDialog.pop();
                                      final clientModal = ClientModel(
                                        clientId: clients.data[index].clientId,
                                      );
                                      clientModal.deleteClient().then((value) {
                                        if (value) {
                                          MessageAlertDialog(
                                              context: context,
                                              message:
                                                  "Successfully deleted client",
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              });
                                        } else {
                                          MessageAlertDialog(
                                              context: context,
                                              message:
                                                  "Unable to delete client",
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              });
                                        }
                                      }).onError((error, stackTrace) {
                                        print(error);
                                        MessageAlertDialog(
                                            context: context,
                                            message: "Unable to delete client",
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            });
                                      });
                                      refreshFuture();
                                      setState(() {});
                                    },
                                    onRightButton: (String clientNameValue) {
                                      //Change this to update
                                      addClientAAlertDialog.pop();
                                      final clientModal = ClientModel(
                                          clientId:
                                              clients.data[index].clientId,
                                          clientName: clientNameValue);
                                      clientModal
                                          .updateClient(clientModal)
                                          .then((value) {
                                        if (value) {
                                          MessageAlertDialog(
                                              context: context,
                                              message:
                                                  "Successfully updated client",
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              });
                                        } else {
                                          MessageAlertDialog(
                                              context: context,
                                              message:
                                                  "Unable to update client",
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              });
                                        }
                                      }).onError((error, stackTrace) {
                                        print(error);
                                        MessageAlertDialog(
                                            context: context,
                                            message: "Unable to update client",
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            });
                                      });
                                      refreshFuture();
                                      setState(() {});
                                    });

                                addClientAAlertDialog.show();*/
                              },
                              child: Card(
                                elevation: 4,
                                child: Container(
                                  height: 80,
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: CircleAvatar(
                                          radius: 35,
                                          foregroundColor: colorStyles['green'],
                                          backgroundColor: Colors.white,
                                          child: Icon(
                                            Icons.person,
                                            size: 45,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        clients.data[index].clientName,
                                        style: TextStyle(
                                            fontFamily: 'OpenSans',
                                            fontSize: 20),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          });
                    }),
                SizedBox(
                  height: 20,
                ),
                Container(
                    child: TextButton(
                        onPressed: () {
                          var addClientAAlertDialog;
                          addClientAAlertDialog = AddClientAlertDialog(
                              context: context,
                              leftButtonText: "CANCEL",
                              rightButtonText: "SAVE",
                              onLeftButton: () {
                                refreshFuture();
                                setState(() {});
                                Navigator.pop(context);
                              },
                              onRightButton: (String clientNameValue) {
                                addClientAAlertDialog.pop();
                                final clientModal =
                                    ClientModel(clientName: clientNameValue);
                                clientModal
                                    .insertClient(clientModal)
                                    .then((value) {
                                  if (value) {
                                    MessageAlertDialog(
                                        context: context,
                                        message: "Successfully created client",
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        });
                                  } else {
                                    MessageAlertDialog(
                                        context: context,
                                        message: "Unable to create client",
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        });
                                  }
                                }).onError((error, stackTrace) {
                                  print(error);
                                  MessageAlertDialog(
                                      context: context,
                                      message: "Unable to create client",
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      });
                                });
                                refreshFuture();
                                setState(() {});
                              });

                          addClientAAlertDialog.show();
                        },
                        child: Icon(
                          Icons.add,
                          size: 40,
                        )))
              ])))
    ]);
  }
}

class AddClientAlertDialog {
  final String leftButtonText;
  final String rightButtonText;
  final String clientName;
  final onLeftButton;
  final onRightButton;
  final BuildContext context;
  const AddClientAlertDialog(
      {Key key,
      this.leftButtonText,
      this.rightButtonText,
      this.onLeftButton,
      this.onRightButton,
      this.context,
      this.clientName = ""});

  Future<void> show() async {
    final createClientForm = GlobalKey<FormState>();
    final clientNameTextFieldController = TextEditingController();
    clientNameTextFieldController.text = this.clientName;
    String clientNameValue = this.clientName;
    bool disableTextFields = false;
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              height: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Add a new client",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'OpenSans'),
                    textAlign: TextAlign.center,
                  ),
                  Form(
                    key: createClientForm,
                    child: DefaultTextField(
                      iconData: null,
                      hintText: "Client name",
                      invalidMessage: "Invalid name",
                      labelText: "",
                      textInputType: TextInputType.name,
                      defaultTextFieldController: clientNameTextFieldController,
                      disableTextFields: disableTextFields,
                      onSaved: (String value) {
                        clientNameValue = value;
                      },
                      onChanged: (String value) {
                        clientNameValue = value;
                      },
                      stylingIndex: 1,
                      regex: r'^[a-zA-Z ]+$',
                      height: 40,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  child: Text(leftButtonText),
                  onPressed: () {
                    onLeftButton();
                  }),
              TextButton(
                  child: Text(rightButtonText),
                  onPressed: () {
                    onRightButton(clientNameValue);
                  }),
            ],
          );
        });
  }

  pop() {
    Navigator.of(context).pop();
  }
}

Future<List<ClientModel>> fetchClients() async {
  print("collecting clients data");
  return await ClientModel().readClients();
}
