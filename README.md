# 438-munch-madness
To run Munch Madness on the simulator, you must first install cocoapods as described in this Stack Overflow thread: https://stackoverflow.com/questions/30418062/how-to-run-pod-install-in-project-directory


Munch Madness is a gamified way to help a group or individual decide where to eat. To start a new game, the user who we call the host will press the button on the home screen that says "Start a group". From there, the host will be directed to another page where they will determine thier restaurant preferences such as cuisine, price range, location and distance. After pressing "Find Restaurants" the host will see a third page with a game code which they can share with thier friends if playing with a group. All users have the opportunity to enter their name which will be reflected under the current players section. Once all other users have joined the game by entering the game code and pressing "Join a Group", the host can press start and the game will begin. 

Now, the users will all see the same page comparing two restaurants with an image and restaurant details. Each user will have up to 5 seconds to swipe left to vote for the top restaurant or left to vote for the bottom restaurant. Whichever restaurant has the most votes will stay and the other will be replaced with a new restaurant until the overall winner is chosen. 

Once the winner page has been presented, users will see the winning restaurant and all of its details. There is a call button from which anyone can call the restaurant (only works on real phone not in simulator) or visit the Yelp page for the restaurant. Users can also return to the start page if they want to play again.

Note: If running on actual device, you may need to press "return" or swipe down on the VC for the keyboard to go away on the join and preferences pages.
