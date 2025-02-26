import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su usuario';
    }
    if (value.length < 3) {
      return 'El usuario debe tener al menos 3 caracteres';
    }
    if (value.contains(' ')) {
      return 'El usuario no puede contener espacios';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();
      ref.read(authProvider.notifier).login(username, password);
    }
  }

  void _fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 900;
    
    return Scaffold(
      body: isSmallScreen 
          ? _buildMobileLayout(authState, size)
          : _buildDesktopLayout(authState, size),
    );
  }

  Widget _buildDesktopLayout(AuthState authState, Size size) {
    return Row(
      children: [
        Container(
          width: size.width * 0.5,
          color: Colors.black,
          padding: EdgeInsets.all(size.width * 0.03),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 1200),
                child: Center(
                  child: Container(
                    width: size.width * 0.15,
                    height: size.width * 0.15,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(size.width * 0.015),
                    child: Image.asset(
                      'assets/images/Logo_SIMCUV.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.05),
              _buildAnimatedTitle(size),
              SizedBox(height: size.height * 0.02),
              _buildSubtitle(size),
            ],
          ),
        ),
        Container(
          width: size.width * 0.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFF5733),
                const Color(0xFFFF5733).withOpacity(0.8),
              ],
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(-10, 0),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.05,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLoginTitle(),
              SizedBox(height: size.height * 0.02),
              _buildWelcomeText(),
              SizedBox(height: size.height * 0.05),
              _buildLoginForm(authState, size),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(AuthState authState, Size size) {
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(minHeight: size.height),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Color(0xFFFF5733)],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.05),
              // Logo
              FadeInDown(
                duration: const Duration(milliseconds: 1200),
                child: Container(
                  width: size.width * 0.4,
                  height: size.width * 0.4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(size.width * 0.03),
                  child: Image.asset(
                    'assets/images/Logo_SIMCUV.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.03),
              _buildAnimatedTitle(size),
              SizedBox(height: size.height * 0.02),
              _buildSubtitle(size),
              SizedBox(height: size.height * 0.05),
              Container(
                padding: EdgeInsets.all(size.width * 0.05),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: _buildLoginForm(authState, size),
              ),
              SizedBox(height: size.height * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTitle(Size size) {
    return FadeInLeft(
      delay: const Duration(milliseconds: 800),
      duration: const Duration(milliseconds: 1000),
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: DefaultTextStyle(
          style: GoogleFonts.montserrat(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: size.width < 900 ? size.width * 0.06 : 36,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          textAlign: TextAlign.center,
          child: AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                'CARTELERA DIGITAL',
                textAlign: TextAlign.center,
                speed: const Duration(milliseconds: 100),
              ),
            ],
            isRepeatingAnimation: false,
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle(Size size) {
    return FadeInLeft(
      delay: const Duration(milliseconds: 1200),
      duration: const Duration(milliseconds: 1000),
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: Text(
          'Sistema de Monitoreo y Control\nde Contenido Digital',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: size.width < 900 ? size.width * 0.04 : 20,
              fontWeight: FontWeight.w300,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTitle() {
    return FadeInRight(
      duration: const Duration(milliseconds: 1000),
      child: Center(
        child: Text(
          'Iniciar Sesión',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return FadeInRight(
      delay: const Duration(milliseconds: 400),
      duration: const Duration(milliseconds: 1000),
      child: Center(
        child: Text(
          'Bienvenido al sistema de gestión',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(AuthState authState, Size size) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _usernameController,
            focusNode: _usernameFocusNode,
            label: 'Usuario',
            icon: Icons.person_outline,
            validator: _validateUsername,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (term) {
              _fieldFocusChange(context, _usernameFocusNode, _passwordFocusNode);
            },
            size: size,
          ),
          SizedBox(height: size.height * 0.02),
          _buildTextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            label: 'Contraseña',
            icon: Icons.lock_outline,
            isPassword: true,
            validator: _validatePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (value) {
              _passwordFocusNode.unfocus();
              _handleLogin();
            },
            size: size,
          ),
          SizedBox(height: size.height * 0.02),
          if (authState.error != null) _buildErrorMessage(authState.error!),
          SizedBox(height: size.height * 0.03),
          _buildLoginButton(authState, size),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputAction? textInputAction,
    void Function(String)? onFieldSubmitted,
    bool isPassword = false,
    required Size size,
  }) {
    return FadeInRight(
      delay: Duration(milliseconds: isPassword ? 1200 : 800),
      duration: const Duration(milliseconds: 1000),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: size.width < 900 ? 14 : 16,
            ),
          ),
          obscureText: isPassword ? _obscurePassword : false,
          validator: validator,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.poppins(
              textStyle: TextStyle(
                color: Colors.white70,
                fontSize: size.width < 900 ? 14 : 16,
              ),
            ),
            errorStyle: GoogleFonts.poppins(
              textStyle: TextStyle(
                color: Colors.red[300],
                fontSize: size.width < 900 ? 12 : 14,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(16),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red[300]!, width: 1),
              borderRadius: BorderRadius.circular(16),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red[300]!, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            prefixIcon: Icon(icon, color: Colors.white70, size: 24),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.white70,
                      size: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String error) {
    return FadeIn(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error,
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton(AuthState authState, Size size) {
    return FadeInUp(
      delay: const Duration(milliseconds: 1600),
      duration: const Duration(milliseconds: 1000),
      child: Container(
        width: double.infinity,
        height: size.width < 900 ? 50 : 55,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2E3192),
              Color(0xFF1BFFFF),
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E3192).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: const Color(0xFF1BFFFF).withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: authState.isLoading ? null : _handleLogin,
            splashColor: Colors.white.withOpacity(0.2),
            highlightColor: Colors.white.withOpacity(0.1),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.02,
                vertical: size.height * 0.015,
              ),
              child: authState.isLoading
                  ? Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                          backgroundColor: Colors.white.withOpacity(0.2),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.login_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'INICIAR SESIÓN',
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: size.width < 900 ? 13 : 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
