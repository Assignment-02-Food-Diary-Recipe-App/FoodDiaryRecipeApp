import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_recipe_app/listing/screens/MyRecipesScreen.dart';
import 'package:food_recipe_app/listing/screens/recipe_listing_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    RecipeListingScreen(),
    MyRecipesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recipe App',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFf9a825), Color(0xFFf57c00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: Drawer(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.horizontal(right: Radius.circular(30)),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFf9a825), Color(0xFFf57c00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user?.displayName ?? 'Welcome!',
              style: GoogleFonts.poppins(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 30),
      ListTile(
        leading: Icon(Icons.lock_reset_rounded, color: Color(0xFFf57c00)),
        title: Text('Change Password',
            style: GoogleFonts.poppins(fontSize: 16)),
        onTap: () {
          Navigator.pushNamed(context, '/change-password');
        },
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Divider(color: Colors.grey.shade300),
      ),
      ListTile(
        leading: Icon(Icons.logout, color: Colors.redAccent),
        title: Text('Logout',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.redAccent)),
        onTap: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
    ],
  ),
),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          selectedItemColor: Color(0xFFf57c00),
          unselectedItemColor: Colors.grey,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'All Recipes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'My Recipes',
            ),
          ],
        ),
      ),
    );
  }
}
