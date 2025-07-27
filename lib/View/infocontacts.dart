import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class NotifyContactsScreen extends StatefulWidget {
  @override
  _NotifyContactsScreenState createState() => _NotifyContactsScreenState();
}

class _NotifyContactsScreenState extends State<NotifyContactsScreen> {
  List<Contact> _contacts = [];
  Set<Contact> _selectedContacts = Set();

  bool _loading = false;
  static const platform = MethodChannel('sms_channel');


  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    setState(() => _loading = true);

    // Ask both permissions
    var contactsStatus = await Permission.contacts.status;
    var smsStatus = await Permission.sms.status;

    if (!contactsStatus.isGranted || !smsStatus.isGranted) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.contacts,
        Permission.sms,
      ].request();

      if (!statuses[Permission.contacts]!.isGranted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Contacts permission denied. Please allow from Settings.'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
        return;
      }

      if (!statuses[Permission.sms]!.isGranted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SMS permission denied.'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
        return;
      }
    }

    try {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      print("Raw contact count: ${contacts.length}");
      for (final c in contacts) {
        print("${c.displayName} - ${c.phones.isNotEmpty ? c.phones.first.number : 'No number'}");
      }

      final filtered = contacts.where((c) =>   c.phones.isNotEmpty &&
          c.phones.any((p) => p.number.trim().isNotEmpty)
      ).toList();

      if (filtered.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No contacts with phone numbers found.')),
        );
      }

      setState(() {
        _contacts = filtered;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load contacts.')),
      );
    }
  }


  Future<void> _sendAlerts() async {
    bool consent = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send Alert?'),
        content: Text(
            'This will send an SMS to your selected contacts. Proceed?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Continue')),
        ],
      ),
    );
    if (!consent) return;

    // 2. Request SMS permission

    // 3. Get phone numbers
    List<String> phoneNumbers = _selectedContacts
        .expand((c) => c.phones)
        .map((p) => p.number )
        .where((n) => n.isNotEmpty)
        .toList();

    if (phoneNumbers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select at least one contact.')));
      return;
    }
    setState(() => _loading = true);


    // 4. Send SMS
    String message =
        "I have tested positive for COVID-19. Please take precautions and get tested if needed.";


    for (final number in phoneNumbers) {
      try {
        final result = await platform.invokeMethod('sendSms', {
          'number': number,
          'message': message,
        });
        print('✅ SMS sent to $number: $result');
        await Future.delayed(Duration(milliseconds: 400)); // optional
      } on PlatformException catch (e) {
        print('❌ Failed to send SMS to $number: ${e.message}');
      }
    }

    setState(() => _loading = false);


    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Alert sent to selected contacts!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notify Contacts"),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: _contacts.isEmpty
                ? Center(child: Text("No contacts found."))
                : ListView.builder(
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                final isSelected = _selectedContacts.contains(contact);
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      contact.displayName != null && contact.displayName!.isNotEmpty
                          ? contact.displayName![0]
                          : '?',
                    ),
                  ),
                  title: Text(contact.displayName ?? ''),
                  subtitle: Text(contact.phones.isNotEmpty
                      ? contact.phones!.first.number ?? ''
                      : ''),
                  trailing: Checkbox(
                    value: isSelected,
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedContacts.add(contact);
                        } else {
                          _selectedContacts.remove(contact);
                        }
                      });
                    },
                  ),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedContacts.remove(contact);
                      } else {
                        _selectedContacts.add(contact);
                      }
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              icon: Icon(Icons.sms),
              label: Text("Send Alert"),
              onPressed: _selectedContacts.isEmpty ? null : _sendAlerts,
            ),
          )
        ],
      ),
    );
  }
}