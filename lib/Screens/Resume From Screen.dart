// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter/foundation.dart';
//
// class ResumeFormScreen extends StatefulWidget {
//   @override
//   _ResumeFormScreenState createState() => _ResumeFormScreenState();
// }
//
// class _ResumeFormScreenState extends State<ResumeFormScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref('resumes');
//   final ImagePicker _imagePicker = ImagePicker();
//
//   // Form controllers
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _contactController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _fatherController = TextEditingController();
//   final TextEditingController _cnicController = TextEditingController();
//   final TextEditingController _dobController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _objectiveController = TextEditingController(
//     text: 'To work in a dynamic professional environment with a growing organization and utilize my creativity and innovative thinking for benefit of the organization and myself.',
//   );
//   final TextEditingController _referenceController = TextEditingController(
//     text: 'Will be furnished on demand.',
//   );
//
//   // Dynamic lists
//   List<TextEditingController> _languageControllers = [TextEditingController()];
//   List<TextEditingController> _skillControllers = [TextEditingController()];
//   List<Experience> _experiences = [Experience()];
//   List<Education> _education = [
//     Education(
//       qualification: '',
//       institution: '',
//       details: '',
//     ),
//   ];
//
//   // Selection values
//   String? _status = 'Single';
//   String? _religion = 'Islam';
//   String? _gender = 'Male';
//   bool _isFresher = false;
//   Uint8List? _imageBytes;
//   String? _base64Image;
//
//   @override
//   void dispose() {
//     // Dispose all controllers
//     _nameController.dispose();
//     _contactController.dispose();
//     _emailController.dispose();
//     _fatherController.dispose();
//     _cnicController.dispose();
//     _dobController.dispose();
//     _addressController.dispose();
//     _objectiveController.dispose();
//     _referenceController.dispose();
//
//     for (var controller in _languageControllers) {
//       controller.dispose();
//     }
//
//     for (var controller in _skillControllers) {
//       controller.dispose();
//     }
//
//     for (var exp in _experiences) {
//       exp.dispose();
//     }
//
//     for (var edu in _education) {
//       edu.dispose();
//     }
//
//     super.dispose();
//   }
//
//   Future<void> _saveResume() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     try {
//       // Prepare data for Firebase
//       final resumeData = {
//         'photo': _base64Image,
//         'name': _nameController.text,
//         'contact': _contactController.text,
//         'email': _emailController.text,
//         'personalInfo': {
//           'fatherName': _fatherController.text,
//           'cnic': _cnicController.text,
//           'dob': _dobController.text,
//           'status': _status,
//           'religion': _religion,
//           'gender': _gender,
//           'address': _addressController.text,
//         },
//         'languages': _languageControllers.map((c) => c.text).toList(),
//         'skills': _skillControllers.map((c) => c.text).toList(),
//         'objective': _objectiveController.text,
//         'experiences': _experiences.map((e) => {
//           'position': e.positionController.text,
//           'company': e.companyController.text,
//           'period': e.periodController.text,
//         }).toList(),
//         'education': _education.map((e) => {
//           'qualification': e.qualificationController.text,
//           'year': e.yearController.text,
//           'institution': e.institutionController.text,
//           'details': e.detailsController.text,
//         }).toList(),
//         'reference': _referenceController.text,
//         'isFresher': _isFresher,
//         'createdAt': ServerValue.timestamp,
//       };
//
//       await _databaseRef.push().set(resumeData);
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Resume saved successfully!'),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to save resume: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: Theme.of(context).primaryColor,
//               onPrimary: Colors.white,
//               onSurface: Colors.black,
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: Theme.of(context).primaryColor,
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (picked != null) {
//       setState(() {
//         _dobController.text = DateFormat('dd-MM-yyyy').format(picked);
//       });
//     }
//   }
//
//   ImageProvider? _getBackgroundImage() {
//     if (_imageBytes != null) return MemoryImage(_imageBytes!);
//     if (_base64Image != null) {
//       try {
//         return MemoryImage(base64Decode(_base64Image!));
//       } catch (e) {
//         print('Error decoding base64 image: $e');
//         return null;
//       }
//     }
//     return null;
//   }
//
//   Future<void> _pickImage() async {
//     try {
//       final XFile? pickedFile = await _imagePicker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 500,
//         maxHeight: 500,
//         imageQuality: 90,
//       );
//
//       if (pickedFile != null) {
//         final bytes = await pickedFile.readAsBytes();
//         setState(() {
//           _imageBytes = bytes;
//           _base64Image = base64Encode(bytes);
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error picking image: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       debugPrint('Image picker error: $e');
//     }
//   }
//
//   Future<void> _takePhoto() async {
//     try {
//       final XFile? pickedFile = await _imagePicker.pickImage(
//         source: ImageSource.camera,
//         maxWidth: 500,
//         maxHeight: 500,
//         imageQuality: 90,
//       );
//
//       if (pickedFile != null) {
//         final bytes = await pickedFile.readAsBytes();
//         setState(() {
//           _imageBytes = bytes;
//           _base64Image = base64Encode(bytes);
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error taking photo: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       debugPrint('Camera error: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Professional Resume Builder',
//             style: TextStyle(fontWeight: FontWeight.w600)),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.save, color: Colors.white),
//             onPressed: _saveResume,
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Profile Photo Section
//               Center(
//                 child: Column(
//                   children: [
//                     Stack(
//                       alignment: Alignment.bottomRight,
//                       children: [
//                         Container(
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                               color: Theme.of(context).primaryColor,
//                               width: 3,
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.1),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 4),
//                               )
//                             ],
//                           ),
//                           child: CircleAvatar(
//                             radius: 70,
//                             backgroundColor: Colors.grey[200],
//                             backgroundImage: _getBackgroundImage(),
//                             child: _imageBytes == null && _base64Image == null
//                                 ? const Icon(Icons.person, size: 60, color: Colors.grey)
//                                 : null,
//                           ),
//                         ),
//                         Container(
//                           decoration: BoxDecoration(
//                             color: Theme.of(context).primaryColor,
//                             shape: BoxShape.circle,
//                             border: Border.all(color: Colors.white, width: 2),
//                           ),
//                           child: IconButton(
//                             icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
//                             onPressed: () {
//                               if (kIsWeb) {
//                                 _pickImage();
//                               } else {
//                                 showModalBottomSheet(
//                                   context: context,
//                                   builder: (context) => Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       ListTile(
//                                         leading: const Icon(Icons.photo_library),
//                                         title: const Text('Choose from gallery'),
//                                         onTap: () {
//                                           Navigator.pop(context);
//                                           _pickImage();
//                                         },
//                                       ),
//                                       if (!kIsWeb)
//                                         ListTile(
//                                           leading: const Icon(Icons.camera_alt),
//                                           title: const Text('Take a photo'),
//                                           onTap: () {
//                                             Navigator.pop(context);
//                                             _takePhoto();
//                                           },
//                                         ),
//                                     ],
//                                   ),
//                                 );
//                               }
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       'Upload Profile Photo',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),
//
//               // Personal Information Section
//               _buildSectionHeader(
//                 title: 'Personal Information',
//                 icon: Icons.person_outline,
//               ),
//               Card(
//                 elevation: 2,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     children: [
//                       TextFormField(
//                         controller: _nameController,
//                         decoration: InputDecoration(
//                           labelText: 'Full Name',
//                           prefixIcon: Icon(Icons.person, color: Colors.grey[600]),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: _contactController,
//                         decoration: InputDecoration(
//                           labelText: 'Contact',
//                           prefixIcon: Icon(Icons.phone, color: Colors.grey[600]),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         keyboardType: TextInputType.phone,
//                         validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: _emailController,
//                         decoration: InputDecoration(
//                           labelText: 'Email',
//                           prefixIcon: Icon(Icons.email, color: Colors.grey[600]),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         keyboardType: TextInputType.emailAddress,
//                         validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: _fatherController,
//                         decoration: InputDecoration(
//                           labelText: 'Father/Husband Name',
//                           prefixIcon: Icon(Icons.family_restroom, color: Colors.grey[600]),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: _cnicController,
//                         decoration: InputDecoration(
//                           labelText: 'CNIC',
//                           prefixIcon: Icon(Icons.credit_card, color: Colors.grey[600]),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: _dobController,
//                         decoration: InputDecoration(
//                           labelText: 'Date of Birth',
//                           prefixIcon: Icon(Icons.calendar_today, color: Colors.grey[600]),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           suffixIcon: IconButton(
//                             icon: const Icon(Icons.calendar_month),
//                             onPressed: () => _selectDate(context),
//                           ),
//                         ),
//                         readOnly: true,
//                         validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
//                       ),
//                       const SizedBox(height: 16),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: DropdownButtonFormField<String>(
//                               value: _status,
//                               items: ['Single', 'Married'].map((status) {
//                                 return DropdownMenuItem(
//                                   value: status,
//                                   child: Text(status),
//                                 );
//                               }).toList(),
//                               onChanged: (value) => setState(() => _status = value),
//                               decoration: InputDecoration(
//                                 labelText: 'Status',
//                                 prefixIcon: Icon(Icons.person_outline, color: Colors.grey[600]),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: DropdownButtonFormField<String>(
//                               value: _religion,
//                               items: ['Islam', 'Christian', 'Hindu', 'Other'].map((religion) {
//                                 return DropdownMenuItem(
//                                   value: religion,
//                                   child: Text(religion),
//                                 );
//                               }).toList(),
//                               onChanged: (value) => setState(() => _religion = value),
//                               decoration: InputDecoration(
//                                 labelText: 'Religion',
//                                 prefixIcon: Icon(Icons.people_outline, color: Colors.grey[600]),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: DropdownButtonFormField<String>(
//                               value: _gender,
//                               items: ['Male', 'Female', 'Other'].map((gender) {
//                                 return DropdownMenuItem(
//                                   value: gender,
//                                   child: Text(gender),
//                                 );
//                               }).toList(),
//                               onChanged: (value) => setState(() => _gender = value),
//                               decoration: InputDecoration(
//                                 labelText: 'Gender',
//                                 prefixIcon: Icon(Icons.person_outline, color: Colors.grey[600]),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: TextFormField(
//                               controller: _addressController,
//                               decoration: InputDecoration(
//                                 labelText: 'Address',
//                                 prefixIcon: Icon(Icons.home, color: Colors.grey[600]),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                               ),
//                               maxLines: 2,
//                               validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//
//               // Languages Section
//               _buildSectionHeader(
//                 title: 'Languages',
//                 icon: Icons.language,
//               ),
//               Card(
//                 elevation: 2,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Text(
//                             'LANGUAGES',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.blueGrey[800],
//                             ),
//                           ),
//                           const Spacer(),
//                           IconButton(
//                             icon: Icon(Icons.add_circle,
//                                 color: Theme.of(context).primaryColor),
//                             onPressed: () => setState(() => _languageControllers.add(TextEditingController())),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       ...List.generate(_languageControllers.length, (index) {
//                         return Padding(
//                           padding: const EdgeInsets.only(bottom: 12),
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: TextFormField(
//                                   controller: _languageControllers[index],
//                                   decoration: InputDecoration(
//                                     labelText: 'Language ${index + 1}',
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                         horizontal: 16, vertical: 14),
//                                   ),
//                                   validator: (value) =>
//                                   value?.isEmpty ?? true ? 'Required' : null,
//                                 ),
//                               ),
//                               if (_languageControllers.length > 1)
//                                 IconButton(
//                                   icon: const Icon(Icons.remove_circle,
//                                       color: Colors.red),
//                                   onPressed: () => setState(() {
//                                     _languageControllers[index].dispose();
//                                     _languageControllers.removeAt(index);
//                                   }),
//                                 ),
//                             ],
//                           ),
//                         );
//                       }),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//
//               // Skills Section
//               _buildSectionHeader(
//                 title: 'Professional Skills',
//                 icon: Icons.work_outline,
//               ),
//               Card(
//                 elevation: 2,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Text(
//                             'SKILLS',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.blueGrey[800],
//                             ),
//                           ),
//                           const Spacer(),
//                           IconButton(
//                             icon: Icon(Icons.add_circle,
//                                 color: Theme.of(context).primaryColor),
//                             onPressed: () => setState(() => _skillControllers.add(TextEditingController())),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       ...List.generate(_skillControllers.length, (index) {
//                         return Padding(
//                           padding: const EdgeInsets.only(bottom: 12),
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: TextFormField(
//                                   controller: _skillControllers[index],
//                                   decoration: InputDecoration(
//                                     labelText: 'Skill ${index + 1}',
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                         horizontal: 16, vertical: 14),
//                                   ),
//                                   validator: (value) =>
//                                   value?.isEmpty ?? true ? 'Required' : null,
//                                 ),
//                               ),
//                               if (_skillControllers.length > 1)
//                                 IconButton(
//                                   icon: const Icon(Icons.remove_circle,
//                                       color: Colors.red),
//                                   onPressed: () => setState(() {
//                                     _skillControllers[index].dispose();
//                                     _skillControllers.removeAt(index);
//                                   }),
//                                 ),
//                             ],
//                           ),
//                         );
//                       }),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//
//               // Objective Section
//               _buildSectionHeader(
//                 title: 'Career Objective',
//                 icon: Icons.flag_outlined,
//               ),
//               Card(
//                 elevation: 2,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'OBJECTIVE',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.blueGrey[800],
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       TextFormField(
//                         controller: _objectiveController,
//                         decoration: InputDecoration(
//                           hintText: 'Enter your career objective...',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           contentPadding: const EdgeInsets.all(16),
//                         ),
//                         maxLines: 4,
//                         validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//
//               // Experience Section
//               _buildSectionHeader(
//                 title: 'Work Experience',
//                 icon: Icons.business_center_outlined,
//               ),
//               Card(
//                 elevation: 2,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Text(
//                             'WORKING EXPERIENCE',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.blueGrey[800],
//                             ),
//                           ),
//                           const Spacer(),
//                           Row(
//                             children: [
//                               Text('Fresher',
//                                   style: TextStyle(color: Colors.grey[700])),
//                               Checkbox(
//                                 value: _isFresher,
//                                 onChanged: (value) =>
//                                     setState(() => _isFresher = value ?? false),
//                               ),
//                             ],
//                           ),
//                           if (!_isFresher)
//                             IconButton(
//                               icon: Icon(Icons.add_circle,
//                                   color: Theme.of(context).primaryColor),
//                               onPressed: () => setState(() => _experiences.add(Experience())),
//                             ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       if (!_isFresher)
//                         ...List.generate(_experiences.length, (index) {
//                           final exp = _experiences[index];
//                           return Container(
//                             margin: const EdgeInsets.only(bottom: 16),
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               color: index.isEven
//                                   ? Colors.blueGrey[50]
//                                   : Colors.grey[100],
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Column(
//                               children: [
//                                 Row(
//                                   children: [
//                                     Text(
//                                       'Experience ${index + 1}',
//                                       style: const TextStyle(
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                     const Spacer(),
//                                     IconButton(
//                                       icon: const Icon(Icons.delete,
//                                           color: Colors.red),
//                                       onPressed: () => setState(() {
//                                         exp.dispose();
//                                         _experiences.removeAt(index);
//                                       }),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 12),
//                                 TextFormField(
//                                   controller: exp.positionController,
//                                   decoration: InputDecoration(
//                                     labelText: 'Position',
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                         horizontal: 12, vertical: 14),
//                                   ),
//                                   validator: (value) =>
//                                   value?.isEmpty ?? true ? 'Required' : null,
//                                 ),
//                                 const SizedBox(height: 12),
//                                 TextFormField(
//                                   controller: exp.companyController,
//                                   decoration: InputDecoration(
//                                     labelText: 'Company',
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                         horizontal: 12, vertical: 14),
//                                   ),
//                                   validator: (value) =>
//                                   value?.isEmpty ?? true ? 'Required' : null,
//                                 ),
//                                 const SizedBox(height: 12),
//                                 TextFormField(
//                                   controller: exp.periodController,
//                                   decoration: InputDecoration(
//                                     labelText: 'Period (e.g., 2018 - Present)',
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                         horizontal: 12, vertical: 14),
//                                   ),
//                                   validator: (value) =>
//                                   value?.isEmpty ?? true ? 'Required' : null,
//                                 ),
//                               ],
//                             ),
//                           );
//                         }),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//
//               // Education Section
//               _buildSectionHeader(
//                 title: 'Education',
//                 icon: Icons.school_outlined,
//               ),
//               Card(
//                 elevation: 2,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Text(
//                             'EDUCATION',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.blueGrey[800],
//                             ),
//                           ),
//                           const Spacer(),
//                           IconButton(
//                             icon: Icon(Icons.add_circle,
//                                 color: Theme.of(context).primaryColor),
//                             onPressed: () => setState(() => _education.add(Education())),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       ...List.generate(_education.length, (index) {
//                         final edu = _education[index];
//                         return Container(
//                           margin: const EdgeInsets.only(bottom: 16),
//                           padding: const EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             color: index.isEven
//                                 ? Colors.blueGrey[50]
//                                 : Colors.grey[100],
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Column(
//                             children: [
//                               Row(
//                                 children: [
//                                   Text(
//                                     'Education ${index + 1}',
//                                     style: const TextStyle(fontWeight: FontWeight.bold),
//                                   ),
//                                   const Spacer(),
//                                   IconButton(
//                                     icon: const Icon(Icons.delete, color: Colors.red),
//                                     onPressed: () => setState(() {
//                                       edu.dispose();
//                                       _education.removeAt(index);
//                                     }),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 12),
//                               TextFormField(
//                                 controller: edu.qualificationController,
//                                 decoration: InputDecoration(
//                                   labelText: 'Qualification',
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   contentPadding: const EdgeInsets.symmetric(
//                                       horizontal: 12, vertical: 14),
//                                 ),
//                                 validator: (value) =>
//                                 value?.isEmpty ?? true ? 'Required' : null,
//                               ),
//                               const SizedBox(height: 12),
//                               TextFormField(
//                                 controller: edu.yearController,
//                                 decoration: InputDecoration(
//                                   labelText: 'Year',
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   contentPadding: const EdgeInsets.symmetric(
//                                       horizontal: 12, vertical: 14),
//                                 ),
//                               ),
//                               const SizedBox(height: 12),
//                               TextFormField(
//                                 controller: edu.institutionController,
//                                 decoration: InputDecoration(
//                                   labelText: 'Institution',
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   contentPadding: const EdgeInsets.symmetric(
//                                       horizontal: 12, vertical: 14),
//                                 ),
//                                 validator: (value) =>
//                                 value?.isEmpty ?? true ? 'Required' : null,
//                               ),
//                               const SizedBox(height: 12),
//                               TextFormField(
//                                 controller: edu.detailsController,
//                                 decoration: InputDecoration(
//                                   labelText: 'Details',
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   contentPadding: const EdgeInsets.symmetric(
//                                       horizontal: 12, vertical: 14),
//                                 ),
//                                 maxLines: 2,
//                               ),
//                             ],
//                           ),
//                         );
//                       }),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//
//               // Reference Section
//               _buildSectionHeader(
//                 title: 'References',
//                 icon: Icons.people_alt_outlined,
//               ),
//               Card(
//                 elevation: 2,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'REFERENCE',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.blueGrey[800],
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       TextFormField(
//                         controller: _referenceController,
//                         decoration: InputDecoration(
//                           hintText: 'Will be furnished on demand',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           contentPadding: const EdgeInsets.all(16),
//                         ),
//                         maxLines: 2,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30),
//
//               // Save Button
//               Center(
//                 child: ElevatedButton.icon(
//                   icon: const Icon(Icons.save, size: 24),
//                   label: const Text('SAVE RESUME',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
//                   onPressed: _saveResume,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     backgroundColor: Theme.of(context).primaryColor,
//                     foregroundColor: Colors.white,
//                     elevation: 4,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSectionHeader({required String title, required IconData icon}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Row(
//         children: [
//           Icon(icon, color: Theme.of(context).primaryColor, size: 24),
//           const SizedBox(width: 12),
//           Text(
//             title,
//             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//               fontWeight: FontWeight.w600,
//               color: Colors.blueGrey[800],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class Experience {
//   final TextEditingController positionController = TextEditingController();
//   final TextEditingController companyController = TextEditingController();
//   final TextEditingController periodController = TextEditingController();
//
//   void dispose() {
//     positionController.dispose();
//     companyController.dispose();
//     periodController.dispose();
//   }
// }
//
// class Education {
//   final TextEditingController qualificationController;
//   final TextEditingController yearController = TextEditingController();
//   final TextEditingController institutionController;
//   final TextEditingController detailsController = TextEditingController();
//
//   Education({
//     String? qualification,
//     String? institution,
//     String? details,
//   })  : qualificationController = TextEditingController(text: qualification),
//         institutionController = TextEditingController(text: institution) {
//     if (details != null) detailsController.text = details;
//   }
//
//   void dispose() {
//     qualificationController.dispose();
//     yearController.dispose();
//     institutionController.dispose();
//     detailsController.dispose();
//   }
// }