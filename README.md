# CMLS-Homework-3-Group-8

Our task for this homework was to create a Drum Set using SuperCollider and an interface to control the parameters of such a Drum Set.

A total of 5 different drum sounds are synthesised, along with a User Interface to control them using different input devices.
In this report, we are going to explain the generation of the drum sounds, the interactive system design and the protocol communication between different interfaces.

We implemented our project using SuperCollider, an environment and programming language for real-time audio synthesis and algorithmic composition, and Arduino, a microcontroller designed to interact with the incoming real-world data through an electronic prototyping platform.

All the controllers are communicating and interacting with the main program on SuperCollider, which produces an output stream of music.
Sounds are generated in the SuperCollider framework through Synth Definitions. Our set of drums is composed by:

  - Hi-hat;
  - Snare drum;
  - Kick drum;
  - Clap;
  - Tom drum.

To better perform the Sound Synthesis, some parameters of the Synths can be modified in real-time by the user.

We set up an Arduino circuit that can send the messages to SuperCollider to play the respective drums and also change parameters. The parameters are controlled by two methods: two potentiometers and one photoresistor.

To allow the communication between SuperCollider and Arduino, we used the serial port communication.
