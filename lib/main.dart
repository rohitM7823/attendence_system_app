import 'dart:developer';

import 'package:attendance_system/core/commons/device_details.dart';
import 'package:attendance_system/data/apis.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'routes/app_router.dart';

List<CameraDescription> cameraDescriptions = [];
String initialRoute = '/';

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  await initialization();
  FlutterNativeSplash.remove();
  runApp(MyApp(
    initialRoute: initialRoute,
  ));
}

Future<void> initialization() async {
  try {
    cameraDescriptions = await availableCameras();
    await DeviceDetails.instance.init();
    /*var isRegistered = await Apis.registerDeviceIfNot();
    bool? isApproved;
    if (isRegistered) {
      isApproved = await Apis.isDeviceApproved();
    }

    initialRoute = isRegistered && isApproved == true ? '/' : '/not_registered';*/
  } catch (Ex) {
    log(Ex.toString(), name: 'INITIALIZATION');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee Attendance',
      theme: AppTheme.lightTheme,
      // onGenerateRoute: generateRoute,
      // initialRoute: widget.initialRoute,
      home: SignInScreenWidget(),
    );
  }
}


class SignInScreenWidget extends StatefulWidget {
  const SignInScreenWidget({super.key});

  @override
  State<SignInScreenWidget> createState() => _SignInScreenWidgetState();
}

class _SignInScreenWidgetState extends State<SignInScreenWidget> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isObscure = true;

  bool get isFilled =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        //title: const Text('Sign In', style: TextStyle(color: Colors.black)),
        //centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back! 👋',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to continue',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF6F6F6),
                hintText: 'Email or Username',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              inputFormatters: [
                //FilteringTextInputFormatter.deny(RegExp(r'[^a-zA-Z0-9@._]')),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: isObscure,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF6F6F6),
                hintText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                      isObscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => isObscure = !isObscure),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              inputFormatters: [
                //LengthLimitingTextInputFormatter(16),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'Forgot Password?',
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isFilled ? () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    return SignUpScreenWidget();
                  },));
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  isFilled ? const Color(0xFF6462E8) : Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Login',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isFilled ? Colors.white : Colors.black54,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text(
                  "Don’t have an account? Sign Up",
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpScreenWidget extends StatefulWidget {
  const SignUpScreenWidget({super.key});

  @override
  State<SignUpScreenWidget> createState() => _SignUpScreenWidgetState();
}

class _SignUpScreenWidgetState extends State<SignUpScreenWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final List<Map<String, String>> _childProfiles = [];

  bool get isFormValid =>
      _formKey.currentState?.validate() == true &&
          _passwordController.text == _confirmPasswordController.text;

  void _showAddChildModal() {
    final childNameController = TextEditingController();
    final childDobController = TextEditingController();
    final childNotesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Child Profile', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: childNameController,
                decoration: const InputDecoration(
                  hintText: 'Child’s Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: childDobController,
                decoration: const InputDecoration(
                  hintText: 'Child’s Age / DOB',
                  prefixIcon: Icon(Icons.cake_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: childNotesController,
                decoration: const InputDecoration(
                  hintText: 'Child’s Health Notes (optional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (childNameController.text.isNotEmpty) {
                      setState(() {
                        _childProfiles.add({
                          'name': childNameController.text,
                          'dob': childDobController.text,
                          'notes': childNotesController.text,
                        });
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add Child'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Sign Up', style: theme.textTheme.titleLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create Account 👋', style: theme.textTheme.displayMedium),
                const SizedBox(height: 8),
                Text('Sign up to get started', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) => value!.isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) => value!.isEmpty ? 'Enter your email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) => value!.length < 6 ? 'Minimum 6 characters' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) => value != _passwordController.text ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 24),
                if (_childProfiles.isNotEmpty) ...[
                  Text('Child Profiles:', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ..._childProfiles.map((child) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.child_care_outlined),
                    title: Text(child['name'] ?? ''),
                    subtitle: Text('${child['dob'] ?? ''}\n${child['notes'] ?? ''}'),
                    isThreeLine: true,
                  )),
                  const SizedBox(height: 16),
                ],
                DottedBorder(
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(12),
                  dashPattern: [6, 3],
                  color: theme.primaryColor,
                  strokeWidth: 1.5,
                  child: InkWell(
                    onTap: _showAddChildModal,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            'Add Another Child',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Skip to use the app solo (13+). Child profiles are for parents only.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isFormValid ? () {} : null,
                    child: const Text('Create Account'),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Already have an account? Sign In'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppTheme {
  // Core Colors
  static const Color primaryColor = Color(0xFF6462E8);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFF7F7F9);
  static const Color textColor = Color(0xFF111111);
  static const Color secondaryTextColor = Color(0xFF888888);
  static const Color iconColor = Color(0xFF333333);
  static const Color dividerColor = Color(0xFFE6E6E6);
  static const Color alertColor = Color(0xFFFFD9C0);
  static const Color alertTextColor = Color(0xFFEE6A00);

  // Themed Button Background Colors
  static const Color painColor = Color(0xFFFFE2E2);
  static const Color moodColor = Color(0xFFFFF6C5);
  static const Color hydrationColor = Color(0xFFE3F1FF);
  static const Color calendarColor = Color(0xFFF2EAFF);

  // Themed Button Icon Colors
  static const Color painIconColor = Color(0xFFE94949);
  static const Color moodIconColor = Color(0xFFE0B100);
  static const Color hydrationIconColor = Color(0xFF4A90E2);
  static const Color calendarIconColor = Color(0xFF9966FF);

  // Radius for cards and inputs
  static const double cardRadius = 12.0;

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    dividerColor: dividerColor,
    fontFamily: GoogleFonts.inter().fontFamily,

    textTheme: TextTheme(
      displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: textColor),
      displayMedium: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
      titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
      titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: textColor),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: secondaryTextColor),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        borderSide: BorderSide(color: dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        borderSide: BorderSide(color: dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        borderSide: BorderSide(color: primaryColor),
      ),
      hintStyle: GoogleFonts.inter(fontSize: 14, color: secondaryTextColor),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),

    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      color: surfaceColor,
      elevation: 0,
    ),

    iconTheme: const IconThemeData(color: iconColor),

    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      background: backgroundColor,
      surface: surfaceColor,
      error: Colors.redAccent,
    ),
  );
}
