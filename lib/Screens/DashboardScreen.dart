// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/foundation.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:provider/provider.dart';
// import 'package:share_plus/share_plus.dart';
// import '../Resume Model.dart';
// import '../ThemeProvider.dart';
//
//
//
// class ResumeFormScreen extends StatefulWidget {
//   final Resume? resume;
//
//   ResumeFormScreen({this.resume});
//
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
//   late TextEditingController _nameController;
//   late TextEditingController _contactController;
//   late TextEditingController _emailController;
//   late TextEditingController _fatherController;
//   late TextEditingController _cnicController;
//   late TextEditingController _dobController;
//   late TextEditingController _addressController;
//   late TextEditingController _objectiveController;
//   late TextEditingController _referenceController;
//
//   // Dynamic lists
//   late List<TextEditingController> _languageControllers;
//   late List<TextEditingController> _skillControllers;
//   late List<Experience> _experiences;
//   late List<Education> _education;
//
//   // Selection values
//   String? _status;
//   String? _religion;
//   String? _gender;
//   bool _isFresher = false;
//   Uint8List? _imageBytes;
//   String? _base64Image;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Initialize with existing resume data or defaults
//     _nameController = TextEditingController(text: widget.resume?.name ?? '');
//     _contactController = TextEditingController(text: widget.resume?.contact ?? '');
//     _emailController = TextEditingController(text: widget.resume?.email ?? '');
//     _fatherController = TextEditingController(
//         text: widget.resume?.personalInfo['fatherName'] ?? ''
//     );
//     _cnicController = TextEditingController(
//         text: widget.resume?.personalInfo['cnic'] ?? ''
//     );
//     _dobController = TextEditingController(
//         text: widget.resume?.personalInfo['dob'] ?? ''
//     );
//     _addressController = TextEditingController(
//         text: widget.resume?.personalInfo['address'] ?? ''
//     );
//     _objectiveController = TextEditingController(
//         text: widget.resume?.objective ??
//             'To work in a dynamic professional environment with a growing organization and utilize my creativity and innovative thinking for benefit of the organization and myself.'
//     );
//     _referenceController = TextEditingController(
//         text: widget.resume?.reference ?? 'Will be furnished on demand.'
//     );
//
//     // Initialize lists
//     _languageControllers = (widget.resume?.languages ?? ['']).map(
//             (lang) => TextEditingController(text: lang)
//     ).toList();
//
//     _skillControllers = (widget.resume?.skills ?? ['']).map(
//             (skill) => TextEditingController(text: skill)
//     ).toList();
//
//     _experiences = (widget.resume?.experiences ?? [{}]).map((exp) {
//       return Experience(
//         position: exp['position'] ?? '',
//         company: exp['company'] ?? '',
//         period: exp['period'] ?? '',
//       );
//     }).toList();
//
//     if (_experiences.isEmpty) _experiences.add(Experience());
//
//     _education = (widget.resume?.education ?? [{}]).map((edu) {
//       return Education(
//         qualification: edu['qualification'] ?? '',
//         institution: edu['institution'] ?? '',
//         details: edu['details'] ?? '',
//         year: edu['year'] ?? '',
//       );
//     }).toList();
//
//     if (_education.isEmpty) _education.add(Education());
//
//     // Set selection values
//     _status = widget.resume?.personalInfo['status'] ?? 'Single';
//     _religion = widget.resume?.personalInfo['religion'] ?? 'Islam';
//     _gender = widget.resume?.personalInfo['gender'] ?? 'Male';
//     _isFresher = widget.resume?.isFresher ?? false;
//     _base64Image = widget.resume?.photo;
//   }
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
//         'createdAt': widget.resume?.createdAt ?? ServerValue.timestamp,
//       };
//
//       if (widget.resume?.key != null) {
//         await _databaseRef.child(widget.resume!.key!).update(resumeData);
//       } else {
//         await _databaseRef.push().set(resumeData);
//       }
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Resume saved successfully!'),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//
//       Navigator.pop(context);
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
//
//   Widget _buildHeaderSection() {
//     return Center(
//       child: Column(
//         children: [
//           Stack(
//             alignment: Alignment.bottomRight,
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: Theme.of(context).primaryColor,
//                     width: 3,
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 8,
//                       offset: const Offset(0, 4),
//                     )
//                   ],
//                 ),
//                 child: CircleAvatar(
//                   radius: 70,
//                   backgroundColor: Colors.grey[200],
//                   backgroundImage: _getBackgroundImage(),
//                   child: _imageBytes == null && _base64Image == null
//                       ? const Icon(Icons.person, size: 60, color: Colors.grey)
//                       : null,
//                 ),
//               ),
//               Container(
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).primaryColor,
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.white, width: 2),
//                 ),
//                 child: IconButton(
//                   icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
//                   onPressed: () {
//                     if (kIsWeb) {
//                       _pickImage();
//                     } else {
//                       showModalBottomSheet(
//                         context: context,
//                         builder: (context) => Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             ListTile(
//                               leading: const Icon(Icons.photo_library),
//                               title: const Text('Choose from gallery'),
//                               onTap: () {
//                                 Navigator.pop(context);
//                                 _pickImage();
//                               },
//                             ),
//                             if (!kIsWeb)
//                               ListTile(
//                                 leading: const Icon(Icons.camera_alt),
//                                 title: const Text('Take a photo'),
//                                 onTap: () {
//                                   Navigator.pop(context);
//                                   _takePhoto();
//                                 },
//                               ),
//                           ],
//                         ),
//                       );
//                     }
//                   },
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Text(
//             'Upload Profile Photo',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//               color: Colors.grey[600],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPersonalInfoSection() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             TextFormField(
//               controller: _nameController,
//               decoration: InputDecoration(
//                 labelText: 'Full Name',
//                 prefixIcon: Icon(Icons.person, color: Colors.grey[600]),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
//             ),
//             const SizedBox(height: 16),
//             TextFormField(
//               controller: _fatherController,
//               decoration: InputDecoration(
//                 labelText: 'Father/Husband Name',
//                 prefixIcon: Icon(Icons.family_restroom, color: Colors.grey[600]),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
//             ),
//
//             const SizedBox(height: 16),
//             TextFormField(
//               controller: _contactController,
//               decoration: InputDecoration(
//                 labelText: 'Contact',
//                 prefixIcon: Icon(Icons.phone, color: Colors.grey[600]),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               keyboardType: TextInputType.phone,
//               validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
//             ),
//
//             const SizedBox(height: 16),
//             TextFormField(
//               controller: _emailController,
//               decoration: InputDecoration(
//                 labelText: 'Email',
//                 prefixIcon: Icon(Icons.email, color: Colors.grey[600]),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               keyboardType: TextInputType.emailAddress,
//
//             ),
//             const SizedBox(height: 16),
//             TextFormField(
//               controller: _cnicController,
//               decoration: InputDecoration(
//                 labelText: 'CNIC',
//                 prefixIcon: Icon(Icons.credit_card, color: Colors.grey[600]),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
//             ),
//             const SizedBox(height: 16),
//             TextFormField(
//               controller: _dobController,
//               decoration: InputDecoration(
//                 labelText: 'Date of Birth',
//                 prefixIcon: Icon(Icons.calendar_today, color: Colors.grey[600]),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 suffixIcon: IconButton(
//                   icon: const Icon(Icons.calendar_month),
//                   onPressed: () => _selectDate(context),
//                 ),
//               ),
//               readOnly: true,
//               validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: DropdownButtonFormField<String>(
//                     value: _status,
//                     items: ['Single', 'Married'].map((status) {
//                       return DropdownMenuItem(
//                         value: status,
//                         child: Text(status),
//                       );
//                     }).toList(),
//                     onChanged: (value) => setState(() => _status = value),
//                     decoration: InputDecoration(
//                       labelText: 'Status',
//                       prefixIcon: Icon(Icons.person_outline, color: Colors.grey[600]),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: DropdownButtonFormField<String>(
//                     value: _religion,
//                     items: ['Islam', 'Christian', 'Hindu', 'Other'].map((religion) {
//                       return DropdownMenuItem(
//                         value: religion,
//                         child: Text(religion),
//                       );
//                     }).toList(),
//                     onChanged: (value) => setState(() => _religion = value),
//                     decoration: InputDecoration(
//                       labelText: 'Religion',
//                       prefixIcon: Icon(Icons.people_outline, color: Colors.grey[600]),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: DropdownButtonFormField<String>(
//                     value: _gender,
//                     items: ['Male', 'Female', 'Other'].map((gender) {
//                       return DropdownMenuItem(
//                         value: gender,
//                         child: Text(gender),
//                       );
//                     }).toList(),
//                     onChanged: (value) => setState(() => _gender = value),
//                     decoration: InputDecoration(
//                       labelText: 'Gender',
//                       prefixIcon: Icon(Icons.person_outline, color: Colors.grey[600]),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: TextFormField(
//                     controller: _addressController,
//                     decoration: InputDecoration(
//                       labelText: 'Address',
//                       prefixIcon: Icon(Icons.home, color: Colors.grey[600]),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     maxLines: 2,
//                     validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDynamicFieldSection({
//     required String title,
//     required List<TextEditingController> controllers,
//     required VoidCallback onAdd,
//     required Function(int) onRemove,
//     String labelPrefix = '',
//   }) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.blueGrey[800],
//                   ),
//                 ),
//                 const Spacer(),
//                 IconButton(
//                   icon: Icon(Icons.add_circle,
//                       color: Theme.of(context).primaryColor),
//                   onPressed: onAdd,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             ...List.generate(controllers.length, (index) {
//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 12),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: TextFormField(
//                         controller: controllers[index],
//                         decoration: InputDecoration(
//                           labelText: '$labelPrefix ${index + 1}',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 14),
//                         ),
//                         validator: (value) =>
//                         value?.isEmpty ?? true ? 'Required' : null,
//                       ),
//                     ),
//                     if (controllers.length > 1)
//                       IconButton(
//                         icon: const Icon(Icons.remove_circle,
//                             color: Colors.red),
//                         onPressed: () => onRemove(index),
//                       ),
//                   ],
//                 ),
//               );
//             }),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildObjectiveSection() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'OBJECTIVE',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.blueGrey[800],
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextFormField(
//               controller: _objectiveController,
//               decoration: InputDecoration(
//                 hintText: 'Enter your career objective...',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 contentPadding: const EdgeInsets.all(16),
//               ),
//               maxLines: 4,
//               validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildExperienceSection() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Text(
//                   'WORKING EXPERIENCE',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.blueGrey[800],
//                   ),
//                 ),
//                 const Spacer(),
//                 Row(
//                   children: [
//                     Text('Fresher',
//                         style: TextStyle(color: Colors.grey[700])),
//                     Checkbox(
//                       value: _isFresher,
//                       onChanged: (value) =>
//                           setState(() => _isFresher = value ?? false),
//                     ),
//                   ],
//                 ),
//                 if (!_isFresher)
//                   IconButton(
//                     icon: Icon(Icons.add_circle,
//                         color: Theme.of(context).primaryColor),
//                     onPressed: () => setState(() => _experiences.add(Experience())),
//                   ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             if (!_isFresher)
//               ...List.generate(_experiences.length, (index) {
//                 final exp = _experiences[index];
//                 return Container(
//                   margin: const EdgeInsets.only(bottom: 16),
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: index.isEven
//                         ? Colors.blueGrey[50]
//                         : Colors.grey[100],
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Column(
//                     children: [
//                       Row(
//                         children: [
//                           Text(
//                             'Experience ${index + 1}',
//                             style: const TextStyle(
//                                 fontWeight: FontWeight.bold),
//                           ),
//                           const Spacer(),
//                           IconButton(
//                             icon: const Icon(Icons.delete,
//                                 color: Colors.red),
//                             onPressed: () => setState(() {
//                               exp.dispose();
//                               _experiences.removeAt(index);
//                             }),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       TextFormField(
//                         controller: exp.positionController,
//                         decoration: InputDecoration(
//                           labelText: 'Position',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 12, vertical: 14),
//                         ),
//                         validator: (value) =>
//                         value?.isEmpty ?? true ? 'Required' : null,
//                       ),
//                       const SizedBox(height: 12),
//                       TextFormField(
//                         controller: exp.companyController,
//                         decoration: InputDecoration(
//                           labelText: 'Company',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 12, vertical: 14),
//                         ),
//                         validator: (value) =>
//                         value?.isEmpty ?? true ? 'Required' : null,
//                       ),
//                       const SizedBox(height: 12),
//                       TextFormField(
//                         controller: exp.periodController,
//                         decoration: InputDecoration(
//                           labelText: 'Period (e.g., 2018 - Present)',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 12, vertical: 14),
//                         ),
//                         validator: (value) =>
//                         value?.isEmpty ?? true ? 'Required' : null,
//                       ),
//                     ],
//                   ),
//                 );
//               }),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEducationSection() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Text(
//                   'EDUCATION',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.blueGrey[800],
//                   ),
//                 ),
//                 const Spacer(),
//                 IconButton(
//                   icon: Icon(Icons.add_circle,
//                       color: Theme.of(context).primaryColor),
//                   onPressed: () => setState(() => _education.add(Education())),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             ...List.generate(_education.length, (index) {
//               final edu = _education[index];
//               return Container(
//                 margin: const EdgeInsets.only(bottom: 16),
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: index.isEven
//                       ? Colors.blueGrey[50]
//                       : Colors.grey[100],
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Column(
//                   children: [
//                     Row(
//                       children: [
//                         Text(
//                           'Education ${index + 1}',
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         const Spacer(),
//                         IconButton(
//                           icon: const Icon(Icons.delete, color: Colors.red),
//                           onPressed: () => setState(() {
//                             edu.dispose();
//                             _education.removeAt(index);
//                           }),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     TextFormField(
//                       controller: edu.qualificationController,
//                       decoration: InputDecoration(
//                         labelText: 'Qualification',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 14),
//                       ),
//                       validator: (value) =>
//                       value?.isEmpty ?? true ? 'Required' : null,
//                     ),
//                     const SizedBox(height: 12),
//                     TextFormField(
//                       controller: edu.yearController,
//                       decoration: InputDecoration(
//                         labelText: 'Year',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 14),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     TextFormField(
//                       controller: edu.institutionController,
//                       decoration: InputDecoration(
//                         labelText: 'Institution',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 14),
//                       ),
//                       validator: (value) =>
//                       value?.isEmpty ?? true ? 'Required' : null,
//                     ),
//                     const SizedBox(height: 12),
//                     TextFormField(
//                       controller: edu.detailsController,
//                       decoration: InputDecoration(
//                         labelText: 'Details',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 14),
//                       ),
//                       maxLines: 2,
//                     ),
//                   ],
//                 ),
//               );
//             }),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildReferenceSection() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'REFERENCE',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.blueGrey[800],
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextFormField(
//               controller: _referenceController,
//               decoration: InputDecoration(
//                 hintText: 'Will be furnished on demand',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 contentPadding: const EdgeInsets.all(16),
//               ),
//               maxLines: 2,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSaveButton() {
//     return Center(
//       child: ElevatedButton.icon(
//         icon: const Icon(Icons.save, size: 24),
//         label: const Text('SAVE RESUME',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
//         onPressed: _saveResume,
//         style: ElevatedButton.styleFrom(
//           padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           backgroundColor: Theme.of(context).primaryColor,
//           foregroundColor: Colors.white,
//           elevation: 4,
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.resume != null ? 'Edit Resume' : 'Create Resume'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.save),
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
//               _buildHeaderSection(),
//               const SizedBox(height: 24),
//               _buildSectionHeader(
//                 title: 'Personal Information',
//                 icon: Icons.person_outline,
//               ),
//               _buildPersonalInfoSection(),
//               const SizedBox(height: 20),
//               _buildSectionHeader(
//                 title: 'Languages',
//                 icon: Icons.language,
//               ),
//               _buildDynamicFieldSection(
//                 title: 'LANGUAGES',
//                 controllers: _languageControllers,
//                 onAdd: () => setState(() => _languageControllers.add(TextEditingController())),
//                 onRemove: (index) => setState(() {
//                   _languageControllers[index].dispose();
//                   _languageControllers.removeAt(index);
//                 }),
//                 labelPrefix: 'Language',
//               ),
//               const SizedBox(height: 20),
//               _buildSectionHeader(
//                 title: 'Professional Skills',
//                 icon: Icons.work_outline,
//               ),
//               _buildDynamicFieldSection(
//                 title: 'SKILLS',
//                 controllers: _skillControllers,
//                 onAdd: () => setState(() => _skillControllers.add(TextEditingController())),
//                 onRemove: (index) => setState(() {
//                   _skillControllers[index].dispose();
//                   _skillControllers.removeAt(index);
//                 }),
//                 labelPrefix: 'Skill',
//               ),
//               const SizedBox(height: 20),
//               _buildSectionHeader(
//                 title: 'Career Objective',
//                 icon: Icons.flag_outlined,
//               ),
//               _buildObjectiveSection(),
//               const SizedBox(height: 20),
//               _buildSectionHeader(
//                 title: 'Work Experience',
//                 icon: Icons.business_center_outlined,
//               ),
//               _buildExperienceSection(),
//               const SizedBox(height: 20),
//               _buildSectionHeader(
//                 title: 'Education',
//                 icon: Icons.school_outlined,
//               ),
//               _buildEducationSection(),
//               const SizedBox(height: 20),
//               _buildSectionHeader(
//                 title: 'References',
//                 icon: Icons.people_alt_outlined,
//               ),
//               _buildReferenceSection(),
//               const SizedBox(height: 30),
//               _buildSaveButton(),
//             ],
//           ),
//         ),
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
//   Experience({String? position, String? company, String? period}) {
//     if (position != null) positionController.text = position;
//     if (company != null) companyController.text = company;
//     if (period != null) periodController.text = period;
//   }
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
//     String? year,
//   })  : qualificationController = TextEditingController(text: qualification ?? ''),
//         institutionController = TextEditingController(text: institution ?? '') {
//     if (details != null) detailsController.text = details;
//     if (year != null) yearController.text = year;
//   }
//
//   void dispose() {
//     qualificationController.dispose();
//     yearController.dispose();
//     institutionController.dispose();
//     detailsController.dispose();
//   }
// }
//
// // Resume List Screen
// // Resume List Screen
// class ResumeListScreen extends StatefulWidget {
//   @override
//   _ResumeListScreenState createState() => _ResumeListScreenState();
// }
//
// class _ResumeListScreenState extends State<ResumeListScreen> {
//   final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref('resumes');
//   List<Resume> _resumes = [];
//   List<Resume> _filteredResumes = [];
//   TextEditingController _searchController = TextEditingController();
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchResumes();
//     _searchController.addListener(_onSearchChanged);
//   }
//
//   @override
//   void dispose() {
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   void _onSearchChanged() {
//     String query = _searchController.text.toLowerCase();
//     setState(() {
//       _filteredResumes = query.isEmpty
//           ? _resumes
//           : _resumes.where((resume) {
//         return resume.name.toLowerCase().contains(query) ||
//             resume.contact.toLowerCase().contains(query) ||
//             resume.personalInfo['fatherName'].toLowerCase().contains(query);
//       }).toList();
//     });
//   }
//
//   Future<void> _fetchResumes() async {
//     try {
//       DatabaseEvent event = await _databaseRef.once();
//       DataSnapshot snapshot = event.snapshot;
//       if (snapshot.value == null) {
//         setState(() => _isLoading = false);
//         return;
//       }
//
//       Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
//       List<Resume> loadedResumes = [];
//       values.forEach((key, value) {
//         loadedResumes.add(Resume.fromMap(value, key));
//       });
//
//       setState(() {
//         _resumes = loadedResumes;
//         _filteredResumes = loadedResumes;
//         _isLoading = false;
//       });
//     } catch (error) {
//       print('Error: $error');
//       setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _deleteResume(String key) async {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Delete Resume'),
//         content: Text('Confirm delete?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               try {
//                 await _databaseRef.child(key).remove();
//                 _fetchResumes();
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Deleted')),
//                 );
//               } catch (error) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Error: $error')),
//                 );
//               }
//             },
//             child: Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _generatePdf(Resume resume) async {
//     final pdf = pw.Document();
//     pdf.addPage(pw.Page(build: (pw.Context context) {
//       return pw.Column(children: [
//         pw.Center(child: pw.Text('RESUME', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
//         pw.Center(child: pw.Text(resume.name.toUpperCase(), style: pw.TextStyle(fontSize: 18))),
//         pw.Divider(),
//         pw.Text('Personal Info', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
//         pw.Row(children: [
//           pw.Expanded(child: pw.Column(children: [
//             _buildPdfRow('S/O', resume.personalInfo['fatherName']),
//             _buildPdfRow('CNIC', resume.personalInfo['cnic']),
//             _buildPdfRow('DOB', resume.personalInfo['dob']),
//           ])),
//           pw.Expanded(child: pw.Column(children: [
//             _buildPdfRow('Status', resume.personalInfo['status']),
//             _buildPdfRow('Religion', resume.personalInfo['religion']),
//             _buildPdfRow('Gender', resume.personalInfo['gender']),
//           ])),
//         ]),
//         _buildPdfRow('Address', resume.personalInfo['address']),
//         pw.Text('Languages', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
//         pw.Wrap(children: resume.languages.map((lang) => pw.Text('• $lang')).toList()),
//         pw.Text('Skills', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
//         pw.Wrap(children: resume.skills.map((skill) => pw.Text('• $skill')).toList()),
//         pw.Text('Objective', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
//         pw.Text(resume.objective),
//         pw.Text('Experience', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
//         ...resume.experiences.map((exp) => pw.Column(children: [
//           pw.Text('• ${exp['position']} at ${exp['company']}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//           pw.Text(exp['period'])
//         ])).toList(),
//         pw.Text('Education', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
//         ...resume.education.map((edu) => pw.Column(children: [
//           pw.Text('• ${edu['qualification']}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//           pw.Text(edu['institution']),
//           if (edu['details'] != null) pw.Text(edu['details'])
//         ])).toList(),
//         pw.Text('Reference', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
//         pw.Text(resume.reference)
//       ]);
//     }));
//
//         await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
//   }
//
//   pw.Widget _buildPdfRow(String label, String value) {
//     return pw.Row(children: [
//       pw.Text('$label: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//       pw.Text(value)
//     ]);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Resumes'),
//         actions: [
//           IconButton(
//             icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
//             onPressed: themeProvider.toggleTheme,
//           ),
//           IconButton(
//             icon: Icon(Icons.add),
//             onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ResumeFormScreen())),
//           ),
//         ],
//       ),
//       body: Column(children: [
//         Padding(
//           padding: EdgeInsets.all(16),
//           child: TextField(
//             controller: _searchController,
//             decoration: InputDecoration(
//               labelText: 'Search',
//               prefixIcon: Icon(Icons.search),
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//               filled: true,
//               fillColor: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[200],
//             ),
//           ),
//         ),
//         Expanded(
//           child: _isLoading
//               ? Center(child: CircularProgressIndicator())
//               : _filteredResumes.isEmpty
//               ? Center(child: Text('No resumes'))
//               : ListView.builder(
//             itemCount: _filteredResumes.length,
//             itemBuilder: (context, index) {
//               final resume = _filteredResumes[index];
//               return Card(
//                 margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 child: ListTile(
//                   leading: CircleAvatar(
//                     backgroundImage: resume.photo != null ? MemoryImage(base64Decode(resume.photo!)) : null,
//                     child: resume.photo == null ? Icon(Icons.person) : null,
//                   ),
//                   title: Text(resume.name, style: TextStyle(fontWeight: FontWeight.bold)),
//                   subtitle: Text(resume.contact),
//                   trailing: PopupMenuButton<String>(
//                     onSelected: (value) {
//                       if (value == 'edit') {
//                         Navigator.push(context, MaterialPageRoute(builder: (context) => ResumeFormScreen()));
//                       } else if (value == 'delete') {
//                         _deleteResume(resume.key!);
//                       } else if (value == 'pdf') {
//                         _generatePdf(resume);
//                       }
//                     },
//                     itemBuilder: (context) => [
//                       PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit), SizedBox(width: 8), Text('Edit')])),
//                       PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete), SizedBox(width: 8), Text('Delete')])),
//                       PopupMenuItem(value: 'pdf', child: Row(children: [Icon(Icons.picture_as_pdf), SizedBox(width: 8), Text('PDF')])),
//                     ],
//                   ),
//                   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ResumeDetailScreen(resume: resume))),
//                 ),
//               );
//             },
//           ),
//         ),
//       ]),
//     );
//   }
// }
//



import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;

import '../Resume Model.dart';
import '../ThemeProvider.dart';



class ResumeFormScreen extends StatefulWidget {
  final Resume? resume;

  const ResumeFormScreen({Key? key, this.resume}) : super(key: key);

  @override
  _ResumeFormScreenState createState() => _ResumeFormScreenState();
}

class _ResumeFormScreenState extends State<ResumeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref('resumes');
  final ImagePicker _imagePicker = ImagePicker();

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _contactController;
  late TextEditingController _emailController;
  late TextEditingController _fatherController;
  late TextEditingController _cnicController;
  late TextEditingController _dobController;
  late TextEditingController _addressController;
  late TextEditingController _objectiveController;
  late TextEditingController _referenceController;

  // Dynamic lists
  late List<TextEditingController> _languageControllers;
  late List<TextEditingController> _skillControllers;
  late List<Experience> _experiences;
  late List<Education> _education;

  // Selection values
  String? _status;
  String? _religion;
  String? _gender;
  bool _isFresher = false;
  String? _base64Image;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Initialize with existing resume data or defaults
    _nameController = TextEditingController(text: widget.resume?.name ?? '');
    _contactController = TextEditingController(text: widget.resume?.contact ?? '');
    _emailController = TextEditingController(text: widget.resume?.email ?? '');
    _fatherController = TextEditingController(text: widget.resume?.personalInfo['fatherName'] ?? '');
    _cnicController = TextEditingController(text: widget.resume?.personalInfo['cnic'] ?? '');
    _dobController = TextEditingController(text: widget.resume?.personalInfo['dob'] ?? '');
    _addressController = TextEditingController(text: widget.resume?.personalInfo['address'] ?? '');
    _objectiveController = TextEditingController(
        text: widget.resume?.objective ?? 'To work in a dynamic professional environment with a growing organization and utilize my creativity and innovative thinking for benefit of the organization and myself.'
    );
    _referenceController = TextEditingController(
        text: widget.resume?.reference ?? 'Will be furnished on demand.'
    );

    // Initialize lists
    _languageControllers = (widget.resume?.languages ?? ['']).map(
            (lang) => TextEditingController(text: lang)
    ).toList();

    _skillControllers = (widget.resume?.skills ?? ['']).map(
            (skill) => TextEditingController(text: skill)
    ).toList();

    _experiences = (widget.resume?.experiences ?? [{}]).map((exp) {
      return Experience(
        position: exp['position'] ?? '',
        company: exp['company'] ?? '',
        period: exp['period'] ?? '',
      );
    }).toList();

    if (_experiences.isEmpty) _experiences.add(Experience());

    _education = (widget.resume?.education ?? [{}]).map((edu) {
      return Education(
        qualification: edu['qualification'] ?? '',
        institution: edu['institution'] ?? '',
        details: edu['details'] ?? '',
        year: edu['year'] ?? '',
      );
    }).toList();

    if (_education.isEmpty) _education.add(Education());

    // Set selection values
    _status = widget.resume?.personalInfo['status'] ?? 'Single';
    _religion = widget.resume?.personalInfo['religion'] ?? 'Islam';
    _gender = widget.resume?.personalInfo['gender'] ?? 'Male';
    _isFresher = widget.resume?.isFresher ?? false;
    _base64Image = widget.resume?.photo;
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    // Dispose all controllers
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _fatherController.dispose();
    _cnicController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _objectiveController.dispose();
    _referenceController.dispose();

    for (var controller in _languageControllers) {
      controller.dispose();
    }

    for (var controller in _skillControllers) {
      controller.dispose();
    }

    for (var exp in _experiences) {
      exp.dispose();
    }

    for (var edu in _education) {
      edu.dispose();
    }
  }

  Map<String, dynamic> _prepareResumeData() {
    return {
      'photo': _base64Image,
      'name': _nameController.text,
      'contact': _contactController.text,
      'email': _emailController.text,
      'personalInfo': {
        'fatherName': _fatherController.text,
        'cnic': _cnicController.text,
        'dob': _dobController.text,
        'status': _status,
        'religion': _religion,
        'gender': _gender,
        'address': _addressController.text,
      },
      'languages': _languageControllers.map((c) => c.text).toList(),
      'skills': _skillControllers.map((c) => c.text).toList(),
      'objective': _objectiveController.text,
      'experiences': _experiences.map((e) => {
        'position': e.positionController.text,
        'company': e.companyController.text,
        'period': e.periodController.text,
      }).toList(),
      'education': _education.map((e) => {
        'qualification': e.qualificationController.text,
        'year': e.yearController.text,
        'institution': e.institutionController.text,
        'details': e.detailsController.text,
      }).toList(),
      'reference': _referenceController.text,
      'isFresher': _isFresher,
    };
  }

  Future<void> _saveResume() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final resumeData = _prepareResumeData();

      if (widget.resume?.key != null) {
        await _databaseRef.child(widget.resume!.key!).update(resumeData);
      } else {
        resumeData['createdAt'] = ServerValue.timestamp;
        await _databaseRef.push().set(resumeData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resume saved successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save resume: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveAsCopy() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final resumeData = _prepareResumeData();
      resumeData['createdAt'] = ServerValue.timestamp;
      await _databaseRef.push().set(resumeData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resume saved as copy successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save resume: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  ImageProvider? _getBackgroundImage() {
    if (_base64Image != null) {
      try {
        return MemoryImage(base64Decode(_base64Image!));
      } catch (e) {
        debugPrint('Error decoding base64 image: $e');
        return null;
      }
    }
    return null;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _base64Image = base64Encode(bytes);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Image picker error: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _base64Image = base64Encode(bytes);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error taking photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Camera error: $e');
    }
  }

  Widget _buildSectionHeader({required String title, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: CircleAvatar(
                  radius: MediaQuery.of(context).size.width * 0.15,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _getBackgroundImage(),
                  child: _base64Image == null
                      ? Icon(Icons.person,
                      size: MediaQuery.of(context).size.width * 0.12,
                      color: Colors.grey)
                      : null,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: IconButton(
                  icon: Icon(Icons.camera_alt,
                      size: MediaQuery.of(context).size.width * 0.05,
                      color: Colors.white),
                  onPressed: () {
                    if (kIsWeb) {
                      _pickImage();
                    } else {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.photo_library),
                                title: const Text('Choose from gallery'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickImage();
                                },
                              ),
                              if (!kIsWeb)
                                ListTile(
                                  leading: const Icon(Icons.camera_alt),
                                  title: const Text('Take a photo'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _takePhoto();
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Upload Profile Photo',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.04,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;

            return Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person, color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _fatherController,
                  decoration: InputDecoration(
                    labelText: 'Father/Husband Name',
                    prefixIcon: Icon(Icons.family_restroom, color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _contactController,
                  decoration: InputDecoration(
                    labelText: 'Contact',
                    prefixIcon: Icon(Icons.phone, color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email, color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _cnicController,
                  decoration: InputDecoration(
                    labelText: 'CNIC',
                    prefixIcon: Icon(Icons.credit_card, color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _dobController,
                  readOnly: true, // Prevents keyboard from showing
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      _dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate); // Format as needed
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    prefixIcon: Icon(Icons.calendar_today, color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),

                const SizedBox(height: 16),

                if (isSmallScreen) ...[
                  DropdownButtonFormField<String>(
                    value: _status,
                    items: ['Single', 'Married'].map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _status = value),
                    decoration: InputDecoration(
                      labelText: 'Status',
                      prefixIcon: Icon(Icons.person_outline, color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _religion,
                    items: ['Islam', 'Christian', 'Hindu', 'Other'].map((religion) {
                      return DropdownMenuItem(
                        value: religion,
                        child: Text(religion),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _religion = value),
                    decoration: InputDecoration(
                      labelText: 'Religion',
                      prefixIcon: Icon(Icons.people_outline, color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _gender,
                    items: ['Male', 'Female', 'Other'].map((gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _gender = value),
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: Icon(Icons.person_outline, color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.home, color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    maxLines: 2,
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _status,
                          items: ['Single', 'Married'].map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _status = value),
                          decoration: InputDecoration(
                            labelText: 'Status',
                            prefixIcon: Icon(Icons.person_outline, color: Colors.grey[600]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _religion,
                          items: ['Islam', 'Christian', 'Hindu', 'Other'].map((religion) {
                            return DropdownMenuItem(
                              value: religion,
                              child: Text(religion),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _religion = value),
                          decoration: InputDecoration(
                            labelText: 'Religion',
                            prefixIcon: Icon(Icons.people_outline, color: Colors.grey[600]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _gender,
                          items: ['Male', 'Female', 'Other'].map((gender) {
                            return DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _gender = value),
                          decoration: InputDecoration(
                            labelText: 'Gender',
                            prefixIcon: Icon(Icons.person_outline, color: Colors.grey[600]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            labelText: 'Address',
                            prefixIcon: Icon(Icons.home, color: Colors.grey[600]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          maxLines: 2,
                          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDynamicFieldSection({
    required String title,
    required List<TextEditingController> controllers,
    required VoidCallback onAdd,
    required Function(int) onRemove,
    String labelPrefix = '',
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey[800],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.add_circle, color: Theme.of(context).primaryColor),
                  onPressed: onAdd,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...List.generate(controllers.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controllers[index],
                        decoration: InputDecoration(
                          labelText: '$labelPrefix ${index + 1}',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                    if (controllers.length > 1)
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => onRemove(index),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildObjectiveSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OBJECTIVE',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.04,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey[800],
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _objectiveController,
              decoration: InputDecoration(
                hintText: 'Enter your career objective...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 4,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'EXPERIENCE',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey[800],
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Text('Fresher', style: TextStyle(color: Colors.grey[700])),
                    Checkbox(
                      value: _isFresher,
                      onChanged: (value) => setState(() => _isFresher = value ?? false),
                    ),
                  ],
                ),
                if (!_isFresher)

                  IconButton(
                    icon: Icon(Icons.add_circle, color: Theme.of(context).primaryColor),
                    onPressed: () => setState(() => _experiences.add(Experience())),
                  ),
              ],
            ),

            const SizedBox(height: 12),
            if (!_isFresher)
              ...List.generate(_experiences.length, (index) {
                final exp = _experiences[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: index.isEven ? Colors.blueGrey[50] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Experience ${index + 1}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => setState(() {
                              exp.dispose();
                              _experiences.removeAt(index);
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: exp.positionController,
                        decoration: InputDecoration(
                          labelText: 'Position',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: exp.companyController,
                        decoration: InputDecoration(
                          labelText: 'Company',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: exp.periodController,
                        decoration: InputDecoration(
                          labelText: 'Period (e.g., 2018 - Present)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'EDUCATION',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey[800],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.add_circle, color: Theme.of(context).primaryColor),
                  onPressed: () => setState(() => _education.add(Education())),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(_education.length, (index) {
              final edu = _education[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: index.isEven ? Colors.blueGrey[50] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Education ${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => setState(() {
                            edu.dispose();
                            _education.removeAt(index);
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: edu.qualificationController,
                      decoration: InputDecoration(
                        labelText: 'Qualification',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: edu.yearController,
                      decoration: InputDecoration(
                        labelText: 'Year',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: edu.institutionController,
                      decoration: InputDecoration(
                        labelText: 'Institution',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: edu.detailsController,
                      decoration: InputDecoration(
                        labelText: 'Details',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'REFERENCE',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.04,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey[800],
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _referenceController,
              decoration: InputDecoration(
                hintText: 'Will be furnished on demand',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.resume != null ? 'Edit Resume' : 'Create Resume'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveResume,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(constraints.maxWidth < 600 ? 16 : 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(),
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                    title: 'Personal Information',
                    icon: Icons.person_outline,
                  ),
                  _buildPersonalInfoSection(),
                  const SizedBox(height: 20),
                  _buildSectionHeader(
                    title: 'Languages',
                    icon: Icons.language,
                  ),
                  _buildDynamicFieldSection(
                    title: 'LANGUAGES',
                    controllers: _languageControllers,
                    onAdd: () => setState(() => _languageControllers.add(TextEditingController())),
                    onRemove: (index) => setState(() {
                      _languageControllers[index].dispose();
                      _languageControllers.removeAt(index);
                    }),
                    labelPrefix: 'Language',
                  ),
                  const SizedBox(height: 20),
                  _buildSectionHeader(
                    title: 'Professional Skills',
                    icon: Icons.work_outline,
                  ),
                  _buildDynamicFieldSection(
                    title: 'SKILLS',
                    controllers: _skillControllers,
                    onAdd: () => setState(() => _skillControllers.add(TextEditingController())),
                    onRemove: (index) => setState(() {
                      _skillControllers[index].dispose();
                      _skillControllers.removeAt(index);
                    }),
                    labelPrefix: 'Skill',
                  ),
                  const SizedBox(height: 20),
                  _buildSectionHeader(
                    title: 'Career Objective',
                    icon: Icons.flag_outlined,
                  ),
                  _buildObjectiveSection(),
                  const SizedBox(height: 20),
                  _buildSectionHeader(
                    title: 'Work Experience',
                    icon: Icons.business_center_outlined,
                  ),
                  _buildExperienceSection(),
                  const SizedBox(height: 20),
                  _buildSectionHeader(
                    title: 'Education',
                    icon: Icons.school_outlined,
                  ),
                  _buildEducationSection(),
                  const SizedBox(height: 20),
                  _buildSectionHeader(
                    title: 'References',
                    icon: Icons.people_alt_outlined,
                  ),
                  _buildReferenceSection(),
                  const SizedBox(height: 30),

                  // Save buttons
                  if (widget.resume != null)
                    constraints.maxWidth < 600
                        ? Column(
                      children: [
                        _buildSaveButton(
                          icon: Icons.save,
                          label: 'UPDATE',
                          onPressed: _saveResume,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 16),
                        _buildSaveButton(
                          icon: Icons.copy,
                          label: 'SAVE AS COPY',
                          onPressed: _saveAsCopy,
                          color: Colors.blueGrey,
                        ),
                      ],
                    )
                        : Row(
                      children: [
                        Expanded(
                          child: _buildSaveButton(
                            icon: Icons.save,
                            label: 'UPDATE',
                            onPressed: _saveResume,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSaveButton(
                            icon: Icons.copy,
                            label: 'SAVE AS COPY',
                            onPressed: _saveAsCopy,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    )
                  else
                    Center(
                      child: _buildSaveButton(
                        icon: Icons.save,
                        label: 'SAVE',
                        onPressed: _saveResume,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSaveButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      icon: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Icon(icon, size: 24),
      ),
      label: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }
}

//Resume List Screen
class ResumeListScreen extends StatefulWidget {
  @override
  _ResumeListScreenState createState() => _ResumeListScreenState();
}

class _ResumeListScreenState extends State<ResumeListScreen> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref('resumes');
  List<Resume> _resumes = [];
  List<Resume> _filteredResumes = [];
  TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  StreamSubscription<DatabaseEvent>? _resumeSubscription; // Add stream listener

  @override
  void initState() {
    super.initState();
    _fetchResumes();
    _searchController.addListener(_onSearchChanged);
    _setupRealtimeListener(); // Use realtime listener instead of one-time fetch
  }

  void _setupRealtimeListener() {
    _resumeSubscription = _databaseRef.onValue.listen((event) {
      _processResumeData(event.snapshot);
    }, onError: (error) {
      print('Error: $error');
      setState(() => _isLoading = false);
    });
  }

  void _processResumeData(DataSnapshot snapshot) {
    if (snapshot.value == null) {
      setState(() {
        _resumes = [];
        _filteredResumes = [];
        _isLoading = false;
      });
      return;
    }

    Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
    List<Resume> loadedResumes = [];

    values.forEach((key, value) {
      loadedResumes.add(Resume.fromMap(value, key));
    });

    setState(() {
      _resumes = loadedResumes;
      _filteredResumes = loadedResumes;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _resumeSubscription?.cancel(); // Cancel listener
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredResumes = query.isEmpty
          ? _resumes
          : _resumes.where((resume) {
        return resume.name.toLowerCase().contains(query) ||
            resume.contact.toLowerCase().contains(query) ||
            (resume.personalInfo['fatherName'] as String).toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _fetchResumes() async {
    try {
      DatabaseEvent event = await _databaseRef.once();
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value == null) {
        setState(() => _isLoading = false);
        return;
      }

      Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
      List<Resume> loadedResumes = [];
      values.forEach((key, value) {
        loadedResumes.add(Resume.fromMap(value, key));
      });

      setState(() {
        _resumes = loadedResumes;
        _filteredResumes = loadedResumes;
        _isLoading = false;
      });
    } catch (error) {
      print('Error: $error');
      setState(() => _isLoading = false);
    }
  }


  Future<void> _deleteResume(String key) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Resume'),
        content: const Text('Confirm delete?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _databaseRef.child(key).remove();
                _fetchResumes();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Deleted')),
                );
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $error')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Enhanced PDF Generation
  Future<Uint8List> _generateResumePdf(Resume resume) async {
    final pdf = pw.Document();

    // Modern color palette
    final primaryBlue = PdfColor.fromHex('#1e3a8a');
    final accentBlue = PdfColor.fromHex('#3b82f6');
    final lightBlue = PdfColor.fromHex('#dbeafe');
    final darkText = PdfColor.fromHex('#1f2937');
    final mediumText = PdfColor.fromHex('#6b7280');

    // Typography
    final nameStyle = pw.TextStyle(
      fontSize: 28,
      fontWeight: pw.FontWeight.bold,
      color: primaryBlue,
    );

    final sectionTitleStyle = pw.TextStyle(
      fontSize: 14,
      fontWeight: pw.FontWeight.bold,
      color: primaryBlue,
    );

    final sidebarTitleStyle = pw.TextStyle(
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
    );

    final sidebarTextStyle = pw.TextStyle(
      fontSize: 10,
      color: PdfColors.white,
    );

    final subtitleStyle = pw.TextStyle(
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
      color: darkText,
    );

    final normalStyle = pw.TextStyle(
      fontSize: 10,
      color: darkText,
    );

    final lightStyle = pw.TextStyle(
      fontSize: 10,
      color: mediumText,
    );

    // Create divider widget
    pw.Widget buildDivider() {
      return pw.Divider(
        height: 1,
        thickness: 1,
        color: accentBlue,
      );
    }

    // Profile image builder - only shows when image exists
    pw.Widget? buildProfileImage(Resume resume) {
      if (resume.photo != null && resume.photo!.isNotEmpty) {
        return pw.Container(
          width: 100,
          height: 100,
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            border: pw.Border.all(color: PdfColors.white, width: 3),
          ),
          child: pw.ClipOval(
            child: pw.Image(
              pw.MemoryImage(base64Decode(resume.photo!)),
              fit: pw.BoxFit.cover,
            ),
          ),
        );
      }
      return null;
    }

    // Section title with underline
    pw.Widget buildSectionTitle(String title, pw.TextStyle style) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: style),
          pw.SizedBox(height: 5),
          pw.Container(
            height: 2,
            width: 40,
            color: PdfColors.white,
          ),
        ],
      );
    }

    // Sidebar item
    pw.Widget buildSidebarItem(String title, String value, pw.TextStyle style) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 12),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: style.copyWith(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(value, style: style),
          ],
        ),
      );
    }

    // Languages bullet list
    pw.Widget buildBulletList(List<dynamic> items, pw.TextStyle style) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          for (final item in items)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('*   ', style: style),
                  pw.Expanded(
                    child: pw.Text(item.toString(), style: style),
                  ),
                ],
              ),
            ),
        ],
      );
    }

    // Main content section builder
    pw.Widget buildMainSection(String title, String content,
        pw.TextStyle titleStyle, pw.TextStyle contentStyle) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: titleStyle),
          pw.SizedBox(height: 10),
          pw.Text(
            content,
            style: contentStyle,
            textAlign: pw.TextAlign.justify,
          ),
        ],
      );
    }

    // Experience section
    pw.Widget buildExperienceSection(Resume resume,
        pw.TextStyle titleStyle, pw.TextStyle subtitleStyle,
        pw.TextStyle normalStyle, pw.TextStyle lightStyle) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('WORK EXPERIENCE', style: titleStyle),
          pw.SizedBox(height: 15),

          if (resume.isFresher)
            pw.Text('Fresher', style: normalStyle),

          if (!resume.isFresher)
            ...resume.experiences.map((exp) {
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 15),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            exp['position'] ?? '',
                            style: subtitleStyle,
                          ),
                        ),
                        pw.Text(
                          exp['period'] ?? '',
                          style: lightStyle,
                        ),
                      ],
                    ),
                    pw.Text(
                      exp['company'] ?? '',
                      style: normalStyle,
                    ),
                    if (exp['description'] != null && exp['description'].isNotEmpty)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 8),
                        child: pw.Text(
                          exp['description'] ?? '',
                          style: normalStyle,
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
        ],
      );
    }

    // Education section
    pw.Widget buildEducationSection(Resume resume,
        pw.TextStyle titleStyle, pw.TextStyle subtitleStyle,
        pw.TextStyle lightStyle) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('EDUCATION', style: titleStyle),
          pw.SizedBox(height: 15),

          if (resume.education.isEmpty)
            pw.Text('No education added', style: lightStyle),

          ...resume.education.map((edu) {
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 15),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    edu['qualification'] ?? '',
                    style: subtitleStyle,
                  ),
                  pw.Text(
                    edu['institution'] ?? '',
                    style: lightStyle,
                  ),
                  if (edu['year'] != null && edu['year'].isNotEmpty)
                    pw.Text(
                      'Year: ${edu['year']}',
                      style: lightStyle,
                    ),
                  if (edu['details'] != null && edu['details'].isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 5),
                      child: pw.Text(
                        edu['details'] ?? '',
                        style: lightStyle,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      );
    }

    // Build profile image
    final profileImage = buildProfileImage(resume);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) => pw.Row(
          children: [
            // Left sidebar
            pw.Container(
              width: 180,
              color: primaryBlue,
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Profile image only if exists
                  if (profileImage != null) pw.Center(child: profileImage),
                  if (profileImage != null) pw.SizedBox(height: 15),

                  // Personal Information
                  buildSectionTitle('PERSONAL INFO', sidebarTitleStyle),
                  pw.SizedBox(height: 7),
                  buildSidebarItem('Father Name', resume.personalInfo['fatherName'] ?? '', sidebarTextStyle),
                  buildSidebarItem('CNIC', resume.personalInfo['cnic'] ?? '', sidebarTextStyle),
                  buildSidebarItem('Phone', resume.contact ?? '', sidebarTextStyle),
                  buildSidebarItem('Email', resume.email ?? '', sidebarTextStyle),
                  buildSidebarItem('DOB', resume.personalInfo['dob'] ?? '', sidebarTextStyle),
                  buildSidebarItem('Status', resume.personalInfo['status'] ?? '', sidebarTextStyle),
                  buildSidebarItem('Religion', resume.personalInfo['religion'] ?? '', sidebarTextStyle),
                  buildSidebarItem('Gender', resume.personalInfo['gender'] ?? '', sidebarTextStyle),
                  if (resume.personalInfo['address'] != null && resume.personalInfo['address'].isNotEmpty)
                    buildSidebarItem('Address', resume.personalInfo['address'], sidebarTextStyle),

                  pw.SizedBox(height: 15),

                  // Languages
                  buildSectionTitle('LANGUAGES', sidebarTitleStyle),
                  pw.SizedBox(height: 7),
                  buildBulletList(resume.languages, sidebarTextStyle),
                ],
              ),
            ),

            // Right main content
            pw.Expanded(
              child: pw.Container(
                color: lightBlue,
                padding: const pw.EdgeInsets.symmetric(vertical: 30, horizontal: 25),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Name section
                    pw.Container(
                      decoration: pw.BoxDecoration(
                          border: pw.Border(left: pw.BorderSide(color: accentBlue, width: 4))
                      ),
                      padding: const pw.EdgeInsets.only(left: 15),
                      child: pw.Text(
                        resume.name.toUpperCase(),
                        style: nameStyle,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    buildDivider(), // Divider after name
                    pw.SizedBox(height: 10),

                    // Objective section
                    buildMainSection('OBJECTIVE', resume.objective,
                        sectionTitleStyle, normalStyle),
                    pw.SizedBox(height: 5),
                    buildDivider(), // Divider after summary
                    pw.SizedBox(height: 10),

                    // Working Experience section
                    buildExperienceSection(resume, sectionTitleStyle, subtitleStyle, normalStyle, lightStyle),
                    pw.SizedBox(height: 5),
                    buildDivider(), // Divider after experience
                    pw.SizedBox(height: 10),

                    // Education section
                    buildEducationSection(resume, sectionTitleStyle, subtitleStyle, lightStyle),
                    pw.SizedBox(height: 5),
                    buildDivider(), // Divider after education
                    pw.SizedBox(height: 10),

                    // Fixed Skills section
                    pw.Text('SKILLS', style: sectionTitleStyle),
                    pw.SizedBox(height: 5),
                    pw.Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: resume.skills.map((skill) {
                        return pw.Text('$skill |', style: normalStyle);
                      }).toList(),
                    ),
                    pw.SizedBox(height: 5),
                    buildDivider(), // Divider after skills
                    pw.SizedBox(height: 5),

                    // Reference section
                    buildMainSection('REFERENCES', resume.reference,
                        sectionTitleStyle, normalStyle),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  Future<void> _generatePdf(Resume resume) async {
    final pdfBytes = await _generateResumePdf(resume);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) => pdfBytes,
    );
  }

  Future<void> _showPdfOptions(Resume resume) async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('Print'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final pdfBytes = await _generateResumePdf(resume);
                  await Printing.layoutPdf(
                    onLayout: (format) => pdfBytes,
                    format: PdfPageFormat.a4,
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Printing failed: $e')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Save as PDF'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final pdfBytes = await _generateResumePdf(resume);
                  final fileName = '${resume.name.replaceAll(' ', '_')}_resume.pdf';

                  if (kIsWeb) {
                    // Web implementation
                    final blob = html.Blob([pdfBytes], 'application/pdf');
                    final url = html.Url.createObjectUrlFromBlob(blob);
                    final anchor = html.document.createElement('a') as html.AnchorElement
                      ..href = url
                      ..download = fileName
                      ..style.display = 'none';

                    html.document.body?.children.add(anchor);
                    anchor.click();
                    html.document.body?.children.remove(anchor);
                    html.Url.revokeObjectUrl(url);
                  } else {
                    // Mobile implementation
                    final dir = await getTemporaryDirectory();
                    final file = File('${dir.path}/$fileName');
                    await file.writeAsBytes(pdfBytes);
                    await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Save failed: $e')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share PDF'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final pdfBytes = await _generateResumePdf(resume);
                  final fileName = '${resume.name.replaceAll(' ', '_')}_resume.pdf';

                  if (kIsWeb) {
                    // Web implementation
                    final blob = html.Blob([pdfBytes], 'application/pdf');
                    final url = html.Url.createObjectUrlFromBlob(blob);
                    html.window.open(url, '_blank');
                    Timer(const Duration(minutes: 1), () => html.Url.revokeObjectUrl(url));
                  } else {
                    // Mobile implementation
                    final dir = await getTemporaryDirectory();
                    final file = File('${dir.path}/$fileName');
                    await file.writeAsBytes(pdfBytes);
                    await Share.shareXFiles([XFile(file.path, name: fileName)]);
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Share failed: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumes'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: themeProvider.toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ResumeFormScreen())),
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[200],
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredResumes.isEmpty
              ? const Center(child: Text('No resumes found'))
              : ListView.builder(
            itemCount: _filteredResumes.length,
            itemBuilder: (context, index) {
              final resume = _filteredResumes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: resume.photo != null
                        ? MemoryImage(base64Decode(resume.photo!))
                        : null,
                    child: resume.photo == null ? const Icon(Icons.person) : null,
                  ),
                  title: Text(resume.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(resume.contact),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => ResumeFormScreen(resume: resume)));
                      } else if (value == 'delete') {
                        _deleteResume(resume.key!);
                      } else if (value == 'pdf') {
                        _showPdfOptions(resume);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(children: [Icon(Icons.edit), SizedBox(width: 8), Text('Edit')]),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [Icon(Icons.delete), SizedBox(width: 8), Text('Delete')]),
                      ),
                      const PopupMenuItem(
                        value: 'pdf',
                        child: Row(children: [Icon(Icons.picture_as_pdf), SizedBox(width: 8), Text('PDF')]),
                      ),
                    ],
                  ),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ResumeDetailScreen(resume: resume))),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}


// Resume Detail Screen
class ResumeDetailScreen extends StatelessWidget {
  final Resume resume;

  const ResumeDetailScreen({required this.resume});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Resume'),

        ),
        body:
        SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: resume.photo != null ? MemoryImage(base64Decode(resume.photo!)) : null,
                      child: resume.photo == null ? Icon(Icons.person, size: 60) : null,
                    ),
                    SizedBox(height: 16),
                    Text(resume.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(resume.contact),
                    Text(resume.email),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Divider(thickness: 2),
              SizedBox(height: 16),
              _buildSectionTitle('Personal Info'),
              _buildInfoRow('Father', resume.personalInfo['fatherName']),
              _buildInfoRow('CNIC', resume.personalInfo['cnic']),
              _buildInfoRow('DOB', resume.personalInfo['dob']),
              _buildInfoRow('Status', resume.personalInfo['status']),
              _buildInfoRow('Religion', resume.personalInfo['religion']),
              _buildInfoRow('Gender', resume.personalInfo['gender']),
              _buildInfoRow('Address', resume.personalInfo['address']),
              SizedBox(height: 24),
              Divider(thickness: 2),
              _buildSectionTitle('Languages'),
              SizedBox(height: 12),
              Wrap(children: resume.languages.map((lang) => Chip(label: Text(lang))).toList()),
              SizedBox(height: 24),
              Divider(thickness: 2),
              _buildSectionTitle('Skills'),
              SizedBox(height: 12),
              Wrap(children: resume.skills.map((skill) => Chip(label: Text(skill))).toList()),
              SizedBox(height: 24),
              Divider(thickness: 2),
              _buildSectionTitle('Objective'),
              SizedBox(height: 12),
              Text(resume.objective),
              SizedBox(height: 24),
              Divider(thickness: 2),
              _buildSectionTitle('Experience'),
              SizedBox(height: 12),
              resume.isFresher
                  ? Text('Fresher')
                  : Column(
                children: resume.experiences.map((exp) => Column(
                  children: [
                    Text('• ${exp['position']} at ${exp['company']}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(exp['period']),
                    SizedBox(height: 5),
                  ],
                )).toList(),
              ),
              SizedBox(height: 24),
              Divider(thickness: 2),
              _buildSectionTitle('Education'),
              SizedBox(height: 12),
              Column(
                children: resume.education.map((edu) => Column(
                  children: [
                    Text('• ${edu['qualification']}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(edu['institution']),
                    if (edu['details'] != null && edu['details'].isNotEmpty)
                      Text(edu['details']),
                    SizedBox(height: 5),
                  ],
                )).toList(),
              ),
              SizedBox(height: 24),
              Divider(thickness: 2),
              _buildSectionTitle('Reference'),
              SizedBox(height: 12),
              Text(resume.reference),
            ],
          ),
        ));
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue));
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$label: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Expanded(child: Text(value, style: TextStyle(fontSize: 16))),
      ]),
    );
  }
}

class Experience {
  final TextEditingController positionController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController periodController = TextEditingController();

  Experience({String? position, String? company, String? period}) {
    if (position != null) positionController.text = position;
    if (company != null) companyController.text = company;
    if (period != null) periodController.text = period;
  }

  void dispose() {
    positionController.dispose();
    companyController.dispose();
    periodController.dispose();
  }
}

class Education {
  final TextEditingController qualificationController;
  final TextEditingController yearController = TextEditingController();
  final TextEditingController institutionController;
  final TextEditingController detailsController = TextEditingController();

  Education({
    String? qualification,
    String? institution,
    String? details,
    String? year,
  })  : qualificationController = TextEditingController(text: qualification ?? ''),
        institutionController = TextEditingController(text: institution ?? '') {
    if (details != null) detailsController.text = details;
    if (year != null) yearController.text = year;
  }

  void dispose() {
    qualificationController.dispose();
    yearController.dispose();
    institutionController.dispose();
    detailsController.dispose();
  }
}
