import 'package:flutter/material.dart';

class ChangePersonalProfile extends StatefulWidget {
  const ChangePersonalProfile({super.key});

  @override
  _ChangePersonalProfileState createState() => _ChangePersonalProfileState();
}

class _ChangePersonalProfileState extends State<ChangePersonalProfile> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _clearAllTextFields() {
    nameController.clear();
    usernameController.clear();
    phoneController.clear();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width:
                MediaQuery.of(context).size.width * 0.9, // Lebar 90% dari layar
            height:
                MediaQuery.of(context).size.height *
                0.4, 
            padding: EdgeInsets.all(30), 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check,
                  color: Color(0xFF100D40),
                  size: 70, // Ikon lebih besar
                ),
                SizedBox(height: 35), // Jarak lebih besar
                Text(
                  "Change Profile Successfully",
                  style: TextStyle(
                    fontSize: 18, // Teks lebih besar
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 80),
                SizedBox(
                  width: double.infinity,
                  height: 50, // Tombol lebih tinggi
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Menutup dialog
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF100D40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      "Back",
                      style: TextStyle(
                        fontSize: 18, 
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Profile", style: TextStyle(color: Colors.black)),

        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Name",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            Text(
              "Username",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            Text(
              "No Telp",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  _showSuccessDialog();

                  _clearAllTextFields();
                 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF100D40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  "Save",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
