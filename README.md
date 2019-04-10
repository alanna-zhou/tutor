# Tutor
Tutor: Connecting tutors and tutees with ease

Tutor makes finding and connecting with tutors and tutees on campus as easy as possible. Many students seek extra help in certain classes and would like fellow students to help them out. Other students, who excel in these same classes, are looking for a way to make money and assist those in need. Tutor allows students to find each other and create that first connection on a centralized, simple, and straightforward platform.

Tutor is designed to be simple and easy to use. Users log in with their email and their netIDs are automatically registered to their account along with their names. To set up their profiles, users can choose from a variety of different profile pictures, colors, and whether they want to be tutors, tutees, or both. Profiles also include the user's graduation year, major, and a short bio including contact information to help users connect with each other. At any time, a user can update their profile.

All of Cornell's course catalog is automatically accessed and stored in Tutor's database. Users can search for and select as many courses as they desire. They then can browse through either the tutors or tutees of the classes they select and view the profiles of other users. At the touch of a button, they can either match up with a tutor/tutee or add themselves to the tutor/tutee list so that other users can add them.

Tutor has a very intuitive and simple interface. The colors are chosen by the user to enhance user experience. Using Cornell email addresses for signing in ensures that every user has a unique identification and also means that students can find out more information on Cornell websites like CUInfo if they want to.

iOS: Most of our views use SnapKit and almost all our information is displayed through TableViews and CollectionViews. For example, preferred colors are selected in a Collection View and courses and tutors are displayed in TableViews. Most of the data is presented on a UINavigationController, but some user setup screens are presented modally. We tried to use modal views when the user wasn't supposed to be able to return to previous screens and navigation views when changing screens was intended.

Backend: We designed our own API to store all the user information and keep track of tutor/tutee pairs. To pull all the course information, we used the CODI Explorer API. We also used the Google Sign-In API for user verification and to give each user a unique netID.

## User Login
Users can't access information until they login to prevent people from registering for classes without the required info.

<img src="https://github.com/alanna-zhou/hackchallenge/blob/master/Screenshots/IMG_0243.PNG" width="300" height="534">

## Profile Customization
There are many ways for users to customize their profiles and display information to others.

<img src="https://github.com/alanna-zhou/hackchallenge/blob/master/Screenshots/IMG_0245.PNG" width="300" height="534"><img src="https://github.com/alanna-zhou/hackchallenge/blob/master/Screenshots/IMG_0247.PNG" width="300" height="534"><img src="https://github.com/alanna-zhou/hackchallenge/blob/master/Screenshots/IMG_0231.PNG" width="300" height="534"><img src="https://github.com/alanna-zhou/hackchallenge/blob/master/Screenshots/IMG_0236.PNG" width="300" height="534"><img src="https://github.com/alanna-zhou/hackchallenge/blob/master/Screenshots/IMG_0244.PNG" width="300" height="534">

## Adding Users, Viewing Profiles, and Tracking Tutors/Tutees
Tutors and courses are displayed in simple, colorful TableViews.

<img src="https://github.com/alanna-zhou/hackchallenge/blob/master/Screenshots/IMG_0239.PNG" width="300" height="534"><img src="https://github.com/alanna-zhou/hackchallenge/blob/master/Screenshots/IMG_0242.PNG" width="300" height="534"><img src="https://github.com/alanna-zhou/hackchallenge/blob/master/Screenshots/IMG_0248.PNG" width="300" height="534">
