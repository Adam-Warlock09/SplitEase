import 'package:flutter/material.dart';
class Page extends StatelessWidget{

	const Page({super.key});

	@override
	Widget build(BuildContext context) {

		return Scaffold(
			body: SafeArea(
				child: Center(
					child: SingleChildScrollView(
						padding: const EdgeInsets.symmetric(horizontal: 24),
						child: Column(
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								const Icon(
									Icons.account_balance_wallet_rounded,
									size: 80,
								),
								AppSpacing.verticalLg,
								Text(
									'Welcome Back!',
									style: AppTextStyles.heading(context),
								),
								AppSpacing.verticalSm,
								Text(
									'Login To Continue',
									style: AppTextStyles.body(context),
								),
								AppSpacing.verticalLg,
								customTextField(hintText: 'Email',),
								AppSpacing.verticalMd,
								customTextField(hintText: 'Password', obscureText: true,),
								AppSpacing.verticalLg,
								SizedBox(
									width: double.infinity,
									child: CustomButton(text: 'Login', onPressed: () {})
								),
								AppSpacing.verticalLg,
								Row(
									mainAxisAlignment: MainAxisAlignment.center,
									children: [
										const Text('New here?'),
										TextButton(
											onPressed: () {},
											child: const Text('Create an account'),
										),
									],
								),
							],
						),
					),
				),
			),
		);
	}
}
