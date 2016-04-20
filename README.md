# Fun and Games

Here are some fun programs and games I've written to explore different kinds of motion, machine learning, or use of a little mathematics to do something different or creative.


Mobiles - 
Hanging mobiles, originally designed by Alexander Calder, are amazing mathematical and physical objects.  They have many similarities to binary trees in Computer Science.  
However, they are also physical objects that have to balance.  Thinking a little more about it, I realized they are recursive physical computers that simultaneously solve many equations (since they have to balance).  
Also, they can be used to explore ideas such as Fibonacci sequences and fractals, and for mathematical challenge games.  ... and this is only looking at statics in 2-dimensions!

Dynamically, and in 3-dimensional space, they rotate on many axes, forming geometric cycloids when observed from below or above.  Viewed from the side, they can have very complex oscillations.

Here I wrote a program to automatically create and draw certain kinds of mobiles, as well as some recreational observations.


Fakespeare - 
an iPhone app that writes "Fake Shakespeare" using a Markov Parody Generator.   It works like this:  Look at real Shakespeare, build a matrix that stores how often each pair of words occurs "the dog", "a ball", etc.   Then, use this matrix to write fake Shakespeare!  This is the same as Claude Shannon's "First Order Text" at the word level.

Amoeba - 
Using the Netlogo platform, control an Amoeba and try to eat the bacteria!  This uses a (pre-built) energy-minimizing graph layout algorithm (basically draws a network as if there are springs on the links, and repulsion between all nodes) to form the "body" of the amoeba.  Then some graphic tricks were used to make it look more "blobby".  
Clicking and dragging on "organelles" - network nodes - allows the user to move the Amoeba around and chase the bacteria.

Climber -
The idea here is to begin to simulate the problem-solving aspect of rock-climbing.  That is, rock climbing as a very complex path-planning problem, also with physical constraints of fatigue and friction.  This is a brain-storming prototype.

