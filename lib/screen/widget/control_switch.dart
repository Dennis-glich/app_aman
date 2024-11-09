import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ControlSwitch extends StatefulWidget {
  final String switchName;
  final bool initialValue;

  ControlSwitch({required this.switchName, required this.initialValue});

  @override
  _ControlSwitchState createState() => _ControlSwitchState();
}

class _ControlSwitchState extends State<ControlSwitch> {
  late bool isOn;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    isOn = widget.initialValue;
  }

  void _updateSwitch(bool value) {
    setState(() {
      isOn = value;
    });
    int dbValue = value ? 1 : 0;
    _database.child('deviceId/control/${widget.switchName}').set(dbValue);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(widget.switchName),
        trailing: Switch(
          value: isOn,
          onChanged: (value) {
            _updateSwitch(value);
          },
        ),
      ),
    );
  }
}
