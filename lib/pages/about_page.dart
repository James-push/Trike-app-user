import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {Navigator.pop(context);},
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "About",
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
                _buildPage(
                    context,
                    'assets/images/about.png',
                    'About TRIKE',
                    'TRIKE is an innovative online tricycle booking system specifically designed for the residents of Sta. Maria Village II. It transforms the traditional tricycle-booking process by providing a user-friendly and efficient platform that addresses existing challenges.'
                ),
                _buildPage(
                    context,
                    'assets/images/purpose.png',
                    'Purpose of TRIKE',
                    'TRIKE aims to design and implement an effective tricycle booking application for the residents of Sta. Maria Village II. By taking advantage of technology, this project seeks to address the inefficiencies and challenges present in the current system while providing a platform for booking local traveling vehicles.'
                ),
                _buildPage(
                    context,
                    'assets/images/features.png',
                    'Features of TRIKE',
                    'TRIKE aims to eliminate dependency on security guards by providing a direct communication channel between residents and tricycle drivers, by which means reducing delays in finding available tricycles and preventing misunderstandings regarding the pickup and drop off location. It seeks to reform the booking process, enabling quick and efficient reservations to minimize wait times and enhance convenience. Also, TRIKE ensures fare consistency through standardized fare metrics, preventing disputes and guaranteeing transparent pricing.'
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SmoothPageIndicator(
              controller: _pageController,
              count: 3,
              effect: WormEffect(
                activeDotColor: Color.fromARGB(255, 75, 201, 104),
                dotColor: Colors.grey,
                dotHeight: 8,
                dotWidth: 8,
                spacing: 16,
                type: WormType.thin,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context, String? imageUrl, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageUrl != null)
          Image.asset(
            imageUrl,
            width: double.infinity,
            height: 250, // Adjusted height
            fit: BoxFit.cover,
          ),
        SizedBox(height: 16.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0), // Padding for the title
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 16.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0), // Padding for the content
          child: Text(
            content,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}