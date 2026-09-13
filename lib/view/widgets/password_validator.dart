// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:creatify_mobile/view/utils/app_images.dart';

// import 'package:creatify_mobile/view/utils/extensions.dart';
// import 'package:creatify_mobile/view/utils/validator.dart';

// class PasswordValidator extends StatefulWidget {
//   const PasswordValidator({
//     super.key,
//     required this.controller,
//   });

//   final TextEditingController controller;

//   @override
//   State<PasswordValidator> createState() => _PasswordValidatorState();
// }

// class _PasswordValidatorState extends State<PasswordValidator> {
//   bool charLenth = false;
//   bool lowerCase = false;
//   bool hasNumb = false;
//   bool upperCase = false;
//   bool specChar = false;

//   @override
//   void initState() {
//     widget.controller.addListener(() {
//       setState(() {
//         charLenth = has8Characters(widget.controller.text);
//         lowerCase = hasLowercase(widget.controller.text);
//         hasNumb = hasANumber(widget.controller.text);
//         upperCase = hasUppercase(widget.controller.text);
//         specChar = hasSpecialCharacter(widget.controller.text);
//       });
//     });

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(bottom: 5),
//           child: Row(
//             children: [
//               charLenth
//                   ? SvgPicture.asset(
//                       AppImages.checkedBox,
//                     )
//                   : SvgPicture.asset(
//                       AppImages.uncheckedBox,
//                     ),
//               10.0.width,
//               Text('At least Eight Characters', style: Theme.of(context).textTheme.bodyMedium),
//             ],
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(bottom: 5),
//           child: Row(
//             children: [
//               upperCase
//                   ? SvgPicture.asset(
//                       AppImages.checkedBox,
//                     )
//                   : SvgPicture.asset(
//                       AppImages.uncheckedBox,
//                     ),
//               10.0.width,
//               Text('At least an Uppercase Letter', style: Theme.of(context).textTheme.bodyMedium),
//             ],
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(bottom: 5),
//           child: Row(
//             children: [
//               lowerCase
//                   ? SvgPicture.asset(
//                       AppImages.checkedBox,
//                     )
//                   : SvgPicture.asset(
//                       AppImages.uncheckedBox,
//                     ),
//               10.0.width,
//               Text('At least one Lowercase Letter', style: Theme.of(context).textTheme.bodyMedium),
//             ],
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(bottom: 5),
//           child: Row(
//             children: [
//               hasNumb
//                   ? SvgPicture.asset(
//                       AppImages.checkedBox,
//                     )
//                   : SvgPicture.asset(
//                       AppImages.uncheckedBox,
//                     ),
//               10.0.width,
//               Text('At least a Number', style: Theme.of(context).textTheme.bodyMedium),
//             ],
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(bottom: 5),
//           child: Row(
//             children: [
//               specChar
//                   ? SvgPicture.asset(
//                       AppImages.checkedBox,
//                     )
//                   : SvgPicture.asset(
//                       AppImages.uncheckedBox,
//                     ),
//               10.0.width,
//               Text('At least one Special Character (e.g !,?)',
//                   style: Theme.of(context).textTheme.bodyMedium),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
